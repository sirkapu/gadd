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

# Per-run scratch dir for the findings/metrics streams (fail-closed hardening
# D): a fixed shared /tmp path lets two concurrent runs stomp each other's
# findings/metrics; a fresh mktemp -d per invocation, cleaned up on exit,
# cannot collide. Threaded to every check via exported env vars.
RUNDIR="$(mktemp -d)"
trap 'rm -rf "$RUNDIR"' EXIT
export GADD_FINDINGS="$RUNDIR/gadd-findings.ndjson"
export GADD_METRICS_FILE="$RUNDIR/gadd-metrics.json"
: > "$GADD_FINDINGS"

# Fail-closed hardening A: an unresolvable GADD_BASE makes every check's
# git-diff machinery swallow the error and see an empty diff — "nothing
# changed" reads as a silent PASS. Validate the base BEFORE running any
# check; on failure, refuse to run checks against an unknown base and report
# loudly instead of silently.
if ! git rev-parse --verify "${GADD_BASE}^{commit}" >/dev/null 2>&1; then
  echo "::error::GADD_BASE '$GADD_BASE' does not resolve to a commit — refusing to run checks against an unknown base" >&2
  jq -cn --arg c "gate-integrity" \
    --arg m "GADD_BASE '$GADD_BASE' does not resolve to a commit — refusing to run checks against an unknown base" \
    '{check:$c, severity:"CRITICAL", message:$m, paths:[]}' >> "$GADD_FINDINGS"
else
  # 01–09 ship with gadd; deployments may add their own NN-*.sh extensions (e.g.
  # 90-deployment-ratchet.sh) — they run in lexical order and report via lib/common.sh.
  #
  # Fail-closed hardening B: a check's exit code is an expected-vs-completed
  # ledger entry, not noise. The ::warning:: line stays for humans, but a
  # nonzero exit ALSO becomes a synthetic MAJOR finding naming the check — a
  # crashed check's detections cannot be trusted, and the verdict must never
  # read PASS while a check silently failed to run.
  for c in "$DIR"/[0-9]*.sh; do
    bash "$c"
    rc=$?
    if [ "$rc" -ne 0 ]; then
      echo "::warning::check $(basename "$c") errored (non-fatal)" >&2
      jq -cn --arg c "gate-integrity" \
        --arg m "check $(basename "$c") exited $rc — a crashed check's detections cannot be trusted; the gate cannot pass while a check failed to run" \
        '{check:$c, severity:"MAJOR", message:$m, paths:[]}' >> "$GADD_FINDINGS"
    fi
  done
fi

mkdir -p gadd/verdicts

# Fail-closed hardening C: `jq -s '.'` slurps ALL lines atomically — one
# malformed NDJSON line makes the whole slurp fail, and the old
# `|| echo '[]'` silently discarded every VALID finding along with it.
# Validate line-by-line instead: a bad line becomes its own synthetic MAJOR
# finding (quoting a safe prefix of the offending line), every good line
# passes through untouched, and the set never collapses to [] just because
# one line was corrupt.
valid_findings="$RUNDIR/valid-findings.ndjson"
: > "$valid_findings"
if [ -f "$GADD_FINDINGS" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    if printf '%s' "$line" | jq -e 'type == "object"' >/dev/null 2>&1; then
      printf '%s\n' "$line" >> "$valid_findings"
    else
      safe_prefix="$(printf '%s' "$line" | cut -c1-120)"
      jq -cn --arg c "gate-integrity" --arg m "malformed NDJSON findings line: $safe_prefix" \
        '{check:$c, severity:"MAJOR", message:$m, paths:[]}' >> "$valid_findings"
    fi
  done < "$GADD_FINDINGS"
fi
findings="$(jq -s '.' "$valid_findings" 2>/dev/null || echo '[]')"

crit=$(echo "$findings" | jq '[.[] | select(.severity=="CRITICAL")] | length')
maj=$(echo  "$findings" | jq '[.[] | select(.severity=="MAJOR")]    | length')
min=$(echo  "$findings" | jq '[.[] | select(.severity=="MINOR")]    | length')
verdict="PASS"; { [ "$crit" -gt 0 ] || [ "$maj" -gt 0 ] || [ "$min" -ge 3 ]; } && verdict="FAIL"
metrics="$(cat "$GADD_METRICS_FILE" 2>/dev/null || echo '{}')"

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
