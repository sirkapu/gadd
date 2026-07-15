#!/usr/bin/env bash
# tests/parity-fixtures.sh — acceptance corpus for the ratchet metric-parity work
# (docs/metric-parity.md): adapters/lv/checks/lib/parity-metrics.mjs (the measurement
# engine) and adapters/lv/checks/10-ratchet-parity.sh (the gating check). Style matches
# tests/fleet-fixtures.sh: numbered scenarios, assert_eq, mktemp fixtures, PASS/FAIL per
# scenario, ALL-PASS summary line, non-zero exit on any failure. jq is allowed HERE (test
# harness, not the instrument under test). Deliberately does not depend on eslint or tsc
# being installed — fixtures without node_modules exercise the null/unavailable path;
# the pure-scan counting metrics (any_count, eslint_disables, oversized_files,
# duplicate_windows) are fully exercised without any tooling.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$REPO_ROOT/adapters/lv/checks/10-ratchet-parity.sh"
ENGINE="$REPO_ROOT/adapters/lv/checks/lib/parity-metrics.mjs"

WORK="$(mktemp -d)"
OUT="$(mktemp -d)"   # stdout/stderr/findings/metrics land here — kept OUTSIDE $WORK so
                      # the zero-disk-writes probe (scenario 9) is never polluted by our
                      # own test-harness redirects.

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

# --- fixture / runner helpers -------------------------------------------------------

count_findings() { jq -s 'length' "$1" 2>/dev/null || echo 0; }

# run_check PREFIX FIXTURE_DIR -> runs 10-ratchet-parity.sh with cwd=FIXTURE_DIR.
# Writes stdout/stderr to $OUT/<prefix>.{stdout,stderr}, findings ndjson to
# $OUT/<prefix>.findings.ndjson, merged metrics json to $OUT/<prefix>.metrics.json.
# Echoes the exit code.
run_check() {
  local prefix="$1" fixture="$2"
  local findings="$OUT/$prefix.findings.ndjson"
  local metrics="$OUT/$prefix.metrics.json"
  : > "$findings"
  (
    cd "$fixture" || exit 99
    export GADD_BASE="deadbeef"
    export GADD_HEAD="deadbeef"
    export GADD_FINDINGS="$findings"
    export GADD_METRICS_FILE="$metrics"
    bash "$CHECK"
  ) >"$OUT/$prefix.stdout" 2>"$OUT/$prefix.stderr"
  echo $?
}

# run_engine PREFIX FIXTURE_DIR -> runs parity-metrics.mjs with cwd=FIXTURE_DIR.
run_engine() {
  local prefix="$1" fixture="$2"
  (
    cd "$fixture" || exit 99
    node "$ENGINE"
  ) >"$OUT/$prefix.stdout" 2>"$OUT/$prefix.stderr"
  echo $?
}

# gen_ts_lines N -> emits N lines of trivial TS statements, NO trailing newline, so
# `content.split("\n")` inside the engine yields exactly N elements (matches the
# parity-source semantics of counting split segments, not visual line count).
gen_ts_lines() {
  local n="$1" i out=""
  for ((i = 1; i <= n; i++)); do
    out+="const v$i = $i;"
    [ "$i" -lt "$n" ] && out+=$'\n'
  done
  printf '%s' "$out"
}

# ===================================================================================
# Scenario 1: no parity.gating block -> check exits 0, notice emitted, measured
# values still merged into the metrics file under a "parity" key.
# ===================================================================================
r1="$WORK/s01"; mkdir -p "$r1/gadd" "$r1/src"
printf '{"accepted_sha":"x"}' > "$r1/gadd/BASELINE.json"
printf 'export const a = 1;\n' > "$r1/src/a.ts"
rc="$(run_check s01 "$r1")"
assert_eq "(1) no parity.gating block -> exit 0" "0" "$rc"
if grep -q "parity baseline not configured — measuring only, not gating" "$OUT/s01.stderr"; then
  pass "(1) adoption notice emitted to stderr"
else
  fail "(1) adoption notice emitted to stderr" "stderr: $(cat "$OUT/s01.stderr")"
