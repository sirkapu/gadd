#!/usr/bin/env bash
# gadd-fleet.sh — upstream aggregation: escaped-regression ledgers + verdict history
# across every governed repo you point it at. Read-only, deterministic, no network,
# no LLM. Writes NOTHING to disk — stdout carries one JSON object, stderr carries a
# human table. The JSON names private repo paths: it is LOCAL-ONLY, never commit it,
# never paste it into a shared doc/PR. See docs/measurement.md.
#
# SCHEMA ADMISSION (ratified 2026-07-14): every verdict file is validated against
# spec/schemas/verdict.schema.json and every ledger line against
# spec/schemas/escaped.schema.json BEFORE aggregation. Only conformant records are
# admitted; every non-conformant record is disclosed per repo under "anomalies"
# (total + by_reason) and WARNed to stderr. A repo whose aggregation of admitted
# records succeeds is status "clean" (counts reflect admitted records only). The
# north_star rolls up escaped_total / accepted_pushes / escaped_rate over CLEAN
# repos only, and lists clean_repos + anomalous_repos.
#
# Usage: bin/gadd-fleet.sh <governed-repo-path> [<path>...]
#   e.g. bin/gadd-fleet.sh ~/code/acme-app ~/code/acme-admin
set -uo pipefail

usage() {
  echo "usage: $(basename "$0") <governed-repo-path> [<path>...]" >&2
  echo "  aggregates gadd/verdicts/*.json + gadd/ESCAPED.jsonl across governed repos" >&2
  echo "  output is LOCAL-ONLY (private repo names/paths) — never commit it" >&2
}

[ "$#" -eq 0 ] && { usage; exit 1; }

# --- WHITELIST: the instrument never runs without its schemas -----------------
# Schemas resolve relative to this script. If either is missing, exit 1 loudly:
# admission is the whole point — we do not aggregate un-validated records.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMAS_DIR="$SCRIPT_DIR/../spec/schemas"
V_SCHEMA="$SCHEMAS_DIR/verdict.schema.json"
E_SCHEMA="$SCHEMAS_DIR/escaped.schema.json"
if [ ! -f "$V_SCHEMA" ]; then
  echo "FATAL: gadd-fleet: verdict schema missing at $V_SCHEMA — refusing to run without its whitelist" >&2
  exit 1
fi
if [ ! -f "$E_SCHEMA" ]; then
  echo "FATAL: gadd-fleet: escaped schema missing at $E_SCHEMA — refusing to run without its whitelist" >&2
  exit 1
fi

