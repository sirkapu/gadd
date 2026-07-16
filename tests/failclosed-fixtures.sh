#!/usr/bin/env bash
# tests/failclosed-fixtures.sh — acceptance corpus for the fail-closed gate
# hardening (run #13, operator-ratified "approve hardening", lifting the
# Ratifier's PARK-TIER-3 on the A–G packet spec'd in run #12). Pins every new
# fail-closed path BOTH directions (the guard fires when it should AND stays
# silent/PASS when it shouldn't), so a mutation deleting the new behavior or
# one that fires it unconditionally is caught either way. Style matches
# tests/inapplicability-fixtures.sh / tests/parity-fixtures.sh: numbered
# scenarios, assert helpers, mktemp fixtures, PASS/FAIL per scenario,
# ALL-PASS summary line, non-zero exit on any failure. adapters/lv/checks/ is
# the source of truth (.gadd/checks/ in THIS repo is an installed copy per
# adapters/lv/bin/install.sh's `cp -r "$SRC/checks/." .gadd/checks/`).
#
# Scenarios:
#   (1) run-all.sh — garbage GADD_BASE -> verdict FAIL + synthetic CRITICAL
#       "gate-integrity" finding naming the bad base; valid base -> no such
#       finding (hardening A).
#   (2) run-all.sh — a check exiting nonzero -> verdict != PASS + synthetic
#       MAJOR "gate-integrity" finding naming the crashed check; all checks
#       clean -> no such finding (hardening B).
#   (3) run-all.sh — a malformed NDJSON findings line -> synthetic MAJOR
#       "gate-integrity" finding quoting it, AND pre-existing valid findings
#       are retained (not wiped); a clean stream -> no synthetic finding
#       (hardening C).
#   (4) 02-lane-violation.sh — the governed-glob fence is read from the
#       ACCEPTED BASE, not the working tree: an emptied working-tree fence
#       does not defeat enforcement when the base's fence is populated; an
#       empty/missing fence in the base produces a stderr notice, not a
#       silent exit (hardening E).
#
# RUN_ALL / LIB_COMMON / CHECK02 are overridable via env — used at receipt
# time to re-run this exact corpus against the PRE-HARDENING scripts (e.g.
# `git show main:adapters/lv/checks/run-all.sh` extracted to a scratch path)
# to demonstrate the new assertions actually bite (mutation honesty): the
# committed default always targets the current, hardened scripts.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUN_ALL="${RUN_ALL:-$REPO_ROOT/adapters/lv/checks/run-all.sh}"
LIB_COMMON="${LIB_COMMON:-$REPO_ROOT/adapters/lv/checks/lib/common.sh}"
CHECK02="${CHECK02:-$REPO_ROOT/adapters/lv/checks/02-lane-violation.sh}"

WORK="$(mktemp -d)"
OUT="$(mktemp -d)"   # stdout/stderr/findings land here — kept OUTSIDE $WORK so
                      # fixture repos stay exactly what each scenario built.

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

# assert_ne NAME NOT_EXPECTED ACTUAL
assert_ne() {
  if [ "$2" != "$3" ]; then pass "$1"; else fail "$1" "expected != [$2] but got [$3]"; fi
}

# assert_zero / assert_nonzero NAME EXIT_CODE
assert_zero() {
  if [ "$2" -eq 0 ] 2>/dev/null; then pass "$1"; else fail "$1" "expected exit 0, got [$2]"; fi
}
assert_nonzero() {
  if [ "$2" -ne 0 ] 2>/dev/null; then pass "$1"; else fail "$1" "expected nonzero exit, got [$2]"; fi
}

# assert_contains NAME NEEDLE HAYSTACK_FILE -> literal substring match.
assert_contains() {
  if grep -qF -- "$2" "$3" 2>/dev/null; then
    pass "$1"
  else
    fail "$1" "not found in: $(cat "$3" 2>/dev/null)"
  fi
}

# assert_verdict_finding NAME VERDICT_JSON_FILE CHECK SEVERITY MSG_SUBSTR ->
# pass if the run-all.sh verdict JSON's .findings[] contains a matching entry.
assert_verdict_finding() {
  local name="$1" file="$2" c="$3" s="$4" m="$5"
  if jq -e --arg c "$c" --arg s "$s" --arg m "$m" \
       '[.findings[]? | select(.check==$c and .severity==$s and (.message|contains($m)))] | length > 0' \
       "$file" >/dev/null 2>&1; then
    pass "$name"
  else
    fail "$name" "no matching finding in: $(cat "$file" 2>/dev/null | tr -d '\n' | cut -c1-300)"
  fi
}