fi
assert_eq "(1) measured values merged under parity key" "true" "$(jq -r '.parity.available' "$OUT/s01.metrics.json")"
assert_eq "(1) no findings emitted (measure-only)" "0" "$(count_findings "$OUT/s01.findings.ndjson")"

# ===================================================================================
# Scenario 2: parity.gating configured + source regresses any_count beyond baseline
# -> MAJOR finding.
# ===================================================================================
r2="$WORK/s02"; mkdir -p "$r2/gadd" "$r2/src"
printf '{"accepted_sha":"x","parity":{"gating":{"any_count":0}}}' > "$r2/gadd/BASELINE.json"
printf 'export const x: any = 1;\n' > "$r2/src/a.ts"
rc="$(run_check s02 "$r2")"
assert_eq "(2) exit 0 (findings drive the verdict, not this check's own exit code)" "0" "$rc"
f2="$(jq -s '.' "$OUT/s02.findings.ndjson")"
assert_eq "(2) any_count regression -> exactly 1 MAJOR ratchet-parity finding" "1" \
  "$(echo "$f2" | jq '[.[] | select(.check=="ratchet-parity" and .severity=="MAJOR" and (.message|test("any_count regressed: 0 -> 1")))] | length')"

# ===================================================================================
# Scenario 3: measured value exactly at baseline -> no finding.
# ===================================================================================
r3="$WORK/s03"; mkdir -p "$r3/gadd" "$r3/src"
printf '{"accepted_sha":"x","parity":{"gating":{"any_count":1}}}' > "$r3/gadd/BASELINE.json"
printf 'export const x: any = 1;\n' > "$r3/src/a.ts"
rc="$(run_check s03 "$r3")"
assert_eq "(3) exit 0" "0" "$rc"
f3="$(jq -s '.' "$OUT/s03.findings.ndjson")"
assert_eq "(3) at-baseline -> zero ratchet-parity findings" "0" \
  "$(echo "$f3" | jq '[.[] | select(.check=="ratchet-parity")] | length')"

# ===================================================================================
# Scenario 4: exempt path with `any` usages -> excluded from any_count.
# ===================================================================================
r4="$WORK/s04"; mkdir -p "$r4/gadd" "$r4/src/legacy"
printf '{"accepted_sha":"x","parity":{"exempt":["src/legacy/"]}}' > "$r4/gadd/BASELINE.json"
printf 'export const a: any = 1;\nexport const b: any = 2;\n' > "$r4/src/legacy/old.ts"
printf 'export const c = 1;\n' > "$r4/src/good.ts"
rc="$(run_engine s04 "$r4")"
assert_eq "(4) engine exit 0" "0" "$rc"
assert_eq "(4) exempt path's 'any' usages excluded -> any_count 0" "0" \
  "$(jq -r '.gating.any_count' "$OUT/s04.stdout")"

# ===================================================================================
# Scenario 5: oversized file beyond ceiling counted; at-ceiling file is not.
# ===================================================================================
r5="$WORK/s05"; mkdir -p "$r5/src"
gen_ts_lines 200 > "$r5/src/atceiling.ts"
gen_ts_lines 201 > "$r5/src/oversized.ts"
rc="$(run_engine s05 "$r5")"
assert_eq "(5) engine exit 0" "0" "$rc"
assert_eq "(5) only the file beyond the ceiling is oversized" "1" \
  "$(jq -r '.gating.oversized_files' "$OUT/s05.stdout")"

# ===================================================================================
# Scenario 6: duplicate_windows detects a copied 6-line block across two files.
# ===================================================================================
r6="$WORK/s06"; mkdir -p "$r6/src"
block=$'function shared() {\n  const alpha = 1;\n  const beta = 2;\n  const gamma = 3;\n  const delta = 4;\n  const epsilon = 5;\n}\n'
printf '%s' "$block" > "$r6/src/dup1.ts"
printf '%s' "$block" > "$r6/src/dup2.ts"
rc="$(run_engine s06 "$r6")"
assert_eq "(6) engine exit 0" "0" "$rc"
assert_eq "(6) identical 6-line block copied across two files -> duplicate_windows 1" "1" \
  "$(jq -r '.gating.duplicate_windows' "$OUT/s06.stdout")"

