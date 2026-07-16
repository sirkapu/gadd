#!/usr/bin/env bash
# gadd-lv check library. Every check sources this.
# Env: GADD_BASE (accepted sha), GADD_HEAD (sha under audit), GADD_FINDINGS (ndjson out file)
set -uo pipefail

GADD_BASE="${GADD_BASE:?set GADD_BASE}"
GADD_HEAD="${GADD_HEAD:-HEAD}"
GADD_FINDINGS="${GADD_FINDINGS:-/tmp/gadd-findings.ndjson}"

finding() { # finding <check> <severity> <message> [paths_csv]
  local check="$1" sev="$2" msg="$3" paths="${4:-}"
  jq -cn --arg c "$check" --arg s "$sev" --arg m "$msg" --arg p "$paths" \
    '{check:$c, severity:$s, message:$m, paths:($p|split(",")|map(select(length>0)))}' \
    >> "$GADD_FINDINGS"
  echo "::warning::[$sev] $check — $msg" >&2
}

changed_files()      { git diff --name-only --diff-filter=ACMR "$GADD_BASE".."$GADD_HEAD" -- "${@:-.}"; }
deleted_files()      { git diff --name-only --diff-filter=D    "$GADD_BASE".."$GADD_HEAD" -- "${@:-.}"; }
added_files()        { git diff --name-only --diff-filter=A    "$GADD_BASE".."$GADD_HEAD" -- "${@:-.}"; }
diff_added_lines()   { git diff --unified=0 "$GADD_BASE".."$GADD_HEAD" -- "${@:-.}" | grep -E '^\+' | grep -vE '^\+\+\+' || true; }
baseline_get()       { jq -r "$1 // empty" gadd/BASELINE.json 2>/dev/null || true; }