# assert_verdict_no_finding NAME VERDICT_JSON_FILE CHECK -> pass if no
# .findings[] entry has this check name.
assert_verdict_no_finding() {
  local name="$1" file="$2" c="$3"
  if jq -e --arg c "$c" '[.findings[]? | select(.check==$c)] | length == 0' "$file" >/dev/null 2>&1; then
    pass "$name"
  else
    fail "$name" "unexpected finding(s) for check=$c present"
  fi
}

# assert_ndjson_finding / assert_ndjson_no_finding — same as above but for a
# raw NDJSON findings file (one bare JSON object per line, not wrapped in a
# verdict envelope) — the shape a check's own GADD_FINDINGS output takes when
# the check is invoked directly rather than via run-all.sh.
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
assert_ndjson_no_finding() {
  local name="$1" file="$2" c="$3"
  if jq -s -e --arg c "$c" '[.[] | select(.check==$c)] | length == 0' "$file" >/dev/null 2>&1; then
    pass "$name"
  else
    fail "$name" "unexpected NDJSON finding(s) for check=$c present"
  fi
}

# mk_git_repo DIR -> git-inits DIR with an initial commit so GADD_BASE/
# GADD_HEAD (required by lib/common.sh) can be real, matching SHAs.
mk_git_repo() {
  local dir="$1"
  mkdir -p "$dir"
  ( cd "$dir" && git init -q && git config user.email t@t.local && git config user.name t \
      && git add -A && git commit -q -m init --allow-empty )
}

# write_baseline DIR -> minimal gadd/BASELINE.json (content doesn't gate
# anything here since every scenario pins GADD_BASE/GADD_HEAD explicitly;
# only its presence as valid JSON matters).
write_baseline() {
  local dir="$1"
  mkdir -p "$dir/gadd"
  cat > "$dir/gadd/BASELINE.json" <<'EOF'
{
  "accepted_sha": "0000000000000000000000000000000000000000",
  "accept_authors": [],
  "metrics": {}
}
EOF
}

# install_run_all CHECKS_DIR -> installs the run-all.sh + lib/common.sh under
# test into a scratch .gadd/checks/ directory. Scenario-specific numbered
# check scripts (including any deliberately crashing/malformed ones) are
# authored directly into CHECKS_DIR by each scenario — scratch only, never
# touching the real .gadd/checks/.
install_run_all() {
  local checks_dir="$1"
  mkdir -p "$checks_dir/lib"
  cp "$RUN_ALL" "$checks_dir/run-all.sh"
  cp "$LIB_COMMON" "$checks_dir/lib/common.sh"
  chmod +x "$checks_dir/run-all.sh"
}

# run_run_all PREFIX FIXTURE_DIR [GADD_BASE_OVERRIDE] -> runs the fixture's
# own .gadd/checks/run-all.sh with cwd=FIXTURE_DIR. GADD_HEAD is always the
# fixture's real HEAD; GADD_BASE defaults to the same (a real, valid, no-op
# range) unless overridden. Writes stdout/stderr to $OUT/<prefix>.{stdout,
# stderr}. Echoes the exit code.
run_run_all() {
  local prefix="$1" fixture="$2" base_override="${3:-}"
  (
    cd "$fixture" || exit 99
    export GADD_HEAD="$(git rev-parse HEAD)"
    export GADD_BASE="${base_override:-$GADD_HEAD}"
    bash .gadd/checks/run-all.sh
  ) >"$OUT/$prefix.stdout" 2>"$OUT/$prefix.stderr"
  echo $?
}

# run_check02 PREFIX FIXTURE_DIR BASE_SHA HEAD_SHA -> runs CHECK02 directly
# (not via run-all.sh) with cwd=FIXTURE_DIR and explicit base/head shas.
# Writes stdout/stderr/findings to $OUT/<prefix>.*. Echoes the exit code.
run_check02() {
  local prefix="$1" fixture="$2" base="$3" head="$4"
  local findings="$OUT/$prefix.findings.ndjson"
  : > "$findings"
  (
    cd "$fixture" || exit 99
    export GADD_BASE="$base"
    export GADD_HEAD="$head"
    export GADD_FINDINGS="$findings"
    bash "$CHECK02"
  ) >"$OUT/$prefix.stdout" 2>"$OUT/$prefix.stderr"
  echo $?
}

# ===================================================================================
# Scenario 1 (hardening A): run-all.sh, garbage GADD_BASE -> verdict FAIL,
# nonzero exit, synthetic CRITICAL "gate-integrity" finding naming the bad
# base. Valid base -> no such finding (mutation-honesty: pins conditional,
# not unconditional).
# ===================================================================================
r1="$WORK/s01"; mk_git_repo "$r1"; write_baseline "$r1"
install_run_all "$r1/.gadd/checks"
cat > "$r1/.gadd/checks/01-noop.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$r1/.gadd/checks/01-noop.sh"
( cd "$r1" && git add -A && git commit -q -m checks )

