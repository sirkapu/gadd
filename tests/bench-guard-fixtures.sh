#!/usr/bin/env bash
# tests/bench-guard-fixtures.sh — acceptance corpus for bin/bench-tree-guard.sh
# (bench scratch-copy mutation discipline, tightened 2026-07-17; isolation rule
# in RED_TEAM/gate-matrix.md). Style matches tests/heartbeat-fixtures.sh:
# numbered scenarios, assert_eq, mktemp fixtures, PASS/FAIL per assert, N/N
# summary line, non-zero exit on any failure. Every scratch git repo lives
# under mktemp — NEVER in the tracked tree, per the very discipline this
# instrument installs. Each scenario carries a mutation-honesty comment naming
# the mutant it kills.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_ROOT/bin/bench-tree-guard.sh"

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

# new_repo NAME -> prints the path of a fresh scratch git repo with one commit
# containing alpha.txt + beta.txt. Scratch only — never the tracked tree.
new_repo() {
  local d="$WORK/$1"
  mkdir -p "$d"
  git -C "$d" init -q
  git -C "$d" config user.email "bench-guard@fixtures.invalid"
  git -C "$d" config user.name "bench-guard-fixtures"
  git -C "$d" config commit.gpgsign false
  printf 'alpha v1\n' > "$d/alpha.txt"
  printf 'beta v1\n' > "$d/beta.txt"
  git -C "$d" add -A
  git -C "$d" commit -q -m "init"
  printf '%s\n' "$d"
}

# ===================================================================================
# Scenario 1: identical tree — snapshot, change nothing, verify -> exit 0, brief OK
# line, and the snapshot line is exactly one well-formed fingerprint line.
# mutation-honesty: kills a mutant whose verify exits nonzero even on a pristine
# match (a guard that can never pass would void every bench round and be routed
# around, i.e. fail-open by disuse).
# ===================================================================================
r1="$(new_repo s01)"
fp1="$(cd "$r1" && "$SCRIPT" snapshot)"; rc1s=$?
assert_eq "(1) snapshot on a clean scratch repo -> exit 0" "0" "$rc1s"
assert_eq "(1) snapshot stdout is exactly one line" "1" "$(printf '%s\n' "$fp1" | wc -l | tr -d ' ')"
assert_eq "(1) snapshot line matches gadd-bench-fp-v1:<64 hex>" "true" \
  "$(printf '%s' "$fp1" | grep -Eq '^gadd-bench-fp-v1:[0-9a-f]{64}$' && echo true || echo false)"
out1="$(cd "$r1" && "$SCRIPT" verify "$fp1" 2>/dev/null)"; rc1v=$?
assert_eq "(1) verify on the unchanged tree -> exit 0" "0" "$rc1v"
assert_eq "(1) verify success prints a brief OK line" "true" \
  "$(printf '%s' "$out1" | grep -q 'OK' && echo true || echo false)"

# ===================================================================================
# Scenario 2: unstaged tracked-file edit after snapshot -> exit 2, loud stderr that
# names the changed path.
# mutation-honesty: kills a mutant that drops component (c)/(b) or the comparison
# itself, letting an adversary's residue on a tracked file return "OK".
# ===================================================================================
r2="$(new_repo s02)"
fp2="$(cd "$r2" && "$SCRIPT" snapshot)"
printf 'alpha MUTATED\n' > "$r2/alpha.txt"
err2="$WORK/err02.txt"
(cd "$r2" && "$SCRIPT" verify "$fp2" >/dev/null 2>"$err2"); rc2=$?
assert_eq "(2) unstaged tracked edit -> exit 2" "2" "$rc2"
assert_eq "(2) stderr names the changed path (alpha.txt)" "true" \
  "$(grep -q 'alpha\.txt' "$err2" && echo true || echo false)"
assert_eq "(2) stderr carries the loud [bench-tree-guard] prefix" "true" \
  "$(grep -q '\[bench-tree-guard\]' "$err2" && echo true || echo false)"

