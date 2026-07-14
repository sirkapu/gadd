#!/usr/bin/env bash
# Installs gadd-lv onto an existing Lovable-created repo. Run from the target repo root.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
[ -d .git ] || { echo "run me from the target repo root"; exit 1; }

mkdir -p .gadd/checks/lib .github/workflows gadd/verdicts gadd/lv-blockers
cp -r "$SRC/checks/." .gadd/checks/
cp "$SRC/workflows/"gadd-*.yml .github/workflows/
[ -d RED_TEAM ] || cp -r "$SRC/../../RED_TEAM" RED_TEAM   # adversary bench (graders — never edited by executors)
for t in AGENTS.md OWNERSHIP.md; do [ -f "$t" ] || cp "$SRC/templates/$t" "$t"; done
cp "$SRC/templates/LV-REPAIR-TEMPLATE.md" gadd/ 2>/dev/null || true

AGENTS_SHA=$(sha256sum AGENTS.md | awk '{print $1}')
cat > gadd/BASELINE.json << JSON
{
  "accepted_sha": "$(git rev-parse HEAD)",
  "agents_md_sha": "$AGENTS_SHA",
  "metrics": { "skipped_tests": 0, "max_file_loc": 400 }
}
JSON
echo "gadd-lv installed. Baseline = $(git rev-parse --short HEAD)."
echo "Next: (1) commit & push, (2) paste AGENTS.md into Lovable Knowledge, (3) build."
