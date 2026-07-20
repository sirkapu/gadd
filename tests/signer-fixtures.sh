#!/usr/bin/env bash
# tests/signer-fixtures.sh — acceptance corpus for the ACCEPT-SIGNER upgrade to
# adapters/lv/checks/02-lane-violation.sh (run #21, ratified design:
# audits/accept-signer-design-v1.md; operator's 3 answers + the Director-pinned
# interpretations in the run-21 mission brief). Style matches
# tests/failclosed-fixtures.sh: numbered scenarios, assert helpers, mktemp
# fixtures (real scratch git repos with throwaway ed25519 keys via ssh-keygen,
# self-contained, no network), PASS/FAIL per scenario, ALL-PASS summary line,
# non-zero exit on any failure. adapters/lv/checks/ is the source of truth
# (.gadd/checks/ in THIS repo is an installed, byte-identical copy).
#
# S11-S14 added in REPAIR ROUND 1 (RED_TEAM-demonstrated blockers against the
# original S1-S10 build; fixtures are append-only per tests/CLAUDE.md — none
# of S1-S10 were edited or removed, only the underlying check-02 logic they
# exercise was hardened):
#   BLOCKER 1 (SECURITY + DATA_INTEGRITY): the enrolled per-commit loop only
#     walked commits touching gadd/BASELINE.json, so a commit touching ONLY
#     gadd/allowed_signers inherited the "clean" exemption from an unrelated,
#     separate, passing gadd/BASELINE.json commit in the same range — full
#     accept-gate compromise on a fully-enrolled deployment. Fixed by walking
#     BOTH governed accept-files with one combined pathspec. S11a/S11b cover
#     the two demonstrated shapes.
#   BLOCKER 2 (REGRESSION): a fresh install's OWNERSHIP.md ships the
#     gadd/allowed_signers fence line unconditionally (item 2's real
#     template), even before any signer is enrolled — so "enroll later"
#     (no GADD_SIGNER_PUBKEY at install, then following the installer's own
#     printed steps) tripped the generic "Governed-side files were modified"
#     CRITICAL, because the old exemption required signers_base non-empty.
#     Fixed with a legacy-first-enrollment exemption. S12 covers it.
#   BLOCKER 3 (REGRESSION): GADD_SIGNER_PUBKEY given as a normal 3-field
#     ssh-keygen .pub file (keytype base64 comment) was misclassified as an
#     already-complete allowed_signers line by a field-count heuristic,
#     writing "ssh-ed25519" itself as the PRINCIPAL — every signed accept
#     then failed verify-commit while the installer printed success. Fixed
#     by classifying on the first token (a known SSH key type -> bare/.pub
#     key -> prepend $EMAIL) instead of field count. S13 covers it.
#   DATA_INTEGRITY note (non-blocking, folded in): a malformed (unparseable)
#     base gadd/BASELINE.json silently disabled the author factor (`jq ...
#     // empty` reads identically to "not set"). Fixed with an explicit
#     fail-closed CRITICAL when the base file exists but does not parse.
#     S14 covers it.
#
# S15-S18 added in RUN-24 (DI wrong-TYPE base guard, operator-ratified queue
# item, run-21 bench note): S14's parse-only guard (`jq -e .`) passed VALID
# JSON that was the WRONG TYPE — a top-level array/string/number, or an
# object whose .accept_authors was present but not an array of strings — and
# `.accept_authors[]? // empty` then silently read as "not set", degrading
# the author factor with no disclosure (a fail-open). Folded into the same
# base_baseline_malformed fail-closed branch as S14 (naming the specific type
# violation) rather than a parallel path. S15 covers a top-level-array base;
# S16 covers a wrong-type .accept_authors (string); S17 guards the UNCHANGED
# path (.accept_authors absent) so the fix stays monotonic — no existing red
# flips green. S18 (REPAIR ROUND 1, TEST_HONESTY blocker) covers the
# array-MEMBER type check: a mixed-type .accept_authors array (a valid string
# alongside a non-string member) — S16 alone left the code's `all` check
# mutable to `any` without any fixture catching it.
#
# S19-S21 added in RUN-28 (h3, ratified, wording-only monotonic tightening):
# `jq -e .`'s exit status tracks the TRUTHINESS of the last output value, not
# parse validity, so a base gadd/BASELINE.json whose content is valid JSON
# `null` or `false` exited nonzero at S14's parse guard and got the generic
# "does not parse" message instead of falling through to S15-S18's
# type-named branch. Both routes were already CRITICAL fail-closed — this is
# wording-only. S19 covers a `null` top level; S20 covers a `false` top
# level (same class as `true`, jq's type name for both is "boolean"); S21
# pins the adjacent empty-stream edge the fix must not regress: a
# whitespace-only base file (jq -e . exits 4, no output at all — distinct
# from exit 1 on a parsed null/false) must still land on the "does not
# parse" wording, never a type-named message with an empty type.
#
# Scenarios (S1-S10, see run-21 mission brief for the full spec):
#   S1  enrolled + signed + allowlisted accept -> no findings (PASS)
#   S2  enrolled + unsigned --author spoof replay -> CRITICAL (signature factor)
#   S3  enrolled + foreign-key signed + spoofed allowlisted email -> CRITICAL
#       (principal match fails even on a valid foreign signature)
#   S4  same-push self-enrollment (attacker appends own pubkey to HEAD signers,
#       signs with it; base signers lack it) -> CRITICAL (base-pinned anchor
#       holds — "the placement IS the fix", no extra code needed beyond
#       reading the anchor from GADD_BASE)
#   S5  base signers non-empty, head signers (a) emptied (b) deleted ->
#       CRITICAL both (ratchet rule: only-tightens, a STATE comparison)
#   S6  legacy, accept_authors set, unsigned accept -> exactly one MINOR
#       nudge, gate-level PASS (verified via run-all.sh)
#   S7  legacy, accept_authors unset, head lacks signers -> MAJOR escalated
#       nudge (SR-8 reading: the existing nudge escalates MINOR->MAJOR)
#   S8  genesis push (accept_authors unset, head ADDS signers) -> MINOR only,
#       no MAJOR (enrollment in flight — the pre-existing legacy window one
#       last time, not a new one; base's OWNERSHIP fence does not yet govern
#       gadd/allowed_signers at the moment it is created, mirroring the
#       design's migration step 2)
#   S9  git<2.34 with base signers present -> CRITICAL fail-closed (a PATH
#       shim fakes `git version` output only, execs the real git otherwise;
#       the underlying commit IS validly signed — proves the gate refuses to
#       even attempt verify-commit rather than silently skipping enforcement)
#   S10 rotation add-new-then-remove-old across two signed accepts -> PASS
#       (each push is its own base-pinned check: push 1's accept is signed
#       with the OLD key, still valid against the pre-rotation base; push 2's
#       accept is signed with the NEW key, valid against push 1's accepted
#       base which by then has both keys)
#
# BOTH-DIRECTION RECEIPT (mandatory, Major tier): S2, S3, S4, S5, S7 are also
# run against the PRE-upgrade check-02 (git show 44f09ed:adapters/lv/checks/
# 02-lane-violation.sh into a scratch copy) to demonstrate the old check
# PASSES every one of them (the red run) — a summary table is printed at the
# end. S4 and S5 need their OWN scratch repos for the red run: the OLD check
# has no concept of gadd/allowed_signers at all, so whether it flags a change
# to that path depends entirely on whether the deployment's OWNERSHIP fence
# already lists it — and pre-this-build, no deployment's fence does yet (the
# fence line ships in THIS build, item 2). Using a fence that lists it against
# the old check would test something that never existed; the red-run repos
# faithfully omit the line, matching the actual pre-upgrade world. S2, S3, S7
# never touch gadd/allowed_signers, so their existing repos are reused as-is.
#
# RUN_ALL / LIB_COMMON / CHECK02 / OLD_CHECK02_REF are overridable via env —
# used at receipt time to re-run this exact corpus against different script
# paths; the committed default always targets the current, upgraded scripts.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUN_ALL="${RUN_ALL:-$REPO_ROOT/adapters/lv/checks/run-all.sh}"
LIB_COMMON="${LIB_COMMON:-$REPO_ROOT/adapters/lv/checks/lib/common.sh}"
CHECK02="${CHECK02:-$REPO_ROOT/adapters/lv/checks/02-lane-violation.sh}"
OLD_CHECK02_REF="${OLD_CHECK02_REF:-44f09ed}"

WORK="$(mktemp -d)"
OUT="$(mktemp -d)"   # stdout/stderr/findings land here — kept OUTSIDE $WORK so
                      # fixture repos stay exactly what each scenario built.
KEYDIR="$WORK/keys"; mkdir -p "$KEYDIR"

cleanup() {
  chmod -R u+rwx "$WORK" 2>/dev/null || true
  rm -rf "$WORK" "$OUT" 2>/dev/null || true
}
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
  if [ "$2" = "$3" ]; then pass "$1"; else fail "$1" "expected [$2] got [$3]"; fi
}

# assert_zero NAME EXIT_CODE
assert_zero() {
  if [ "$2" -eq 0 ] 2>/dev/null; then pass "$1"; else fail "$1" "expected exit 0, got [$2]"; fi
}

# assert_ndjson_finding NAME FILE CHECK SEVERITY MSG_SUBSTR -> pass if a raw
# NDJSON findings stream (one bare JSON object per line — the shape a check's
# own GADD_FINDINGS output takes when invoked directly) contains a matching entry.
assert_ndjson_finding() {
  local name="$1" file="$2" c="$3" s="$4" m="$5"
  if jq -s -e --arg c "$c" --arg s "$s" --arg m "$m" \
       '[.[] | select(.check==$c and .severity==$s and (.message|contains($m)))] | length > 0' \
       "$file" >/dev/null 2>&1; then
    pass "$name"
  else
    fail "$name" "no matching NDJSON finding in: $(cat "$file" 2>/dev/null | tr -d '\n' | cut -c1-300)"
  fi
}

# assert_ndjson_no_finding NAME FILE CHECK -> pass if no NDJSON line has this
# check name, regardless of severity.
assert_ndjson_no_finding() {
  local name="$1" file="$2" c="$3"
  if jq -s -e --arg c "$c" '[.[] | select(.check==$c)] | length == 0' "$file" >/dev/null 2>&1; then
    pass "$name"
  else
    fail "$name" "unexpected NDJSON finding(s) for check=$c present: $(cat "$file" 2>/dev/null | tr -d '\n' | cut -c1-300)"
  fi
}