# ===================================================================================
# Scenario 3: staged edit (edit + git add, nothing committed) -> exit 2. The index
# is part of the fingerprint, not just the worktree.
# mutation-honesty: kills a mutant that fingerprints only unstaged state (e.g. diff
# without HEAD), blind to an adversary staging its residue.
# ===================================================================================
r3="$(new_repo s03)"
fp3="$(cd "$r3" && "$SCRIPT" snapshot)"
printf 'alpha staged-mutation\n' > "$r3/alpha.txt"
git -C "$r3" add alpha.txt
err3="$WORK/err03.txt"
(cd "$r3" && "$SCRIPT" verify "$fp3" >/dev/null 2>"$err3"); rc3=$?
assert_eq "(3) staged tracked edit -> exit 2" "2" "$rc3"
assert_eq "(3) stderr names the staged path (alpha.txt)" "true" \
  "$(grep -q 'alpha\.txt' "$err3" && echo true || echo false)"

# ===================================================================================
# Scenario 4: new untracked file appears after snapshot -> exit 2, named on stderr.
# mutation-honesty: kills a mutant that fingerprints only tracked state (drops the
# untracked side of component (b)/(d)), letting an adversary leave droppings.
# ===================================================================================
r4="$(new_repo s04)"
fp4="$(cd "$r4" && "$SCRIPT" snapshot)"
printf 'adversary dropping\n' > "$r4/dropping.txt"
err4="$WORK/err04.txt"
(cd "$r4" && "$SCRIPT" verify "$fp4" >/dev/null 2>"$err4"); rc4=$?
assert_eq "(4) new untracked file -> exit 2" "2" "$rc4"
assert_eq "(4) stderr names the new file (dropping.txt)" "true" \
  "$(grep -q 'dropping\.txt' "$err4" && echo true || echo false)"

# ===================================================================================
# Scenario 5: tracked file deleted after snapshot -> exit 2, named on stderr.
# mutation-honesty: kills a mutant that only checks content of files still present
# and never notices a path vanished.
# ===================================================================================
r5="$(new_repo s05)"
fp5="$(cd "$r5" && "$SCRIPT" snapshot)"
rm "$r5/beta.txt"
err5="$WORK/err05.txt"
(cd "$r5" && "$SCRIPT" verify "$fp5" >/dev/null 2>"$err5"); rc5=$?
assert_eq "(5) deleted tracked file -> exit 2" "2" "$rc5"
assert_eq "(5) stderr names the deleted file (beta.txt)" "true" \
  "$(grep -q 'beta\.txt' "$err5" && echo true || echo false)"

# ===================================================================================
# Scenario 6: HEAD moved (new commit) after snapshot, worktree left clean -> exit 2.
# Status and diff are both empty here, so only component (a) can catch it.
# mutation-honesty: kills a mutant that drops the HEAD commit id from the
# fingerprint, blind to an adversary committing its mutation.
# ===================================================================================
r6="$(new_repo s06)"
fp6="$(cd "$r6" && "$SCRIPT" snapshot)"
git -C "$r6" commit -q --allow-empty -m "adversary moved HEAD"
err6="$WORK/err06.txt"
(cd "$r6" && "$SCRIPT" verify "$fp6" >/dev/null 2>"$err6"); rc6=$?
assert_eq "(6) HEAD moved by a new commit -> exit 2" "2" "$rc6"
assert_eq "(6) stderr reports the current HEAD" "true" \
  "$(grep -q 'HEAD now:' "$err6" && echo true || echo false)"

# ===================================================================================
# Scenario 7: edit-then-exact-restore between snapshot and verify -> exit 0. THIS IS
# THE DISCLOSED TRANSIENT LIMITATION, pinned on purpose: the fingerprint is
# state-based, compared at two points in time — a write exactly reverted before
# verify is invisible to it. The gate-matrix contract's prohibition (bench members
# never write ANY tracked path, even transiently) covers this case; the guard
# detects residue, it does not replace the rule. This scenario documents the honest
# boundary of the instrument rather than pretending it detects the undetectable.
# mutation-honesty: kills a mutant that fingerprints volatile metadata (mtimes,
# inode/stat info) and false-positives on content-identical trees, which would
# make the guard cry wolf and get routed around.
# ===================================================================================
r7="$(new_repo s07)"
fp7="$(cd "$r7" && "$SCRIPT" snapshot)"
printf 'alpha transiently mutated\n' > "$r7/alpha.txt"
printf 'alpha v1\n' > "$r7/alpha.txt"   # exact byte-for-byte restore
(cd "$r7" && "$SCRIPT" verify "$fp7" >/dev/null 2>&1); rc7=$?
assert_eq "(7) edit-then-exact-restore -> exit 0 (disclosed limitation: state-based fingerprint; the contract's prohibition covers the transient case)" "0" "$rc7"

