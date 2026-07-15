#!/usr/bin/env bash
# tests/fleet-fixtures.sh — acceptance corpus for bin/gadd-fleet.mjs, built from
# adversary rounds 1-5. jq is allowed HERE (test harness, not the instrument under
# test). Self-contained: builds all fixtures under mktemp, runs the instrument
# against them, asserts, prints numbered PASS/FAIL per scenario, and exits non-zero
# if any scenario fails.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLEET="$REPO_ROOT/bin/gadd-fleet.mjs"

WORK="$(mktemp -d)"
OUT="$(mktemp -d)"   # instrument stdout/stderr land here — kept OUTSIDE $WORK so the
                      # zero-disk-writes probe over $WORK is never polluted by our own
                      # test-harness redirects.

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

# --- fixture helpers --------------------------------------------------------------

mkrepo() {
  local dir="$WORK/$1"
  mkdir -p "$dir/gadd/verdicts"
  echo "$dir"
}

valid_verdict() {
  local verdict="${1:-PASS}"
  printf '{"sha":"aaaaaaa","base_sha":"bbbbbbb","verdict":"%s","findings":[]}' "$verdict"
}

valid_escaped_line() {
  local check="${1:-some-check}"
  printf '{"date":"2026-07-14","accepted_sha":"deadbeef","check":"%s","severity":"CRITICAL","description":"test entry"}' "$check"
}

run_fleet() {
  # run_fleet OUTPREFIX <args...>  -> writes $OUT/<prefix>.stdout / .stderr, returns exit code
  local prefix="$1"; shift
  node "$FLEET" "$@" >"$OUT/$prefix.stdout" 2>"$OUT/$prefix.stderr"
  echo $?
}

# ===================================================================================
# Scenario 1: malformed verdict JSON
# ===================================================================================
r1="$(mkrepo s01)"
printf '{not valid json' > "$r1/gadd/verdicts/bad.json"
rc="$(run_fleet s01 "$r1")"
j="$(cat "$OUT/s01.stdout")"
assert_eq "s01 exit 0" "0" "$rc"
assert_eq "(1) malformed verdict JSON -> anomaly malformed_json=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.malformed_json')"
assert_eq "(1) verdicts_total stays 0" "0" "$(echo "$j" | jq '.repos[0].verdicts_total')"
assert_eq "(1) repo status clean (disclosed, not fatal)" "clean" "$(echo "$j" | jq -r '.repos[0].status')"

# ===================================================================================
# Scenario 2: unreadable verdict file (chmod 000, restore after)
# ===================================================================================
r2="$(mkrepo s02)"
echo -n "$(valid_verdict)" > "$r2/gadd/verdicts/locked.json"
chmod 000 "$r2/gadd/verdicts/locked.json"
rc="$(run_fleet s02 "$r2")"
j="$(cat "$OUT/s02.stdout")"
chmod 644 "$r2/gadd/verdicts/locked.json"
if [ "$(id -u)" = "0" ]; then
  fail "(2) unreadable verdict file -> anomaly unreadable=1" "skipped: running as root, permission bits ineffective"
  fail "(2) unreadable -> anomalies.total == 1 (unreadable counted into total)" "skipped: running as root"
else
  assert_eq "(2) unreadable verdict file -> anomaly unreadable=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.unreadable')"
  assert_eq "(2) unreadable -> anomalies.total == 1 (unreadable counted into total)" "1" "$(echo "$j" | jq '.repos[0].anomalies.total')"
fi

# ===================================================================================
# Scenario 3: empty 0-byte verdict
# ===================================================================================
r3="$(mkrepo s03)"
: > "$r3/gadd/verdicts/empty.json"
rc="$(run_fleet s03 "$r3")"
j="$(cat "$OUT/s03.stdout")"
assert_eq "(3) empty 0-byte verdict -> anomaly empty=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.empty')"
assert_eq "(3) empty 0-byte verdict -> anomalies.total == 1 (empty counted into total)" "1" "$(echo "$j" | jq '.repos[0].anomalies.total')"

