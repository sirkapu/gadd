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
# n3 (run-33): refresh now requires an explicit, ownership-matching pid
# argument (fail-closed ownership check — see scenarios 17-21 below). The
# held pid here is $LIVE_PID, so that is the argument this assert must pass;
# the assertion text/intent is unchanged, only the now-mandatory argument
# was added.
out9="$(cd "$r9" && "$SCRIPT" refresh "$LIVE_PID")"; rc9=$?
after9="$(mtime_of "$(lock_dir "$r9")/lease")"
assert_eq "(9) refresh while held -> exit 0" "0" "$rc9"
assert_eq "(9) refresh moves the lease mtime forward" "true" \
  "$([ "$after9" -gt "$before9" ] && echo true || echo false)"

r9b="$(new_repo s09b)"
err9b="$WORK/err09b.txt"
# n3: no lock exists in r9b at all; a valid pid argument (1234, arbitrary —
# there is nothing to match against) is supplied so this scenario continues
# to isolate the no-lock case (E3) from the missing-argument case (E5,
# scenario 21).
(cd "$r9b" && "$SCRIPT" refresh 1234 >/dev/null 2>"$err9b"); rc9b=$?
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
# Bench round 1 additions (run-30 A3, additive only — everything above untouched).
# Scenarios 14-16 close TEST_HONESTY's E3 exit-4 blocker and pin the two
# adversary-specified SECURITY notes on lease_age_seconds (unreadable mtime,
# future-dated/clock-skew mtime).
# ===================================================================================

# ===================================================================================
# Scenario 14 (E3 exit-4 reclaim-race, TEST_HONESTY blocker): the post-reclaim
# mkdir-failure path was untested — a mutant deleting the `exit 4` line survived
# the round-0 corpus. Two receipts:
#   (a) STRUCTURAL — the acquire branch text contains an `exit 4` (same
#       grep-level pattern as scenario 11's is_alive/kill-0 structural check).
#   (b) FORCED RACE — a PATH-shimmed `mkdir` that always fails deterministically
#       simulates "lost the reclaim race" (another process's mkdir won, or a
#       filesystem refusal) without any OS-specific permission trick: a
#       read-only-parent-directory approach is flaky under root-run CI, where
#       permission bits are frequently bypassed entirely, so it is NOT used
#       here. The lock dir is set up with the real mkdir/touch/backdate before
#       the shimmed PATH is applied to the script's own invocation only.
# mutation-honesty: (a) kills a mutant that strips the `exit 4` line (falling
# through to whatever exit status bash produces next — likely 0, the prior
# mkdir's success). (b) kills a mutant that treats a failed post-reclaim mkdir
# as success (e.g. drops the `if` guard and always prints "lock acquired"),
# which would silently hand the lock to two processes at once.
# ===================================================================================
acquire_block_14="$(awk '/^  acquire\)/{flag=1} flag{print} /^  refresh\)/{if(flag)exit}' "$SCRIPT")"
assert_eq "(14a) acquire branch contains an 'exit 4' fail-closed path (structural receipt)" "true" \
  "$(printf '%s' "$acquire_block_14" | grep -q 'exit 4' && echo true || echo false)"

