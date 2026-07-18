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
# Bench repair round 1 additions (additive only — scenarios 1-13 and the
# mutation-bite receipt above are untouched). Scenarios 14-20 pin the two r1
# blockers (staged-index content, ignored-path residue) and the r1 notes
# (non-regular-file safety, git-env neutralization).
# ===================================================================================

# ===================================================================================
# Scenario 14: EXACT DATA_INTEGRITY r1 repro — poisoned index behind a restored
# worktree. Baseline: stage v3 of alpha.txt, restore the worktree to HEAD content
# (status "MM", worktree diff empty), snapshot. Adversary: swap the STAGED content
# to v4 and restore the worktree again — status flags and worktree diff are
# byte-identical to the baseline; only index-vs-HEAD content differs. verify must
# exit 2. Pre-fix this exited 0 (the hole).
# mutation-honesty: kills a mutant that drops component (d) (`git diff --cached
# --binary`) from the fingerprint, blind to index-content swaps.
# ===================================================================================
r14="$(new_repo s14)"
printf 'v3-poison\n' > "$r14/alpha.txt"
git -C "$r14" add alpha.txt
printf 'alpha v1\n' > "$r14/alpha.txt"   # worktree restored to HEAD content
fp14="$(cd "$r14" && "$SCRIPT" snapshot)"
printf 'v4-poison\n' > "$r14/alpha.txt"
git -C "$r14" add alpha.txt
printf 'alpha v1\n' > "$r14/alpha.txt"   # worktree restored again — same status, same worktree diff
err14="$WORK/err14.txt"
(cd "$r14" && "$SCRIPT" verify "$fp14" >/dev/null 2>"$err14"); rc14=$?
assert_eq "(14) staged-content swap behind restored worktree -> exit 2 (DI r1 blocker)" "2" "$rc14"
assert_eq "(14) stderr names the poisoned path (alpha.txt)" "true" \
  "$(grep -q 'alpha\.txt' "$err14" && echo true || echo false)"

# ===================================================================================
# Scenario 15: ignored-file dropping (SECURITY r1 repro) — .gitignore'd path
# appears after snapshot. Committed .gitignore covers secret-*; the dropping is
# invisible to status and to exclude-honoring enumeration, so only component (e)
# (no-exclude enumeration) can catch it. verify must exit 2. Pre-fix exited 0.
# mutation-honesty: kills a mutant that restores --exclude-standard to the
# untracked enumeration, re-opening the ignored-residue blind spot.
# ===================================================================================
r15="$(new_repo s15)"
printf 'secret-*\n' > "$r15/.gitignore"
git -C "$r15" add .gitignore
git -C "$r15" commit -q -m "add ignore rule"
fp15="$(cd "$r15" && "$SCRIPT" snapshot)"
printf 'adversary droppings\n' > "$r15/secret-residue.txt"
err15="$WORK/err15.txt"
(cd "$r15" && "$SCRIPT" verify "$fp15" >/dev/null 2>"$err15"); rc15=$?
assert_eq "(15) ignored-file dropping -> exit 2 (SECURITY r1 blocker)" "2" "$rc15"
assert_eq "(15) stderr names the ignored dropping (secret-residue.txt)" "true" \
  "$(grep -q 'secret-residue\.txt' "$err15" && echo true || echo false)"

# ===================================================================================
# Scenario 16: ignored-file CONTENT change — ignored file present at snapshot time
# and at verify time, same name, different bytes. Status output is identical in
# both states (empty — the file is ignored), so only per-file hashing of the
# no-exclude enumeration can catch it. verify must exit 2.
# mutation-honesty: kills a mutant that lists ignored paths but skips hashing
# their bytes (path-presence-only coverage).
# ===================================================================================
r16="$(new_repo s16)"
printf 'secret-*\n' > "$r16/.gitignore"
git -C "$r16" add .gitignore
git -C "$r16" commit -q -m "add ignore rule"
printf 'payload v1\n' > "$r16/secret-cache.txt"
fp16="$(cd "$r16" && "$SCRIPT" snapshot)"
printf 'payload v2\n' > "$r16/secret-cache.txt"
err16="$WORK/err16.txt"
(cd "$r16" && "$SCRIPT" verify "$fp16" >/dev/null 2>"$err16"); rc16=$?
assert_eq "(16) ignored-file content change -> exit 2" "2" "$rc16"