# ===================================================================================
# Scenario 4: non-object verdict (5)
# ===================================================================================
r4="$(mkrepo s04)"
printf '5' > "$r4/gadd/verdicts/scalar.json"
rc="$(run_fleet s04 "$r4")"
j="$(cat "$OUT/s04.stdout")"
assert_eq "(4) non-object verdict '5' -> anomaly not_object=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.not_object')"
assert_eq "(4) not_object -> anomalies.total == 1 (not_object counted into total)" "1" "$(echo "$j" | jq '.repos[0].anomalies.total')"

# ===================================================================================
# Scenario 5: lowercase verdict value "pass" -> schema_nonconformant
# ===================================================================================
r5="$(mkrepo s05)"
printf '{"sha":"a","base_sha":"b","verdict":"pass","findings":[]}' > "$r5/gadd/verdicts/lower.json"
rc="$(run_fleet s05 "$r5")"
j="$(cat "$OUT/s05.stdout")"
assert_eq "(5) lowercase verdict 'pass' -> schema_nonconformant=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.schema_nonconformant')"
assert_eq "(5) schema_nonconformant -> anomalies.total == 1 (counted into total)" "1" "$(echo "$j" | jq '.repos[0].anomalies.total')"

# ===================================================================================
# Scenario 6: findings array containing a stray scalar -> that verdict nonconformant,
# repo stays clean, sibling verdicts + 3 valid ledger entries stay INTACT in counts.
# ===================================================================================
r6="$(mkrepo s06)"
echo -n "$(valid_verdict PASS)" > "$r6/gadd/verdicts/v1.json"
echo -n "$(valid_verdict FAIL)" > "$r6/gadd/verdicts/v2.json"
echo -n "$(valid_verdict PASS)" > "$r6/gadd/verdicts/v3.json"
printf '{"sha":"z","base_sha":"y","verdict":"PASS","findings":[{"check":"c","severity":"MINOR","message":"m"}, "stray-scalar"]}' > "$r6/gadd/verdicts/bad.json"
{
  valid_escaped_line "check-a"
  echo
  valid_escaped_line "check-b"
  echo
  valid_escaped_line "check-c"
} > "$r6/gadd/ESCAPED.jsonl"
rc="$(run_fleet s06 "$r6")"
j="$(cat "$OUT/s06.stdout")"
assert_eq "(6) stray-scalar finding -> that verdict nonconformant" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.schema_nonconformant')"
assert_eq "(6) repo stays clean" "clean" "$(echo "$j" | jq -r '.repos[0].status')"
assert_eq "(6) sibling verdicts intact (3 admitted)" "3" "$(echo "$j" | jq '.repos[0].verdicts_total')"
assert_eq "(6) 3 valid ledger entries intact" "3" "$(echo "$j" | jq '.repos[0].escaped_total')"
assert_eq "(6) escaped_by_check CONTENTS exact (round-6: never previously asserted)" "true" \
  "$(echo "$j" | jq '.repos[0].escaped_by_check == {"check-a":1,"check-b":1,"check-c":1}')"
assert_eq "(6) pass_count == 2 (mixed-verdict repo: 2 PASS)" "2" "$(echo "$j" | jq '.repos[0].pass_count')"
assert_eq "(6) fail_count == 1 (mixed-verdict repo: 1 FAIL)" "1" "$(echo "$j" | jq '.repos[0].fail_count')"
assert_eq "(6) north_star.escaped_total == 3 (rollup sum over clean repos)" "3" "$(echo "$j" | jq '.north_star.escaped_total')"
assert_eq "(6) north_star.accepted_pushes == 2 (sum of PASS verdicts, not clean-repo count)" "2" "$(echo "$j" | jq '.north_star.accepted_pushes')"
assert_eq "(6) north_star.escaped_rate == 1.5 (measured: 3 escaped / 2 accepted, not flipped)" "1.5" "$(echo "$j" | jq -r '.north_star.escaped_rate')"

