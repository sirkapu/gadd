#!/usr/bin/env bash
# gadd-fleet.sh — upstream aggregation: escaped-regression ledgers + verdict history
# across every governed repo you point it at. Read-only, deterministic, no network,
# no LLM. Writes NOTHING to disk — stdout carries one JSON object, stderr carries a
# human table. The JSON names private repo paths: it is LOCAL-ONLY, never commit it,
# never paste it into a shared doc/PR. See docs/measurement.md.
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

  parse_errors=0

  # --- verdicts ---
  verdicts_dir="$repo/gadd/verdicts"
  verdict_files=()
  if [ -d "$verdicts_dir" ]; then
    if [ -r "$verdicts_dir" ]; then
      shopt -s nullglob
      verdict_files=("$verdicts_dir"/*.json)
      shopt -u nullglob
    else
      echo "WARN: gadd-fleet: $verdicts_dir not readable — fail-open, treating as 0 verdicts" >&2
    fi
  else
    echo "WARN: gadd-fleet: $verdicts_dir missing — fail-open, treating as 0 verdicts" >&2
  fi

  valid_verdicts=()
  dates=()
  for f in "${verdict_files[@]}"; do
    d="$(mtime_date "$f")"
    [ -n "$d" ] && dates+=("$d")
    content="$(cat "$f" 2>/dev/null)"
    if printf '%s' "$content" | jq empty >/dev/null 2>&1; then
      valid_verdicts+=("$content")
    else
      parse_errors=$((parse_errors + 1))
      echo "WARN: gadd-fleet: $f is malformed JSON — fail-open, counted in parse_errors" >&2
    fi
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
    echo "WARN: gadd-fleet: $ledger unreadable — escaped counts unavailable" >&2
    parse_errors=$((parse_errors + 1))
  elif [ -f "$ledger" ]; then
    if [ -s "$ledger" ]; then
      while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        if printf '%s' "$line" | jq -e 'type=="object"' >/dev/null 2>&1; then
          valid_escaped+=("$line")
        else
          parse_errors=$((parse_errors + 1))
          echo "WARN: gadd-fleet: $ledger has a malformed JSONL line — fail-open, counted in parse_errors" >&2
        fi
      done < "$ledger"
    fi
    # empty file = healthy zero, no warning
  else
    echo "WARN: gadd-fleet: $ledger missing — escaped counted as 0" >&2
  fi

  escaped_json='[]'
  if [ "${#valid_escaped[@]}" -gt 0 ]; then
    escaped_json="$(printf '%s\n' "${valid_escaped[@]}" | jq -s '.')"
  fi

  repo_obj="$(jq -n \
    --arg path "$repo" \
    --argjson verdicts "$verdicts_json" \
    --argjson escaped "$escaped_json" \
    --arg first "$first" \
    --arg last "$last" \
    --argjson parse_errors "$parse_errors" '
    {
      path: $path,
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
        [$escaped[] | (.check // "unknown")] | group_by(.) | map({(.[0]): length}) | add // {}
      ),
      window: {
        first: (if $first == "" then null else $first end),
        last:  (if $last  == "" then null else $last  end)
      },
      parse_errors: $parse_errors
    }')"

  repo_objs+=("$repo_obj")
done

repos_json='[]'
if [ "${#repo_objs[@]}" -gt 0 ]; then
  repos_json="$(printf '%s\n' "${repo_objs[@]}" | jq -s '.')"
fi

escaped_total_sum="$(echo "$repos_json" | jq '[.[].escaped_total] | add // 0')"
accepted_pushes="$(echo "$repos_json" | jq '[.[].pass_count] | add // 0')"
if [ "$accepted_pushes" -eq 0 ]; then
  escaped_rate="unmeasured"
else
  escaped_rate="$(jq -n -r --argjson e "$escaped_total_sum" --argjson a "$accepted_pushes" '($e / $a) | tostring')"
fi

output_json="$(jq -n \
  --argjson repos "$repos_json" \
  --argjson escaped_total "$escaped_total_sum" \
  --argjson accepted_pushes "$accepted_pushes" \
  --arg escaped_rate "$escaped_rate" '
  {
    generated_note: "local-only, do not commit",
    repos: $repos,
    north_star: {
      escaped_total: $escaped_total,
      accepted_pushes: $accepted_pushes,
      escaped_rate: $escaped_rate
    }
  }')"

printf '%s\n' "$output_json"

{
  echo ""
  echo "gadd-fleet — LOCAL-ONLY, do not commit"
  printf '%-46s %8s %6s %6s %9s %6s %6s %6s %7s\n' \
    "repo" "verdicts" "pass" "fail" "escaped" "CRIT" "MAJ" "MIN" "errors"
  echo "$repos_json" | jq -r '.[] | [.path, .verdicts_total, .pass_count, .fail_count, .escaped_total, .findings.CRITICAL, .findings.MAJOR, .findings.MINOR, .parse_errors] | @tsv' |
    while IFS=$'\t' read -r p vt pc fc et cr mj mn pe; do
      printf '%-46s %8s %6s %6s %9s %6s %6s %6s %7s\n' "$p" "$vt" "$pc" "$fc" "$et" "$cr" "$mj" "$mn" "$pe"
    done
  echo ""
  echo "north star — escaped_total=$escaped_total_sum accepted_pushes=$accepted_pushes escaped_rate=$escaped_rate"
} >&2

exit 0