BAD_BASE="0000000000000000000000000000000000dead"
rc="$(run_run_all s01bad "$r1" "$BAD_BASE")"
assert_nonzero "(1a) run-all garbage GADD_BASE -> nonzero exit" "$rc"
assert_eq "(1a) run-all garbage GADD_BASE -> verdict FAIL" "FAIL" \
  "$(jq -r '.verdict' "$OUT/s01bad.stdout" 2>/dev/null)"
assert_verdict_finding "(1a) run-all garbage GADD_BASE -> synthetic CRITICAL gate-integrity naming the bad base" \
  "$OUT/s01bad.stdout" "gate-integrity" "CRITICAL" "$BAD_BASE"

rc="$(run_run_all s01good "$r1" "")"
assert_zero "(1b) run-all valid GADD_BASE -> exit 0" "$rc"
assert_eq "(1b) run-all valid GADD_BASE -> verdict PASS" "PASS" \
  "$(jq -r '.verdict' "$OUT/s01good.stdout" 2>/dev/null)"
assert_verdict_no_finding "(1b) run-all valid GADD_BASE -> no gate-integrity finding" \
  "$OUT/s01good.stdout" "gate-integrity"

# ===================================================================================
# Scenario 2 (hardening B): run-all.sh, a check exiting nonzero -> verdict !=
# PASS, synthetic MAJOR "gate-integrity" finding naming the crashed check.
# All checks clean -> no such finding.
# ===================================================================================
r2="$WORK/s02"; mk_git_repo "$r2"; write_baseline "$r2"
install_run_all "$r2/.gadd/checks"
cat > "$r2/.gadd/checks/01-noop.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$r2/.gadd/checks/02-crash.sh" <<'EOF'
#!/usr/bin/env bash
# Scratch-only synthetic crashing check (fixture scenario 2) — never
# installed in the real .gadd/checks/; exists to pin run-all.sh's exit-code
# ledger (hardening B).
echo "synthetic crash for hardening fixture" >&2
exit 7
EOF
chmod +x "$r2/.gadd/checks/"*.sh
( cd "$r2" && git add -A && git commit -q -m checks )

rc="$(run_run_all s02crash "$r2" "")"
verdict="$(jq -r '.verdict' "$OUT/s02crash.stdout" 2>/dev/null)"
assert_ne "(2a) run-all crashing check -> verdict != PASS" "PASS" "$verdict"
assert_verdict_finding "(2a) run-all crashing check -> synthetic MAJOR gate-integrity naming 02-crash.sh" \
  "$OUT/s02crash.stdout" "gate-integrity" "MAJOR" "02-crash.sh"

r2b="$WORK/s02clean"; mk_git_repo "$r2b"; write_baseline "$r2b"
install_run_all "$r2b/.gadd/checks"
cat > "$r2b/.gadd/checks/01-noop.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$r2b/.gadd/checks/01-noop.sh"
( cd "$r2b" && git add -A && git commit -q -m checks )

rc="$(run_run_all s02clean "$r2b" "")"
assert_zero "(2b) run-all all-checks-clean -> exit 0" "$rc"
assert_eq "(2b) run-all all-checks-clean -> verdict PASS" "PASS" \
  "$(jq -r '.verdict' "$OUT/s02clean.stdout" 2>/dev/null)"
assert_verdict_no_finding "(2b) run-all all-checks-clean -> no gate-integrity finding" \
  "$OUT/s02clean.stdout" "gate-integrity"

# ===================================================================================
# Scenario 3 (hardening C): run-all.sh, a malformed NDJSON findings line ->
# synthetic MAJOR "gate-integrity" finding quoting it, AND a pre-existing
# valid finding on the same stream is retained (not wiped by the bad line).
# A clean stream -> no synthetic finding, valid finding still present.
# ===================================================================================
r3="$WORK/s03"; mk_git_repo "$r3"; write_baseline "$r3"
install_run_all "$r3/.gadd/checks"
cat > "$r3/.gadd/checks/01-mixed.sh" <<'EOF'
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
finding "canary" "MINOR" "pre-existing valid finding used to prove retention"
printf 'not-json-garbage-line\n' >> "$GADD_FINDINGS"
exit 0
EOF
chmod +x "$r3/.gadd/checks/01-mixed.sh"
( cd "$r3" && git add -A && git commit -q -m checks )

rc="$(run_run_all s03bad "$r3" "")"
verdict="$(jq -r '.verdict' "$OUT/s03bad.stdout" 2>/dev/null)"
assert_ne "(3a) run-all malformed NDJSON line -> verdict != PASS" "PASS" "$verdict"
assert_verdict_finding "(3a) run-all malformed NDJSON line -> synthetic MAJOR gate-integrity quoting the bad line" \
  "$OUT/s03bad.stdout" "gate-integrity" "MAJOR" "not-json-garbage-line"
