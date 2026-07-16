#!/usr/bin/env bash
# tests/heartbeat-fixtures.sh — acceptance corpus for bin/loop-heartbeat.sh
# (deterministic context-ceiling enforcement, SPEED AUDIT v1 P1, ratified
# 2026-07-16). Style matches tests/parity-fixtures.sh: numbered scenarios,
# assert_eq, mktemp fixtures, PASS/FAIL per scenario, ALL-PASS summary line,
# non-zero exit on any failure. Exercises both directions of the ceiling check,
# all three measurement fallback tiers (tokens/bytes/turns), the fail-closed
# cannot-measure path, and the env ceiling override.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_ROOT/bin/loop-heartbeat.sh"

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

# usage_line INPUT_TOKENS CACHE_CREATION CACHE_READ -> one assistant JSONL line
# whose message.usage sums to a chosen total context value.
usage_line() {
  printf '{"type":"assistant","message":{"usage":{"input_tokens":%s,"cache_creation_input_tokens":%s,"cache_read_input_tokens":%s,"output_tokens":10}}}\n' "$1" "$2" "$3"
}

# ===================================================================================
# Scenario 1: small synthetic transcript, one assistant usage line summing well under
# the default ceiling -> exit 0, tokens method, correct measured value.
# ===================================================================================
f1="$WORK/s01.jsonl"
usage_line 2 1000 4998 > "$f1"   # total = 6000
out1="$("$SCRIPT" check "$f1")"; rc1=$?
assert_eq "(1) under-ceiling synthetic transcript -> exit 0" "0" "$rc1"
assert_eq "(1) status line reports tokens method" "true" "$(printf '%s' "$out1" | grep -q 'via tokens method' && echo true || echo false)"
status1="$("$SCRIPT" status "$f1")"
assert_eq "(1) status JSON value == 6000" "6000" "$(printf '%s' "$status1" | jq -r '.value')"
assert_eq "(1) status JSON method == tokens" "tokens" "$(printf '%s' "$status1" | jq -r '.method')"

# ===================================================================================
# Scenario 2: synthetic transcript whose LATEST assistant usage exceeds the default
# ceiling (earlier lines are smaller, proving we read the most-recent turn, not a
# sum or a max over all lines) -> exit 3, loud CEILING REACHED line.
# ===================================================================================
f2="$WORK/s02.jsonl"
{
  usage_line 0 10000 20000       # total 30000 — small, early turn
  usage_line 0 50000 100000      # total 150000 — mid turn
  usage_line 0 100000 350000     # total 450000 — latest turn, over 400000 default ceiling
} > "$f2"
out2="$("$SCRIPT" check "$f2")"; rc2=$?
assert_eq "(2) latest-turn context over ceiling -> exit 3" "3" "$rc2"
assert_eq "(2) loud CEILING REACHED line emitted" "true" \
  "$(printf '%s' "$out2" | grep -q 'CEILING REACHED' && echo true || echo false)"
status2="$("$SCRIPT" status "$f2")"
assert_eq "(2) status JSON value == 450000 (most-recent turn, not sum-of-all)" "450000" \
  "$(printf '%s' "$status2" | jq -r '.value')"

# ===================================================================================
# Scenario 3: missing/unreadable transcript -> exit 2, never exit 0, fail-closed
# messaging. Both check and status modes covered.
# ===================================================================================
missing="$WORK/does-not-exist.jsonl"
"$SCRIPT" check "$missing" >/dev/null 2>&1; rc3="$?"
assert_eq "(3) missing transcript, check mode -> exit 2 (never 0)" "2" "$rc3"
status3="$("$SCRIPT" status "$missing")"; rc3s="$?"
assert_eq "(3) missing transcript, status mode -> exit 2" "2" "$rc3s"
assert_eq "(3) status JSON measured:false on missing transcript" "false" \
  "$(printf '%s' "$status3" | jq -r '.measured')"

# ===================================================================================
# Scenario 4: GADD_CTX_CEILING_TOKENS env override is respected in both directions —
# a value that would pass at the default ceiling fails under a lowered override, and
# the status JSON reports the overridden ceiling.
# ===================================================================================
f4="$WORK/s04.jsonl"
usage_line 2 10000 40000 > "$f4"   # total = 50000: under default 400000, over 40000
GADD_CTX_CEILING_TOKENS=40000 "$SCRIPT" check "$f4" >/dev/null 2>&1; rc4="$?"
assert_eq "(4) lowered ceiling override -> same measurement now fails (exit 3)" "3" "$rc4"
status4="$(GADD_CTX_CEILING_TOKENS=40000 "$SCRIPT" status "$f4")"
assert_eq "(4) status JSON reports the overridden ceiling" "40000" "$(printf '%s' "$status4" | jq -r '.ceiling')"