# ===================================================================================
# Scenario 8: untracked file CONTENT change — same name, same size, different bytes,
# present at snapshot time and at verify time -> exit 2. `git status --porcelain`
# output is byte-identical in both states (?? probe.txt), so only component (d)
# (per-file content hashing of untracked files) can catch this.
# mutation-honesty: kills a mutant that fingerprints untracked files by status
# listing alone and skips hashing their bytes.
# ===================================================================================
r8="$(new_repo s08)"
printf 'AAAA\n' > "$r8/probe.txt"
fp8="$(cd "$r8" && "$SCRIPT" snapshot)"
printf 'BBBB\n' > "$r8/probe.txt"   # same path, same length, different bytes
err8="$WORK/err08.txt"
(cd "$r8" && "$SCRIPT" verify "$fp8" >/dev/null 2>"$err8"); rc8=$?
assert_eq "(8) untracked same-name different-bytes swap -> exit 2" "2" "$rc8"
assert_eq "(8) stderr names the untracked path (probe.txt)" "true" \
  "$(grep -q 'probe\.txt' "$err8" && echo true || echo false)"

# ===================================================================================
# Scenario 9: malformed fingerprint argument (right prefix, garbage body) -> exit 2,
# loud stderr, never a comparison against garbage.
# mutation-honesty: kills a mutant that string-compares whatever it is handed and
# exits 0 only by luck, or worse, treats an unparseable arg as "no baseline, pass".
# ===================================================================================
r9="$(new_repo s09)"
err9="$WORK/err09.txt"
(cd "$r9" && "$SCRIPT" verify "gadd-bench-fp-v1:not-64-hex" >/dev/null 2>"$err9"); rc9=$?
assert_eq "(9) malformed fingerprint body -> exit 2" "2" "$rc9"
assert_eq "(9) stderr says malformed, loudly" "true" \
  "$(grep -q 'malformed fingerprint' "$err9" && echo true || echo false)"

# ===================================================================================
# Scenario 10: wrong version prefix (gadd-bench-fp-v0, well-formed hex body) ->
# exit 2. A fingerprint from another scheme version must never be compared as if
# it were v1.
# mutation-honesty: kills a mutant that ignores the prefix and compares hex bodies
# across incompatible fingerprint schemes.
# ===================================================================================
r10="$(new_repo s10)"
err10="$WORK/err10.txt"
zeros64="$(printf '0%.0s' $(seq 1 64))"
(cd "$r10" && "$SCRIPT" verify "gadd-bench-fp-v0:$zeros64" >/dev/null 2>"$err10"); rc10=$?
assert_eq "(10) wrong version prefix -> exit 2" "2" "$rc10"
assert_eq "(10) stderr names the version-prefix problem" "true" \
  "$(grep -q 'version prefix' "$err10" && echo true || echo false)"

# ===================================================================================
# Scenario 11: missing argument and unknown subcommand -> exit 2 each, loud stderr.
# Every non-identical outcome is exit 2 — never 0, never silent.
# mutation-honesty: kills a mutant whose argument parsing falls through to exit 0
# (bash default last-command status) on unexpected invocations.
# ===================================================================================
r11="$(new_repo s11)"
err11a="$WORK/err11a.txt"
(cd "$r11" && "$SCRIPT" verify >/dev/null 2>"$err11a"); rc11a=$?
assert_eq "(11) verify with no fingerprint argument -> exit 2" "2" "$rc11a"
assert_eq "(11) missing-arg stderr is loud, not silent" "true" \
  "$(grep -q '\[bench-tree-guard\]' "$err11a" && echo true || echo false)"
