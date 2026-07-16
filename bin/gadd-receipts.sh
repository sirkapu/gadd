#!/usr/bin/env bash
# gadd-receipts: composite receipts mode — gate suite + parity + residue + fixtures +
# git receipt set, in ONE call, one structured (JSON) output for packets. Ratified
# spec (SPEED AUDIT v1, P3, 2026-07-16): "receipts mode: gate suite + parity +
# residue + fixtures + git receipt set in ONE call, one structured output for
# packets."
#
# Runs, in order, capturing exit code + a key summary line per suite:
#   1. .gadd/checks/run-all.sh   (if present; else reported "not installed")
#   2. every tests/*-fixtures.sh harness, discovered by glob (order = glob order)
#   3. bin/residue-check.sh
# ...then appends a git receipt block (branch, HEAD sha, porcelain count, HEAD
# parents) — informational, not gated.
#
# HONESTY RULES (fail-closed, never skipped-as-green):
#   - A suite that cannot run at all (missing script, glob finds nothing) is
#     reported with exit != 0 and folds into overall.all_green=false. It is NEVER
#     silently omitted or reported as green.
#   - A suite's real nonzero exit is never swallowed — it is captured and reported
#     verbatim, and also fails overall.all_green.
#   - This script's OWN exit code is 0 only if overall.all_green is true.
#
# USAGE: bin/gadd-receipts.sh
#   Outputs one JSON object to stdout. All commentary/progress goes to stderr.
set -uo pipefail
TOPLEVEL="$(git rev-parse --show-toplevel)" || { echo "FATAL: git rev-parse --show-toplevel failed — not inside a git repo? Refusing to run against an unknown tree." >&2; exit 1; }
cd "$TOPLEVEL" || { echo "FATAL: cd to '$TOPLEVEL' failed — refusing to run against an unknown tree." >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

SUITES_NDJSON="$WORK/suites.ndjson"
: > "$SUITES_NDJSON"
ALL_GREEN=true

# record_suite <name> <exit_code> <summary>
# Appends one suite result as an NDJSON line. Never lets a summary string with
# quotes/newlines corrupt the JSON — jq -R handles the escaping.
record_suite() {
  local name="$1" ec="$2" summary="$3"
  jq -n --arg name "$name" --argjson exit "$ec" --arg summary "$summary" \
    '{name: $name, exit: $exit, summary: $summary}' >> "$SUITES_NDJSON"
  if [ "$ec" -ne 0 ]; then
    ALL_GREEN=false
  fi
  echo "[gadd-receipts] $name: exit $ec — $summary" >&2
}

# ---------------------------------------------------------------------------
# 1. Gate suite: .gadd/checks/run-all.sh
# ---------------------------------------------------------------------------
GATE="./.gadd/checks/run-all.sh"
if [ -f "$GATE" ]; then
  gate_out="$WORK/gate.stdout"
  gate_err="$WORK/gate.stderr"
  bash "$GATE" >"$gate_out" 2>"$gate_err"
  gate_ec=$?
  gate_verdict="$(jq -r '.verdict // empty' "$gate_out" 2>/dev/null || true)"
  gate_sha="$(jq -r '.sha // empty' "$gate_out" 2>/dev/null || true)"
  gate_base="$(jq -r '.base_sha // empty' "$gate_out" 2>/dev/null || true)"
  if [ -n "$gate_verdict" ]; then
    gate_summary="verdict: $gate_verdict (${gate_sha:0:7} vs base ${gate_base:0:7})"
    if [ "$gate_verdict" != "PASS" ]; then
      # Cross-check: the parsed verdict is the ONLY signal that gets to declare
      # green. A gate suite that exits 0 while its own verdict JSON says
      # anything other than PASS is lying about its exit code — never trust
      # the process exit alone; force the suite nonzero regardless of $gate_ec.
      gate_ec=1
    fi
  else
    # Gate ran but did not emit a parseable verdict JSON — never fabricate a
    # summary; report what actually happened and fail closed.
    gate_summary="ran but emitted no parseable verdict JSON (exit $gate_ec)"
    gate_ec=1
  fi
  record_suite "gate" "$gate_ec" "$gate_summary"
else
  record_suite "gate" 1 "not installed"
fi

# ---------------------------------------------------------------------------
# 2. Every tests/*-fixtures.sh harness, discovered by glob.
# ---------------------------------------------------------------------------
shopt -s nullglob
fixtures=(tests/*-fixtures.sh)
shopt -u nullglob
if [ "${#fixtures[@]}" -eq 0 ]; then
  record_suite "fixtures" 1 "no tests/*-fixtures.sh harnesses found — cannot run"
else
  for f in "${fixtures[@]}"; do
    fname="$(basename "$f")"
    f_out="$WORK/${fname}.stdout"
    bash "$f" >"$f_out" 2>&1
    f_ec=$?
    f_summary="$(grep -E '^[0-9]+/[0-9]+ PASS$' "$f_out" | tail -1)"
    if [ -z "$f_summary" ]; then
      f_summary="no PASS summary line found in output (exit $f_ec)"
      f_ec=1
    else
      # Cross-check: the exit code alone never gets to declare green. Parse
      # N/M out of the summary line itself and require N == M — a harness
      # that prints "0/40 PASS" (or any N < M) and exits 0 is lying about its
      # exit code and must not fabricate green.
      f_n="${f_summary%%/*}"
      f_rest="${f_summary#*/}"
      f_m="${f_rest%% *}"
      if [ "$((10#$f_n))" -ne "$((10#$f_m))" ]; then
        f_summary="$f_summary (parsed count mismatch: $f_n of $f_m passed — not all-green despite exit $f_ec)"
        f_ec=1
      fi
    fi
    record_suite "fixtures:$fname" "$f_ec" "$f_summary"
  done
fi

# ---------------------------------------------------------------------------
# 3. bin/residue-check.sh
# ---------------------------------------------------------------------------
RESIDUE="bin/residue-check.sh"
if [ -f "$RESIDUE" ]; then
  r_out="$WORK/residue.stdout"
  bash "$RESIDUE" >"$r_out" 2>&1
  r_ec=$?
  # Parsed signal: a genuine clean verdict, or a legitimate degraded-skip
  # notice (blocklist absent/empty) — both are honest exit-0 states per
  # bin/residue-check.sh's own contract.
  r_clean="$(grep -E '^residue check: clean' "$r_out" | tail -1)"
  r_notice="$(grep -E '^notice:' "$r_out" | tail -1)"
  if [ -n "$r_clean" ]; then
    r_summary="$r_clean"
  elif [ -n "$r_notice" ]; then
    r_summary="$r_notice"
  else
    r_summary="$(tail -1 "$r_out")"
    [ -z "$r_summary" ] && r_summary="(no output)"
  fi
  if [ "$r_ec" -eq 0 ] && [ -z "$r_clean" ] && [ -z "$r_notice" ]; then
    # Cross-check: exit 0 alone never gets to declare green. If the process
    # exited 0 but its own output contains neither a "clean" verdict nor a
    # legitimate skip notice (e.g. a lying script that prints "RESIDUE: ..."
    # hits and still exits 0), never trust the exit code — force nonzero.
    r_ec=1
    r_summary="exit 0 but no parseable clean/notice signal in output: $r_summary"
  fi
  record_suite "residue" "$r_ec" "$r_summary"
else
  record_suite "residue" 1 "not installed"
fi

# ---------------------------------------------------------------------------
# Git receipt set — informational, not gated (nothing here can make a suite
# "fail"; it is a factual snapshot for the packet).
# ---------------------------------------------------------------------------
git_branch="$(git rev-parse --abbrev-ref HEAD)"
git_head="$(git rev-parse HEAD)"
git_porcelain_count="$(git status --porcelain | wc -l | tr -d ' ')"
git_parents_json="$(git log -1 --pretty=%P HEAD | tr ' ' '\n' | jq -R -s -c 'split("\n") | map(select(length > 0))')"

# ---------------------------------------------------------------------------
# Assemble the one structured output.
# ---------------------------------------------------------------------------
suites_json="$(jq -s -c '.' "$SUITES_NDJSON")"
jq -n \
  --argjson suites "$suites_json" \
  --arg branch "$git_branch" \
  --arg head "$git_head" \
  --argjson porcelain_count "$git_porcelain_count" \
  --argjson parents "$git_parents_json" \
  --argjson all_green "$ALL_GREEN" \
  '{
    suites: $suites,
    git: {
      branch: $branch,
      head_sha: $head,
      porcelain_count: $porcelain_count,
      head_parents: $parents
    },
    overall: { all_green: $all_green }
  }'

[ "$ALL_GREEN" = "true" ] && exit 0 || exit 1