r14="$(new_repo s14)"
(cd "$r14" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
backdate "$(lock_dir "$r14")/lease" 7200   # stale under default TTL -> reclaim will be attempted
mkdir_shim14="$WORK/mkdir-shim-14"
mkdir -p "$mkdir_shim14"
cat > "$mkdir_shim14/mkdir" <<'EOF'
#!/usr/bin/env bash
# Always fails, regardless of arguments — deterministic "lost the reclaim
# race" simulation. Only shadows `mkdir` for the single shimmed invocation
# below; fixture setup above used the real mkdir.
exit 1
EOF
chmod +x "$mkdir_shim14/mkdir"
err14="$WORK/err14.txt"
(cd "$r14" && PATH="$mkdir_shim14:$PATH" "$SCRIPT" acquire 4001 >/dev/null 2>"$err14"); rc14=$?
assert_eq "(14b) forced post-reclaim mkdir failure -> exit 4 (lost the race, fail closed)" "4" "$rc14"
assert_eq "(14b) stderr names the failed-reclaim condition" "true" \
  "$(grep -q 'failed to acquire lock after stale reclaim' "$err14" && echo true || echo false)"

# ===================================================================================
# Scenario 15 (SECURITY note 1): unreadable lease mtime must refuse (exit 4),
# never be silently treated as 0 -> maximally-stale -> fail-open reclaim.
# Simulated deterministically via a PATH-shimmed `stat` that EXITS 0 WITH EMPTY
# STDOUT for every invocation (both the BSD `-f %m` and GNU `-c %Y` forms
# resolve to this shim). A shim that instead makes `stat` FAIL (nonzero exit)
# was deliberately rejected: `mtime_of`'s `stat -f ... || stat -c ...` is the
# LAST command in its function body, run inside the command-substitution
# subshell backing `m="$(lease_reference_mtime)"` — under `set -e`, both stat
# forms failing trips `set -e` inside that subshell BEFORE this script's own
# `[[ "$m" =~ ... ]]` guard ever runs (verified empirically: an
# always-exit-1 stat shim yields exit 1 from the raw stat failure, not exit 4
# from the guard). An exit-0-empty-output shim is what actually reaches and
# exercises the guard, so that is what is used.
# mutation-honesty: kills a mutant that removes/weakens the
# `[[ "$m" =~ ^[0-9]+$ ]] || { ...; exit 4; }` guard, letting
# `$((now - m))` silently treat empty/garbage as 0 and report a fully-stale
# lease ripe for fail-open reclaim.
# ===================================================================================
r15="$(new_repo s15)"
(cd "$r15" && "$SCRIPT" acquire "$LIVE_PID" >/dev/null)
stat_shim15="$WORK/stat-shim-15"
mkdir -p "$stat_shim15"
cat > "$stat_shim15/stat" <<'EOF'
#!/usr/bin/env bash
# Always succeeds, always silent — simulates an mtime read that resolves to
# nothing (unreadable/garbage), NOT a stat failure (a failure trips set -e
# inside mtime_of's subshell before this script's own guard ever runs — see
# the scenario 15 comment above).
exit 0
EOF
chmod +x "$stat_shim15/stat"
err15="$WORK/err15.txt"
(cd "$r15" && PATH="$stat_shim15:$PATH" "$SCRIPT" acquire 5001 >/dev/null 2>"$err15"); rc15=$?
assert_eq "(15) unreadable lease mtime -> exit 4 (fail-closed, never a lucky 0-reclaim)" "4" "$rc15"
assert_eq "(15) stderr is loud about the unreadable mtime" "true" \
  "$(grep -q 'unreadable lease mtime' "$err15" && echo true || echo false)"

echo ""
echo "--- mutation-bite receipt: FIX2 guard stripped on a scratch copy reopens the fail-open hole ---"
mutant15="$WORK/loop-lock.mutant15.sh"
awk '{ if ($0 ~ /unreadable lease mtime/) print "  :"; else print }' "$SCRIPT" > "$mutant15"
chmod +x "$mutant15"
assert_eq "(15 setup) guard-stripped mutant differs from the real script" "false" \
  "$(cmp -s "$SCRIPT" "$mutant15" && echo true || echo false)"
r15m="$(new_repo s15m)"
(cd "$r15m" && "$mutant15" acquire "$LIVE_PID" >/dev/null)
(cd "$r15m" && PATH="$stat_shim15:$PATH" "$mutant15" acquire 5002 >/dev/null 2>&1); rc15m=$?
assert_eq "(15 mutation-bite) guard-stripped mutant treats unreadable mtime as 0/max-stale -> exit 0 fail-open reclaim (scratch copy only)" "0" "$rc15m"

# ===================================================================================
# Scenario 16 (SECURITY note 2): future-dated lease (clock skew) must clamp to
# age 0, never go negative -> permanently FRESH -> unkillable wedge. Reuses the
# `backdate` helper with a NEGATIVE seconds-ago argument (epoch = now - (-N) =
# now + N), which is exactly "touch -t next-year" on the lease marker.
# mutation-honesty: kills a mutant that drops the `[ "$age" -lt 0 ] && age=0`
# clamp. A negative age would still satisfy acquire's `age <= ttl` check (so
# 16a's exit-3 outcome alone would not distinguish clamped-0 from raw-negative)
# — the LOAD-BEARING assertions are 16b's: status must print exactly "age 0s",
# never a negative number, and must still say FRESH.
# ===================================================================================
r16="$(new_repo s16)"
(cd "$r16" && "$SCRIPT" acquire "$DEAD_PID" >/dev/null)
backdate "$(lock_dir "$r16")/lease" -31536000   # ~1 year in the future (clock skew)
out16a="$(cd "$r16" && "$SCRIPT" acquire 6101 2>&1)"; rc16a=$?
assert_eq "(16a) future-dated lease -> acquire exit 3 (held, not stale)" "3" "$rc16a"
out16b="$(cd "$r16" && "$SCRIPT" status)"; rc16b=$?
assert_eq "(16b) status always exits 0" "0" "$rc16b"
assert_eq "(16b) status reports lease age exactly 0s (clamped, not negative)" "true" \
  "$(printf '%s' "$out16b" | grep -q 'lease age 0s' && echo true || echo false)"
assert_eq "(16b) status reports FRESH" "true" \
  "$(printf '%s' "$out16b" | grep -q 'FRESH' && echo true || echo false)"
assert_eq "(16b) status output carries no negative number anywhere" "false" \
  "$(printf '%s' "$out16b" | grep -Eq -- '-[0-9]' && echo true || echo false)"

# ===================================================================================
# Bench round 2 additions (run-33 n3, additive only — everything above
# untouched save the two `refresh` call-sites in scenario 9/9b, which now
# pass the pid `refresh` requires — see the n3 comments there). refresh no
# longer trusts whoever holds the lock: it must prove ownership by pid-match
# against the recorded holder, closing the silent-usurper-refresh hole (a
# loop whose lock was stale-reclaimed by a newcomer must learn it lost
# ownership, not silently keep refreshing the newcomer's lease). Scenarios
# 17-21 pin E1-E5 both directions.
# ===================================================================================

# ===================================================================================
# Scenario 17 (E1): matching pid refreshes -> exit 0, lease mtime advances,
# stdout names the pid.
# mutation-honesty: kills a mutant that adds the ownership check but gets the
# comparison backwards (refuses on MATCH instead of mismatch), or that drops
# the `touch` on the success path.
# ===================================================================================
r17="$(new_repo s17)"
(cd "$r17" && "$SCRIPT" acquire "$LIVE_PID" >/dev/null)
backdate "$(lock_dir "$r17")/lease" 100
before17="$(mtime_of "$(lock_dir "$r17")/lease")"
sleep 1
out17="$(cd "$r17" && "$SCRIPT" refresh "$LIVE_PID")"; rc17=$?
after17="$(mtime_of "$(lock_dir "$r17")/lease")"
assert_eq "(17) matching-pid refresh -> exit 0" "0" "$rc17"
assert_eq "(17) matching-pid refresh advances the lease mtime" "true" \
  "$([ "$after17" -gt "$before17" ] && echo true || echo false)"
assert_eq "(17) matching-pid refresh stdout names the pid" "true" \
  "$(printf '%s' "$out17" | grep -q "pid $LIVE_PID" && echo true || echo false)"

# ===================================================================================
# Scenario 18 (E2, THE OWNERSHIP-CHECK CASE): mismatched pid -> exit 5, lease
# mtime UNCHANGED (never refresh a lease you don't own), stderr names BOTH
# the caller's claimed pid and the recorded holder pid.
# mutation-honesty: kills a mutant that refreshes for whoever holds the lock
# regardless of the caller's claim (the exact usurper-refresh hole this
# check closes) — that mutant would exit 0 and advance the mtime here.
# ===================================================================================
r18="$(new_repo s18)"
(cd "$r18" && "$SCRIPT" acquire "$LIVE_PID" >/dev/null)
backdate "$(lock_dir "$r18")/lease" 100
before18="$(mtime_of "$(lock_dir "$r18")/lease")"
err18="$WORK/err18.txt"
out18="$(cd "$r18" && "$SCRIPT" refresh "$DEAD_PID" 2>"$err18")"; rc18=$?
after18="$(mtime_of "$(lock_dir "$r18")/lease")"
assert_eq "(18) mismatched-pid refresh -> exit 5" "5" "$rc18"
assert_eq "(18) mismatched-pid refresh leaves the lease mtime unchanged" "$before18" "$after18"
assert_eq "(18) mismatch stderr names the caller's claimed pid" "true" \
  "$(grep -q "$DEAD_PID" "$err18" && echo true || echo false)"
assert_eq "(18) mismatch stderr names the recorded holder pid" "true" \
  "$(grep -q "$LIVE_PID" "$err18" && echo true || echo false)"

# ===================================================================================
# Scenario 19 (E3, pid-arg-supplied variant): no lock dir exists, but the
# refresh call carries a syntactically valid pid -> exit 5, the pre-existing
# "cannot refresh — no lock held" stderr message preserved verbatim, lease
# marker never created.
# mutation-honesty: kills a mutant that reorders the ownership check ahead of
# the lock-exists check in a way that swallows/rewords the no-lock message.
# ===================================================================================
r19="$(new_repo s19)"
err19="$WORK/err19.txt"
(cd "$r19" && "$SCRIPT" refresh 4321 >/dev/null 2>"$err19"); rc19=$?
assert_eq "(19) no-lock refresh with a valid pid arg -> exit 5" "5" "$rc19"
assert_eq "(19) no-lock message preserved verbatim" "true" \
  "$(grep -q '\[loop-lock\] cannot refresh — no lock held' "$err19" && echo true || echo false)"
assert_eq "(19) no-lock refresh never creates a lock dir" "false" \
  "$([ -d "$(lock_dir "$r19")" ] && echo true || echo false)"

# ===================================================================================
# Scenario 20 (E4): corrupt lock — pid file empty, and pid file non-numeric.
# Both cases: ownership is unverifiable -> exit 5, lease mtime UNCHANGED,
# loud stderr. Lock dir + lease are built manually (mirrors scenarios 5/6's
# old-format-lock construction) since `acquire` always writes a valid
# numeric pid.
# mutation-honesty: kills a mutant that treats an unreadable/corrupt held pid
# as "no one owns it, so anyone may refresh" (fail-open) instead of refusing.
# ===================================================================================
r20a="$(new_repo s20a)"
mkdir -p "$(lock_dir "$r20a")"
: > "$(lock_dir "$r20a")/pid"   # empty pid file
touch "$(lock_dir "$r20a")/lease"
backdate "$(lock_dir "$r20a")/lease" 100
before20a="$(mtime_of "$(lock_dir "$r20a")/lease")"
err20a="$WORK/err20a.txt"
(cd "$r20a" && "$SCRIPT" refresh 5555 >/dev/null 2>"$err20a"); rc20a=$?
after20a="$(mtime_of "$(lock_dir "$r20a")/lease")"
assert_eq "(20a) empty pid file -> refresh exit 5" "5" "$rc20a"
assert_eq "(20a) empty pid file -> lease mtime unchanged" "$before20a" "$after20a"
assert_eq "(20a) empty pid file -> stderr is loud about corrupt/unverifiable ownership" "true" \
  "$(grep -Eq 'corrupt|unverifiable' "$err20a" && echo true || echo false)"

r20b="$(new_repo s20b)"
mkdir -p "$(lock_dir "$r20b")"
echo "not-a-pid" > "$(lock_dir "$r20b")/pid"   # non-numeric pid file
touch "$(lock_dir "$r20b")/lease"
backdate "$(lock_dir "$r20b")/lease" 100
before20b="$(mtime_of "$(lock_dir "$r20b")/lease")"
err20b="$WORK/err20b.txt"
(cd "$r20b" && "$SCRIPT" refresh 5556 >/dev/null 2>"$err20b"); rc20b=$?
after20b="$(mtime_of "$(lock_dir "$r20b")/lease")"
assert_eq "(20b) non-numeric pid file -> refresh exit 5" "5" "$rc20b"
assert_eq "(20b) non-numeric pid file -> lease mtime unchanged" "$before20b" "$after20b"
assert_eq "(20b) non-numeric pid file -> stderr is loud about corrupt/unverifiable ownership" "true" \
  "$(grep -Eq 'corrupt|unverifiable' "$err20b" && echo true || echo false)"

# ===================================================================================
# Scenario 21 (E5): a missing or invalid ownership claim is a caller bug —
# exit 2 with the usage line, distinct from the lost-lock exit 5. Covers no
# argument at all, a non-numeric argument, and an explicit empty-string
# argument, all against a HELD lock (so a passing exit-5 result would prove
# the argument check is being skipped and the no-lock/ownership checks are
# firing instead). Lease mtime must not change in any case.
# mutation-honesty: kills a mutant that folds a missing/invalid pid argument
# into the ownership-mismatch branch (wrongly returning 5 instead of 2), or
# one that lets an unset `$2` reach the ownership comparison as an empty
# string that happens to not match (accidentally correct exit code for the
# wrong reason, but still failing the usage-message assertions here).
# ===================================================================================
r21="$(new_repo s21)"
(cd "$r21" && "$SCRIPT" acquire "$LIVE_PID" >/dev/null)
backdate "$(lock_dir "$r21")/lease" 100
before21="$(mtime_of "$(lock_dir "$r21")/lease")"

err21a="$WORK/err21a.txt"
(cd "$r21" && "$SCRIPT" refresh >/dev/null 2>"$err21a"); rc21a=$?
assert_eq "(21a) refresh with no pid argument -> exit 2" "2" "$rc21a"
assert_eq "(21a) no-pid-argument stderr carries usage" "true" \
  "$(grep -q 'usage:' "$err21a" && echo true || echo false)"

err21b="$WORK/err21b.txt"
(cd "$r21" && "$SCRIPT" refresh notanumber >/dev/null 2>"$err21b"); rc21b=$?
assert_eq "(21b) refresh with a non-numeric pid argument -> exit 2" "2" "$rc21b"
assert_eq "(21b) non-numeric-argument stderr carries usage" "true" \
  "$(grep -q 'usage:' "$err21b" && echo true || echo false)"

err21c="$WORK/err21c.txt"
(cd "$r21" && "$SCRIPT" refresh "" >/dev/null 2>"$err21c"); rc21c=$?
assert_eq "(21c) refresh with an explicit empty-string pid argument -> exit 2" "2" "$rc21c"
assert_eq "(21c) empty-argument stderr carries usage" "true" \
  "$(grep -q 'usage:' "$err21c" && echo true || echo false)"

after21="$(mtime_of "$(lock_dir "$r21")/lease")"
assert_eq "(21) invalid-argument refresh attempts never move the lease mtime" "$before21" "$after21"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
