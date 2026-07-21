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

# TOTAL-SILENT-BYPASS HARDENING (run-32, ratified D1, Major tier; fail-closed
# doctrine, operator rationale verbatim: "a gate unable to run must never
# silently pass"): changed_files/deleted_files/added_files previously ran
# `git diff --name-only ...` as the last statement of a one-liner function —
# no `|| true`, but every caller invokes them via `$(...)` or `< <(...)`
# without ever checking $?, so a git failure was indistinguishable from a
# clean "nothing changed". diff_added_lines additionally piped through
# `grep ... | grep ... || true`, where the `|| true` swallowed a git failure
# the exact same way grep's own legitimate no-match rc=1 is swallowed —
# doubly indistinguishable. If GADD_BASE resolves (run-all.sh hardening A
# passes) but an object the walk needs is missing/corrupt (e.g. the base
# commit's tracked-subtree tree object deleted from .git/objects — a
# partial-clone or corruption shape), `git diff` fails nonzero with EMPTY
# stdout and every check built on these helpers sees "nothing changed" —
# zero findings end-to-end, a vacuous PASS (MEASURED taxonomy: rc=128,
# "fatal: unable to read tree <sha>", zero bytes on stdout — mktemp scratch
# repro + exact commands/output in the run-32 feat commit body).
#
# Each helper now captures git's OWN exit status (never discarded, never
# `|| true`-swallowed) and, on nonzero rc, records a CRITICAL finding via
# the existing finding() — check="lib-common" (a fixed name, not the
# caller's own check slug: this file is sourced by every one of the ~7
# checks in this directory, so a name tied to *this* library's own read
# failure stays stable in tests regardless of which check happened to be
# running when the read broke — mirrors run-all.sh's synthetic
# "gate-integrity" name for gate-level infrastructure failures). A finding
# recorded inside the helper makes the gate FAIL regardless of what the
# caller does with the (still-empty) return value — the caller never needs
# to check $?.
#
# The healthy (rc=0) path is reconstructed BYTE-IDENTICAL to the prior
# direct-stream behavior: a bare command substitution strips only TRAILING
# newlines (embedded ones are untouched), so a non-empty capture is
# re-emitted with exactly one trailing newline restored — the same shape
# git's own `--name-only` / unified-diff stream produces; an empty capture
# emits nothing at all, matching git's own zero-byte output for "no
# changes" (never a phantom blank line from an unconditional `printf '%s\n'
# ""`).
changed_files() {
  local out rc paths="${*:-.}"
  out="$(git diff --name-only --diff-filter=ACMR "$GADD_BASE".."$GADD_HEAD" -- "${@:-.}")"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    finding "lib-common" "CRITICAL" "changed_files(): git diff --name-only failed (rc=$rc) for pathspec '$paths' — fail-closed" "$paths"
    return 0
  fi
  [ -n "$out" ] && printf '%s\n' "$out"
  return 0
}

deleted_files() {
  local out rc paths="${*:-.}"
  out="$(git diff --name-only --diff-filter=D "$GADD_BASE".."$GADD_HEAD" -- "${@:-.}")"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    finding "lib-common" "CRITICAL" "deleted_files(): git diff --name-only failed (rc=$rc) for pathspec '$paths' — fail-closed" "$paths"
    return 0
  fi
  [ -n "$out" ] && printf '%s\n' "$out"
  return 0
}

added_files() {
  local out rc paths="${*:-.}"
  out="$(git diff --name-only --diff-filter=A "$GADD_BASE".."$GADD_HEAD" -- "${@:-.}")"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    finding "lib-common" "CRITICAL" "added_files(): git diff --name-only failed (rc=$rc) for pathspec '$paths' — fail-closed" "$paths"
    return 0
  fi
  [ -n "$out" ] && printf '%s\n' "$out"
  return 0
}

# diff_added_lines: captures git's diff output to a variable FIRST and
# checks git's own rc before ever invoking grep, so grep's legitimate
# no-match rc=1 (a clean "no added lines") stays completely separate from a
# git invocation failure — the two were conflated by the old bare `|| true`
# at the end of the whole pipeline.
diff_added_lines() {
  local out rc paths="${*:-.}"
  out="$(git diff --unified=0 "$GADD_BASE".."$GADD_HEAD" -- "${@:-.}")"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    finding "lib-common" "CRITICAL" "diff_added_lines(): git diff --unified=0 failed (rc=$rc) for pathspec '$paths' — fail-closed" "$paths"
    return 0
  fi
  [ -z "$out" ] && return 0
  printf '%s\n' "$out" | grep -E '^\+' | grep -vE '^\+\+\+' || true
}

baseline_get()       { jq -r "$1 // empty" gadd/BASELINE.json 2>/dev/null || true; }