# ===================================================================================
# Scenario 17: exclude pattern planted in .git/info/exclude, then a matching
# dropping. Planting an exclude is the adversary's cloaking move — status and any
# exclude-honoring enumeration go blind, but component (e) consults no excludes
# at all, so the dropping is still hashed. verify must exit 2.
# mutation-honesty: kills a mutant that enumerates with any exclude source
# honored (.gitignore, info/exclude, core.excludesFile) — a plantable cloak.
# ===================================================================================
r17="$(new_repo s17)"
fp17="$(cd "$r17" && "$SCRIPT" snapshot)"
printf 'covert-*\n' >> "$r17/.git/info/exclude"
printf 'cloaked droppings\n' > "$r17/covert-drop.txt"
err17="$WORK/err17.txt"
(cd "$r17" && "$SCRIPT" verify "$fp17" >/dev/null 2>"$err17"); rc17=$?
assert_eq "(17) info/exclude-cloaked dropping -> exit 2" "2" "$rc17"
assert_eq "(17) stderr names the cloaked dropping (covert-drop.txt)" "true" \
  "$(grep -q 'covert-drop\.txt' "$err17" && echo true || echo false)"

# ===================================================================================
# Scenario 18: untracked FIFO present -> NO HANG, deterministic result. Documented
# outcome: exit 0 — git itself never enumerates non-regular files (`ls-files -o`
# skips FIFOs/sockets/devices; verified empirically), so the guard never sees and
# NEVER OPENS the FIFO; its presence is invisible to any git-based fingerprint
# (disclosed limitation in the instrument header). The load-bearing assertion is
# that verify RETURNS — a guard that opened the FIFO would block forever on a
# reader-less pipe. Run with a watchdog so a hang fails the suite instead of
# wedging it.
# mutation-honesty: kills a mutant that stats/opens every enumerated OR
# hand-globbed path without a regular-file check (the hang class).
# ===================================================================================
r18="$(new_repo s18)"
fp18="$(cd "$r18" && "$SCRIPT" snapshot)"
mkfifo "$r18/pipe1"
(cd "$r18" && "$SCRIPT" verify "$fp18" >/dev/null 2>&1) &
pid18=$!
rc18=124
for _ in $(seq 1 50); do
  kill -0 "$pid18" 2>/dev/null || { wait "$pid18"; rc18=$?; break; }
  sleep 0.2
done
if [ "$rc18" = "124" ]; then
  kill -9 "$pid18" 2>/dev/null || true
  wait "$pid18" 2>/dev/null || true
fi
assert_eq "(18) untracked FIFO -> no hang, deterministic exit 0 (git never enumerates non-regular files; guard never opens them — disclosed)" "0" "$rc18"

# ===================================================================================
# Scenario 19: untracked symlink retarget — link present at snapshot pointing at
# alpha.txt, retargeted to beta.txt before verify. The guard hashes the TARGET
# STRING (readlink), never the referent's content (no follow — a link into a
# moving target or a FIFO must not be opened), so the retarget is caught even
# though the link's own status listing (?? link1) is unchanged. verify must
# exit 2.
# mutation-honesty: kills a mutant that hashes symlinks by opening them (follows
# into referents — wrong substrate and a hang/traversal risk) or skips them.
# ===================================================================================
r19="$(new_repo s19)"
ln -s alpha.txt "$r19/link1"
fp19="$(cd "$r19" && "$SCRIPT" snapshot)"
rm "$r19/link1"
ln -s beta.txt "$r19/link1"
err19="$WORK/err19.txt"
(cd "$r19" && "$SCRIPT" verify "$fp19" >/dev/null 2>"$err19"); rc19=$?
assert_eq "(19) untracked symlink retarget -> exit 2" "2" "$rc19"
assert_eq "(19) stderr names the retargeted link (link1)" "true" \
  "$(grep -q 'link1' "$err19" && echo true || echo false)"

# ===================================================================================
# Scenario 20: GIT_INDEX_FILE poisoning neutralized — the guard unsets ALL
# inherited GIT_* env at startup, so a bogus GIT_INDEX_FILE must not redirect the
# measurement: a poisoned-env snapshot equals the clean snapshot byte-for-byte,
# and a poisoned-env verify against the clean fingerprint exits 0.
# mutation-honesty: kills a mutant that trusts inherited git environment — under
# which a caller-planted GIT_INDEX_FILE makes the guard fingerprint a phantom
# index (every git status/diff read lies) instead of the real repo.
# ===================================================================================
r20="$(new_repo s20)"
fp20="$(cd "$r20" && "$SCRIPT" snapshot)"
fp20p="$(cd "$r20" && GIT_INDEX_FILE="$WORK/bogus-index-does-not-exist" "$SCRIPT" snapshot)"
assert_eq "(20) snapshot under bogus GIT_INDEX_FILE == clean snapshot (env neutralized)" "$fp20" "$fp20p"
(cd "$r20" && GIT_INDEX_FILE="$WORK/bogus-index-does-not-exist" "$SCRIPT" verify "$fp20" >/dev/null 2>&1); rc20=$?
assert_eq "(20) verify under bogus GIT_INDEX_FILE -> exit 0 on the unchanged tree" "0" "$rc20"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
