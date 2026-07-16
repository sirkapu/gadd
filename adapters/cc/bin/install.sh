#!/usr/bin/env bash
# Installs gadd-cc (in-loop adapter) onto an existing repo governed by Claude Code.
# Run from the target repo root.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
[ -d .git ] || { echo "run me from the target repo root"; exit 1; }

mkdir -p .claude/agents .claude/commands bin .gadd/schemas
cp -r "$SRC/agents/." .claude/agents/
cp -r "$SRC/commands/." .claude/commands/
cp "$SRC/../../spec/schemas/"*.json .gadd/schemas/
[ -d RED_TEAM ] || cp -r "$SRC/../../RED_TEAM" RED_TEAM   # adversary bench (graders — never edited by executors)

if [ -L context ] || [ -L context/ubc.md ]; then
  UBC_STATUS="  context/ubc.md -> REFUSED (context or context/ubc.md is a symlink — left untouched)"
elif [ -f context/ubc.md ]; then
  UBC_STATUS="  context/ubc.md -> SKIPPED (already exists — left untouched)"
else
  mkdir -p context
  cp "$SRC/../../context/ubc.md" context/ubc.md
  UBC_STATUS="  context/ubc.md -> context/ubc.md  (Ultrathink-Before-Coding standard, only if absent)"
fi

# mission-loop dependencies (mandatory step-0 lock + optional launchd scheduling) —
# copied so /mission-loop's references resolve in the target repo, not just in gadd itself.
cp "$SRC/bin/loop-lock.sh" bin/loop-lock.sh
cp "$SRC/bin/loop-heartbeat.sh" bin/loop-heartbeat.sh
cp "$SRC/bin/schedule-loop.sh" bin/schedule-loop.sh
cp "$SRC/bin/mission-loop.plist.template" bin/mission-loop.plist.template
chmod +x bin/loop-lock.sh bin/loop-heartbeat.sh bin/schedule-loop.sh

echo "gadd-cc installed:"
echo "  agents/    -> .claude/agents/   (executor, mechanic, fixer, 5x RED_TEAM adversary, ratifier)"
echo "  commands/  -> .claude/commands/ (/gadd-loop, /mission-loop, /objective-audit)"
echo "  RED_TEAM/  -> RED_TEAM/         (adversary bench definitions — graders, only if absent)"
echo "  spec/schemas -> .gadd/schemas/  (verdict + baseline schemas)"
echo "  bin/loop-lock.sh, bin/loop-heartbeat.sh, bin/schedule-loop.sh, bin/mission-loop.plist.template (mission-loop's own dependencies)"
echo "$UBC_STATUS"
echo
echo "Next:"
echo '  git add -A && git commit -m "chore: install gadd-cc"'
echo "  Then: /gadd-loop <feature or spec path>  — one feature loop, tiered model dispatch"
echo "     or: /mission-loop                     — the autonomous run-until-done driver"
echo "Pairs with adapters/lv's deterministic ratchet if also installed (.gadd/): if you install"
echo "  gadd-lv too, follow ITS install output for the accept-then-push dance (gadd/BASELINE.json) —"
echo "  gadd-cc itself writes no baseline and needs no accept step."
echo 'Suggestion (not applied automatically — your call): add to your CLAUDE.md a line like "Standards: see [context/ubc.md](context/ubc.md)"'
