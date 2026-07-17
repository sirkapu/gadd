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
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