# ===================================================================================
# Scenario 7: findings as scalar "oops" -> nonconformant, disclosed
# ===================================================================================
r7="$(mkrepo s07)"
printf '{"sha":"a","base_sha":"b","verdict":"PASS","findings":"oops"}' > "$r7/gadd/verdicts/badfindings.json"
rc="$(run_fleet s07 "$r7")"
j="$(cat "$OUT/s07.stdout")"
assert_eq "(7) findings as scalar 'oops' -> schema_nonconformant=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.schema_nonconformant')"
assert_eq "(7) verdicts_total stays 0" "0" "$(echo "$j" | jq '.repos[0].verdicts_total')"

# ===================================================================================
# Scenario 8: non-object ledger line (42)
# ===================================================================================
r8="$(mkrepo s08)"
printf '42\n' > "$r8/gadd/ESCAPED.jsonl"
rc="$(run_fleet s08 "$r8")"
j="$(cat "$OUT/s08.stdout")"
assert_eq "(8) non-object ledger line '42' -> not_object=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.not_object')"
assert_eq "(8) escaped_total stays 0" "0" "$(echo "$j" | jq '.repos[0].escaped_total')"

# ===================================================================================
# Scenario 9: malformed ledger line ({not json)
# ===================================================================================
r9="$(mkrepo s09)"
printf '{not json\n' > "$r9/gadd/ESCAPED.jsonl"
rc="$(run_fleet s09 "$r9")"
j="$(cat "$OUT/s09.stdout")"
assert_eq "(9) malformed ledger line -> malformed_json=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.malformed_json')"

# ===================================================================================
# Scenario 10: ledger line with "check":5 -> schema_nonconformant
# ===================================================================================
r10="$(mkrepo s10)"
printf '{"date":"2026-07-14","accepted_sha":"x","check":5,"severity":"MAJOR","description":"d"}\n' > "$r10/gadd/ESCAPED.jsonl"
rc="$(run_fleet s10 "$r10")"
j="$(cat "$OUT/s10.stdout")"
assert_eq "(10) ledger 'check':5 -> schema_nonconformant=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.schema_nonconformant')"

# ===================================================================================
# Scenario 11: existing unreadable ledger -> escaped null + anomalous + excluded from
# north_star (even though verdicts in this repo are fine)
# ===================================================================================
r11="$(mkrepo s11)"
echo -n "$(valid_verdict PASS)" > "$r11/gadd/verdicts/v1.json"
echo -n "$(valid_verdict PASS)" > "$r11/gadd/verdicts/v2.json"
echo -n "$(valid_escaped_line)" > "$r11/gadd/ESCAPED.jsonl"
chmod 000 "$r11/gadd/ESCAPED.jsonl"
rc="$(run_fleet s11 "$r11")"
j="$(cat "$OUT/s11.stdout")"
chmod 644 "$r11/gadd/ESCAPED.jsonl"
if [ "$(id -u)" = "0" ]; then
  fail "(11) unreadable ledger -> status anomalous, escaped_total null" "skipped: running as root, permission bits ineffective"
  fail "(11) excluded from north_star" "skipped: running as root"
else
  assert_eq "(11) unreadable ledger -> status anomalous" "anomalous" "$(echo "$j" | jq -r '.repos[0].status')"
  assert_eq "(11) escaped_total null" "null" "$(echo "$j" | jq '.repos[0].escaped_total')"
  assert_eq "(11) verdicts_total NOT null (dir was fine)" "2" "$(echo "$j" | jq '.repos[0].verdicts_total')"
  assert_eq "(11) excluded from north_star (clean_repos=0)" "0" "$(echo "$j" | jq '.north_star.clean_repos')"
  assert_eq "(11) excluded from north_star (accepted_pushes=0)" "0" "$(echo "$j" | jq '.north_star.accepted_pushes')"
fi

# ===================================================================================
# Scenario 12: missing ledger -> zero + WARN, no anomaly
# ===================================================================================
r12="$(mkrepo s12)"
echo -n "$(valid_verdict PASS)" > "$r12/gadd/verdicts/v1.json"
rc="$(run_fleet s12 "$r12")"
j="$(cat "$OUT/s12.stdout")"
assert_eq "(12) missing ledger -> escaped_total 0" "0" "$(echo "$j" | jq '.repos[0].escaped_total')"
assert_eq "(12) missing ledger -> no anomaly" "0" "$(echo "$j" | jq '.repos[0].anomalies.total')"
assert_eq "(12) missing ledger -> status clean" "clean" "$(echo "$j" | jq -r '.repos[0].status')"
if grep -q "missing — escaped counted as 0" "$OUT/s12.stderr"; then
  pass "(12) WARN emitted for missing ledger"
