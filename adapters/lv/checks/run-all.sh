#!/usr/bin/env bash
# Aggregates all checks into one verdict JSON. Exit 1 on FAIL (job-level signal only — never a merge gate).
# Validates BASELINE.json and the emitted verdict against spec schemas when installed (.gadd/schemas/).
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMAS="$DIR/../schemas"

if [ -f "$SCHEMAS/baseline.schema.json" ]; then
  jq -e --slurpfile s "$SCHEMAS/baseline.schema.json" '($s[0].required - keys) == []' gadd/BASELINE.json >/dev/null \
    || { echo "::error::gadd/BASELINE.json missing required fields per baseline.schema.json" >&2; exit 1; }
fi

export GADD_BASE="${GADD_BASE:-$(jq -r '.accepted_sha' gadd/BASELINE.json)}"
export GADD_HEAD="${GADD_HEAD:-$(git rev-parse HEAD)}"
export GADD_FINDINGS="/tmp/gadd-findings.ndjson"
: > "$GADD_FINDINGS"

# 01–09 ship with gadd; deployments may add their own NN-*.sh extensions (e.g.
# 90-deployment-ratchet.sh) — they run in lexical order and report via lib/common.sh.
for c in "$DIR"/[0-9]*.sh; do bash "$c" || echo "::warning::check $(basename "$c") errored (non-fatal)" >&2; done

mkdir -p gadd/verdicts
findings="$(jq -s '.' "$GADD_FINDINGS" 2>/dev/null || echo '[]')"
crit=$(echo "$findings" | jq '[.[] | select(.severity=="CRITICAL")] | length')
maj=$(echo  "$findings" | jq '[.[] | select(.severity=="MAJOR")]    | length')
min=$(echo  "$findings" | jq '[.[] | select(.severity=="MINOR")]    | length')
verdict="PASS"; { [ "$crit" -gt 0 ] || [ "$maj" -gt 0 ] || [ "$min" -ge 3 ]; } && verdict="FAIL"
metrics="$(cat /tmp/gadd-metrics.json 2>/dev/null || echo '{}')"

verdict_json="$(jq -n --arg sha "$GADD_HEAD" --arg base "$GADD_BASE" --arg v "$verdict" \
      --argjson f "$findings" --argjson m "$metrics" \
      '{sha:$sha, base_sha:$base, verdict:$v, findings:$f, metrics:$m}')"
printf '%s\n' "$verdict_json" | tee "gadd/verdicts/${GADD_HEAD}.json"

schema_bad=0
if [ -f "$SCHEMAS/verdict.schema.json" ]; then
  printf '%s' "$verdict_json" | jq -e --slurpfile s "$SCHEMAS/verdict.schema.json" '
    . as $d
    | (($s[0].required - ($d|keys)) == [])
      and ($s[0].properties.verdict.enum | index($d.verdict) != null)
      and ([ $d.findings[]? as $f
             | (($s[0].properties.findings.items.required - ($f|keys)) == [])
               and ($s[0].properties.findings.items.properties.severity.enum | index($f.severity) != null)
           ] | all)
  ' >/dev/null || { schema_bad=1
    echo "::error::emitted verdict does not conform to verdict.schema.json" >&2; }
else
  echo "::notice::.gadd/schemas not installed — verdict schema validation skipped" >&2
fi

{ echo "## GADD verdict: **$verdict** (\`${GADD_HEAD:0:7}\` vs accepted \`${GADD_BASE:0:7}\`)"
  echo ""; echo "| Check | Severity | Message |"; echo "|---|---|---|"
  echo "$findings" | jq -r '.[] | "| \(.check) | \(.severity) | \(.message) |"'
} >> "${GITHUB_STEP_SUMMARY:-/dev/null}" 2>/dev/null || true

[ "$verdict" = "PASS" ] && [ "$schema_bad" -eq 0 ]
