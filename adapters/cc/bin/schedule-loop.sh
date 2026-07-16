#!/usr/bin/env bash
# Installs (or removes) the launchd user-agent that runs the gadd mission loop
# nightly at 02:17 local time. Renders bin/mission-loop.plist.template into
# $HOME/Library/LaunchAgents/com.gadd.mission-loop.plist — the rendered plist
# (which contains this machine's real paths) is NEVER written inside the repo.
#
# Night-mode park-and-continue governs every scheduled run (see
# .claude/commands/mission-loop.md): a run that finds only parked work (items
# awaiting operator ratification) reports QUEUE EMPTY and exits cleanly — that
# is the system working as designed, not a failure.
#
# USAGE: bin/schedule-loop.sh             install/reload the launchd job
#        bin/schedule-loop.sh --uninstall bootout the job and remove its plist
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

LABEL="com.gadd.mission-loop"
TEMPLATE="bin/mission-loop.plist.template"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST="$PLIST_DIR/$LABEL.plist"
UID_GUI="gui/$(id -u)"

if [ "${1:-}" = "--uninstall" ]; then
  launchctl bootout "$UID_GUI/$LABEL" 2>/dev/null || true
  rm -f "$PLIST"
  echo "uninstalled: $LABEL bootout + $PLIST removed"
  exit 0
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "FAIL: $TEMPLATE missing" >&2
  exit 1
fi

REPO_PATH="$(pwd)"
CLAUDE_BIN="$(command -v claude || true)"
if [ -z "$CLAUDE_BIN" ]; then
  echo "FAIL: 'claude' not found on PATH — install/link the claude CLI before scheduling the mission loop." >&2
  exit 1
fi
LOG_PATH="$HOME/Library/Logs/gadd-mission-loop.log"

mkdir -p "$PLIST_DIR"
mkdir -p "$(dirname "$LOG_PATH")"

sed -e "s|{{REPO_PATH}}|$REPO_PATH|g" \
    -e "s|{{CLAUDE_BIN}}|$CLAUDE_BIN|g" \
    -e "s|{{LOG_PATH}}|$LOG_PATH|g" \
    "$TEMPLATE" > "$PLIST"

launchctl bootout "$UID_GUI/$LABEL" 2>/dev/null || true
launchctl bootstrap "$UID_GUI" "$PLIST"

echo "installed: $LABEL -> $PLIST (repo=$REPO_PATH claude=$CLAUDE_BIN log=$LOG_PATH)"
launchctl print "$UID_GUI/$LABEL" | head
