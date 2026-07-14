#!/usr/bin/env bash
# LLM adversary bench (advisory). One ISOLATED API call per adversary definition in
# RED_TEAM/ — independent contexts run in parallel; no adversary ever sees another's
# verdict. Never a single prompt role-playing the bench (see docs/rejection-ledger.md).
# Models per orchestration tier: structural -> cheap, judgment -> strong.
# Requires ANTHROPIC_API_KEY. Never edits code; output feeds the repair prompt.
set -euo pipefail
DIFF_FILE="${1:?usage: redteam.sh <diff.patch>}"
BENCH_DIR="${GADD_BENCH_DIR:-RED_TEAM}"
[ -d "$BENCH_DIR" ] || { echo "no $BENCH_DIR/ bench in this repo — install it (cp -r gadd/RED_TEAM .)"; exit 1; }

CHEAP_MODEL="${GADD_MODEL_CHEAP:-claude-haiku-4-5-20251001}"
STRONG_MODEL="${GADD_MODEL_STRONG:-claude-opus-4-8}"
SHA=$(git rev-parse HEAD)
TMP=$(mktemp -d)
mkdir -p gadd/verdicts

run_adversary() {
  local def="$1" name model prompt body resp
  name=$(basename "$def" .md)
  if grep -q '^Tier: structural' "$def"; then model="$CHEAP_MODEL"; else model="$STRONG_MODEL"; fi
  prompt="You are ONE adversary of the GADD RED_TEAM bench, reviewing a diff from an autonomous coding agent. Your definition (role, attack surface, pass criteria, output contract) follows — attack strictly within it. You have no knowledge of the other adversaries' verdicts. Reply per your output contract: VERDICT: PASS or VERDICT: FAIL, then at most 3 blockers, each with a one-line fix. No code rewrites.

$(cat "$def")"
  body=$(jq -n --arg m "$model" --arg p "$prompt" --arg d "$(head -c 150000 "$DIFF_FILE")" \
    '{model:$m, max_tokens:1000, messages:[{role:"user", content:($p + "\n\n<diff>\n" + $d + "\n</diff>")}]}')
  resp=$(curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" \
    -d "$body")
  echo "$resp" | jq -r '.content[0].text // empty' > "$TMP/$name.txt"
  cp "$TMP/$name.txt" "gadd/verdicts/$SHA.redteam.$name.txt"
}

pids=()
for def in "$BENCH_DIR"/*.md; do
  case "$(basename "$def")" in gate-matrix.md|CLAUDE.md|README.md) continue ;; esac
  run_adversary "$def" &
  pids+=("$!")
done
[ "${#pids[@]}" -gt 0 ] || { echo "no adversary definitions in $BENCH_DIR/"; exit 1; }
for p in "${pids[@]}"; do wait "$p" || true; done

# Mechanical aggregation: any FAIL, missing, or empty/errored response fails the bench.
overall=0
[ "$(ls "$TMP" | wc -l)" -eq "${#pids[@]}" ] || { echo "an adversary produced no verdict"; overall=1; }
for f in "$TMP"/*.txt; do
  echo "--- $(basename "$f" .txt) ---"
  cat "$f"
  grep -q "VERDICT: PASS" "$f" || overall=1
done
exit "$overall"
