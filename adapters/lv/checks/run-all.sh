#!/usr/bin/env bash
# Aggregates all checks into one verdict JSON. Exit 1 on FAIL (job-level signal only — never a merge gate).
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
export GADD_BASE="${GADD_BASE:-$(jq -r '.accepted_sha' gadd/BASELINE.json)}"
export GADD_HEAD="${GADD_HEAD:-$(git rev-parse HEAD)}"
export GADD_FINDINGS="/tmp/gadd-findings.ndjson"
: > "$GADD_FINDINGS"

for c in "$DIR"/0*.sh; do bash "$c" || echo "::warning::check $(basename "$c") errored (non-fatal)" >&2; done

mkdir -p gadd/verdicts
findings="$(jq -s '.' "$GADD_FINDINGS" 2>/dev/null || echo '[]')"
crit=$(echo "$findings" | jq '[.[] | select(.severity=="CRITICAL")] | length')
maj=$(echo  "$findings" | jq '[.[] | select(.severity=="MAJOR")]    | length')
min=$(echo  "$findings" | jq '[.[] | select(.severity=="MINOR")]    | length')
verdict="PASS"; { [ "$crit" -gt 0 ] || [ "$maj" -gt 0 ] || [ "$min" -ge 3 ]; } && verdict="FAIL"
metrics="$(cat /tmp/gadd-metrics.json 2>/dev/null || echo '{}')"

jq -n --arg sha "$GADD_HEAD" --arg base "$GADD_BASE" --arg v "$verdict" \
      --argjson f "$findings" --argjson m "$metrics" \
      '{sha:$sha, base_sha:$base, verdict:$v, findings:$f, metrics:$m}' \
      | tee "gadd/verdicts/${GADD_HEAD}.json"

{ echo "## GADD verdict: **$verdict** (\`${GADD_HEAD:0:7}\` vs accepted \`${GADD_BASE:0:7}\`)"
  echo ""; echo "| Check | Severity | Message |"; echo "|---|---|---|"
  echo "$findings" | jq -r '.[] | "| \(.check) | \(.severity) | \(.message) |"'
} >> "${GITHUB_STEP_SUMMARY:-/dev/null}" 2>/dev/null || true

[ "$verdict" = "PASS" ]