else
  fail "(12) WARN emitted for missing ledger" "stderr did not contain expected WARN"
fi

# ===================================================================================
# Scenario 13: accepted_pushes 0 -> "unmeasured"
# ===================================================================================
r13="$(mkrepo s13)"
echo -n "$(valid_verdict FAIL)" > "$r13/gadd/verdicts/v1.json"
rc="$(run_fleet s13 "$r13")"
j="$(cat "$OUT/s13.stdout")"
assert_eq "(13) accepted_pushes 0 -> escaped_rate unmeasured" "unmeasured" "$(echo "$j" | jq -r '.north_star.escaped_rate')"
assert_eq "(13) accepted_pushes is 0" "0" "$(echo "$j" | jq '.north_star.accepted_pushes')"

# ===================================================================================
# Scenario 14: no args -> exit 1
# ===================================================================================
rc="$(run_fleet s14)"
assert_eq "(14) no args -> exit 1" "1" "$rc"
if [ -s "$OUT/s14.stderr" ] && grep -qi "usage" "$OUT/s14.stderr"; then
  pass "(14) usage printed to stderr"
else
  fail "(14) usage printed to stderr" "stderr: $(cat "$OUT/s14.stderr")"
fi

# ===================================================================================
# Scenario 15: zero disk writes (find -newer probe over repo + fixtures)
# ===================================================================================
sleep 1
marker="$OUT/marker-s15"
touch "$marker"
sleep 1
all_repos=()
for d in "$WORK"/s*; do
  [ -d "$d/gadd" ] && all_repos+=("$d")
done
rc="$(run_fleet s15 "${all_repos[@]}")"
changed="$(find "$WORK" -newer "$marker" 2>/dev/null)"
if [ -z "$changed" ]; then
  pass "(15) zero disk writes across all fixture repos"
else
  fail "(15) zero disk writes across all fixture repos" "changed: $changed"
fi

# ===================================================================================
# Scenario 16: every repo always emitted (repos in output == unique args with gadd/)
# ===================================================================================
r16a="$(mkrepo s16a)"
r16b="$(mkrepo s16b)"
r16c="$(mkrepo s16c)"
echo -n "$(valid_verdict PASS)" > "$r16a/gadd/verdicts/v1.json"
echo -n "$(valid_verdict PASS)" > "$r16b/gadd/verdicts/v1.json"
printf '{not valid' > "$r16c/gadd/verdicts/bad.json"
notgoverned="$WORK/s16-notgoverned"
mkdir -p "$notgoverned"   # no gadd/ inside — must be skipped entirely
rc="$(run_fleet s16 "$r16a" "$r16b" "$r16c" "$notgoverned")"
j="$(cat "$OUT/s16.stdout")"
assert_eq "(16) repos array length == 3 governed args (ungoverned skipped)" "3" "$(echo "$j" | jq '.repos | length')"

# ===================================================================================
# Scenario 17: CONCATENATED multi-doc verdict file -> ONE anomaly, not multiple
# admitted records
# ===================================================================================
r17="$(mkrepo s17)"
printf '{"sha":"a","base_sha":"b","verdict":"PASS","findings":[]}{"garbage":true}' > "$r17/gadd/verdicts/multidoc.json"
rc="$(run_fleet s17 "$r17")"
j="$(cat "$OUT/s17.stdout")"
assert_eq "(17) multi-doc file -> verdicts_total stays 0 (not admitted)" "0" "$(echo "$j" | jq '.repos[0].verdicts_total')"
assert_eq "(17) multi-doc file -> exactly ONE anomaly total" "1" "$(echo "$j" | jq '.repos[0].anomalies.total')"

