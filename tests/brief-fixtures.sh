#!/usr/bin/env bash
# tests/brief-fixtures.sh — acceptance corpus for bin/brief-check.sh
# (brief-freshness close-check, audits/brief-freshness-eval-v1.md §5,
# operator run-25 decision-2 amendment). Style matches
# tests/heartbeat-fixtures.sh: numbered scenarios, assert_eq, mktemp
# fixtures, PASS/FAIL per scenario, ALL-PASS summary line, non-zero exit
# on any failure. Fixtures build their own scratch dir under mktemp (never
# the repo tree or a shared /tmp path), pointing bin/brief-check.sh at
# them via its GADD_LANTERN_FILE / GADD_BRIEF_FILE overrides — the same
# env-var parameterization pattern tests/heartbeat-fixtures.sh uses to
# drive bin/loop-heartbeat.sh.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_ROOT/bin/brief-check.sh"

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

# declared_line RUN_NUMBER -> one LANTERN.md DECLARED entry line for RUN_NUMBER.
declared_line() {
  printf -- '- **mission-loop run #%s DECLARED (2026-07-17 system clock; fixture)** foo bar.\n' "$1"
}

# close_line RUN_NUMBER -> one LANTERN.md CLOSE entry line for RUN_NUMBER (never
# matches the DECLARED-anchored ERE, regardless of position in the file).
close_line() {
  printf -- '- **mission-loop run #%s CLOSE (2026-07-17 system clock; fixture)** foo bar.\n' "$1"
}

# header_line RUN_NUMBER -> BRIEF.md header line for RUN_NUMBER, stable format.
header_line() {
  printf '# gadd brief — mission-loop run #%s (2026-07-17)\n' "$1"
}

# ===================================================================================
# Scenario (a): fresh header PASS — header run #N == topmost DECLARED N -> exit 0.
# ===================================================================================
lantern_a="$WORK/lantern_a.md"
brief_a="$WORK/brief_a.md"
{
  declared_line 26
  declared_line 25
} > "$lantern_a"
header_line 26 > "$brief_a"
out_a="$(GADD_LANTERN_FILE="$lantern_a" GADD_BRIEF_FILE="$brief_a" "$SCRIPT")"; rc_a=$?
assert_eq "(a) fresh header, N matches -> exit 0" "0" "$rc_a"
assert_eq "(a) fresh header -> PASS line emitted" "true" \
  "$(printf '%s' "$out_a" | grep -q 'PASS' && echo true || echo false)"

# ===================================================================================
# Scenario (b): stale header FAIL — header run #(N-1) -> exit 1, message names
# both numbers.
# ===================================================================================
lantern_b="$WORK/lantern_b.md"
brief_b="$WORK/brief_b.md"
{
  declared_line 26
  declared_line 25
} > "$lantern_b"
header_line 25 > "$brief_b"
out_b="$(GADD_LANTERN_FILE="$lantern_b" GADD_BRIEF_FILE="$brief_b" "$SCRIPT" 2>&1)"; rc_b=$?
assert_eq "(b) stale header (N-1) -> exit 1" "1" "$rc_b"
assert_eq "(b) stale-header message names header run #25" "true" \
  "$(printf '%s' "$out_b" | grep -q 'run #25' && echo true || echo false)"
assert_eq "(b) stale-header message names derived run #26" "true" \
  "$(printf '%s' "$out_b" | grep -q 'run #26' && echo true || echo false)"

# ===================================================================================
# Scenario (c): ROLLS-TO-VACUITY PIN — brief BODY mentions "run #N" (a rolls-to
# line) but the HEADER is stale -> still FAIL exit 1. Pins the §2 vacuity finding
# (an anywhere-in-file criterion would pass this every time) closed forever.
# ===================================================================================
lantern_c="$WORK/lantern_c.md"
brief_c="$WORK/brief_c.md"
{
  declared_line 26
  declared_line 25
} > "$lantern_c"
{
  header_line 25
  echo ""
  echo "## Rolls to run #26"
  echo ""
  echo "wall after the push chain; run #26 starting here would be dumb-zone work."
} > "$brief_c"
out_c="$(GADD_LANTERN_FILE="$lantern_c" GADD_BRIEF_FILE="$brief_c" "$SCRIPT" 2>&1)"; rc_c=$?
assert_eq "(c) rolls-to-vacuity pin: stale header + body mentions run #N -> exit 1 (never PASS)" "1" "$rc_c"
assert_eq "(c) rolls-to-vacuity pin: message names both numbers" "true" \
  "$(printf '%s' "$out_c" | grep -q 'run #25' && printf '%s' "$out_c" | grep -q 'run #26' && echo true || echo false)"

# ===================================================================================
# Scenario (d): missing BRIEF.md -> FAIL exit 1 ("a missing brief is stale by
# definition").
# ===================================================================================
lantern_d="$WORK/lantern_d.md"
missing_brief="$WORK/does-not-exist-brief.md"
declared_line 26 > "$lantern_d"
out_d="$(GADD_LANTERN_FILE="$lantern_d" GADD_BRIEF_FILE="$missing_brief" "$SCRIPT" 2>&1)"; rc_d=$?
assert_eq "(d) missing BRIEF.md -> exit 1 (never 0, never 2)" "1" "$rc_d"
assert_eq "(d) missing BRIEF.md message says stale/missing" "true" \
  "$(printf '%s' "$out_d" | grep -qi 'not found or unreadable' && echo true || echo false)"