# ===================================================================================
# Scenario 7: configured gating metric whose tool is unavailable (no local eslint
# install in the fixture) -> MAJOR "unmeasurable but gating" finding, never a silent
# pass and never a fabricated 0.
# ===================================================================================
r7="$WORK/s07"; mkdir -p "$r7/gadd" "$r7/src"
printf '{"accepted_sha":"x","parity":{"gating":{"eslint_errors":0}}}' > "$r7/gadd/BASELINE.json"
printf 'export const a = 1;\n' > "$r7/src/a.ts"
rc="$(run_check s07 "$r7")"
assert_eq "(7) exit 0" "0" "$rc"
f7="$(jq -s '.' "$OUT/s07.findings.ndjson")"
assert_eq "(7) eslint unavailable + gating configured -> MAJOR unmeasurable finding" "1" \
  "$(echo "$f7" | jq '[.[] | select(.check=="ratchet-parity" and .severity=="MAJOR" and (.message|test("eslint_errors unmeasurable but gating")))] | length')"

# ===================================================================================
# Scenario 8: no src/ dir -> available:false, exit 0.
# ===================================================================================
r8="$WORK/s08"; mkdir -p "$r8"
rc="$(run_engine s08 "$r8")"
assert_eq "(8) no src/ dir -> exit 0" "0" "$rc"
assert_eq "(8) no src/ dir -> exact unavailable payload" '{"available":false,"reason":"no src"}' \
  "$(tr -d '\n' < "$OUT/s08.stdout")"

# ===================================================================================
# Scenario 9: engine writes nothing to disk (find -newer probe over the fixture).
# ===================================================================================
r9="$WORK/s09"; mkdir -p "$r9/gadd" "$r9/src"
printf '{"accepted_sha":"x"}' > "$r9/gadd/BASELINE.json"
printf 'export const x: any = 1;\n// eslint-disable-next-line\n' > "$r9/src/a.ts"
sleep 1
marker="$OUT/marker-s09"
touch "$marker"
sleep 1
rc="$(run_engine s09 "$r9")"
changed="$(find "$r9" -newer "$marker" 2>/dev/null)"
if [ "$rc" = "0" ] && [ -z "$changed" ]; then
  pass "(9) engine writes nothing to disk"
else
  fail "(9) engine writes nothing to disk" "rc=$rc changed: $changed"
fi

# ===================================================================================
# Scenario 10: a DANGLING node_modules/.bin/tsc symlink (points at a nonexistent
# target) + parity.gating configuring tsc_errors -> engine reports tsc_errors null
# AND the check emits the MAJOR unmeasurable finding. existsSync follows symlinks, so
# this exercises the toolAvailable() early-return (dangling link -> tool "absent"),
# not the post-spawn runtime-failure guards — scenario 14 covers the runtime path.
# ===================================================================================
r10="$WORK/s10"; mkdir -p "$r10/gadd" "$r10/src" "$r10/node_modules/.bin"
printf '{"accepted_sha":"x","parity":{"gating":{"tsc_errors":0}}}' > "$r10/gadd/BASELINE.json"
printf '{"compilerOptions":{"noEmit":true}}' > "$r10/tsconfig.json"
printf 'export const a = 1;\n' > "$r10/src/a.ts"
ln -s "$r10/does-not-exist-tsc-target" "$r10/node_modules/.bin/tsc"
rc="$(run_check s10 "$r10")"
assert_eq "(10) exit 0" "0" "$rc"
assert_eq "(10) dangling tsc symlink -> tsc_errors reported null, never fabricated 0" "null" \
  "$(jq -r '.parity.gating.tsc_errors' "$OUT/s10.metrics.json")"
f10="$(jq -s '.' "$OUT/s10.findings.ndjson")"
assert_eq "(10) tsc unmeasurable + gating configured -> MAJOR unmeasurable finding" "1" \
  "$(echo "$f10" | jq '[.[] | select(.check=="ratchet-parity" and .severity=="MAJOR" and (.message|test("tsc_errors unmeasurable but gating")))] | length')"