assert_verdict_finding "(3a) run-all malformed NDJSON line -> pre-existing valid finding retained, not wiped" \
  "$OUT/s03bad.stdout" "canary" "MINOR" "pre-existing valid finding"

r3b="$WORK/s03clean"; mk_git_repo "$r3b"; write_baseline "$r3b"
install_run_all "$r3b/.gadd/checks"
cat > "$r3b/.gadd/checks/01-clean.sh" <<'EOF'
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
finding "canary" "MINOR" "pre-existing valid finding used to prove retention"
exit 0
EOF
chmod +x "$r3b/.gadd/checks/01-clean.sh"
( cd "$r3b" && git add -A && git commit -q -m checks )

rc="$(run_run_all s03clean "$r3b" "")"
assert_zero "(3b) run-all clean NDJSON stream -> exit 0" "$rc"
assert_eq "(3b) run-all clean NDJSON stream -> verdict PASS" "PASS" \
  "$(jq -r '.verdict' "$OUT/s03clean.stdout" 2>/dev/null)"
assert_verdict_no_finding "(3b) run-all clean NDJSON stream -> no synthetic gate-integrity finding" \
  "$OUT/s03clean.stdout" "gate-integrity"
assert_verdict_finding "(3b) run-all clean NDJSON stream -> canary finding still present" \
  "$OUT/s03clean.stdout" "canary" "MINOR" "pre-existing valid finding"

# ===================================================================================
# Scenario 4 (hardening E): 02-lane-violation.sh reads the governed-glob
# fence from the ACCEPTED BASE, not the working tree. An emptied working-tree
# fence does not defeat enforcement when the base's fence is populated. An
# empty/missing fence in the base produces a stderr notice, not a silent
# exit — and a populated WORKING-TREE fence is correctly ignored in that case
# (the base has an OWNERSHIP.md; the working-tree fallback only applies when
# the base has none at all).
# ===================================================================================
r4="$WORK/s04"
mkdir -p "$r4"
( cd "$r4" && git init -q && git config user.email t@t.local && git config user.name t )
cat > "$r4/OWNERSHIP.md" <<'EOF'
```gadd-governed
secret.txt
```
EOF
printf 'v1\n' > "$r4/secret.txt"
( cd "$r4" && git add -A && git commit -q -m base )
BASE4="$(cd "$r4" && git rev-parse HEAD)"

# Empty the working-tree/HEAD fence AND modify the file the BASE fence governs.
cat > "$r4/OWNERSHIP.md" <<'EOF'
```gadd-governed
```
EOF
printf 'v2\n' > "$r4/secret.txt"
( cd "$r4" && git add -A && git commit -q -m head )
HEAD4="$(cd "$r4" && git rev-parse HEAD)"

rc="$(run_check02 s04fire "$r4" "$BASE4" "$HEAD4")"
assert_zero "(4a) lane-violation base fence populated -> exit 0 (finding is recorded, not a nonzero exit)" "$rc"
assert_ndjson_finding "(4a) lane-violation reads fence from BASE (working-tree emptied) -> CRITICAL still fires" \
  "$OUT/s04fire.findings.ndjson" "lane-violation" "CRITICAL" "OWNERSHIP.md lanes"

r4b="$WORK/s04b"
mkdir -p "$r4b"
( cd "$r4b" && git init -q && git config user.email t@t.local && git config user.name t )
cat > "$r4b/OWNERSHIP.md" <<'EOF'
```gadd-governed
```
EOF
printf 'v1\n' > "$r4b/secret.txt"
( cd "$r4b" && git add -A && git commit -q -m base )
BASE4B="$(cd "$r4b" && git rev-parse HEAD)"

# Populate a WORKING-TREE fence (must be ignored: base has an OWNERSHIP.md,
# just an empty one, so the "base has none at all" fallback does not apply)
# and modify the file that fence would govern.
cat > "$r4b/OWNERSHIP.md" <<'EOF'
```gadd-governed
secret.txt
```
EOF
printf 'v2\n' > "$r4b/secret.txt"
( cd "$r4b" && git add -A && git commit -q -m head )
HEAD4B="$(cd "$r4b" && git rev-parse HEAD)"

rc="$(run_check02 s04empty "$r4b" "$BASE4B" "$HEAD4B")"
assert_zero "(4b) lane-violation base fence empty -> exit 0" "$rc"
assert_contains "(4b) lane-violation base fence empty -> stderr notice, not silent" \
  "::notice::lane-violation" "$OUT/s04empty.stderr"
assert_ndjson_no_finding "(4b) lane-violation base fence empty (working-tree fence correctly ignored) -> no CRITICAL finding" \
  "$OUT/s04empty.findings.ndjson" "lane-violation"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