# ===================================================================================
# Scenario 18: verdict file with a raw NUL byte -> anomaly, never silently
# mutated-then-admitted
# ===================================================================================
r18="$(mkrepo s18)"
printf '{"sha":"a\000b","base_sha":"c","verdict":"PASS","findings":[]}' > "$r18/gadd/verdicts/nul.json"
rc="$(run_fleet s18 "$r18")"
j="$(cat "$OUT/s18.stdout")"
assert_eq "(18) raw NUL byte -> verdicts_total stays 0 (never admitted)" "0" "$(echo "$j" | jq '.repos[0].verdicts_total')"
assert_eq "(18) raw NUL byte -> disclosed as an anomaly" "1" "$(echo "$j" | jq '.repos[0].anomalies.total')"

# ===================================================================================
# Scenario 19: directory named x.json inside verdicts/ -> not_a_file anomaly
# ===================================================================================
r19="$(mkrepo s19)"
mkdir -p "$r19/gadd/verdicts/x.json"
rc="$(run_fleet s19 "$r19")"
j="$(cat "$OUT/s19.stdout")"
assert_eq "(19) directory named x.json -> not_a_file=1" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.not_a_file')"
assert_eq "(19) directory named x.json -> NOT misclassified as empty" "0" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.empty')"
assert_eq "(19) not_a_file -> anomalies.total == 1 (not_a_file counted into total)" "1" "$(echo "$j" | jq '.repos[0].anomalies.total')"

# ===================================================================================
# Scenario 20: duplicate repo path args -> deduped with WARN, counted once
# ===================================================================================
r20="$(mkrepo s20)"
echo -n "$(valid_verdict PASS)" > "$r20/gadd/verdicts/v1.json"
rc="$(run_fleet s20 "$r20" "$r20")"
j="$(cat "$OUT/s20.stdout")"
assert_eq "(20) duplicate args -> repos array length 1" "1" "$(echo "$j" | jq '.repos | length')"
if grep -qi "duplicate" "$OUT/s20.stderr"; then
  pass "(20) WARN emitted for duplicate path"
else
  fail "(20) WARN emitted for duplicate path" "stderr: $(cat "$OUT/s20.stderr")"
fi

# ===================================================================================
# Scenario 21: positive control — docs/example-verdict.json admitted clean
# (8 findings: 5 CRITICAL, 3 MAJOR)
# ===================================================================================
r21="$(mkrepo s21)"
cp "$REPO_ROOT/docs/example-verdict.json" "$r21/gadd/verdicts/only.json"
rc="$(run_fleet s21 "$r21")"
j="$(cat "$OUT/s21.stdout")"
assert_eq "(21) positive control -> status clean" "clean" "$(echo "$j" | jq -r '.repos[0].status')"
assert_eq "(21) positive control -> verdicts_total 1" "1" "$(echo "$j" | jq '.repos[0].verdicts_total')"
assert_eq "(21) positive control -> CRITICAL 5" "5" "$(echo "$j" | jq '.repos[0].findings.CRITICAL')"
assert_eq "(21) positive control -> MAJOR 3" "3" "$(echo "$j" | jq '.repos[0].findings.MAJOR')"
assert_eq "(21) positive control -> zero anomalies" "0" "$(echo "$j" | jq '.repos[0].anomalies.total')"

# ===================================================================================
# Scenario 22: prototype-pollution check names in ledger ("__proto__", "toString",
# "constructor") -> all three land as OWN keys with value 1, nothing lost, nothing
# fabricated. Asserts escaped_by_check CONTENTS, not just totals.
# ===================================================================================
r22="$(mkrepo s22)"
{
  valid_escaped_line "__proto__"
  echo
  valid_escaped_line "toString"
  echo
  valid_escaped_line "constructor"
} > "$r22/gadd/ESCAPED.jsonl"
rc="$(run_fleet s22 "$r22")"
j="$(cat "$OUT/s22.stdout")"
assert_eq "(22) proto-key checks -> escaped_total 3" "3" "$(echo "$j" | jq '.repos[0].escaped_total')"
assert_eq "(22) escaped_by_check[\"__proto__\"] == 1 (not silently lost)" "1" \
  "$(echo "$j" | jq '.repos[0].escaped_by_check["__proto__"]')"