# ===================================================================================
# Scenario 11: parity.gating with a malformed (non-integer) baseline value
# {"any_count":"abc"} + source that regresses any_count -> MAJOR malformed-baseline
# finding, never a silent pass (a non-integer baseline makes both -gt and -lt integer
# comparisons fail silently, so a real regression would otherwise sail through).
# ===================================================================================
r11="$WORK/s11"; mkdir -p "$r11/gadd" "$r11/src"
printf '{"accepted_sha":"x","parity":{"gating":{"any_count":"abc"}}}' > "$r11/gadd/BASELINE.json"
printf 'export const x: any = 1;\n' > "$r11/src/a.ts"
rc="$(run_check s11 "$r11")"
assert_eq "(11) exit 0" "0" "$rc"
f11="$(jq -s '.' "$OUT/s11.findings.ndjson")"
assert_eq "(11) malformed baseline gating value -> MAJOR malformed-baseline finding" "1" \
  "$(echo "$f11" | jq '[.[] | select(.check=="ratchet-parity" and .severity=="MAJOR" and (.message|test("malformed baseline gating value for any_count: abc")))] | length')"
assert_eq "(11) malformed baseline -> no silent pass (exactly 1 ratchet-parity finding)" "1" \
  "$(echo "$f11" | jq '[.[] | select(.check=="ratchet-parity")] | length')"

# ===================================================================================
# Scenario 12: eslint_disables — the last pure-scan metric without coverage. Source
# contains two eslint-disable directives; the engine must measure exactly 2 (kills a
# deleted-counter mutation that would report 0), and with parity.gating configuring
# eslint_disables below the measured count the check must fire the MAJOR regression.
# ===================================================================================
r12="$WORK/s12"; mkdir -p "$r12/gadd" "$r12/src"
printf '{"accepted_sha":"x","parity":{"gating":{"eslint_disables":1}}}' > "$r12/gadd/BASELINE.json"
printf '// eslint-disable-next-line no-console\nconsole.log(1);\n/* eslint-disable no-unused-vars */\nexport const a = 1;\n' > "$r12/src/a.ts"
rc="$(run_engine s12e "$r12")"
assert_eq "(12) engine exit 0" "0" "$rc"
assert_eq "(12) two eslint-disable directives -> engine measures eslint_disables 2" "2" \
  "$(jq -r '.gating.eslint_disables' "$OUT/s12e.stdout")"
rc="$(run_check s12 "$r12")"
assert_eq "(12) check exit 0" "0" "$rc"
f12="$(jq -s '.' "$OUT/s12.findings.ndjson")"
assert_eq "(12) eslint_disables above baseline -> exactly 1 MAJOR regression finding" "1" \
  "$(echo "$f12" | jq '[.[] | select(.check=="ratchet-parity" and .severity=="MAJOR" and (.message|test("eslint_disables regressed: 1 -> 2")))] | length')"

# ===================================================================================
# Scenario 13: .d.ts auto-exemption — a generated-style .d.ts full of `as any`
# alongside a clean .ts, with NO exempt config, must contribute nothing to any_count
# (kills a removed-.d.ts-exemption mutation that would false-fail gates on generated
# declaration files). source_file_count 1 pins that the .d.ts is excluded from the
# source set itself, not merely uncounted.
# ===================================================================================
r13="$WORK/s13"; mkdir -p "$r13/src"
printf 'declare const g: unknown as any;\nexport type T = string as any;\nconst z = 1 as any;\n' > "$r13/src/gen.d.ts"
printf 'export const clean = 1;\n' > "$r13/src/clean.ts"
rc="$(run_engine s13 "$r13")"
assert_eq "(13) engine exit 0" "0" "$rc"
assert_eq "(13) .d.ts 'as any' occurrences auto-exempt (no exempt config) -> any_count 0" "0" \
  "$(jq -r '.gating.any_count' "$OUT/s13.stdout")"
assert_eq "(13) .d.ts excluded from source set -> source_file_count 1" "1" \
  "$(jq -r '.trend.source_file_count' "$OUT/s13.stdout")"