# assert_ndjson_no_finding_sev NAME FILE CHECK SEVERITY -> pass if no NDJSON
# line has this check+severity pair (a finer sibling of assert_ndjson_no_finding
# for scenarios that expect one severity present and another explicitly absent).
assert_ndjson_no_finding_sev() {
  local name="$1" file="$2" c="$3" s="$4"
  if jq -s -e --arg c "$c" --arg s "$s" '[.[] | select(.check==$c and .severity==$s)] | length == 0' \
       "$file" >/dev/null 2>&1; then
    pass "$name"
  else
    fail "$name" "unexpected $c/$s finding present: $(cat "$file" 2>/dev/null | tr -d '\n' | cut -c1-300)"
  fi
}

# ===================================================================================
# Fixture helpers
# ===================================================================================

# gen_key NAME -> generates a throwaway ed25519 keypair under $KEYDIR/NAME
# (passphrase-less, scratch-only). Echoes the path to the PUBLIC key file.
gen_key() {
  local name="$1"
  ssh-keygen -t ed25519 -N "" -f "$KEYDIR/$name" -q >/dev/null 2>&1
  printf '%s\n' "$KEYDIR/$name.pub"
}

# mk_signer_repo DIR ACCEPT_AUTHORS_JSON WITH_SIGNERS_LINE(0|1) -> git-inits DIR
# with gadd/BASELINE.json (accept_authors=ACCEPT_AUTHORS_JSON) and an
# OWNERSHIP.md whose gadd-governed fence always lists gadd/BASELINE.json, and
# ALSO gadd/allowed_signers when WITH_SIGNERS_LINE=1 (the post-genesis /
# fresh-deployment-template state) — omitted when 0 (the pre-genesis /
# pre-this-build state, per the design's migration step 2 and the red-run
# rationale above).
mk_signer_repo() {
  local dir="$1" authors="$2" withline="$3"
  mkdir -p "$dir/gadd"
  ( cd "$dir" && git init -q && git config user.email t@test.local && git config user.name t )
  cat > "$dir/gadd/BASELINE.json" <<EOF
{"accepted_sha":"0000000000000000000000000000000000000000","accept_authors":$authors,"metrics":{}}
EOF
  if [ "$withline" = "1" ]; then
    cat > "$dir/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
  else
    cat > "$dir/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
```
EOF
  fi
  ( cd "$dir" && git add -A && git commit -q -m init ) >/dev/null
}

# accept_commit DIR MSG EMAIL [SIGNINGKEY_PUB_PATH] -> stages whatever
# working-tree changes already exist in DIR and commits with subject MSG,
# author/committer email EMAIL. Signs with SIGNINGKEY_PUB_PATH (ssh format)
# when given; commits --no-gpg-sign otherwise. Echoes the new commit's SHA.
accept_commit() {
  local dir="$1" msg="$2" email="$3" key="${4:-}"
  (
    cd "$dir"
    git add -A
    if [ -n "$key" ]; then
      git config gpg.format ssh
      git config user.signingkey "$key"
      GIT_AUTHOR_EMAIL="$email" GIT_COMMITTER_EMAIL="$email" GIT_AUTHOR_NAME=t GIT_COMMITTER_NAME=t \
        git commit -q -S -m "$msg"
    else
      git config --unset gpg.format 2>/dev/null || true
      GIT_AUTHOR_EMAIL="$email" GIT_COMMITTER_EMAIL="$email" GIT_AUTHOR_NAME=t GIT_COMMITTER_NAME=t \
        git commit -q -m "$msg" --no-gpg-sign
    fi
  ) >/dev/null
  ( cd "$dir" && git rev-parse HEAD )
}

# bump_baseline DIR SHA -> rewrites gadd/BASELINE.json's accepted_sha field
# in-place (the accept dance). Working-tree only; caller commits afterwards.
bump_baseline() {
  local dir="$1" sha="$2"
  jq --arg sha "$sha" '.accepted_sha=$sha' "$dir/gadd/BASELINE.json" > "$dir/BASELINE.json.tmp"
  mv "$dir/BASELINE.json.tmp" "$dir/gadd/BASELINE.json"
}

# mk_enrolled_repo DIR ACCEPT_AUTHORS_JSON KEYNAME EMAIL [WITH_SIGNERS_LINE(1)] ->
# mk_signer_repo + a genesis accept commit that creates gadd/allowed_signers
# with KEYNAME's pubkey allowlisting EMAIL, signed by KEYNAME. Echoes the
# genesis commit's SHA (the enrolled base for subsequent scenario commits).
mk_enrolled_repo() {
  local dir="$1" authors="$2" keyname="$3" email="$4" withline="${5:-1}"
  mk_signer_repo "$dir" "$authors" "$withline"
  local key; key="$(gen_key "$keyname")"
  printf '%s\n' "$email $(cat "$key")" > "$dir/gadd/allowed_signers"
  bump_baseline "$dir" "genesis-placeholder"
  accept_commit "$dir" "gadd: accept genesis" "$email" "$key"
}

# run_a_check SCRIPT PREFIX DIR BASE HEAD [PATH_PREFIX] -> runs SCRIPT with
# cwd=DIR and explicit GADD_BASE/GADD_HEAD/GADD_FINDINGS. When PATH_PREFIX is
# given, it is prepended to PATH for the run (used by S9's git-version shim).
# Writes stdout/stderr/findings to $OUT/<prefix>.*. Echoes the exit code.
run_a_check() {
  local script="$1" prefix="$2" dir="$3" base="$4" head="$5" pathprefix="${6:-}"
  local findings="$OUT/$prefix.findings.ndjson"
  : > "$findings"
  (
    cd "$dir" || exit 99
    export GADD_BASE="$base"
    export GADD_HEAD="$head"
    export GADD_FINDINGS="$findings"
    [ -n "$pathprefix" ] && export PATH="$pathprefix:$PATH"
    bash "$script"
  ) >"$OUT/$prefix.stdout" 2>"$OUT/$prefix.stderr"
  echo $?
}
run_check02()     { run_a_check "$CHECK02"     "$@"; }
run_old_check02() { run_a_check "$OLD_CHECK02" "$@"; }

# install_scratch_gate DIR -> installs run-all.sh + lib/common.sh + the
# CURRENT (upgraded) check02 as .gadd/checks/02-lane-violation.sh under DIR,
# so run-all.sh's verdict aggregation (MINOR count / MAJOR-or-CRITICAL ->
# FAIL) can be exercised end to end (used by S6's gate-level PASS assertion).
install_scratch_gate() {
  local dir="$1"
  mkdir -p "$dir/.gadd/checks/lib"
  cp "$RUN_ALL" "$dir/.gadd/checks/run-all.sh"
  cp "$LIB_COMMON" "$dir/.gadd/checks/lib/common.sh"
  cp "$CHECK02" "$dir/.gadd/checks/02-lane-violation.sh"
  chmod +x "$dir/.gadd/checks/run-all.sh" "$dir/.gadd/checks/02-lane-violation.sh"
}

# git<2.34 PATH shim (S9): fakes `git version`'s output only; execs the real
# git for every other subcommand.
FAKEBIN="$WORK/fakebin"; mkdir -p "$FAKEBIN"
REAL_GIT="$(command -v git)"
cat > "$FAKEBIN/git" <<EOF
#!/usr/bin/env bash
if [ "\$1" = "version" ]; then
  echo "git version 2.30.0"
  exit 0
fi
exec "$REAL_GIT" "\$@"
EOF
chmod +x "$FAKEBIN/git"

# Extract the PRE-upgrade check-02 (+ its then-current lib/common.sh, which
# this build does not touch) for the both-direction red-run receipt.
OLDDIR="$OUT/oldcheck"; mkdir -p "$OLDDIR/lib"
if ! git -C "$REPO_ROOT" show "$OLD_CHECK02_REF:adapters/lv/checks/02-lane-violation.sh" > "$OLDDIR/02-lane-violation.sh" \
    || [ ! -s "$OLDDIR/02-lane-violation.sh" ]; then
  echo "FATAL: cannot extract pre-upgrade check-02 at $OLD_CHECK02_REF — history unavailable (shallow clone?); red-run receipts cannot run" >&2
  exit 1
fi
cp "$LIB_COMMON" "$OLDDIR/lib/common.sh"
OLD_CHECK02="$OLDDIR/02-lane-violation.sh"

# ===================================================================================
# S1: enrolled + signed + allowlisted accept -> no findings (PASS)
# ===================================================================================
r1="$WORK/s01"
GEN1="$(mk_enrolled_repo "$r1" '["accept@test.local"]' key1 "accept@test.local")"
KEY1="$KEYDIR/key1.pub"
bump_baseline "$r1" "s1head"
HEAD1="$(accept_commit "$r1" "gadd: accept s1" "accept@test.local" "$KEY1")"
rc="$(run_check02 s01 "$r1" "$GEN1" "$HEAD1")"
assert_zero "(S1) enrolled+signed+allowlisted accept -> exit 0" "$rc"
assert_ndjson_no_finding "(S1) enrolled+signed+allowlisted accept -> no lane-violation findings (PASS)" \
  "$OUT/s01.findings.ndjson" "lane-violation"

# ===================================================================================
# S2: enrolled + unsigned --author spoof replay -> CRITICAL (signature factor)
# ===================================================================================
r2="$WORK/s02"
GEN2="$(mk_enrolled_repo "$r2" '["accept@test.local"]' key2 "accept@test.local")"
bump_baseline "$r2" "s2head"
HEAD2="$(accept_commit "$r2" "gadd: accept s2 spoof" "accept@test.local" "")"
rc="$(run_check02 s02 "$r2" "$GEN2" "$HEAD2")"
assert_zero "(S2) exit 0 (finding recorded, not a crash)" "$rc"
assert_ndjson_finding "(S2) enrolled + unsigned author-spoof replay -> CRITICAL (factor: signature)" \
  "$OUT/s02.findings.ndjson" "lane-violation" "CRITICAL" "factor: signature"

# ===================================================================================
# S3: enrolled + foreign-key signed + spoofed allowlisted email -> CRITICAL
# (principal match fails even on a valid foreign signature)
# ===================================================================================
r3="$WORK/s03"
GEN3="$(mk_enrolled_repo "$r3" '["accept@test.local"]' key3 "accept@test.local")"
FKEY3="$(gen_key key3-foreign)"
bump_baseline "$r3" "s3head"
HEAD3="$(accept_commit "$r3" "gadd: accept s3 foreign-key" "accept@test.local" "$FKEY3")"
rc="$(run_check02 s03 "$r3" "$GEN3" "$HEAD3")"
assert_zero "(S3) exit 0" "$rc"
assert_ndjson_finding "(S3) enrolled + foreign-key signed + spoofed allowlisted email -> CRITICAL (factor: signature)" \
  "$OUT/s03.findings.ndjson" "lane-violation" "CRITICAL" "factor: signature"

# ===================================================================================
# S4: same-push self-enrollment (attacker appends own pubkey to HEAD signers,
# signs with it; base signers lack it) -> CRITICAL (base-pinned anchor holds)
# ===================================================================================
r4="$WORK/s04"
GEN4="$(mk_enrolled_repo "$r4" '["accept@test.local"]' key4 "accept@test.local")"
AKEY4="$(gen_key key4-attacker)"
{ cat "$r4/gadd/allowed_signers"; printf '%s\n' "accept@test.local $(cat "$AKEY4")"; } > "$r4/allowed_signers.tmp"
mv "$r4/allowed_signers.tmp" "$r4/gadd/allowed_signers"
bump_baseline "$r4" "s4head"
HEAD4="$(accept_commit "$r4" "gadd: accept s4 self-enroll" "accept@test.local" "$AKEY4")"
rc="$(run_check02 s04 "$r4" "$GEN4" "$HEAD4")"
assert_zero "(S4) exit 0" "$rc"
assert_ndjson_finding "(S4) same-push self-enrollment -> CRITICAL (factor: signature, base-pinned anchor holds)" \
  "$OUT/s04.findings.ndjson" "lane-violation" "CRITICAL" "factor: signature"

# ===================================================================================
# S5: base signers non-empty, head signers (a) emptied (b) deleted -> CRITICAL both
# ===================================================================================
r5a="$WORK/s05a"
GEN5a="$(mk_enrolled_repo "$r5a" '["accept@test.local"]' key5a "accept@test.local")"
KEY5a="$KEYDIR/key5a.pub"
: > "$r5a/gadd/allowed_signers"
bump_baseline "$r5a" "s5ahead"
HEAD5a="$(accept_commit "$r5a" "gadd: accept s5a empties" "accept@test.local" "$KEY5a")"
rc="$(run_check02 s05a "$r5a" "$GEN5a" "$HEAD5a")"
assert_zero "(S5a) exit 0" "$rc"
assert_ndjson_finding "(S5a) base signers non-empty, head EMPTIED -> CRITICAL only-tightens" \
  "$OUT/s05a.findings.ndjson" "lane-violation" "CRITICAL" "only-tightens"

r5b="$WORK/s05b"
GEN5b="$(mk_enrolled_repo "$r5b" '["accept@test.local"]' key5b "accept@test.local")"
KEY5b="$KEYDIR/key5b.pub"
rm -f "$r5b/gadd/allowed_signers"
bump_baseline "$r5b" "s5bhead"
HEAD5b="$(accept_commit "$r5b" "gadd: accept s5b deletes" "accept@test.local" "$KEY5b")"
rc="$(run_check02 s05b "$r5b" "$GEN5b" "$HEAD5b")"
assert_zero "(S5b) exit 0" "$rc"
assert_ndjson_finding "(S5b) base signers non-empty, head DELETED -> CRITICAL only-tightens" \
  "$OUT/s05b.findings.ndjson" "lane-violation" "CRITICAL" "only-tightens"

# ===================================================================================
# S6: legacy, accept_authors set, unsigned accept -> exactly one MINOR nudge,
# gate-level PASS (verified via run-all.sh, not just the raw finding)
# ===================================================================================
r6="$WORK/s06"
mk_signer_repo "$r6" '["accept@test.local"]' 1
BASE6="$(cd "$r6" && git rev-parse HEAD)"
bump_baseline "$r6" "s6head"
HEAD6="$(accept_commit "$r6" "gadd: accept s6" "accept@test.local" "")"
install_scratch_gate "$r6"
(
  cd "$r6"
  export GADD_BASE="$BASE6" GADD_HEAD="$HEAD6"
  bash .gadd/checks/run-all.sh
) >"$OUT/s06.stdout" 2>"$OUT/s06.stderr"
assert_eq "(S6) legacy accept_authors-set unsigned accept -> verdict PASS" "PASS" \
  "$(jq -r '.verdict' "$OUT/s06.stdout" 2>/dev/null)"
assert_eq "(S6) exactly one MINOR lane-violation nudge" "1" \
  "$(jq '[.findings[]? | select(.check=="lane-violation" and .severity=="MINOR")] | length' "$OUT/s06.stdout" 2>/dev/null)"

# ===================================================================================
# S7: legacy, accept_authors unset, head lacks signers -> MAJOR escalated nudge
# ===================================================================================
r7="$WORK/s07"
mk_signer_repo "$r7" '[]' 1
BASE7="$(cd "$r7" && git rev-parse HEAD)"
bump_baseline "$r7" "s7head"
HEAD7="$(accept_commit "$r7" "gadd: accept s7" "accept@test.local" "")"
rc="$(run_check02 s07 "$r7" "$BASE7" "$HEAD7")"
assert_zero "(S7) exit 0" "$rc"
assert_ndjson_finding "(S7) legacy accept_authors-unset, head lacks signers -> MAJOR escalated nudge" \
  "$OUT/s07.findings.ndjson" "lane-violation" "MAJOR" "enroll a signer"

# ===================================================================================
# S8: genesis push (accept_authors unset, head ADDS signers) -> MINOR only, no
# MAJOR, no CRITICAL. Base fence deliberately does NOT yet govern
# gadd/allowed_signers (it is added in this very commit, per migration step 2).
# ===================================================================================
r8="$WORK/s08"
mk_signer_repo "$r8" '[]' 0
BASE8="$(cd "$r8" && git rev-parse HEAD)"
cat > "$r8/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
KEY8="$(gen_key key8)"
printf '%s\n' "someone@else.test $(cat "$KEY8")" > "$r8/gadd/allowed_signers"
bump_baseline "$r8" "s8head"
HEAD8="$(accept_commit "$r8" "gadd: accept s8 genesis" "accept@test.local" "")"
rc="$(run_check02 s08 "$r8" "$BASE8" "$HEAD8")"
assert_zero "(S8) exit 0" "$rc"
assert_ndjson_finding "(S8) genesis push -> MINOR nudge (enrollment in flight)" \
  "$OUT/s08.findings.ndjson" "lane-violation" "MINOR" "enrollment in flight"
assert_ndjson_no_finding_sev "(S8) genesis push -> no MAJOR" "$OUT/s08.findings.ndjson" "lane-violation" "MAJOR"
assert_ndjson_no_finding_sev "(S8) genesis push -> no CRITICAL" "$OUT/s08.findings.ndjson" "lane-violation" "CRITICAL"

# ===================================================================================
# S9: git<2.34 with base signers present -> CRITICAL fail-closed. The
# underlying commit IS validly signed — this proves the gate refuses to even
# attempt verify-commit under an old git, rather than silently skipping
# enforcement.
# ===================================================================================
r9="$WORK/s09"
GEN9="$(mk_enrolled_repo "$r9" '["accept@test.local"]' key9 "accept@test.local")"
KEY9="$KEYDIR/key9.pub"
bump_baseline "$r9" "s9head"
HEAD9="$(accept_commit "$r9" "gadd: accept s9" "accept@test.local" "$KEY9")"
rc="$(run_check02 s09 "$r9" "$GEN9" "$HEAD9" "$FAKEBIN")"
assert_zero "(S9) exit 0" "$rc"
assert_ndjson_finding "(S9) git<2.34 with base signers present -> CRITICAL fail-closed" \
  "$OUT/s09.findings.ndjson" "lane-violation" "CRITICAL" "git < 2.34"

# ===================================================================================
# S10: rotation add-new-then-remove-old across two signed accepts -> PASS.
# Each push is its own base-pinned check (two separate accept/advance cycles).
# ===================================================================================
r10="$WORK/s10"
GEN10="$(mk_enrolled_repo "$r10" '["accept@test.local"]' key10a "accept@test.local")"
KEY10A="$KEYDIR/key10a.pub"
KEY10B="$(gen_key key10b)"

# push 1: add key10b alongside key10a, signed with key10a (still valid vs GEN10)
{ cat "$r10/gadd/allowed_signers"; printf '%s\n' "accept@test.local $(cat "$KEY10B")"; } > "$r10/allowed_signers.tmp"
mv "$r10/allowed_signers.tmp" "$r10/gadd/allowed_signers"
bump_baseline "$r10" "s10push1"
PUSH1_10="$(accept_commit "$r10" "gadd: accept s10 push1 add key" "accept@test.local" "$KEY10A")"
rc="$(run_check02 s10push1 "$r10" "$GEN10" "$PUSH1_10")"
assert_zero "(S10 push1) exit 0" "$rc"
assert_ndjson_no_finding "(S10 push1) rotation add-new-key (old key still base-pinned-valid) -> PASS" \
  "$OUT/s10push1.findings.ndjson" "lane-violation"

# push 2: remove key10a, keep only key10b, signed with key10b (valid vs push1's
# accepted base, which by now has both keys)
printf '%s\n' "accept@test.local $(cat "$KEY10B")" > "$r10/gadd/allowed_signers"
bump_baseline "$r10" "s10push2"
PUSH2_10="$(accept_commit "$r10" "gadd: accept s10 push2 remove old key" "accept@test.local" "$KEY10B")"
rc="$(run_check02 s10push2 "$r10" "$PUSH1_10" "$PUSH2_10")"
assert_zero "(S10 push2) exit 0" "$rc"
assert_ndjson_no_finding "(S10 push2) rotation remove-old-key (new-key-pinned base) -> PASS" \
  "$OUT/s10push2.findings.ndjson" "lane-violation"

# ===================================================================================
# S11a (REPAIR ROUND 1, BLOCKER 1 — SECURITY): two commits in ONE range —
# a legit signed "gadd: accept" (touches gadd/BASELINE.json only) plus a
# SEPARATE unsigned attacker commit touching ONLY gadd/allowed_signers
# (appending an attacker pubkey under a foreign author). Pre-fix, the
# attacker commit was invisible to the per-commit loop (pathspec was
# gadd/BASELINE.json only) and inherited the legit commit's "clean"
# accept_bad=0 via the exemption -> zero findings, attacker key lands in the
# accepted base. Post-fix: CRITICAL (factor: subject, since the attacker's
# message never claims to be a "gadd: accept").
# ===================================================================================
r11a="$WORK/s11a"
GEN11a="$(mk_enrolled_repo "$r11a" '["accept@test.local"]' key11a "accept@test.local")"
KEY11A="$KEYDIR/key11a.pub"
bump_baseline "$r11a" "s11alegit"
accept_commit "$r11a" "gadd: accept s11a legit" "accept@test.local" "$KEY11A" >/dev/null
AKEY11A="$(gen_key key11a-attacker)"
{ cat "$r11a/gadd/allowed_signers"; printf '%s\n' "attacker@evil.test $(cat "$AKEY11A")"; } > "$r11a/allowed_signers.tmp"
mv "$r11a/allowed_signers.tmp" "$r11a/gadd/allowed_signers"
MAL11A="$(accept_commit "$r11a" "chore: rotate signer roster" "attacker@evil.test" "")"
rc="$(run_check02 s11a "$r11a" "$GEN11a" "$MAL11A")"
assert_zero "(S11a) exit 0" "$rc"
assert_ndjson_finding "(S11a) BLOCKER-1 SECURITY: legit signed accept + separate unsigned attacker commit touching only allowed_signers -> CRITICAL" \
  "$OUT/s11a.findings.ndjson" "lane-violation" "CRITICAL" "factor: subject"

# ===================================================================================
# S11b (REPAIR ROUND 1, BLOCKER 1 — DATA_INTEGRITY): base already enrolled
# and accepted from a PRIOR cycle (GADD_BASE = a prior legit signed accept);
# the CURRENT range contains a single unsigned attacker commit touching ONLY
# gadd/allowed_signers, with no gadd/BASELINE.json touch anywhere in range.
# The generic OWNERSHIP-fence fallback already caught this shape pre-fix
# (baseline_touched was empty, denying the old exemption) but only with the
# generic message; post-fix it is walked by the per-commit loop too and gets
# the specific factor-named CRITICAL as well.
# ===================================================================================
r11b="$WORK/s11b"
GEN11b="$(mk_enrolled_repo "$r11b" '["accept@test.local"]' key11b "accept@test.local")"
KEY11B="$KEYDIR/key11b.pub"
bump_baseline "$r11b" "s11blegit"
LEGIT11B="$(accept_commit "$r11b" "gadd: accept s11b legit" "accept@test.local" "$KEY11B")"
AKEY11B="$(gen_key key11b-attacker)"
{ cat "$r11b/gadd/allowed_signers"; printf '%s\n' "attacker@evil.test $(cat "$AKEY11B")"; } > "$r11b/allowed_signers.tmp"
mv "$r11b/allowed_signers.tmp" "$r11b/gadd/allowed_signers"
MAL11B="$(accept_commit "$r11b" "chore: rotate signer roster" "attacker@evil.test" "")"
rc="$(run_check02 s11b "$r11b" "$LEGIT11B" "$MAL11B")"
assert_zero "(S11b) exit 0" "$rc"
assert_ndjson_finding "(S11b) BLOCKER-1 DATA_INTEGRITY: single unsigned commit touching only allowed_signers, no baseline touch in range -> CRITICAL" \
  "$OUT/s11b.findings.ndjson" "lane-violation" "CRITICAL" "factor: subject"

# ===================================================================================
# S12 (REPAIR ROUND 1, BLOCKER 2): legacy deployment, "enroll later" — the
# base's OWNERSHIP fence ALREADY governs gadd/allowed_signers (the real
# fresh-install shape once the template ships the fence line
# unconditionally), but no signers file exists yet (signers_base empty).
# A valid legacy accept (correct subject, author allowlisted, unsigned — no
# base anchor exists yet to sign against) ADDS gadd/allowed_signers in the
# same commit that bumps gadd/BASELINE.json -> PASS, no findings at all
# (accept_authors is set and head now has signers, so neither legacy nudge
# bullet fires either).
# ===================================================================================
r12="$WORK/s12"
mk_signer_repo "$r12" '["accept@test.local"]' 1
BASE12="$(cd "$r12" && git rev-parse HEAD)"
KEY12="$(gen_key key12)"
printf '%s\n' "accept@test.local $(cat "$KEY12")" > "$r12/gadd/allowed_signers"
bump_baseline "$r12" "s12head"
HEAD12="$(accept_commit "$r12" "gadd: accept s12 enroll-later" "accept@test.local" "")"
rc="$(run_check02 s12 "$r12" "$BASE12" "$HEAD12")"
assert_zero "(S12) exit 0" "$rc"
assert_ndjson_no_finding "(S12) BLOCKER-2: legacy enroll-later (fence already governs allowed_signers, valid unsigned accept) -> PASS" \
  "$OUT/s12.findings.ndjson" "lane-violation"

# ===================================================================================
# S13 (REPAIR ROUND 1, BLOCKER 3): adapters/lv/bin/install.sh given a REAL
# ssh-keygen .pub file (3 fields: keytype, base64, comment) via
# GADD_SIGNER_PUBKEY. Must classify by the first token (a known SSH key
# type) and prepend git user.email as the principal, dropping the comment —
# NOT write the 3-field line verbatim (which would make "ssh-ed25519" itself
# the principal and brick every future verify-commit). A subsequent signed
# accept using that key must then verify cleanly.
# ===================================================================================
INSTALL_SH="${INSTALL_SH:-$REPO_ROOT/adapters/lv/bin/install.sh}"
r13="$WORK/s13"
mkdir -p "$r13"
( cd "$r13" && git init -q && git config user.email s13@test.local && git config user.name t && git commit -q --allow-empty -m init ) >/dev/null
KEY13="$(gen_key key13)"
FULL_PUB13="$(cat "$KEY13")"   # real ssh-keygen .pub: "keytype base64 comment" (3 fields)
(
  cd "$r13"
  GADD_SIGNER_PUBKEY="$FULL_PUB13" bash "$INSTALL_SH"
) >"$OUT/s13-install.stdout" 2>"$OUT/s13-install.stderr"
PRINCIPAL13="$(awk '{print $1}' "$r13/gadd/allowed_signers" 2>/dev/null)"
assert_eq "(S13) BLOCKER-3: installer classifies a 3-field .pub by first token -> principal is EMAIL, not the keytype" \
  "s13@test.local" "$PRINCIPAL13"

( cd "$r13" && git add -A && git commit -q -m "chore: install gadd-lv" ) >/dev/null
INSTALLED13="$(cd "$r13" && git rev-parse HEAD)"
bump_baseline "$r13" "s13head"
HEAD13="$(accept_commit "$r13" "gadd: accept s13" "s13@test.local" "$KEY13")"
rc="$(run_check02 s13 "$r13" "$INSTALLED13" "$HEAD13")"
assert_zero "(S13) exit 0" "$rc"
assert_ndjson_no_finding "(S13) signed accept with the correctly-classified key verifies -> PASS" \
  "$OUT/s13.findings.ndjson" "lane-violation"

# ===================================================================================
# S14 (REPAIR ROUND 1, DATA_INTEGRITY note, non-blocking): the base's
# gadd/BASELINE.json EXISTS but does not parse as JSON. Pre-fix, `jq ... //
# empty || true` silently read this identically to "accept_authors not set",
# dropping the author factor with no disclosure. Post-fix: an explicit
# fail-closed CRITICAL naming the parse failure.
# ===================================================================================
r14="$WORK/s14"
mkdir -p "$r14/gadd"
( cd "$r14" && git init -q && git config user.email accept@test.local && git config user.name t ) >/dev/null
printf 'not valid json{{{' > "$r14/gadd/BASELINE.json"
cat > "$r14/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
( cd "$r14" && git add -A && git commit -q -m init ) >/dev/null
BASE14="$(cd "$r14" && git rev-parse HEAD)"
printf '{"accepted_sha":"x","accept_authors":["accept@test.local"],"metrics":{}}' > "$r14/gadd/BASELINE.json"
HEAD14="$(accept_commit "$r14" "gadd: accept s14 malformed-base" "accept@test.local" "")"
rc="$(run_check02 s14 "$r14" "$BASE14" "$HEAD14")"
assert_zero "(S14) exit 0" "$rc"
assert_ndjson_finding "(S14) DATA_INTEGRITY note: malformed base gadd/BASELINE.json -> CRITICAL fail-closed, not a silent skip" \
  "$OUT/s14.findings.ndjson" "lane-violation" "CRITICAL" "does not parse"

# ===================================================================================
# S15 (RUN-24, DI wrong-TYPE base guard): the base's gadd/BASELINE.json EXISTS
# and parses as valid JSON, but its top level is an ARRAY, not an object.
# Pre-fix, the parse-only guard passed this and the author factor silently
# degraded to "not set" (demonstrated in the mission's both-direction
# receipt: only a MAJOR "spoofable" nudge, no CRITICAL). Post-fix: an
# explicit fail-closed CRITICAL naming the wrong type; the generic
# governed-fence CRITICAL also fires since accept_bad denies the exemption
# (verdict is not vacuously clean).
# ===================================================================================
r15="$WORK/s15"
mkdir -p "$r15/gadd"
( cd "$r15" && git init -q && git config user.email accept@test.local && git config user.name t ) >/dev/null
printf '[1,2,3]' > "$r15/gadd/BASELINE.json"
cat > "$r15/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
( cd "$r15" && git add -A && git commit -q -m init ) >/dev/null
BASE15="$(cd "$r15" && git rev-parse HEAD)"
printf '{"accepted_sha":"x","accept_authors":["accept@test.local"],"metrics":{}}' > "$r15/gadd/BASELINE.json"
HEAD15="$(accept_commit "$r15" "gadd: accept s15 wrong-type-array" "accept@test.local" "")"
rc="$(run_check02 s15 "$r15" "$BASE15" "$HEAD15")"
assert_zero "(S15) exit 0" "$rc"
assert_ndjson_finding "(S15) RUN-24 DI wrong-TYPE: base top-level is an array, not an object -> CRITICAL fail-closed" \
  "$OUT/s15.findings.ndjson" "lane-violation" "CRITICAL" "not an object"
assert_ndjson_finding "(S15) verdict not vacuously clean: generic governed-fence CRITICAL also fires" \
  "$OUT/s15.findings.ndjson" "lane-violation" "CRITICAL" "Governed-side files were modified"

# ===================================================================================
# S16 (RUN-24, DI wrong-TYPE base guard): the base's gadd/BASELINE.json is a
# valid object, but .accept_authors is present and non-null yet the WRONG
# TYPE (a string, not an array of strings). Pre-fix, `.accept_authors[]? //
# empty` silently read this identically to "not set" too. Post-fix: an
# explicit fail-closed CRITICAL naming the field and the type violation.
# ===================================================================================
r16="$WORK/s16"
mk_signer_repo "$r16" '"someone@example.com"' 1
BASE16="$(cd "$r16" && git rev-parse HEAD)"
bump_baseline "$r16" "s16head"
HEAD16="$(accept_commit "$r16" "gadd: accept s16 wrong-type-authors" "accept@test.local" "")"
rc="$(run_check02 s16 "$r16" "$BASE16" "$HEAD16")"
assert_zero "(S16) exit 0" "$rc"
assert_ndjson_finding "(S16) RUN-24 DI wrong-TYPE: .accept_authors is a string, not an array -> CRITICAL fail-closed" \
  "$OUT/s16.findings.ndjson" "lane-violation" "CRITICAL" "not an array of strings"
assert_ndjson_finding "(S16) verdict not vacuously clean: generic governed-fence CRITICAL also fires" \
  "$OUT/s16.findings.ndjson" "lane-violation" "CRITICAL" "Governed-side files were modified"

# ===================================================================================
# S17 (RUN-24, DI wrong-TYPE base guard — guards the UNCHANGED path): the
# base's gadd/BASELINE.json is a valid object with .accept_authors ABSENT
# entirely (not just empty/null-valued — the key is missing). This is the
# legitimate "not set" shape and must keep its existing behavior exactly:
# no wrong-type CRITICAL, just the pre-existing legacy nudge. Proves the fix
# is monotonic — no existing red flips green, no existing green flips red.
# ===================================================================================
r17="$WORK/s17"
mkdir -p "$r17/gadd"
( cd "$r17" && git init -q && git config user.email accept@test.local && git config user.name t ) >/dev/null
printf '{"accepted_sha":"0000000000000000000000000000000000000000","metrics":{}}' > "$r17/gadd/BASELINE.json"
cat > "$r17/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
( cd "$r17" && git add -A && git commit -q -m init ) >/dev/null
BASE17="$(cd "$r17" && git rev-parse HEAD)"
printf '{"accepted_sha":"x","metrics":{}}' > "$r17/gadd/BASELINE.json"
HEAD17="$(accept_commit "$r17" "gadd: accept s17 authors-absent" "accept@test.local" "")"
rc="$(run_check02 s17 "$r17" "$BASE17" "$HEAD17")"
assert_zero "(S17) exit 0" "$rc"
assert_ndjson_no_finding_sev "(S17) RUN-24 guard: .accept_authors ABSENT -> no wrong-type CRITICAL (behavior unchanged)" \
  "$OUT/s17.findings.ndjson" "lane-violation" "CRITICAL"
assert_ndjson_finding "(S17) pre-existing legacy nudge still fires unchanged (accept_authors not set, no signer)" \
  "$OUT/s17.findings.ndjson" "lane-violation" "MAJOR" "accept authorship spoofable"

# ===================================================================================
# S18 (RUN-24 REPAIR ROUND 1, TEST_HONESTY blocker): S15-S17 never exercised
# the array-MEMBER type check — the code validates
# `[.accept_authors[] | type == "string"] | all`, but S16 only covers
# .accept_authors being a string (whole-field wrong type). An array
# CONTAINING a non-string member (e.g. a legit email alongside a stray
# number) is caught by the code yet was uncovered by any fixture — a
# mutation of `all` to `any` would have passed the whole suite. .accept_authors
# is a mixed-type array with one valid string member and one non-string
# member -> same CRITICAL fail-closed treatment as S15/S16.
# ===================================================================================
r18="$WORK/s18"
mk_signer_repo "$r18" '["valid@example.com", 123]' 1
BASE18="$(cd "$r18" && git rev-parse HEAD)"
bump_baseline "$r18" "s18head"
HEAD18="$(accept_commit "$r18" "gadd: accept s18 mixed-type-authors-array" "accept@test.local" "")"
rc="$(run_check02 s18 "$r18" "$BASE18" "$HEAD18")"
assert_zero "(S18) exit 0" "$rc"
assert_ndjson_finding "(S18) RUN-24 REPAIR: .accept_authors array contains a non-string member -> CRITICAL fail-closed" \
  "$OUT/s18.findings.ndjson" "lane-violation" "CRITICAL" "non-string member"
assert_ndjson_finding "(S18) verdict not vacuously clean: generic governed-fence CRITICAL also fires" \
  "$OUT/s18.findings.ndjson" "lane-violation" "CRITICAL" "Governed-side files were modified"

# ===================================================================================
# S19 (RUN-28 h3): the base's gadd/BASELINE.json EXISTS and is valid JSON
# whose top level is the literal `null`. Pre-fix, `jq -e .` exits nonzero on
# a falsy top-level value (truthiness, not parse validity) and the guard
# fell through to the generic "does not parse" message. Post-fix: routed to
# the type-named message, same as the array/string wrong-type shapes above.
# ===================================================================================
r19="$WORK/s19"
mkdir -p "$r19/gadd"
( cd "$r19" && git init -q && git config user.email accept@test.local && git config user.name t ) >/dev/null
printf 'null' > "$r19/gadd/BASELINE.json"
cat > "$r19/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
( cd "$r19" && git add -A && git commit -q -m init ) >/dev/null
BASE19="$(cd "$r19" && git rev-parse HEAD)"
printf '{"accepted_sha":"x","accept_authors":["accept@test.local"],"metrics":{}}' > "$r19/gadd/BASELINE.json"
HEAD19="$(accept_commit "$r19" "gadd: accept s19 null-base" "accept@test.local" "")"
rc="$(run_check02 s19 "$r19" "$BASE19" "$HEAD19")"
assert_zero "(S19) exit 0" "$rc"
assert_ndjson_finding "(S19) RUN-28 h3: base top level is JSON null -> CRITICAL, type-named" \
  "$OUT/s19.findings.ndjson" "lane-violation" "CRITICAL" "top level is a JSON null, not an object"
if jq -s -e --arg c "lane-violation" --arg s "CRITICAL" \
     '[.[] | select(.check==$c and .severity==$s and (.message|contains("does not parse")))] | length == 0' \
     "$OUT/s19.findings.ndjson" >/dev/null 2>&1; then
  pass "(S19) message does NOT contain the old 'does not parse' wording (kills stale-routing mutant)"
else
  fail "(S19) message does NOT contain the old 'does not parse' wording" \
    "found 'does not parse' in: $(cat "$OUT/s19.findings.ndjson" 2>/dev/null | tr -d '\n' | cut -c1-300)"
fi

# ===================================================================================
# S20 (RUN-28 h3): same class as S19, base top level is the literal `false`
# (jq's type name for both true and false is "boolean").
# ===================================================================================
r20="$WORK/s20"
mkdir -p "$r20/gadd"
( cd "$r20" && git init -q && git config user.email accept@test.local && git config user.name t ) >/dev/null
printf 'false' > "$r20/gadd/BASELINE.json"
cat > "$r20/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
( cd "$r20" && git add -A && git commit -q -m init ) >/dev/null
BASE20="$(cd "$r20" && git rev-parse HEAD)"
printf '{"accepted_sha":"x","accept_authors":["accept@test.local"],"metrics":{}}' > "$r20/gadd/BASELINE.json"
HEAD20="$(accept_commit "$r20" "gadd: accept s20 false-base" "accept@test.local" "")"
rc="$(run_check02 s20 "$r20" "$BASE20" "$HEAD20")"
assert_zero "(S20) exit 0" "$rc"
assert_ndjson_finding "(S20) RUN-28 h3: base top level is JSON false -> CRITICAL, naming 'boolean'" \
  "$OUT/s20.findings.ndjson" "lane-violation" "CRITICAL" "top level is a JSON boolean, not an object"
if jq -s -e --arg c "lane-violation" --arg s "CRITICAL" \
     '[.[] | select(.check==$c and .severity==$s and (.message|contains("does not parse")))] | length == 0' \
     "$OUT/s20.findings.ndjson" >/dev/null 2>&1; then
  pass "(S20) message does NOT contain the old 'does not parse' wording (kills stale-routing mutant)"
else
  fail "(S20) message does NOT contain the old 'does not parse' wording" \
    "found 'does not parse' in: $(cat "$OUT/s20.findings.ndjson" 2>/dev/null | tr -d '\n' | cut -c1-300)"
fi

# ===================================================================================
# S21 (RUN-28 h3, adjacent edge the fix must not regress): base
# gadd/BASELINE.json is a WHITESPACE-ONLY stream (git-show returns it
# non-empty — spaces, no parseable JSON value at all). `jq -e .` exits 4 here
# (no output produced), distinct from exit 1 on a parsed null/false — must
# still route to "does not parse", never a type-named message with an empty
# type (jq -r 'type' would print nothing on this same empty stream).
# ===================================================================================
r21="$WORK/s21"
mkdir -p "$r21/gadd"
( cd "$r21" && git init -q && git config user.email accept@test.local && git config user.name t ) >/dev/null
printf '   ' > "$r21/gadd/BASELINE.json"
cat > "$r21/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
( cd "$r21" && git add -A && git commit -q -m init ) >/dev/null
BASE21="$(cd "$r21" && git rev-parse HEAD)"
printf '{"accepted_sha":"x","accept_authors":["accept@test.local"],"metrics":{}}' > "$r21/gadd/BASELINE.json"
HEAD21="$(accept_commit "$r21" "gadd: accept s21 whitespace-base" "accept@test.local" "")"
rc="$(run_check02 s21 "$r21" "$BASE21" "$HEAD21")"
assert_zero "(S21) exit 0" "$rc"
assert_ndjson_finding "(S21) RUN-28 h3 empty-stream guard: whitespace-only base -> CRITICAL, 'does not parse' (pinned, not type-named)" \
  "$OUT/s21.findings.ndjson" "lane-violation" "CRITICAL" "does not parse"
if jq -s -e --arg c "lane-violation" --arg s "CRITICAL" \
     '[.[] | select(.check==$c and .severity==$s and (.message|contains("is a JSON , not an object")))] | length == 0' \
     "$OUT/s21.findings.ndjson" >/dev/null 2>&1; then
  pass "(S21) message does NOT contain a blank-typed 'is a JSON , not an object' (kills empty-type-name mutant)"
else
  fail "(S21) message does NOT contain a blank-typed 'is a JSON , not an object'" \
    "found blank type in: $(cat "$OUT/s21.findings.ndjson" 2>/dev/null | tr -d '\n' | cut -c1-300)"
fi

# ===================================================================================
# BOTH-DIRECTION RECEIPT: S2, S3, S4, S5, S7 replayed against the PRE-upgrade
# check-02 ($OLD_CHECK02_REF). S2/S3/S7 never touch gadd/allowed_signers, so
# their existing repos are reused directly. S4/S5 need fresh repos whose
# OWNERSHIP fence omits the gadd/allowed_signers line (see header rationale).
# ===================================================================================
old_s2="$(run_old_check02 old-s02 "$r2" "$GEN2" "$HEAD2")"
old_s3="$(run_old_check02 old-s03 "$r3" "$GEN3" "$HEAD3")"
old_s7="$(run_old_check02 old-s07 "$r7" "$BASE7" "$HEAD7")"

r4red="$WORK/s04red"
GEN4red="$(mk_enrolled_repo "$r4red" '["accept@test.local"]' key4red "accept@test.local" 0)"
AKEY4red="$(gen_key key4red-attacker)"
{ cat "$r4red/gadd/allowed_signers"; printf '%s\n' "accept@test.local $(cat "$AKEY4red")"; } > "$r4red/allowed_signers.tmp"
mv "$r4red/allowed_signers.tmp" "$r4red/gadd/allowed_signers"
bump_baseline "$r4red" "s4redhead"
HEAD4red="$(accept_commit "$r4red" "gadd: accept s4 self-enroll" "accept@test.local" "$AKEY4red")"
old_s4="$(run_old_check02 old-s04 "$r4red" "$GEN4red" "$HEAD4red")"

r5red="$WORK/s05red"
GEN5red="$(mk_enrolled_repo "$r5red" '["accept@test.local"]' key5red "accept@test.local" 0)"
KEY5red="$KEYDIR/key5red.pub"
: > "$r5red/gadd/allowed_signers"
bump_baseline "$r5red" "s5redhead"
HEAD5red="$(accept_commit "$r5red" "gadd: accept s5 empties" "accept@test.local" "$KEY5red")"
old_s5="$(run_old_check02 old-s05 "$r5red" "$GEN5red" "$HEAD5red")"

assert_zero "(red-run S2) old check-02 does not crash" "$old_s2"
assert_ndjson_no_finding "(red-run S2) old check-02 PASSES the unsigned author-spoof replay (no signature concept)" \
  "$OUT/old-s02.findings.ndjson" "lane-violation"
assert_zero "(red-run S3) old check-02 does not crash" "$old_s3"
assert_ndjson_no_finding "(red-run S3) old check-02 PASSES the foreign-key-signed spoofed-email replay" \
  "$OUT/old-s03.findings.ndjson" "lane-violation"
assert_zero "(red-run S4) old check-02 does not crash" "$old_s4"
assert_ndjson_no_finding "(red-run S4) old check-02 PASSES same-push self-enrollment (no base-pinned anchor)" \
  "$OUT/old-s04.findings.ndjson" "lane-violation"
assert_zero "(red-run S5) old check-02 does not crash" "$old_s5"
assert_ndjson_no_finding "(red-run S5) old check-02 PASSES the trust-anchor-emptied ratchet violation (no ratchet rule)" \
  "$OUT/old-s05.findings.ndjson" "lane-violation"
assert_zero "(red-run S7) old check-02 does not crash" "$old_s7"
assert_ndjson_finding "(red-run S7) old check-02 only nudges MINOR, never escalates to MAJOR" \
  "$OUT/old-s07.findings.ndjson" "lane-violation" "MINOR" "accept_authors not set"
assert_ndjson_no_finding_sev "(red-run S7) old check-02 has no MAJOR escalation path" \
  "$OUT/old-s07.findings.ndjson" "lane-violation" "MAJOR"

sev_of() { # sev_of FILE CHECK -> highest severity present for CHECK, or "none"
  jq -s -r --arg c "$2" '
    [.[] | select(.check==$c) | .severity] as $s
    | if ($s | index("CRITICAL")) then "CRITICAL"
      elif ($s | index("MAJOR")) then "MAJOR"
      elif ($s | index("MINOR")) then "MINOR"
      else "none" end
  ' "$1" 2>/dev/null || echo "none"
}

echo ""
echo "BOTH-DIRECTION RED-RUN TABLE (old check-02 @ ${OLD_CHECK02_REF} vs the new, upgraded check)"
printf '%-6s %-52s %-10s %-10s\n' "Scen" "Attack" "OLD" "NEW"
printf '%-6s %-52s %-10s %-10s\n' "S2" "unsigned author-spoof replay"            "$(sev_of "$OUT/old-s02.findings.ndjson" lane-violation)" "$(sev_of "$OUT/s02.findings.ndjson" lane-violation)"
printf '%-6s %-52s %-10s %-10s\n' "S3" "foreign-key signed, spoofed email"        "$(sev_of "$OUT/old-s03.findings.ndjson" lane-violation)" "$(sev_of "$OUT/s03.findings.ndjson" lane-violation)"
printf '%-6s %-52s %-10s %-10s\n' "S4" "same-push self-enrollment"                "$(sev_of "$OUT/old-s04.findings.ndjson" lane-violation)" "$(sev_of "$OUT/s04.findings.ndjson" lane-violation)"
printf '%-6s %-52s %-10s %-10s\n' "S5" "trust anchor emptied (ratchet)"           "$(sev_of "$OUT/old-s05.findings.ndjson" lane-violation)" "$(sev_of "$OUT/s05a.findings.ndjson" lane-violation)"
printf '%-6s %-52s %-10s %-10s\n' "S7" "accept_authors-unset, no signer (nudge)"  "$(sev_of "$OUT/old-s07.findings.ndjson" lane-violation)" "$(sev_of "$OUT/s07.findings.ndjson" lane-violation)"
echo ""

# ===================================================================================
# RUN-31 A2 (SWALLOWED-ERROR HARDENING): S22-S26 exercise the jq-probe and
# git-trust-anchor-read hardening added in this build (defect classes 1 and
# 2, run-28 bench anomaly A2). Static PATH shims (one for jq, one for git)
# are parameterized via env vars set immediately before each run_check02
# call, so ONE shim file serves every scenario below without per-scenario
# code generation / heredoc quoting hazards.
# ===================================================================================
REAL_JQ="$(command -v jq)"
export REAL_JQ_FOR_SHIM="$REAL_JQ"
export REAL_GIT_FOR_SHIM="$REAL_GIT"

JQSHIM_DIR="$WORK/jqshim"; mkdir -p "$JQSHIM_DIR"
cat > "$JQSHIM_DIR/jq" <<'EOF'
#!/usr/bin/env bash
# Static jq-failure shim (S22/S23 below): fails ONLY when its argv exactly
# matches $JQSHIM_TARGET (a \x1f-joined arg list), delegating to the real jq
# otherwise. Simulates a genuine jq INVOCATION failure (transient tool
# failure), never a data-shape difference -- the underlying JSON is always
# valid at every call site this targets.
joined="$(printf '%s\x1f' "$@")"
if [ -n "${JQSHIM_TARGET:-}" ] && [ "$joined" = "$JQSHIM_TARGET" ]; then
  echo "fake jq invocation failure (simulated, tests/signer-fixtures.sh)" >&2
  exit "${JQSHIM_FAILRC:-2}"
fi
exec "$REAL_JQ_FOR_SHIM" "$@"
EOF
chmod +x "$JQSHIM_DIR/jq"

GITSHIM_DIR="$WORK/gitshim"; mkdir -p "$GITSHIM_DIR"
cat > "$GITSHIM_DIR/git" <<'EOF'
#!/usr/bin/env bash
# Static git-read-failure shim (S24/S25/S26 below): fails ANY git invocation
# whose argv contains the exact arg $GITSHIM_TARGET (typically a "REF:PATH"
# revision spec), with a rc OTHER than 0 or 1 (so the check's own probes can
# never mistake this for a clean "definitively absent" -- a real absence
# reports exit 1). Delegates to the real git otherwise.
for a in "$@"; do
  if [ -n "${GITSHIM_TARGET:-}" ] && [ "$a" = "$GITSHIM_TARGET" ]; then
    echo "fake transient git failure for $GITSHIM_TARGET (simulated, tests/signer-fixtures.sh)" >&2
    exit "${GITSHIM_FAILRC:-2}"
  fi
done
exec "$REAL_GIT_FOR_SHIM" "$@"
EOF
chmod +x "$GITSHIM_DIR/git"

# Extract the pre-THIS-fix check-02 (run-31 A2's own starting point, the
# origin/main tip at the time this repair round started) for the
# both-direction receipts below -- DIFFERENT from OLD_CHECK02_REF (44f09ed,
# the pre-run-21 ancient version used by the S2/S3/S4/S5/S7 red-run table
# above). Per the run-31 A2 mission brief: "obtain via `git show
# main:.gadd/checks/02-lane-violation.sh` into a scratch copy" -- pinned to
# a full 40-char commit SHA rather than the bare ref `main` (repair round 1,
# REGRESSION fix): in CI (actions/checkout@v4, detached HEAD, pull_request)
# only `origin/main` exists locally, not a bare `main` ref, so the bare
# default fatal-exited the suite after S21 in that environment. Verified
# (2026-07-19): this SHA resolves to origin/main, and
# `git show 43d896c187eaefa78bfe3ed5e767b0d68e03510c:.gadd/checks/02-lane-violation.sh`
# hashes to 87ddc7e2790669995383fb677b5300733c63bbeb (sha1) -- the pre-fix
# blob S22/S24's prefix-run receipts require to reproduce the swallowed
# blank-type message and the fail-open LEGACY degrade.
PREFIX_CHECK02_REF="${PREFIX_CHECK02_REF:-43d896c187eaefa78bfe3ed5e767b0d68e03510c}"
PREFIXDIR="$OUT/prefixcheck"; mkdir -p "$PREFIXDIR/lib"
if ! git -C "$REPO_ROOT" show "$PREFIX_CHECK02_REF:.gadd/checks/02-lane-violation.sh" > "$PREFIXDIR/02-lane-violation.sh" \
    || [ ! -s "$PREFIXDIR/02-lane-violation.sh" ]; then
  echo "FATAL: cannot extract pre-run-31-A2 check-02 at $PREFIX_CHECK02_REF -- both-direction receipts cannot run" >&2
  exit 1
fi
cp "$LIB_COMMON" "$PREFIXDIR/lib/common.sh"
PREFIX_CHECK02="$PREFIXDIR/02-lane-violation.sh"
run_prefix_check02() { run_a_check "$PREFIX_CHECK02" "$@"; }

# ===================================================================================
# S22 (run-31 A2 R1): base gadd/BASELINE.json top level is a JSON array (the
# S15 shape) but the jq -r 'type' probe that would name it is forced to fail
# via JQSHIM_TARGET="-r type". Pre-fix, `jq -r 'type' ... || true` silently
# yields an EMPTY string here, rendering the blank-typed message "top level
# is a JSON , not an object". Post-fix: a distinct, explicitly-worded
# fail-closed CRITICAL naming the jq failure -- never a blank type.
# ===================================================================================
r22="$WORK/s22"
mkdir -p "$r22/gadd"
( cd "$r22" && git init -q && git config user.email accept@test.local && git config user.name t ) >/dev/null
printf '[1,2,3]' > "$r22/gadd/BASELINE.json"
cat > "$r22/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
( cd "$r22" && git add -A && git commit -q -m init ) >/dev/null
BASE22="$(cd "$r22" && git rev-parse HEAD)"
printf '{"accepted_sha":"x","accept_authors":["accept@test.local"],"metrics":{}}' > "$r22/gadd/BASELINE.json"
HEAD22="$(accept_commit "$r22" "gadd: accept s22 jq-type-probe-fails" "accept@test.local" "")"
export JQSHIM_TARGET="$(printf '%s\x1f' -r type)"
export JQSHIM_FAILRC=2
rc="$(run_check02 s22 "$r22" "$BASE22" "$HEAD22" "$JQSHIM_DIR")"
unset JQSHIM_TARGET JQSHIM_FAILRC
assert_zero "(S22) exit 0" "$rc"
assert_ndjson_finding "(S22) jq -r 'type' probe invocation failure -> distinct fail-closed CRITICAL, named" \
  "$OUT/s22.findings.ndjson" "lane-violation" "CRITICAL" "jq failure during type probe"
if jq -s -e --arg c "lane-violation" --arg s "CRITICAL" \
     '[.[] | select(.check==$c and .severity==$s and (.message|contains("is a JSON , not an object")))] | length == 0' \
     "$OUT/s22.findings.ndjson" >/dev/null 2>&1; then
  pass "(S22) message is NEVER blank-typed (kills the swallowed-|| true regression)"
else
  fail "(S22) message is NEVER blank-typed" \
    "found blank type in: $(cat "$OUT/s22.findings.ndjson" 2>/dev/null | tr -d '\n' | cut -c1-300)"
fi

# ===================================================================================
# S23 (run-31 A2 R1): base gadd/BASELINE.json is well-formed with
# accept_authors a genuine array of strings (would PASS cleanly with no
# shim). The array-of-strings membership probe (`jq -e '[...] | all'`) is
# forced to fail via JQSHIM_TARGET matching its exact program text, with a
# rc OTHER than 0/1 (not the clean "found a non-string member" rc=1).
# Post-fix message must be distinguishable from S18's genuine
# non-string-member wording.
# ===================================================================================
r23="$WORK/s23"
mkdir -p "$r23/gadd"
( cd "$r23" && git init -q && git config user.email accept@test.local && git config user.name t ) >/dev/null
printf '{"accepted_sha":"0","accept_authors":["accept@test.local"],"metrics":{}}' > "$r23/gadd/BASELINE.json"
cat > "$r23/OWNERSHIP.md" <<'EOF'
```gadd-governed
gadd/BASELINE.json
gadd/allowed_signers
```
EOF
( cd "$r23" && git add -A && git commit -q -m init ) >/dev/null
BASE23="$(cd "$r23" && git rev-parse HEAD)"
printf '{"accepted_sha":"x","accept_authors":["accept@test.local"],"metrics":{}}' > "$r23/gadd/BASELINE.json"
HEAD23="$(accept_commit "$r23" "gadd: accept s23 jq-membership-probe-fails" "accept@test.local" "")"
export JQSHIM_TARGET="$(printf '%s\x1f' -e '[.accept_authors[] | type == "string"] | all')"
export JQSHIM_FAILRC=2
rc="$(run_check02 s23 "$r23" "$BASE23" "$HEAD23" "$JQSHIM_DIR")"
unset JQSHIM_TARGET JQSHIM_FAILRC
assert_zero "(S23) exit 0" "$rc"
assert_ndjson_finding "(S23) array-of-strings membership probe invocation failure -> distinct fail-closed CRITICAL" \
  "$OUT/s23.findings.ndjson" "lane-violation" "CRITICAL" "jq failure during membership probe"
if jq -s -e --arg c "lane-violation" --arg s "CRITICAL" \
     '[.[] | select(.check==$c and .severity==$s and (.message|contains("non-string member")))] | length == 0' \
     "$OUT/s23.findings.ndjson" >/dev/null 2>&1; then
  pass "(S23) message is distinguishable from a genuine non-string member (S18 wording absent)"
else
  fail "(S23) message is distinguishable from a genuine non-string member" \
    "found S18-style wording in: $(cat "$OUT/s23.findings.ndjson" 2>/dev/null | tr -d '\n' | cut -c1-300)"
fi

# ===================================================================================
# S24 (run-31 A2 R2, defect class 2): a genuinely ENROLLED repo (real
# gadd/allowed_signers present and valid at base) whose base read is forced
# transiently unreadable via GITSHIM_TARGET="$BASE:gadd/allowed_signers"
# (rc=2, never 1 -- never mistaken for clean absence). The accept commit is
# left UNSIGNED on purpose: pre-fix, the read failure reads identically to
# "no anchor enrolled" and the check falls straight through to the LEGACY
# path, which (accept_authors set, head signers present) emits ZERO
# findings -- a silent full bypass of signature verification. Post-fix:
# CRITICAL fail-closed, no LEGACY-path nudge language, exemption denied
# (generic governed-fence CRITICAL also fires).
# ===================================================================================
r24="$WORK/s24"
GEN24="$(mk_enrolled_repo "$r24" '["accept@test.local"]' key24 "accept@test.local")"
bump_baseline "$r24" "s24head"
HEAD24="$(accept_commit "$r24" "gadd: accept s24 base-signers-unreadable" "accept@test.local" "")"
export GITSHIM_TARGET="$GEN24:gadd/allowed_signers"
export GITSHIM_FAILRC=2
rc="$(run_check02 s24 "$r24" "$GEN24" "$HEAD24" "$GITSHIM_DIR")"
unset GITSHIM_TARGET GITSHIM_FAILRC
assert_zero "(S24) exit 0" "$rc"
assert_ndjson_finding "(S24) BLOCKER (defect class 2): base gadd/allowed_signers read failure -> CRITICAL fail-closed, naming the anchor" \
  "$OUT/s24.findings.ndjson" "lane-violation" "CRITICAL" "cannot read gadd/allowed_signers from accepted base"
assert_ndjson_finding "(S24) exemption denied: generic governed-fence CRITICAL also fires" \
  "$OUT/s24.findings.ndjson" "lane-violation" "CRITICAL" "Governed-side files were modified"
if jq -s -e --arg c "lane-violation" \
     '[.[] | select(.check==$c and ((.severity=="MINOR") or (.severity=="MAJOR")))] | length == 0' \
     "$OUT/s24.findings.ndjson" >/dev/null 2>&1; then
  pass "(S24) NO LEGACY-path MINOR/MAJOR nudge fires (no fail-open degrade to legacy)"
else
  fail "(S24) NO LEGACY-path MINOR/MAJOR nudge fires" \
    "found a MINOR/MAJOR nudge in: $(cat "$OUT/s24.findings.ndjson" 2>/dev/null | tr -d '\n' | cut -c1-300)"
fi

# ===================================================================================
# S25 (run-31 A2 R2): same shape as S24, targeting the base
# gadd/BASELINE.json read instead of gadd/allowed_signers. Post-fix:
# CRITICAL fail-closed naming the anchor, exemption denied, and NOT
# conflated with the "does not parse" / "not an object" malformed-base
# wording (this base parses fine -- the GIT READ is what failed).
# ===================================================================================
r25="$WORK/s25"
GEN25="$(mk_enrolled_repo "$r25" '["accept@test.local"]' key25 "accept@test.local")"
KEY25="$KEYDIR/key25.pub"
bump_baseline "$r25" "s25head"
HEAD25="$(accept_commit "$r25" "gadd: accept s25 base-baseline-unreadable" "accept@test.local" "$KEY25")"
export GITSHIM_TARGET="$GEN25:gadd/BASELINE.json"
export GITSHIM_FAILRC=2
rc="$(run_check02 s25 "$r25" "$GEN25" "$HEAD25" "$GITSHIM_DIR")"
unset GITSHIM_TARGET GITSHIM_FAILRC
assert_zero "(S25) exit 0" "$rc"
assert_ndjson_finding "(S25) base gadd/BASELINE.json read failure -> CRITICAL fail-closed, naming the anchor" \
  "$OUT/s25.findings.ndjson" "lane-violation" "CRITICAL" "cannot read gadd/BASELINE.json from accepted base"
assert_ndjson_finding "(S25) exemption denied: generic governed-fence CRITICAL also fires" \
  "$OUT/s25.findings.ndjson" "lane-violation" "CRITICAL" "Governed-side files were modified"
if jq -s -e --arg c "lane-violation" --arg s "CRITICAL" \
     '[.[] | select(.check==$c and .severity==$s and ((.message|contains("does not parse")) or (.message|contains("not an object"))))] | length == 0' \
     "$OUT/s25.findings.ndjson" >/dev/null 2>&1; then
  pass "(S25) NOT conflated with the malformed-base wording (a real git read failure, not a parse failure)"
else
  fail "(S25) NOT conflated with the malformed-base wording" \
    "found malformed-base wording in: $(cat "$OUT/s25.findings.ndjson" 2>/dev/null | tr -d '\n' | cut -c1-300)"
fi

# ===================================================================================
# S26 (run-31 A2 R3): ENROLLED repo, base signers read cleanly, but the HEAD
# signers read is forced unreadable. Pre-fix code has no concept of this at
# all (head_signers just reads empty). Post-fix: the ratchet rule's
# "emptied/deleted -- only-tightens" message must NOT fire (head signers is
# not KNOWN to be empty, only unreadable) -- the read-failure message fires
# in its place.
# ===================================================================================
r26="$WORK/s26"
GEN26="$(mk_enrolled_repo "$r26" '["accept@test.local"]' key26 "accept@test.local")"
KEY26="$KEYDIR/key26.pub"
bump_baseline "$r26" "s26head"
HEAD26="$(accept_commit "$r26" "gadd: accept s26 head-signers-unreadable" "accept@test.local" "$KEY26")"
export GITSHIM_TARGET="$HEAD26:gadd/allowed_signers"
export GITSHIM_FAILRC=2
rc="$(run_check02 s26 "$r26" "$GEN26" "$HEAD26" "$GITSHIM_DIR")"
unset GITSHIM_TARGET GITSHIM_FAILRC
assert_zero "(S26) exit 0" "$rc"
assert_ndjson_finding "(S26) HEAD gadd/allowed_signers read failure -> CRITICAL fail-closed, naming HEAD" \
  "$OUT/s26.findings.ndjson" "lane-violation" "CRITICAL" "cannot read gadd/allowed_signers from HEAD"
if jq -s -e --arg c "lane-violation" --arg s "CRITICAL" \
     '[.[] | select(.check==$c and .severity==$s and (.message|contains("emptied/deleted")))] | length == 0' \
     "$OUT/s26.findings.ndjson" >/dev/null 2>&1; then
  pass "(S26) R3: the ratchet rule's 'emptied/deleted' message does NOT fire for a read failure"
else
  fail "(S26) R3: the ratchet rule's 'emptied/deleted' message does NOT fire for a read failure" \
    "found the ratchet message in: $(cat "$OUT/s26.findings.ndjson" 2>/dev/null | tr -d '\n' | cut -c1-300)"
fi

# ===================================================================================
# S27 (run-31 A2 repair round 1, G2): drives the genuinely-MISSING (not
# corrupt) tree-object boundary G1 above hardens against, with a REAL git
# object-store deletion -- not a PATH-shim simulation like S22-S26. ENROLLED
# shape (mk_enrolled_repo); the BASE commit's "gadd" subtree loose object is
# deleted from .git/objects. gadd/BASELINE.json and gadd/allowed_signers
# both live directly under "gadd/" and therefore share exactly ONE tree
# object -- there is no way to corrupt the anchor for one without also
# corrupting the other's.
#
# MEASURED (bash -x trace against both script versions, same fixture):
# git_read_trust_anchor's OWN classification IS correctly hardened by G1 --
# signers_base_status flips from "absent" (pre-G1, de7139b) to "unreadable"
# (post-G1) for the IDENTICAL corrupted object, exactly as designed, and
# baseline_status flips the same way. BUT neither classification is ever
# acted on for this fixture: accept_touched (this file's own
# baseline_touched / signers_touched, `git log "$BASE".."$HEAD" -- gadd/...`)
# and the generic governed-fence fallback (changed_files/deleted_files in
# lib/common.sh) independently read the SAME corrupted "gadd" subtree via
# UNGUARDED git log/git diff invocations (no `2>/dev/null`, no rc check --
# pre-existing, untouched by R1/R2/R3/G1). Git's tree-diff machinery cannot
# determine "did commit X touch gadd/BASELINE.json" without resolving
# BASE's own version of that path, so those calls fail the identical way,
# silently return empty, accept_touched never becomes 1, and the generic
# fallback's viol list also stays empty. BOTH the pre-G1 and post-G1 script
# therefore exit 0 with ZERO findings for this fixture -- worse than the
# LEGACY degrade G1 targeted (a TOTAL silent bypass, no nudge at all).
#
# DISCLOSED GAP (out of this repair round's ratified scope -- the Director
# ruled G1 to git_read_trust_anchor specifically, "apply exactly these,
# nothing else"): a genuinely missing/corrupted "gadd" subtree object at the
# accepted base is NOT fail-closed end-to-end even after this repair round,
# because baseline_touched/signers_touched/changed_files/deleted_files share
# the identical unguarded-git-read swallow G1 closed only inside
# git_read_trust_anchor. Flagged here for a future ratified round rather
# than silently fixed or silently assumed fixed; this fixture PINS the
# current (undesirable) both-versions-identical behavior so it stays
# visible instead of being papered over.
# ===================================================================================
PRE_G1_CHECK02_REF="${PRE_G1_CHECK02_REF:-de7139b6ec64b351a31a4b00cc3057d1b80d178e}"
PREG1DIR="$OUT/preg1check"; mkdir -p "$PREG1DIR/lib"
if ! git -C "$REPO_ROOT" show "$PRE_G1_CHECK02_REF:.gadd/checks/02-lane-violation.sh" > "$PREG1DIR/02-lane-violation.sh" \
    || [ ! -s "$PREG1DIR/02-lane-violation.sh" ]; then
  echo "FATAL: cannot extract pre-G1 check-02 at $PRE_G1_CHECK02_REF -- S27 both-direction receipt cannot run" >&2
  exit 1
fi
cp "$LIB_COMMON" "$PREG1DIR/lib/common.sh"
PRE_G1_CHECK02="$PREG1DIR/02-lane-violation.sh"
run_pre_g1_check02() { run_a_check "$PRE_G1_CHECK02" "$@"; }

r27="$WORK/s27"
GEN27="$(mk_enrolled_repo "$r27" '["accept@test.local"]' key27 "accept@test.local")"
bump_baseline "$r27" "s27head"
HEAD27="$(accept_commit "$r27" "gadd: accept s27 missing-subtree-object" "accept@test.local" "")"
GADD27_TREE="$(cd "$r27" && git ls-tree "$GEN27" gadd | awk '{print $3}')"
GADD27_OBJPATH="$r27/.git/objects/${GADD27_TREE:0:2}/${GADD27_TREE:2}"
if [ ! -f "$GADD27_OBJPATH" ]; then
  echo "FATAL (S27): expected loose object $GADD27_OBJPATH not found -- fixture setup assumption (fresh scratch repo, no packs) broke" >&2
  exit 1
fi
rm -f "$GADD27_OBJPATH"

rc="$(run_check02 s27 "$r27" "$GEN27" "$HEAD27")"
assert_zero "(S27) NEW script does not crash on a missing base subtree object" "$rc"
assert_ndjson_no_finding "(S27) DISCLOSED GAP: NEW script still produces ZERO findings end-to-end for a missing base 'gadd' subtree object -- git_read_trust_anchor's own read is correctly hardened (bash -x trace: absent -> unreadable, see fix commit body) but accept_touched's separate, unguarded git-log swallow masks it before any finding can fire; closing this is out of this round's ratified scope" \
  "$OUT/s27.findings.ndjson" "lane-violation"

prefix_s27="$(run_pre_g1_check02 pre-g1-s27 "$r27" "$GEN27" "$HEAD27")"
assert_zero "(pre-G1-run S27) pre-G1 check-02 (de7139b) does not crash either" "$prefix_s27"
assert_ndjson_no_finding "(pre-G1-run S27) pre-G1 check-02 ALSO produces ZERO findings -- same masking mechanism, unrelated to G1 -- no visible both-direction bite for this specific fixture (disclosed, not papered over)" \
  "$OUT/pre-g1-s27.findings.ndjson" "lane-violation"

echo ""
echo "S27 BOTH-DIRECTION RECEIPT (missing base 'gadd' subtree object, ENROLLED) -- DISCLOSED GAP, not a validated fix"
printf '%-6s %-58s %-10s %-10s\n' "Scen" "Attack" "PRE-G1" "POST-G1"
printf '%-6s %-58s %-10s %-10s\n' "S27" "missing gadd/ subtree object at accepted base" "$(sev_of "$OUT/pre-g1-s27.findings.ndjson" lane-violation)" "$(sev_of "$OUT/s27.findings.ndjson" lane-violation)"
echo "S27 NOTE: both columns read 'none' -- the mutation does NOT bite end-to-end for this"
echo "fixture. git_read_trust_anchor IS correctly hardened in isolation (internal"
echo "signers_base_status/baseline_status flip absent->unreadable, verified via bash -x"
echo "trace, not observable through NDJSON findings here); accept_touched's own,"
echo "separate unguarded git-log swallow masks it. Out of this round's ratified G1/G2"
echo "scope -- flagged for a future round, see repair-round-1 commit body / report."
echo ""

# ===================================================================================
# BOTH-DIRECTION RECEIPT (run-31 A2, R7c): S22 and S24 replayed against the
# PRE-fix check-02 (this run's own starting point, main tip) under the
# IDENTICAL simulated failure, proving the mutation bites -- the old bad
# behavior actually reproduces, not just "the new code looks right".
# ===================================================================================
export JQSHIM_TARGET="$(printf '%s\x1f' -r type)"
export JQSHIM_FAILRC=2
prefix_s22="$(run_prefix_check02 prefix-s22 "$r22" "$BASE22" "$HEAD22" "$JQSHIM_DIR")"
unset JQSHIM_TARGET JQSHIM_FAILRC
assert_zero "(prefix-run S22) pre-fix check-02 does not crash" "$prefix_s22"
assert_ndjson_finding "(prefix-run S22) pre-fix check-02 REPRODUCES the blank-typed message under the identical jq failure" \
  "$OUT/prefix-s22.findings.ndjson" "lane-violation" "CRITICAL" "is a JSON , not an object"

export GITSHIM_TARGET="$GEN24:gadd/allowed_signers"
export GITSHIM_FAILRC=2
prefix_s24="$(run_prefix_check02 prefix-s24 "$r24" "$GEN24" "$HEAD24" "$GITSHIM_DIR")"
unset GITSHIM_TARGET GITSHIM_FAILRC
assert_zero "(prefix-run S24) pre-fix check-02 does not crash" "$prefix_s24"
assert_ndjson_no_finding "(prefix-run S24) pre-fix check-02 REPRODUCES the fail-open degrade: ZERO findings despite the unsigned accept + unreadable base anchor" \
  "$OUT/prefix-s24.findings.ndjson" "lane-violation"

echo ""
echo "BOTH-DIRECTION RED-RUN TABLE (run-31 A2 pre-fix check-02 @ ${PREFIX_CHECK02_REF} vs the new, hardened check)"
printf '%-6s %-58s %-10s %-10s\n' "Scen" "Attack" "PRE-FIX" "NEW"
printf '%-6s %-58s %-10s %-10s\n' "S22" "jq -r type probe invocation failure (blank-type bug)" "$(sev_of "$OUT/prefix-s22.findings.ndjson" lane-violation)" "$(sev_of "$OUT/s22.findings.ndjson" lane-violation)"
printf '%-6s %-58s %-10s %-10s\n' "S24" "base allowed_signers read failure (fail-open to legacy)" "$(sev_of "$OUT/prefix-s24.findings.ndjson" lane-violation)" "$(sev_of "$OUT/s24.findings.ndjson" lane-violation)"
echo ""

# ===================================================================================
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
