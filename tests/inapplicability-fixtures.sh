#!/usr/bin/env bash
# tests/inapplicability-fixtures.sh — acceptance corpus for the "inapplicable ->
# disclose, don't stay silent" behavior of adapters/lv/checks/01-contract-drift.sh
# and adapters/lv/checks/07-ratchet-metrics.sh (added run #11, TH round-2 blocker:
# the ::notice::…(available:false) stderr lines had zero test coverage — a mutation
# deleting them passed every harness). Style matches tests/parity-fixtures.sh /
# tests/fleet-fixtures.sh: numbered scenarios, assert_eq, mktemp fixtures, PASS/FAIL
# per scenario, ALL-PASS summary line, non-zero exit on any failure. adapters/lv/checks/
# is the source of truth (.gadd/checks/ in THIS repo is an installed copy per
# adapters/lv/bin/install.sh's `cp -r "$SRC/checks/." .gadd/checks/`) — same convention
# parity-fixtures.sh uses for check 10. Every scenario pins BOTH directions: the notice
# fires when the target dir is absent AND stays silent when it is present, so a mutation
# that deletes the disclosure line (or one that always emits it) is caught either way.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK01="$REPO_ROOT/adapters/lv/checks/01-contract-drift.sh"
CHECK07="$REPO_ROOT/adapters/lv/checks/07-ratchet-metrics.sh"

NOTICE01="::notice::contract-drift inapplicable — src/contracts absent (available:false)"
NOTICE07="::notice::ratchet-metrics inapplicable — src absent (available:false)"

WORK="$(mktemp -d)"
OUT="$(mktemp -d)"   # stdout/stderr/findings land here — kept OUTSIDE $WORK so fixture
                      # repos stay exactly what each scenario built, nothing extra.

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
  if [ "$2" = "$3" ]; then
    pass "$1"
  else
    fail "$1" "expected [$2] got [$3]"
  fi
}

# assert_contains NAME NEEDLE HAYSTACK_FILE -> pass if NEEDLE is a literal
# (fixed-string) substring of HAYSTACK_FILE's contents.
assert_contains() {
  if grep -qF -- "$2" "$3"; then
    pass "$1"
  else
    fail "$1" "not found in: $(cat "$3")"
  fi
}

# assert_not_contains NAME NEEDLE HAYSTACK_FILE -> pass if NEEDLE is absent.
assert_not_contains() {
  if grep -qF -- "$2" "$3"; then
    fail "$1" "unexpectedly present in: $(cat "$3")"
  else
    pass "$1"
  fi
}

# mk_git_repo DIR -> git-inits DIR with an initial commit so GADD_BASE/GADD_HEAD
# (required by lib/common.sh) can be real, matching SHAs — a real "scratch repo",
# not a bare directory, so check 01's git-diff machinery runs clean (no "fatal: not
# a git repository" stderr noise polluting the notice assertion).
mk_git_repo() {
  local dir="$1"
  mkdir -p "$dir"
  ( cd "$dir" && git init -q && git config user.email t@t.local && git config user.name t \
      && git add -A && git commit -q -m init --allow-empty )
}

# run_check PREFIX FIXTURE_DIR CHECK -> runs CHECK with cwd=FIXTURE_DIR, GADD_BASE
# and GADD_HEAD pinned to the fixture's own HEAD (a real, valid, no-op range).
# Writes stdout/stderr to $OUT/<prefix>.{stdout,stderr}. Echoes the exit code.
run_check() {
  local prefix="$1" fixture="$2" check="$3"
  local findings="$OUT/$prefix.findings.ndjson"
  : > "$findings"
  (
    cd "$fixture" || exit 99
    export GADD_BASE="$(git rev-parse HEAD)"
    export GADD_HEAD="$GADD_BASE"
    export GADD_FINDINGS="$findings"
    bash "$check"
  ) >"$OUT/$prefix.stdout" 2>"$OUT/$prefix.stderr"
  echo $?
}

# ===================================================================================
# Scenario 1: check 01 (contract-drift), src/contracts ABSENT -> inapplicability
# notice emitted to stderr, exit 0.
# ===================================================================================
r1="$WORK/s01"; mk_git_repo "$r1"
rc="$(run_check s01 "$r1" "$CHECK01")"
assert_eq "(1) check01 src/contracts absent -> exit 0" "0" "$rc"
assert_contains "(1) check01 src/contracts absent -> notice emitted" "$NOTICE01" "$OUT/s01.stderr"

# ===================================================================================
# Scenario 2: check 01 (contract-drift), src/contracts PRESENT -> no inapplicability
# notice (mutation-honesty: pins the notice is conditional, not unconditional).
# ===================================================================================
r2="$WORK/s02"; mk_git_repo "$r2"
mkdir -p "$r2/src/contracts"
printf 'export type X = 1;\n' > "$r2/src/contracts/x.ts"
( cd "$r2" && git add -A && git commit -q -m contracts )
rc="$(run_check s02 "$r2" "$CHECK01")"
assert_eq "(2) check01 src/contracts present -> exit 0" "0" "$rc"
assert_not_contains "(2) check01 src/contracts present -> no inapplicability notice" "$NOTICE01" "$OUT/s02.stderr"

# ===================================================================================
# Scenario 3: check 07 (ratchet-metrics), src ABSENT -> inapplicability notice
# emitted to stderr, exit 0.
# ===================================================================================
r3="$WORK/s03"; mk_git_repo "$r3"
rc="$(run_check s03 "$r3" "$CHECK07")"
assert_eq "(3) check07 src absent -> exit 0" "0" "$rc"
assert_contains "(3) check07 src absent -> notice emitted" "$NOTICE07" "$OUT/s03.stderr"

# ===================================================================================
# Scenario 4: check 07 (ratchet-metrics), src PRESENT -> no inapplicability notice
# (mutation-honesty: pins the notice is conditional, not unconditional).
# ===================================================================================
r4="$WORK/s04"; mk_git_repo "$r4"
mkdir -p "$r4/src"
printf 'export const a = 1;\n' > "$r4/src/a.ts"
( cd "$r4" && git add -A && git commit -q -m src )
rc="$(run_check s04 "$r4" "$CHECK07")"
assert_eq "(4) check07 src present -> exit 0" "0" "$rc"
assert_not_contains "(4) check07 src present -> no inapplicability notice" "$NOTICE07" "$OUT/s04.stderr"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