# ===================================================================================
# Scenario 14: a tsc that exists, RUNS, and crashes — executable fake
# node_modules/.bin/tsc printing a stack trace (no `error TS` diagnostics) and exiting
# 2 — with parity.gating configuring tsc_errors. This exercises the REAL post-spawn
# runtime-failure path (nonzero exit + zero parsed diagnostics = unmeasurable): the
# engine must report null, never a fabricated 0, and the check fires the MAJOR
# unmeasurable finding.
# ===================================================================================
r14="$WORK/s14"; mkdir -p "$r14/gadd" "$r14/src" "$r14/node_modules/.bin"
printf '{"accepted_sha":"x","parity":{"gating":{"tsc_errors":0}}}' > "$r14/gadd/BASELINE.json"
printf '{"compilerOptions":{"noEmit":true}}' > "$r14/tsconfig.json"
printf 'export const a = 1;\n' > "$r14/src/a.ts"
cat > "$r14/node_modules/.bin/tsc" <<'FAKETSC'
#!/bin/sh
echo "TypeError: Cannot read properties of undefined (reading 'crash')" >&2
echo "    at Object.<anonymous> (/fake/tsc.js:1:1)" >&2
exit 2
FAKETSC
chmod +x "$r14/node_modules/.bin/tsc"
rc="$(run_engine s14e "$r14")"
assert_eq "(14) engine exit 0" "0" "$rc"
assert_eq "(14) crashing tsc (nonzero exit, no TS diagnostics) -> tsc_errors null, never 0" "null" \
  "$(jq -r '.gating.tsc_errors' "$OUT/s14e.stdout")"
rc="$(run_check s14 "$r14")"
assert_eq "(14) check exit 0" "0" "$rc"
f14="$(jq -s '.' "$OUT/s14.findings.ndjson")"
assert_eq "(14) crashing tsc + gating configured -> MAJOR unmeasurable finding" "1" \
  "$(echo "$f14" | jq '[.[] | select(.check=="ratchet-parity" and .severity=="MAJOR" and (.message|test("tsc_errors unmeasurable but gating")))] | length')"

# ===================================================================================
# Scenario 15: exempt-prefix segment boundary — exempt "src/legacy" (no trailing
# slash) must cover src/legacy/** but NOT the sibling src/legacy_v2/, which merely
# shares the string prefix. The `as any` in src/legacy_v2/live.ts is COUNTED and the
# regression finding fires; src/legacy/inner.ts stays exempt (any_count is exactly 1,
# not 2, pinning both directions of the boundary).
# ===================================================================================
r15="$WORK/s15"; mkdir -p "$r15/gadd" "$r15/src/legacy" "$r15/src/legacy_v2"
printf '{"accepted_sha":"x","parity":{"exempt":["src/legacy"],"gating":{"any_count":0}}}' > "$r15/gadd/BASELINE.json"
printf 'export const inner: any = 1;\n' > "$r15/src/legacy/inner.ts"
printf 'export const live: any = 1;\n' > "$r15/src/legacy_v2/live.ts"
rc="$(run_engine s15e "$r15")"
assert_eq "(15) engine exit 0" "0" "$rc"
assert_eq "(15) src/legacy_v2 counted, src/legacy exempt -> any_count exactly 1" "1" \
  "$(jq -r '.gating.any_count' "$OUT/s15e.stdout")"
rc="$(run_check s15 "$r15")"
assert_eq "(15) check exit 0" "0" "$rc"
f15="$(jq -s '.' "$OUT/s15.findings.ndjson")"
assert_eq "(15) legacy_v2 regression not swallowed by exempt sibling -> MAJOR finding" "1" \
  "$(echo "$f15" | jq '[.[] | select(.check=="ratchet-parity" and .severity=="MAJOR" and (.message|test("any_count regressed: 0 -> 1")))] | length')"

# ===================================================================================
echo ""
echo "=================================================================="
echo "$NPASS/$N PASS"
echo "=================================================================="

if [ "$NFAIL" -gt 0 ]; then
  exit 1
fi
exit 0