# ===================================================================================
# Scenario 5: bytes fallback tier — a transcript with assistant lines but no usage
# field at all (tier 1 unavailable) must fall to the bytes heuristic, method labeled
# "bytes" in the output, never silently treated as tokens or as unmeasurable.
# ===================================================================================
f5="$WORK/s05.jsonl"
printf '{"type":"assistant","message":{"content":[{"type":"text","text":"no usage field here"}]}}\n' > "$f5"
status5="$("$SCRIPT" status "$f5")"
assert_eq "(5) no usage field -> falls back to bytes method" "bytes" "$(printf '%s' "$status5" | jq -r '.method')"
assert_eq "(5) bytes fallback note discloses the conversion" "true" \
  "$(printf '%s' "$status5" | jq -r '.note' | grep -q 'bytes-per-token' && echo true || echo false)"

# ===================================================================================
# Scenario 6: turns fallback tier — same no-usage transcript, but with the bytes
# conversion constant deliberately disabled (GADD_CTX_BYTES_PER_TOKEN=0, guarding
# the div-by-zero path) forces the chain past bytes to the last-resort turn-count
# heuristic, labeled "turns".
# ===================================================================================
status6="$(GADD_CTX_BYTES_PER_TOKEN=0 "$SCRIPT" status "$f5")"
assert_eq "(6) bytes disabled -> falls back to turns method" "turns" "$(printf '%s' "$status6" | jq -r '.method')"
assert_eq "(6) turns fallback note discloses the conversion" "true" \
  "$(printf '%s' "$status6" | jq -r '.note' | grep -q 'tokens/turn' && echo true || echo false)"

# ===================================================================================
# Scenario 7: fully unmeasurable — empty file (no bytes, no turns, no tokens) ->
# exit 2 in both modes, never fabricated as under-ceiling.
# ===================================================================================
f7="$WORK/s07.jsonl"
: > "$f7"
"$SCRIPT" check "$f7" >/dev/null 2>&1; rc7="$?"
assert_eq "(7) empty transcript -> exit 2 (never 0)" "2" "$rc7"
status7="$("$SCRIPT" status "$f7")"
assert_eq "(7) empty transcript status JSON measured:false" "false" "$(printf '%s' "$status7" | jq -r '.measured')"

# ===================================================================================
# Scenario 8: exit codes are the ONLY trusted signal for automation, but the human-
# facing loud line must also be present on stdout for both the ceiling-reached and
# cannot-measure paths (never silent, per the ratified fail-loud requirement).
# ===================================================================================
out8="$("$SCRIPT" check "$missing" 2>/dev/null)"
assert_eq "(8) cannot-measure path prints a loud CANNOT MEASURE line" "true" \
  "$(printf '%s' "$out8" | grep -q 'CANNOT MEASURE' && echo true || echo false)"

# ===================================================================================
# Scenario 9: GADD_CTX_CEILING_TOKENS validation (DATA_INTEGRITY blocker, run #14) —
# a non-numeric ceiling must never fall through to the -ge comparison as a false
# (bash-error) result and print OK/exit 0 on an over-ceiling transcript. It must
# fail closed: exit 2, loud line, in BOTH check and status modes.
# ===================================================================================
f9="$WORK/s09.jsonl"
usage_line 0 100000 350000 > "$f9"   # total 450000 — over the default 400000 ceiling

# 9a: garbage non-numeric ceiling ("400k") -> exit 2, never OK/exit 0.
out9a="$(GADD_CTX_CEILING_TOKENS=400k "$SCRIPT" check "$f9")"; rc9a=$?
assert_eq "(9a) garbage ceiling '400k' -> exit 2 (never 0/OK on over-ceiling data)" "2" "$rc9a"
assert_eq "(9a) garbage ceiling prints loud CANNOT MEASURE line" "true" \
  "$(printf '%s' "$out9a" | grep -q 'CANNOT MEASURE' && echo true || echo false)"
assert_eq "(9a) garbage ceiling never prints OK" "false" \
  "$(printf '%s' "$out9a" | grep -q ' OK ' && echo true || echo false)"
status9a="$(GADD_CTX_CEILING_TOKENS=400k "$SCRIPT" status "$f9")"; rc9as=$?
assert_eq "(9a) garbage ceiling, status mode -> exit 2" "2" "$rc9as"
assert_eq "(9a) garbage ceiling, status JSON measured:false" "false" \
  "$(printf '%s' "$status9a" | jq -r '.measured')"

# 9b: purely alphabetic ceiling ("abc") -> same fail-closed behavior.
out9b="$(GADD_CTX_CEILING_TOKENS=abc "$SCRIPT" check "$f9")"; rc9b=$?
assert_eq "(9b) garbage ceiling 'abc' -> exit 2" "2" "$rc9b"
assert_eq "(9b) garbage ceiling 'abc' prints loud CANNOT MEASURE line" "true" \
  "$(printf '%s' "$out9b" | grep -q 'CANNOT MEASURE' && echo true || echo false)"

