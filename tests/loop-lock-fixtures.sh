#!/usr/bin/env bash
# tests/loop-lock-fixtures.sh — acceptance corpus for bin/loop-lock.sh
# (lease-based single-instance lock, run-30 A3 hardening 2026-07-17: staleness
# is lease age past TTL, refreshed at phase boundaries — NEVER pid-death.
# Retires the pid-liveness staleness design of 2026-07-15, which A3
# demonstrated wrongly stale-reclaimed a live loop's lock because every
# Bash-call shell pid in this harness dies at call end). Style matches
# tests/bench-guard-fixtures.sh: numbered scenarios, assert_eq, mktemp
# fixtures, PASS/FAIL per assert, N/N summary line, non-zero exit on any
# failure. Every scratch git repo lives under mktemp — NEVER the tracked
# tree, and this corpus NEVER touches the real .git/gadd-loop.lock. Each
# scenario that guards a fail-open hole carries a mutation-bite comment
# naming the mutant it would catch.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_ROOT/bin/loop-lock.sh"

WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK" 2>/dev/null || true; }
trap cleanup EXIT

N=0
NPASS=0
NFAIL=0

pass() {
  N=$((N + 1))
  NPASS=$((NPASS + 1))
  printf 'PASS %2d: %s\n' "$N" "$1"
}

fail() {
  N=$((N + 1))
  NFAIL=$((NFAIL + 1))
  printf 'FAIL %2d: %s\n' "$N" "$1"
  if [ -n "${2:-}" ]; then
    printf '         %s\n' "$2"
  fi
}

# assert_eq NAME EXPECTED ACTUAL
assert_eq() {
  if [ "$2" = "$3" ]; then
    pass "$1"
  else
    fail "$1" "expected [$2] got [$3]"
  fi
}

# new_repo NAME -> prints the path of a fresh scratch git repo with one commit.
# Scratch only — never the tracked tree, never real .git/gadd-loop.lock.
new_repo() {
  local d="$WORK/$1"
  mkdir -p "$d"
  git -C "$d" init -q
  git -C "$d" config user.email "loop-lock@fixtures.invalid"
  git -C "$d" config user.name "loop-lock-fixtures"
  git -C "$d" config commit.gpgsign false
  git -C "$d" commit -q --allow-empty -m "init"
  printf '%s\n' "$d"
}

# lock_dir REPO -> prints the lock dir path for REPO.
lock_dir() { printf '%s/.git/gadd-loop.lock\n' "$1"; }

# backdate FILE SECONDS_AGO -> sets FILE's mtime to now - SECONDS_AGO, via a
# portable epoch (BSD `touch -j -f` / GNU `touch -d @epoch`).
backdate() {
  local f="$1" ago="$2" epoch
  epoch=$(( $(date +%s) - ago ))
  if date -r "$epoch" >/dev/null 2>&1; then
    # BSD date is available for formatting; use touch -t with a portable
    # strftime the target platform accepts.
    touch -t "$(date -r "$epoch" +%Y%m%d%H%M.%S)" "$f" 2>/dev/null && return
  fi
  touch -d "@$epoch" "$f" 2>/dev/null && return
  # last resort: GNU touch -t YYYYMMDDhhmm.ss via date -d
  touch -t "$(date -d "@$epoch" +%Y%m%d%H%M.%S 2>/dev/null)" "$f"
}

# mtime_of FILE -> epoch mtime (mirrors the script's own portable helper).
mtime_of() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null
}

DEAD_PID=99999999   # astronomically unlikely to be a live pid on any platform
LIVE_PID=$$          # this fixture script's own pid — guaranteed alive throughout

# ===================================================================================
# Scenario 1 (E1): fresh acquire on a lock-free repo -> exit 0, pid recorded in
# pid file, lease marker created.
# mutation-honesty: kills a mutant that skips writing the pid file or the lease
# marker on the happy path, silently degrading every downstream status/refresh
# read.
# ===================================================================================
r1="$(new_repo s01)"
out1="$(cd "$r1" && "$SCRIPT" acquire 4242)"; rc1=$?
assert_eq "(1) fresh acquire -> exit 0" "0" "$rc1"
assert_eq "(1) pid file records the acquiring pid" "4242" "$(cat "$(lock_dir "$r1")/pid")"
assert_eq "(1) lease marker file exists" "true" \
  "$([ -f "$(lock_dir "$r1")/lease" ] && echo true || echo false)"