# Shared, schema-driven validation preamble. Reads required[], property types, and
# enums straight from the schema (the run-all.sh validator pattern), extended so
# that array-of-object properties (findings) are checked element by element.
JQ_DEFS='
  def type_ok($v; $t):
    ($t == null)
    or ($t == "string"  and ($v|type) == "string")
    or ($t == "object"  and ($v|type) == "object")
    or ($t == "array"   and ($v|type) == "array")
    or ($t == "number"  and ($v|type) == "number")
    or ($t == "integer" and ($v|type) == "number")
    or ($t == "boolean" and ($v|type) == "boolean");
  def check_obj($doc; $schema):
    ((($schema.required // []) - ($doc | keys)) == [])
    and ([ ($schema.properties // {}) | to_entries[]
           | .key as $k | .value as $ps
           | if ($doc | has($k))
             then type_ok($doc[$k]; $ps.type)
                  and (if ($ps.enum) then ($ps.enum | index($doc[$k]) != null) else true end)
             else true end
         ] | all);
'

# validate_verdict: reads $content (an already-parsed JSON *object*), returns 0 iff
# it conforms to verdict.schema.json — including: findings is an array, and every
# finding is an object meeting findings.items required/enums/types.
validate_verdict() {
  printf '%s' "$1" | jq -e --slurpfile s "$V_SCHEMA" "$JQ_DEFS"'
    $s[0] as $schema
    | (type == "object")
      and check_obj(.; $schema)
      and ((.findings | type) == "array")
      and ([ .findings[]?
             | (type == "object")
               and check_obj(.; $schema.properties.findings.items)
           ] | all)
  ' >/dev/null 2>&1
}

# validate_escaped: reads a single JSON *object* line, returns 0 iff it conforms to
# escaped.schema.json (required[], property types incl. string check, severity enum).
validate_escaped() {
  printf '%s' "$1" | jq -e --slurpfile s "$E_SCHEMA" "$JQ_DEFS"'
    $s[0] as $schema
    | (type == "object") and check_obj(.; $schema)
  ' >/dev/null 2>&1
}

# mtime -> YYYY-MM-DD. Probe BSD stat (macOS) first, fall back to GNU stat (Linux).
mtime_date() {
  local f="$1" out
  if out="$(stat -f '%Sm' -t '%Y-%m-%d' "$f" 2>/dev/null)"; then
    printf '%s\n' "$out"
  elif out="$(stat -c '%y' "$f" 2>/dev/null)"; then
    printf '%s\n' "${out%% *}"
  fi
}

repo_objs=()

for repo in "$@"; do
  if [ ! -d "$repo" ]; then
    echo "WARN: gadd-fleet: '$repo' is not a directory — skipping" >&2
    continue
  fi
  if [ ! -d "$repo/gadd" ]; then
    echo "WARN: gadd-fleet: '$repo' has no gadd/ — skipping (not a governed repo?)" >&2
    continue
  fi

  # anomaly tallies, per reason class (ratified: disclosure must be actionable)
  anom_unreadable=0
  anom_empty=0
  anom_malformed_json=0
  anom_not_object=0
  anom_schema_nonconformant=0
  anom_aggregation_failed=0

  # --- verdicts ---
  verdicts_dir="$repo/gadd/verdicts"
  verdict_files=()
  if [ -d "$verdicts_dir" ]; then
    if [ -r "$verdicts_dir" ]; then
      shopt -s nullglob
      verdict_files=("$verdicts_dir"/*.json)
      shopt -u nullglob
    else
      echo "WARN: gadd-fleet: $verdicts_dir not readable — treating as 0 verdicts" >&2
    fi
  else
    echo "WARN: gadd-fleet: $verdicts_dir missing — treating as 0 verdicts" >&2
  fi

  valid_verdicts=()
  dates=()
  for f in ${verdict_files[@]+"${verdict_files[@]}"}; do
    if [ ! -r "$f" ]; then
      anom_unreadable=$((anom_unreadable + 1))
      echo "WARN: gadd-fleet: $f verdict file unreadable — anomaly (unreadable)" >&2
      continue
    fi
    content="$(cat "$f" 2>/dev/null)"
    if [ -z "$content" ]; then
      anom_empty=$((anom_empty + 1))
      echo "WARN: gadd-fleet: $f verdict file empty — anomaly (empty)" >&2
      continue
    fi
    if ! printf '%s' "$content" | jq empty >/dev/null 2>&1; then
      anom_malformed_json=$((anom_malformed_json + 1))
      echo "WARN: gadd-fleet: $f is malformed JSON — anomaly (malformed_json)" >&2
      continue
    fi
    if ! printf '%s' "$content" | jq -e 'type=="object"' >/dev/null 2>&1; then
      anom_not_object=$((anom_not_object + 1))
      echo "WARN: gadd-fleet: $f verdict is not a JSON object — anomaly (not_object)" >&2
      continue
    fi
    if ! validate_verdict "$content"; then
      anom_schema_nonconformant=$((anom_schema_nonconformant + 1))
      echo "WARN: gadd-fleet: $f verdict fails verdict.schema.json — anomaly (schema_nonconformant)" >&2
      continue
    fi
    # ADMITTED
    valid_verdicts+=("$content")
    d="$(mtime_date "$f")"
    [ -n "$d" ] && dates+=("$d")
  done

  verdicts_json='[]'
  if [ "${#valid_verdicts[@]}" -gt 0 ]; then
    verdicts_json="$(printf '%s\n' "${valid_verdicts[@]}" | jq -s '.')"
  fi

  first=""; last=""
  if [ "${#dates[@]}" -gt 0 ]; then
    first="$(printf '%s\n' "${dates[@]}" | sort | head -1)"
    last="$(printf '%s\n' "${dates[@]}" | sort | tail -1)"
  fi

  # --- escaped-regression ledger ---
  ledger="$repo/gadd/ESCAPED.jsonl"
  valid_escaped=()
  if [ -f "$ledger" ] && [ ! -r "$ledger" ]; then
    anom_unreadable=$((anom_unreadable + 1))
    echo "WARN: gadd-fleet: $ledger unreadable — anomaly (unreadable), escaped counts unavailable from it" >&2
  elif [ -f "$ledger" ]; then
    if [ -s "$ledger" ]; then
      while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        if ! printf '%s' "$line" | jq empty >/dev/null 2>&1; then
          anom_malformed_json=$((anom_malformed_json + 1))
          echo "WARN: gadd-fleet: $ledger has a malformed JSONL line — anomaly (malformed_json)" >&2
        elif ! printf '%s' "$line" | jq -e 'type=="object"' >/dev/null 2>&1; then
          anom_not_object=$((anom_not_object + 1))
          echo "WARN: gadd-fleet: $ledger has a non-object JSONL line — anomaly (not_object)" >&2
        elif ! validate_escaped "$line"; then
          anom_schema_nonconformant=$((anom_schema_nonconformant + 1))
          echo "WARN: gadd-fleet: $ledger has a line failing escaped.schema.json — anomaly (schema_nonconformant)" >&2
        else
          valid_escaped+=("$line")
        fi
      done < "$ledger"
    fi
    # empty file = healthy zero, no anomaly
  else
    echo "WARN: gadd-fleet: $ledger missing — escaped counted as 0" >&2
  fi

  escaped_json='[]'
  if [ "${#valid_escaped[@]}" -gt 0 ]; then
    escaped_json="$(printf '%s\n' "${valid_escaped[@]}" | jq -s '.')"
  fi

  # --- aggregate ADMITTED records only ---
  repo_obj="$(jq -n \
    --arg path "$repo" \
    --argjson verdicts "$verdicts_json" \
    --argjson escaped "$escaped_json" \
    --arg first "$first" \
    --arg last "$last" \
    --argjson unreadable "$anom_unreadable" \
    --argjson empty "$anom_empty" \
    --argjson malformed_json "$anom_malformed_json" \
    --argjson not_object "$anom_not_object" \
    --argjson schema_nonconformant "$anom_schema_nonconformant" \
    --argjson aggregation_failed "$anom_aggregation_failed" '
    {
      path: $path,
      status: "clean",
      verdicts_total: ($verdicts | length),
      pass_count: ([$verdicts[] | select(.verdict=="PASS")] | length),
      fail_count: ([$verdicts[] | select(.verdict=="FAIL")] | length),
      findings: {
        CRITICAL: ([$verdicts[].findings[]? | select(.severity=="CRITICAL")] | length),
        MAJOR:    ([$verdicts[].findings[]? | select(.severity=="MAJOR")]    | length),
        MINOR:    ([$verdicts[].findings[]? | select(.severity=="MINOR")]    | length)
      },
      escaped_total: ($escaped | length),
      escaped_by_check: (
        [$escaped[] | (.check // "unknown" | tostring)] | group_by(.) | map({(.[0]): length}) | add // {}
      ),
      window: {
        first: (if $first == "" then null else $first end),
        last:  (if $last  == "" then null else $last  end)
      },
      anomalies: {
        total: ($unreadable + $empty + $malformed_json + $not_object + $schema_nonconformant + $aggregation_failed),
        by_reason: {
          unreadable: $unreadable,
          empty: $empty,
          malformed_json: $malformed_json,
          not_object: $not_object,
          schema_nonconformant: $schema_nonconformant,
          aggregation_failed: $aggregation_failed
        }
      }
    }')"
  jq_rc=$?

  # NEVER ZEROS: if aggregation of admitted records itself failed, the repo is
  # still emitted — as "anomalous", every numeric count field null (not 0), with
  # anomalies populated (aggregation_failed +1) and a WARN. It must never vanish.
  if [ "$jq_rc" -ne 0 ] || [ -z "$repo_obj" ]; then
    echo "WARN: gadd-fleet: aggregation failed for $repo — emitted as anomalous, counts null (aggregation_failed)" >&2
    anom_aggregation_failed=$((anom_aggregation_failed + 1))
    repo_obj="$(jq -n \
      --arg path "$repo" \
      --argjson unreadable "$anom_unreadable" \
      --argjson empty "$anom_empty" \
      --argjson malformed_json "$anom_malformed_json" \
      --argjson not_object "$anom_not_object" \
      --argjson schema_nonconformant "$anom_schema_nonconformant" \
      --argjson aggregation_failed "$anom_aggregation_failed" '
      {
        path: $path,
        status: "anomalous",
        verdicts_total: null,
        pass_count: null,
        fail_count: null,
        findings: { CRITICAL: null, MAJOR: null, MINOR: null },
        escaped_total: null,
        escaped_by_check: {},
        window: { first: null, last: null },
        anomalies: {
          total: ($unreadable + $empty + $malformed_json + $not_object + $schema_nonconformant + $aggregation_failed),
          by_reason: {
            unreadable: $unreadable,
            empty: $empty,
            malformed_json: $malformed_json,
            not_object: $not_object,
            schema_nonconformant: $schema_nonconformant,
            aggregation_failed: $aggregation_failed
          }
        }
      }')"
  fi

  repo_objs+=("$repo_obj")
done

repos_json='[]'
if [ "${#repo_objs[@]}" -gt 0 ]; then
  repos_json="$(printf '%s\n' "${repo_objs[@]}" | jq -s '.')"
fi

# NORTH STAR over CLEAN repos only.
escaped_total_sum="$(echo "$repos_json" | jq '[.[] | select(.status=="clean") | .escaped_total] | add // 0')"
accepted_pushes="$(echo "$repos_json" | jq '[.[] | select(.status=="clean") | .pass_count] | add // 0')"
clean_repos="$(echo "$repos_json" | jq '[.[] | select(.status=="clean")] | length')"
anomalous_repos_json="$(echo "$repos_json" | jq '[.[] | select(.status=="anomalous") | .path]')"
anomalous_repos_count="$(echo "$anomalous_repos_json" | jq 'length')"
if [ "$accepted_pushes" -eq 0 ]; then
  escaped_rate="unmeasured"
else
  escaped_rate="$(jq -n -r --argjson e "$escaped_total_sum" --argjson a "$accepted_pushes" '($e / $a) | tostring')"
fi

output_json="$(jq -n \
  --argjson repos "$repos_json" \
  --argjson escaped_total "$escaped_total_sum" \
  --argjson accepted_pushes "$accepted_pushes" \
  --argjson clean_repos "$clean_repos" \
  --argjson anomalous_repos "$anomalous_repos_json" \
  --arg escaped_rate "$escaped_rate" '
  {
    generated_note: "local-only, do not commit",
    repos: $repos,
    north_star: {
      clean_repos: $clean_repos,
      anomalous_repos: $anomalous_repos,
      escaped_total: $escaped_total,
      accepted_pushes: $accepted_pushes,
      escaped_rate: $escaped_rate
    }
  }')"

printf '%s\n' "$output_json"

{
  echo ""
  echo "gadd-fleet — LOCAL-ONLY, do not commit"
  printf '%-46s %8s %6s %6s %9s %6s %6s %6s %10s %10s\n' \
    "repo" "verdicts" "pass" "fail" "escaped" "CRIT" "MAJ" "MIN" "status" "anomalies"
  echo "$repos_json" | jq -r '.[] | [.path, .verdicts_total, .pass_count, .fail_count, .escaped_total, .findings.CRITICAL, .findings.MAJOR, .findings.MINOR, .status, .anomalies.total] | @tsv' |
    while IFS=$'\t' read -r p vt pc fc et cr mj mn st an; do
      printf '%-46s %8s %6s %6s %9s %6s %6s %6s %10s %10s\n' "$p" "$vt" "$pc" "$fc" "$et" "$cr" "$mj" "$mn" "$st" "$an"
    done
  echo ""
  echo "north star — clean_repos=$clean_repos anomalous_repos=$anomalous_repos_count escaped_total=$escaped_total_sum accepted_pushes=$accepted_pushes escaped_rate=$escaped_rate"
} >&2

exit 0