# 9c: zero ceiling -> non-positive, must fail closed (exit 2), not divide/compare
# against a zero threshold.
out9c="$(GADD_CTX_CEILING_TOKENS=0 "$SCRIPT" check "$f9")"; rc9c=$?
assert_eq "(9c) zero ceiling -> exit 2 (non-positive rejected)" "2" "$rc9c"

# 9d: negative ceiling -> non-positive, must fail closed (exit 2).
out9d="$(GADD_CTX_CEILING_TOKENS=-5 "$SCRIPT" check "$f9")"; rc9d=$?
assert_eq "(9d) negative ceiling '-5' -> exit 2 (non-positive rejected)" "2" "$rc9d"

# 9e: valid numeric ceiling override still works, both directions — lowered valid
# ceiling still fires exit 3 on over-ceiling data (regression guard: the new
# validation must not break the existing, already-passing override path).
out9e="$(GADD_CTX_CEILING_TOKENS=100000 "$SCRIPT" check "$f9")"; rc9e=$?
assert_eq "(9e) valid numeric ceiling override -> still exits 3 on over-ceiling data" "3" "$rc9e"
assert_eq "(9e) valid override loud CEILING REACHED line still present" "true" \
  "$(printf '%s' "$out9e" | grep -q 'CEILING REACHED' && echo true || echo false)"

# 9f: valid numeric ceiling override, raised above the measured value -> exit 0 OK,
# proving valid overrides still pass through correctly in the other direction too.
out9f="$(GADD_CTX_CEILING_TOKENS=999999999 "$SCRIPT" check "$f9")"; rc9f=$?
assert_eq "(9f) valid raised ceiling override -> exit 0 OK on now-under-ceiling data" "0" "$rc9f"
assert_eq "(9f) valid raised override prints OK line" "true" \
  "$(printf '%s' "$out9f" | grep -q '\] OK ' && echo true || echo false)"

# ===================================================================================
# Mutation demo: strip the ceiling comparison in a scratch copy of the script ->
# the fixture that depends on exit 3 (scenario 2) must fail against the mutant.
# This is a live demonstration, not a pass/fail assertion of this suite itself.
# ===================================================================================
echo ""
echo "--- mutation demo: ceiling comparison stripped ---"
mutant="$WORK/loop-heartbeat.mutant.sh"
cp "$SCRIPT" "$mutant"
chmod +x "$mutant"
# Replace the ceiling-reached branch condition with a false literal so the mutant
# always falls through to "OK", regardless of measured value vs ceiling.
sed -i.bak 's/if \[ "\$VALUE" -ge "\$CEILING" \]; then/if false; then/' "$mutant"
rm -f "$mutant.bak"
"$mutant" check "$f2" >/dev/null 2>&1
mutant_rc=$?
if [ "$mutant_rc" != "3" ]; then
  echo "mutation demo CONFIRMED: ceiling-stripped mutant no longer exits 3 on an over-ceiling transcript (got exit $mutant_rc) — the real script's comparison is load-bearing."
else
  echo "mutation demo INCONCLUSIVE: mutant still exited 3 — sed substitution did not take effect as expected."
fi

# ===================================================================================
# Mutation demo 2 (DATA_INTEGRITY blocker, run #14): strip the CEILING validation
# guard in a scratch copy -> scenario 9a (garbage ceiling "400k" -> exit 2) must fail
# against the mutant, since a garbage CEILING would then flow unvalidated into the
# check-mode `-ge` comparison (bash errors, reads false, script falls through to OK).
# ===================================================================================
echo ""
echo "--- mutation demo: CEILING validation guard stripped ---"
mutant2="$WORK/loop-heartbeat.mutant2.sh"
cp "$SCRIPT" "$mutant2"
chmod +x "$mutant2"
# Replace the validation condition with a literal-false guard so the mutant never
# rejects any CEILING value, however garbage, and falls straight through.
sed -i.bak 's/if ! \[ "\$CEILING" -gt 0 \] 2>\/dev\/null; then/if false; then/' "$mutant2"
rm -f "$mutant2.bak"
mutant2_out="$(GADD_CTX_CEILING_TOKENS=400k "$mutant2" check "$f9" 2>&1)"
mutant2_rc=$?
if [ "$mutant2_rc" = "2" ]; then
  echo "mutation demo INCONCLUSIVE: mutant still exited 2 — sed substitution did not take effect as expected."
elif printf '%s' "$mutant2_out" | grep -q '\] OK '; then
  echo "mutation demo CONFIRMED: validation-stripped mutant prints OK (exit $mutant2_rc) on an over-ceiling transcript with garbage GADD_CTX_CEILING_TOKENS=400k — the real script's guard is load-bearing (fail-open reproduced on the mutant)."
else
  echo "mutation demo CONFIRMED (partial): validation-stripped mutant no longer exits 2 on garbage ceiling (got exit $mutant2_rc, output: $mutant2_out)."
fi

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
