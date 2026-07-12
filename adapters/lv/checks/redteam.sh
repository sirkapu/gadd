#!/usr/bin/env bash
# LLM adversaries (advisory). Reads a diff, asks for VERDICT + max 3 blockers + one-line fixes.
# Requires ANTHROPIC_API_KEY. Never edits code; output feeds the repair prompt.
set -euo pipefail
DIFF_FILE="${1:?usage: redteam.sh <diff.patch>}"
PROMPT="You are 5 adversarial reviewers (security, data-integrity, contract-fidelity, test-honesty, regression) reviewing ONE diff from an autonomous coding agent. Reply with exactly: VERDICT: PASS or FAIL, then at most 3 blockers, each with a one-line fix. No code rewrites."
BODY=$(jq -n --arg p "$PROMPT" --arg d "$(head -c 150000 "$DIFF_FILE")" \
  '{model:"claude-sonnet-4-6", max_tokens:1000, messages:[{role:"user", content:($p + "\n\n<diff>\n" + $d + "\n</diff>")}]}')
RESP=$(curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" \
  -d "$BODY")
TEXT=$(echo "$RESP" | jq -r '.content[0].text // empty')
echo "$TEXT"
mkdir -p gadd/verdicts && echo "$TEXT" > "gadd/verdicts/$(git rev-parse HEAD).redteam.txt"
echo "$TEXT" | grep -q "VERDICT: PASS"