# ===================================================================================
# Scenario 2 (E2, THE A3 REGRESSION CASE): dead recorded pid, FRESH lease ->
# exit 3. This is the exact anomaly: pid-death must NEVER be read as staleness.
# mutation-honesty: kills the A3 mutant itself — any acquire path that
# resurrects pid-liveness as a staleness input (e.g. `is_alive "$held_pid" ||
# reclaim`) would wrongly reclaim here and exit 0 instead of 3.
# ===================================================================================
r2="$(new_repo s02)"
(cd "$r2" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
out2="$(cd "$r2" && "$SCRIPT" acquire 7777 2>&1)"; rc2=$?
assert_eq "(2) dead-pid, fresh lease -> exit 3 (A3 regression pin)" "3" "$rc2"
assert_eq "(2) newcomer's pid never overwrites the held pid file" "$DEAD_PID" \
  "$(cat "$(lock_dir "$r2")/pid")"

# ===================================================================================
# Scenario 3 (E2 sibling): LIVE recorded pid, fresh lease -> exit 3, same as the
# dead-pid case — proving liveness plays no role in either direction.
# mutation-honesty: kills a mutant that special-cases live pids differently
# from dead ones in the fresh-lease branch (any asymmetry between scenario 2
# and 3's outcome, given both have a fresh lease, is a bug per E2/E8).
# ===================================================================================
r3="$(new_repo s03)"
(cd "$r3" && "$SCRIPT" acquire "$LIVE_PID" >/dev/null)
out3="$(cd "$r3" && "$SCRIPT" acquire 8888 2>&1)"; rc3=$?
assert_eq "(3) live-pid, fresh lease -> exit 3 (matches scenario 2's outcome)" "3" "$rc3"

# ===================================================================================
# Scenario 4 (E3): lease older than TTL -> reclaim, exit 0, new pid + fresh
# lease recorded.
# mutation-honesty: kills a mutant that never reclaims (permanently wedged
# lock) or that reclaims unconditionally regardless of age (would also pass
# scenario 2/3 wrongly if triggered from the same code path — this scenario
# proves the age-based branch DOES fire when it should).
# ===================================================================================
r4="$(new_repo s04)"
(cd "$r4" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
backdate "$(lock_dir "$r4")/lease" 7200   # 2h old, default TTL is 3600s
out4="$(cd "$r4" && "$SCRIPT" acquire 3333 2>&1)"; rc4=$?
assert_eq "(4) stale lease (age > default TTL) -> exit 0 reclaim" "0" "$rc4"
assert_eq "(4) reclaim records the new pid" "3333" "$(cat "$(lock_dir "$r4")/pid")"
assert_eq "(4) reclaim message says stale lease" "true" \
  "$(printf '%s' "$out4" | grep -q 'stale lease' && echo true || echo false)"

# ===================================================================================
# Scenario 5 (E4): old-format lock dir with NO lease marker, fresh dir-mtime
# -> exit 3 (dir mtime stands in for the lease clock and is fresh).
# mutation-honesty: kills a mutant that treats a missing lease marker as
# "unmeasurable -> always reclaim" (fail-open on every legacy lock) or as
# "unmeasurable -> always block" (permanently wedged legacy lock, never ages
# out per scenario 6).
# ===================================================================================
r5="$(new_repo s05)"
mkdir -p "$(lock_dir "$r5")"
echo "$DEAD_PID" > "$(lock_dir "$r5")/pid"
out5="$(cd "$r5" && "$SCRIPT" acquire 1111 2>&1)"; rc5=$?
assert_eq "(5) old-format lock (no lease marker), fresh dir-mtime -> exit 3" "3" "$rc5"

# ===================================================================================
# Scenario 6 (E4 sibling): same old-format lock, but dir-mtime backdated past
# TTL -> reclaim, exit 0. Proves the dir-mtime fallback is a real clock, not a
# permanent wedge.
# mutation-honesty: kills a mutant whose E4 fallback reads a constant (e.g.
# always "age 0") instead of the dir's actual mtime.
# ===================================================================================
r6="$(new_repo s06)"
mkdir -p "$(lock_dir "$r6")"
echo "$DEAD_PID" > "$(lock_dir "$r6")/pid"
backdate "$(lock_dir "$r6")" 7200
out6="$(cd "$r6" && "$SCRIPT" acquire 2222 2>&1)"; rc6=$?
assert_eq "(6) old-format lock, aged dir-mtime -> exit 0 reclaim" "0" "$rc6"

# ===================================================================================
# Scenario 7 (E5): TTL override honored in BOTH directions — a short TTL makes
# an otherwise-fresh lease reclaimable; a long TTL keeps an otherwise-stale
# lease blocking.
# mutation-honesty: kills a mutant that hardcodes DEFAULT_TTL and ignores
# GADD_LOOP_LEASE_TTL entirely.
# ===================================================================================
r7a="$(new_repo s07a)"
(cd "$r7a" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
backdate "$(lock_dir "$r7a")/lease" 30   # 30s old — fresh under default TTL
out7a="$(cd "$r7a" && GADD_LOOP_LEASE_TTL=5 "$SCRIPT" acquire 9001 2>&1)"; rc7a=$?
assert_eq "(7a) short TTL override makes a would-be-fresh lease reclaimable -> exit 0" "0" "$rc7a"

r7b="$(new_repo s07b)"
(cd "$r7b" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
backdate "$(lock_dir "$r7b")/lease" 7200   # 2h old — stale under default TTL
out7b="$(cd "$r7b" && GADD_LOOP_LEASE_TTL=999999 "$SCRIPT" acquire 9002 2>&1)"; rc7b=$?
assert_eq "(7b) long TTL override keeps a would-be-stale lease blocking -> exit 3" "3" "$rc7b"

# ===================================================================================
# Scenario 8 (E5): invalid TTL values fall back to the default LOUDLY on stderr,
# and NEVER make an otherwise-fresh lock reclaimable (fail-closed: invalid
# config may only make reclaim harder, never easier). Covers empty,
# non-numeric, zero, and negative.
# mutation-honesty: kills a mutant that treats an invalid/empty TTL as 0
# (every lock becomes instantly reclaimable — the opposite of fail-closed).
# ===================================================================================
for bad in "" "abc" "0" "-5"; do
  r8="$(new_repo "s08-$(echo "$bad" | tr -dc 'a-zA-Z0-9' )_x")"
  (cd "$r8" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
  err8="$WORK/err08-$(echo "$bad" | tr -dc 'a-zA-Z0-9')_x.txt"
  out8="$(cd "$r8" && GADD_LOOP_LEASE_TTL="$bad" "$SCRIPT" acquire 9500 2>"$err8")"; rc8=$?
  assert_eq "(8 TTL='$bad') fresh lease under invalid TTL -> exit 3 (never reclaimable)" "3" "$rc8"
  assert_eq "(8 TTL='$bad') invalid TTL warned loudly on stderr" "true" \
    "$(grep -q 'invalid GADD_LOOP_LEASE_TTL' "$err8" && echo true || echo false)"
done

# ===================================================================================
# Scenario 9 (E6): refresh updates the lease mtime, and reports the right exit
# code held (0) vs free (5).
# mutation-honesty: kills a mutant whose refresh is a no-op (touch dropped),
# which would make E3's TTL-based staleness detection blind to a live loop
# that is actually still phase-advancing.
# ===================================================================================
r9="$(new_repo s09)"
(cd "$r9" && "$SCRIPT" acquire "$LIVE_PID" >/dev/null)
backdate "$(lock_dir "$r9")/lease" 100
before9="$(mtime_of "$(lock_dir "$r9")/lease")"
sleep 1
out9="$(cd "$r9" && "$SCRIPT" refresh)"; rc9=$?
after9="$(mtime_of "$(lock_dir "$r9")/lease")"
assert_eq "(9) refresh while held -> exit 0" "0" "$rc9"
assert_eq "(9) refresh moves the lease mtime forward" "true" \
  "$([ "$after9" -gt "$before9" ] && echo true || echo false)"

r9b="$(new_repo s09b)"
err9b="$WORK/err09b.txt"
(cd "$r9b" && "$SCRIPT" refresh >/dev/null 2>"$err9b"); rc9b=$?
assert_eq "(9b) refresh with no lock held -> exit 5" "5" "$rc9b"
assert_eq "(9b) refresh-with-no-lock is loud on stderr" "true" \
  "$(grep -q 'no lock held' "$err9b" && echo true || echo false)"

# ===================================================================================
# Scenario 10 (E7): status reports holder pid, advisory liveness, lease age,
# effective TTL, and FRESH/STALE wording — and a DEAD recorded pid with a
# FRESH lease still reports FRESH (the A3 case, from the status surface).
# mutation-honesty: kills a mutant that derives status FRESH/STALE from pid
# liveness instead of lease age (the exact A3 bug, surfaced via `status`).
# ===================================================================================
r10="$(new_repo s10)"
(cd "$r10" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
out10="$(cd "$r10" && "$SCRIPT" status)"; rc10=$?
assert_eq "(10) status while held -> exit 0" "0" "$rc10"
assert_eq "(10) status names the holder pid" "true" \
  "$(printf '%s' "$out10" | grep -q "pid $DEAD_PID" && echo true || echo false)"
assert_eq "(10) status shows advisory dead liveness for the dead recorded pid" "true" \
  "$(printf '%s' "$out10" | grep -q 'dead' && echo true || echo false)"
assert_eq "(10) status reports FRESH (lease fresh, despite dead recorded pid)" "true" \
  "$(printf '%s' "$out10" | grep -q 'FRESH' && echo true || echo false)"
assert_eq "(10) status never claims STALE for a dead-pid-but-fresh-lease lock" "false" \
  "$(printf '%s' "$out10" | grep -q 'STALE' && echo true || echo false)"

backdate "$(lock_dir "$r10")/lease" 7200
out10b="$(cd "$r10" && "$SCRIPT" status)"; rc10b=$?
assert_eq "(10b) status after lease ages past TTL -> STALE" "true" \
  "$(printf '%s' "$out10b" | grep -q 'STALE' && echo true || echo false)"
assert_eq "(10b) status always exits 0" "0" "$rc10b"

r10c="$(new_repo s10c)"
out10c="$(cd "$r10c" && "$SCRIPT" status)"; rc10c=$?
assert_eq "(10c) status on a free lock -> 'free', exit 0" "true" \
  "$([ "$rc10c" = "0" ] && printf '%s' "$out10c" | grep -q 'free' && echo true || echo false)"

# ===================================================================================
# Scenario 11 (E8, grep-level receipt): no liveness check appears in any
# acquire/reclaim decision path. `is_alive`/`kill -0` may only appear in the
# script's definition/comments and inside the `status` case body.
# mutation-honesty: this is the structural receipt for the A3 fix itself —
# a regression that reintroduces `is_alive` (or any `kill -0`) into the
# acquire branch would fail this assertion even before scenario 2/3 could be
# exercised, giving a fast, precise failure signal.
# ===================================================================================
acquire_block="$(awk '/^  acquire\)/{flag=1} flag{print} /^  refresh\)/{if(flag)exit}' "$SCRIPT")"
assert_eq "(11) no is_alive/kill -0 reference inside the acquire branch" "true" \
  "$(printf '%s' "$acquire_block" | grep -qE 'is_alive|kill -0' && echo false || echo true)"

# ===================================================================================
# Scenario 12: usage/unknown-subcommand -> exit 2, loud stderr; no subcommand
# at all -> exit 2.
# mutation-honesty: kills a mutant whose argument parsing falls through to
# exit 0 (bash default last-command status) on unexpected invocations.
# ===================================================================================
r12="$(new_repo s12)"
err12a="$WORK/err12a.txt"
(cd "$r12" && "$SCRIPT" frobnicate >/dev/null 2>"$err12a"); rc12a=$?
assert_eq "(12a) unknown subcommand -> exit 2" "2" "$rc12a"
assert_eq "(12a) unknown-subcommand stderr carries usage" "true" \
  "$(grep -q 'usage:' "$err12a" && echo true || echo false)"
err12b="$WORK/err12b.txt"
(cd "$r12" && "$SCRIPT" >/dev/null 2>"$err12b"); rc12b=$?
assert_eq "(12b) no subcommand at all -> exit 2" "2" "$rc12b"

# ===================================================================================
# Scenario 13: release idempotence x2 — releasing a held lock succeeds and
# names the prior holder; releasing again (already free) is a no-op exit 0.
# mutation-honesty: kills a mutant that errors (nonzero) on a second release,
# which would make the loop's own cleanup-after-STOP path fragile.
# ===================================================================================
r13="$(new_repo s13)"
(cd "$r13" && "$SCRIPT" acquire "$LIVE_PID" >/dev/null)
out13a="$(cd "$r13" && "$SCRIPT" release)"; rc13a=$?
assert_eq "(13a) release while held -> exit 0" "0" "$rc13a"
assert_eq "(13a) release names the prior holder pid" "true" \
  "$(printf '%s' "$out13a" | grep -q "$LIVE_PID" && echo true || echo false)"
assert_eq "(13a) lock dir removed after release" "false" \
  "$([ -d "$(lock_dir "$r13")" ] && echo true || echo false)"
out13b="$(cd "$r13" && "$SCRIPT" release)"; rc13b=$?
assert_eq "(13b) second release (already free) -> exit 0, idempotent no-op" "0" "$rc13b"
assert_eq "(13b) second release message says no-op" "true" \
  "$(printf '%s' "$out13b" | grep -q 'no-op' && echo true || echo false)"

# ===================================================================================
echo ""
echo "--- mutation-bite receipt: reintroducing pid-liveness into the acquire
--- branch (the A3 mutant) reopens scenario 2/3 and the structural receipt ---"
mutant="$WORK/loop-lock.mutant.sh"
mutant_awk="$WORK/mutant.awk"
# Reintroduce the pre-A3 bug: force `age` to a huge value whenever the
# recorded pid is dead, right before the age-vs-TTL comparison in the
# acquire branch ONLY (the identical "if age <= ttl" text also appears in
# the status branch, so the insertion is gated on an in_acquire flag that
# turns off at the next case arm, and fires at most once via `done`).
cat > "$mutant_awk" <<'AWK'
/^  acquire\)/ { in_acquire = 1 }
/^  refresh\)/ { in_acquire = 0 }
in_acquire && !done && /if \[ "\$age" -le "\$ttl" \]; then/ {
  print "    if [ -n \"$held_pid\" ] && ! is_alive \"$held_pid\" 2>/dev/null; then age=999999; fi"
  done = 1
}
{ print }
AWK
awk -f "$mutant_awk" "$SCRIPT" > "$mutant"
chmod +x "$mutant"
assert_eq "(M setup) mutant differs from the real script (awk insertion took effect on the scratch copy)" "false" \
  "$(cmp -s "$SCRIPT" "$mutant" && echo true || echo false)"
mM="$(new_repo sM)"
(cd "$mM" && "$mutant" acquire "$DEAD_PID" >/dev/null)
(cd "$mM" && "$mutant" acquire 6001 >/dev/null 2>&1); rcM_mut=$?
mM2="$(new_repo sM2)"
(cd "$mM2" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
(cd "$mM2" && "$SCRIPT" acquire 6002 >/dev/null 2>&1); rcM_real=$?
assert_eq "(M) A3-reintroducing mutant wrongly reclaims a dead-pid fresh-lease lock -> exit 0 (fail-open reproduced on the scratch copy)" "0" "$rcM_mut"
assert_eq "(M) real script exits 3 on the identical scenario — scenario 2 kills this mutant" "3" "$rcM_real"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
