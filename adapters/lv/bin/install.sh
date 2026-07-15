#!/usr/bin/env bash
# Installs gadd-lv onto an existing Lovable-created repo. Run from the target repo root.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
[ -d .git ] || { echo "run me from the target repo root"; exit 1; }

mkdir -p .gadd/checks/lib .gadd/schemas .github/workflows gadd/verdicts gadd/lv-blockers
[ -f gadd/ESCAPED.jsonl ] || touch gadd/ESCAPED.jsonl   # escaped-regression ledger, one JSONL line per defect (see docs/measurement.md)
cp -r "$SRC/checks/." .gadd/checks/
cp "$SRC/../../spec/schemas/"*.json .gadd/schemas/
cp "$SRC/workflows/"gadd-*.yml .github/workflows/
[ -d RED_TEAM ] || cp -r "$SRC/../../RED_TEAM" RED_TEAM   # adversary bench (graders — never edited by executors)
for t in AGENTS.md OWNERSHIP.md; do [ -f "$t" ] || cp "$SRC/templates/$t" "$t"; done
cp "$SRC/templates/LV-REPAIR-TEMPLATE.md" gadd/ 2>/dev/null || true

AGENTS_SHA=$(sha256sum AGENTS.md | awk '{print $1}')
EMAIL="$(git config user.email || true)"
ACCEPT_AUTHORS="[]"; [ -n "$EMAIL" ] && ACCEPT_AUTHORS="[\"$EMAIL\"]"
cat > gadd/BASELINE.json << JSON
{
  "accepted_sha": "$(git rev-parse HEAD)",
  "agents_md_sha": "$AGENTS_SHA",
  "accept_authors": $ACCEPT_AUTHORS,
  "metrics": { "skipped_tests": 0, "max_file_loc": 400 }
}
JSON
echo "gadd-lv installed. Baseline = $(git rev-parse --short HEAD) (pre-install HEAD)."
echo "Next — commit the install, then ACCEPT it, then push BOTH commits together"
echo "(otherwise the first ratchet run flags the installation itself as a lane violation):"
echo '  1) git add -A && git commit -m "chore: install gadd-lv"'
echo '  2) jq --arg sha "$(git rev-parse HEAD)" '"'"'.accepted_sha=$sha'"'"' gadd/BASELINE.json > t && mv t gadd/BASELINE.json'
echo '     git commit -am "gadd: accept $(git rev-parse --short HEAD)"'
echo '  3) git push'
echo "  4) paste AGENTS.md into Lovable Knowledge, then build."