assert_eq "(22) escaped_by_check[\"toString\"] == 1 (not fabricated garbage)" "1" \
  "$(echo "$j" | jq '.repos[0].escaped_by_check["toString"]')"
assert_eq "(22) escaped_by_check[\"constructor\"] == 1 (not fabricated garbage)" "1" \
  "$(echo "$j" | jq '.repos[0].escaped_by_check["constructor"]')"
assert_eq "(22) escaped_by_check exact contents, exactly 3 keys" "true" \
  "$(echo "$j" | jq '.repos[0].escaped_by_check == {"__proto__":1,"toString":1,"constructor":1}')"

# ===================================================================================
# Scenario 23: chmod-000 on a governed repo's directory (statting gadd/ hits EACCES,
# not ENOENT) -> the repo must NOT vanish: emitted with status anomalous, all-null
# counts, and an unreadable anomaly. Perms restored immediately after the run.
# ===================================================================================
r23="$(mkrepo s23)"
echo -n "$(valid_verdict PASS)" > "$r23/gadd/verdicts/v1.json"
chmod 000 "$r23"
rc="$(run_fleet s23 "$r23")"
j="$(cat "$OUT/s23.stdout")"
chmod 755 "$r23"
if [ "$(id -u)" = "0" ]; then
  fail "(23) chmod-000 governed repo -> EMITTED, not vanished" "skipped: running as root, permission bits ineffective"
  fail "(23) chmod-000 governed repo -> anomalous with null counts + unreadable anomaly" "skipped: running as root"
else
  assert_eq "(23) chmod-000 governed repo -> EMITTED (repos length 1)" "1" "$(echo "$j" | jq '.repos | length')"
  assert_eq "(23) status anomalous" "anomalous" "$(echo "$j" | jq -r '.repos[0].status')"
  assert_eq "(23) verdicts_total null (never fabricate zeros)" "null" "$(echo "$j" | jq '.repos[0].verdicts_total')"
  assert_eq "(23) pass_count null" "null" "$(echo "$j" | jq '.repos[0].pass_count')"
  assert_eq "(23) escaped_total null" "null" "$(echo "$j" | jq '.repos[0].escaped_total')"
  assert_eq "(23) unreadable anomaly disclosed" "1" "$(echo "$j" | jq '.repos[0].anomalies.by_reason.unreadable')"
  assert_eq "(23) excluded from north_star (clean_repos=0)" "0" "$(echo "$j" | jq '.north_star.clean_repos')"
fi

# ===================================================================================
# Scenario 24: same repo passed directly AND via a symlink alias -> deduped on the
# resolved real path: repos length 1, duplicate WARN, north_star counts it once.
# ===================================================================================
r24="$(mkrepo s24)"
echo -n "$(valid_verdict PASS)" > "$r24/gadd/verdicts/v1.json"
ln -s "$r24" "$WORK/s24-alias"
rc="$(run_fleet s24 "$r24" "$WORK/s24-alias")"
j="$(cat "$OUT/s24.stdout")"
assert_eq "(24) symlink alias -> repos array length 1" "1" "$(echo "$j" | jq '.repos | length')"
if grep -qi "duplicate" "$OUT/s24.stderr"; then
  pass "(24) WARN emitted for symlink-aliased duplicate"
else
  fail "(24) WARN emitted for symlink-aliased duplicate" "stderr: $(cat "$OUT/s24.stderr")"
fi
assert_eq "(24) north_star counts once (accepted_pushes=1, not 2)" "1" "$(echo "$j" | jq '.north_star.accepted_pushes')"
assert_eq "(24) north_star clean_repos 1" "1" "$(echo "$j" | jq '.north_star.clean_repos')"