# ===================================================================================
# Scenario (e): LANTERN with no DECLARED entry -> exit 2 (fail-closed), and
# stdout/stderr must never claim PASS.
# ===================================================================================
lantern_e="$WORK/lantern_e.md"
brief_e="$WORK/brief_e.md"
{
  echo "- **mission-loop run #26 CLOSE (2026-07-17 system clock; fixture)** no declared entry here."
  echo "some other lantern prose, no DECLARED line at all."
} > "$lantern_e"
header_line 26 > "$brief_e"
out_e="$(GADD_LANTERN_FILE="$lantern_e" GADD_BRIEF_FILE="$brief_e" "$SCRIPT" 2>&1)"; rc_e=$?
assert_eq "(e) no DECLARED entry -> exit 2 (fail-closed)" "2" "$rc_e"
assert_eq "(e) no DECLARED entry -> output never claims PASS" "false" \
  "$(printf '%s' "$out_e" | grep -q 'PASS' && echo true || echo false)"
assert_eq "(e) no DECLARED entry -> loud cannot-derive message" "true" \
  "$(printf '%s' "$out_e" | grep -qi 'cannot derive run number' && echo true || echo false)"

# ===================================================================================
# Scenario (f): word boundary — header carrying run #250 must NOT satisfy a
# derived N of 25 (prefix/substring false-positive), AND a lantern whose topmost
# DECLARED entry is run #250 must derive N=250 (not truncate to 25).
# ===================================================================================
# (f1) derived N=25 (topmost DECLARED is run #25); header carries run #250 ->
# must FAIL, never a false PASS via "run #25" being a prefix of "run #250".
lantern_f1="$WORK/lantern_f1.md"
brief_f1="$WORK/brief_f1.md"
declared_line 25 > "$lantern_f1"
header_line 250 > "$brief_f1"
out_f1="$(GADD_LANTERN_FILE="$lantern_f1" GADD_BRIEF_FILE="$brief_f1" "$SCRIPT" 2>&1)"; rc_f1=$?
assert_eq "(f1) header run #250 vs derived N=25 -> exit 1 (never a prefix false-PASS)" "1" "$rc_f1"

# (f2) lantern's topmost DECLARED entry is run #250 -> derived N must be 250,
# not truncated to 25: a header of run #250 must PASS...
lantern_f2="$WORK/lantern_f2.md"
brief_f2a="$WORK/brief_f2a.md"
declared_line 250 > "$lantern_f2"
header_line 250 > "$brief_f2a"
out_f2a="$(GADD_LANTERN_FILE="$lantern_f2" GADD_BRIEF_FILE="$brief_f2a" "$SCRIPT" 2>&1)"; rc_f2a=$?
assert_eq "(f2a) lantern topmost DECLARED run #250 + header run #250 -> exit 0" "0" "$rc_f2a"

# ...while a header of run #25 against that SAME lantern must FAIL, naming both
# 25 and 250 (proves derivation read 250 in full, not a truncated 25).
brief_f2b="$WORK/brief_f2b.md"
header_line 25 > "$brief_f2b"
out_f2b="$(GADD_LANTERN_FILE="$lantern_f2" GADD_BRIEF_FILE="$brief_f2b" "$SCRIPT" 2>&1)"; rc_f2b=$?
assert_eq "(f2b) lantern topmost DECLARED run #250 + header run #25 -> exit 1" "1" "$rc_f2b"
assert_eq "(f2b) message names header run #25" "true" \
  "$(printf '%s' "$out_f2b" | grep -q 'run #25[^0]' && echo true || echo false)"
assert_eq "(f2b) message names derived run #250" "true" \
  "$(printf '%s' "$out_f2b" | grep -q 'run #250' && echo true || echo false)"

# ===================================================================================
# Scenario (g): close-entry immunity — a CLOSE log entry sitting ABOVE the
# topmost DECLARED entry does not perturb derivation (it never matches the
# DECLARED-anchored ERE regardless of position).
# ===================================================================================
lantern_g="$WORK/lantern_g.md"
brief_g="$WORK/brief_g.md"
{
  close_line 26
  declared_line 26
  declared_line 25
} > "$lantern_g"
header_line 26 > "$brief_g"
out_g="$(GADD_LANTERN_FILE="$lantern_g" GADD_BRIEF_FILE="$brief_g" "$SCRIPT" 2>&1)"; rc_g=$?
assert_eq "(g) CLOSE entry above topmost DECLARED -> derivation unperturbed, exit 0" "0" "$rc_g"

# g2: same close-above-declared shape, but header is stale -> still correctly
# FAILs against the DECLARED-derived N (26), proving the CLOSE line was never
# mistaken for N=26 nor silently dropped derivation to something else.
brief_g2="$WORK/brief_g2.md"
header_line 25 > "$brief_g2"
out_g2="$(GADD_LANTERN_FILE="$lantern_g" GADD_BRIEF_FILE="$brief_g2" "$SCRIPT" 2>&1)"; rc_g2=$?
assert_eq "(g2) CLOSE entry above topmost DECLARED, stale header -> exit 1 naming #26" "true" \
  "$([ "$rc_g2" = "1" ] && printf '%s' "$out_g2" | grep -q 'run #26' && echo true || echo false)"

# ===================================================================================
# Scenario 2 (regression): default paths — running the script with no overrides
# against the real repo-root LANTERN.md/BRIEF.md must not crash (exit 0/1/2 only,
# never a bash error). The live tree is EXPECTED to be stale right now (a
# required receipt of this build), so exit 1 is the correct live outcome — this
# assertion only pins "no crash", not a specific run number.
# ===================================================================================
"$SCRIPT" >/dev/null 2>&1
rc_default=$?
assert_eq "(default-paths) real repo paths -> exit is 0, 1, or 2 (never a crash)" "true" \
  "$( [ "$rc_default" = "0" ] || [ "$rc_default" = "1" ] || [ "$rc_default" = "2" ] && echo true || echo false )"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