err11b="$WORK/err11b.txt"
(cd "$r11" && "$SCRIPT" frobnicate >/dev/null 2>"$err11b"); rc11b=$?
assert_eq "(11) unknown subcommand -> exit 2" "2" "$rc11b"
err11c="$WORK/err11c.txt"
(cd "$r11" && "$SCRIPT" >/dev/null 2>"$err11c"); rc11c=$?
assert_eq "(11) no subcommand at all -> exit 2" "2" "$rc11c"

# ===================================================================================
# Scenario 12: run outside any git repository -> exit 2 for both subcommands, loud
# CANNOT MEASURE stderr. Fail-closed: an unmeasurable tree is never "unchanged".
# mutation-honesty: kills a mutant that hashes empty git output as a valid
# fingerprint of nothing and happily verifies it.
# ===================================================================================
nonrepo="$WORK/not-a-repo"
mkdir -p "$nonrepo"
err12a="$WORK/err12a.txt"
(cd "$nonrepo" && "$SCRIPT" snapshot >/dev/null 2>"$err12a"); rc12a=$?
assert_eq "(12) snapshot outside a git repo -> exit 2" "2" "$rc12a"
assert_eq "(12) snapshot failure stderr says CANNOT MEASURE" "true" \
  "$(grep -q 'CANNOT MEASURE' "$err12a" && echo true || echo false)"
(cd "$nonrepo" && "$SCRIPT" verify "$fp1" >/dev/null 2>&1); rc12b=$?
assert_eq "(12) verify outside a git repo -> exit 2 (never a lucky match)" "2" "$rc12b"

# ===================================================================================
# Scenario 13: determinism — two snapshots on an unchanged tree (including an
# untracked file, exercising the sorted null-safe hashing path) are byte-identical.
# mutation-honesty: kills a mutant with unstable iteration order or an unpinned
# locale, whose fingerprint flaps on identical trees and voids honest rounds.
# ===================================================================================
r13="$(new_repo s13)"
printf 'untracked but stable\n' > "$r13/stable.txt"
snap13a="$(cd "$r13" && "$SCRIPT" snapshot)"
snap13b="$(cd "$r13" && "$SCRIPT" snapshot)"
assert_eq "(13) two snapshots on an unchanged tree are byte-identical" "$snap13a" "$snap13b"
(cd "$r13" && "$SCRIPT" verify "$snap13a" >/dev/null 2>&1); rc13=$?
assert_eq "(13) verify against either snapshot -> exit 0" "0" "$rc13"

# ===================================================================================
# Mutation-bite receipt (executed, on a SCRATCH COPY only — per the very discipline
# this corpus instruments): copy the guard to a scratch path, break the comparison
# there (`[ "$current" = "$expected" ]` -> `true`) so the mutant's verify always
# reports OK, then replay scenario 2 (unstaged tracked edit) against the mutant.
# The mutant must exit 0 where the real guard exits 2 — proving scenario 2 of this
# suite would catch that mutant, i.e. the comparison is load-bearing. The tracked
# bin/bench-tree-guard.sh is never touched.
# ===================================================================================
echo ""
echo "--- mutation-bite receipt: verify comparison stripped in a scratch copy ---"
mutant="$WORK/bench-tree-guard.mutant.sh"
cp "$SCRIPT" "$mutant"
chmod +x "$mutant"
sed -i.bak 's/if \[ "\$current" = "\$expected" \]; then/if true; then/' "$mutant"
rm -f "$mutant.bak"
assert_eq "(M) mutant differs from the real guard (sed took effect on the scratch copy)" "false" \
  "$(cmp -s "$SCRIPT" "$mutant" && echo true || echo false)"
rM="$(new_repo sM)"
fpM="$(cd "$rM" && "$mutant" snapshot)"
printf 'alpha MUTATED\n' > "$rM/alpha.txt"
(cd "$rM" && "$mutant" verify "$fpM" >/dev/null 2>&1); rcM_mut=$?
(cd "$rM" && "$SCRIPT" verify "$fpM" >/dev/null 2>&1); rcM_real=$?
assert_eq "(M) comparison-stripped mutant reports OK (exit 0) on a mutated tree — fail-open reproduced on the scratch copy" "0" "$rcM_mut"
assert_eq "(M) real guard exits 2 on the same mutated tree — scenario 2 kills this mutant; the comparison is load-bearing" "2" "$rcM_real"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