# ===================================================================================
# Scenario 25: window.first / window.last derived from admitted-verdict mtimes.
# Three valid PASS verdicts given controlled distinct mtimes via `touch -t`; the
# reported window must span the earliest and latest mtime dates. Guards an
# off-by-one in the sorted-mtime selection (first/last).
# ===================================================================================
r25="$(mkrepo s25)"
echo -n "$(valid_verdict PASS)" > "$r25/gadd/verdicts/v1.json"
echo -n "$(valid_verdict PASS)" > "$r25/gadd/verdicts/v2.json"
echo -n "$(valid_verdict PASS)" > "$r25/gadd/verdicts/v3.json"
touch -t 202603030303 "$r25/gadd/verdicts/v1.json"
touch -t 202601010101 "$r25/gadd/verdicts/v2.json"
touch -t 202607070707 "$r25/gadd/verdicts/v3.json"
rc="$(run_fleet s25 "$r25")"
j="$(cat "$OUT/s25.stdout")"
assert_eq "(25) window.first == earliest mtime date" "2026-01-01" "$(echo "$j" | jq -r '.repos[0].window.first')"
assert_eq "(25) window.last == latest mtime date" "2026-07-07" "$(echo "$j" | jq -r '.repos[0].window.last')"

# ===================================================================================
# Scenario 26: mixed fleet in ONE invocation — repoX clean (one valid PASS verdict),
# repoY chmod-000 (anomalous). north_star must count ONLY the clean repo: a mutation
# reporting ALL repos as clean would inflate clean_repos to 2 here. Perms restored
# immediately after the run (scenario 23 style).
# ===================================================================================
r26x="$(mkrepo s26x)"
r26y="$(mkrepo s26y)"
echo -n "$(valid_verdict PASS)" > "$r26x/gadd/verdicts/v1.json"
echo -n "$(valid_verdict PASS)" > "$r26y/gadd/verdicts/v1.json"
chmod 000 "$r26y"
rc="$(run_fleet s26 "$r26x" "$r26y")"
j="$(cat "$OUT/s26.stdout")"
chmod 755 "$r26y"
assert_eq "(26) mixed fleet -> repos array length 2" "2" "$(echo "$j" | jq '.repos | length')"
if [ "$(id -u)" = "0" ]; then
  fail "(26) mixed fleet -> north_star.clean_repos == 1" "skipped: running as root, permission bits ineffective"
  fail "(26) mixed fleet -> north_star.anomalous_repos length == 1" "skipped: running as root"
  fail "(26) mixed fleet -> north_star.accepted_pushes == 1" "skipped: running as root"
  fail "(26) anomalous_repos entries are path strings, not objects" "skipped: running as root"
else
  assert_eq "(26) mixed fleet -> north_star.clean_repos == 1" "1" "$(echo "$j" | jq '.north_star.clean_repos')"
  assert_eq "(26) mixed fleet -> north_star.anomalous_repos length == 1" "1" "$(echo "$j" | jq '.north_star.anomalous_repos | length')"
  assert_eq "(26) mixed fleet -> north_star.accepted_pushes == 1" "1" "$(echo "$j" | jq '.north_star.accepted_pushes')"
  assert_eq "(26) anomalous_repos entries are path strings, not objects" "string" "$(echo "$j" | jq -r '.north_star.anomalous_repos[0] | type')"
fi

# ===================================================================================
# Scenario 27: ONE repo carrying TWO different anomaly classes (one empty 0-byte
# verdict + one malformed-JSON verdict) -> anomalies.total must be 2. Kills
# hardcoded-total mutants (total=1) and single-class-total mutants
# (total=by_reason.empty or total=by_reason.malformed_json alone) that every
# single-anomaly fixture survives. Does NOT cover class-drop variants that omit a
# class absent here (e.g. dropping not_a_file from the sum) — those are pinned by
# the per-scenario anomalies.total assertions in scenarios 2/3/4/5/19.
# ===================================================================================
r27="$(mkrepo s27)"
: > "$r27/gadd/verdicts/empty.json"
printf '{not valid json' > "$r27/gadd/verdicts/bad.json"
rc="$(run_fleet s27 "$r27")"
j="$(cat "$OUT/s27.stdout")"
assert_eq "(27) empty + malformed in one repo -> anomalies.total == 2 (cross-class sum)" "2" "$(echo "$j" | jq '.repos[0].anomalies.total')"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
