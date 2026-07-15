#!/usr/bin/env bash
# Release-audit addition: seed self-application checks (audits/gadd-seed-payload.md §7).
# (a) every folder routed in root CLAUDE.md's routing table has a CLAUDE.md
#     (.claude/ exempt); adapters/lv and adapters/cc additionally required
#     regardless of whether adapters/ itself lists them (they're subfolders,
#     not routing-table rows).
# (b) root CLAUDE.md is <= 60 lines: the operational, measurable definition
#     of the "1 page" hard cap (`wc -l` on the file — a page of terminal-
#     width markdown fits comfortably inside 60 lines with wrap headroom).
# (c) AGENTS.md, after stripping its first line (the format-header comment),
#     is byte-identical to CLAUDE.md — the content-sync requirement.
# (d) "new cross-references in touched files are markdown links" is a
#     review-time criterion, not statically checkable here: printed as a
#     NOTICE, never fails this script.
#
# USAGE: bin/seed-audit.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ROOT_CLAUDE="CLAUDE.md"
AGENTS="AGENTS.md"
status=0

if [ ! -f "$ROOT_CLAUDE" ]; then
  echo "FAIL: $ROOT_CLAUDE missing"
  exit 1
fi

# --- (a) every routed folder (+ adapters/lv, adapters/cc) has a CLAUDE.md ---
# Folder-column links look like "[name/](name/)" in the routing table: both
# the link text and the target end in "/", which the Loads column (ending in
# "CLAUDE.md)") never does.
folders="$(grep -oE '\[[^]]+/\]\([^)]+/\)' "$ROOT_CLAUDE" | sed -E 's/.*\(([^)]+)\)/\1/' | sort -u || true)"
if [ -z "$folders" ]; then
  echo "FAIL: no routed folders found in $ROOT_CLAUDE routing table"
  status=1
fi
missing=""
for f in $folders adapters/lv adapters/cc; do
  f="${f%/}"
  [ "$f" = ".claude" ] && continue
  if [ ! -f "$f/CLAUDE.md" ]; then
    missing="$missing $f"
  fi
done
missing="$(printf '%s\n' "$missing" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ')"
if [ -n "$(echo "$missing" | tr -d '[:space:]')" ]; then
  echo "FAIL: missing CLAUDE.md in: $missing"
  status=1
else
  echo "PASS: every routed folder (+ adapters/lv, adapters/cc) has a CLAUDE.md"
fi

# --- (b) root CLAUDE.md <= 60 lines ---
lines="$(wc -l < "$ROOT_CLAUDE" | tr -d ' ')"
if [ "$lines" -gt 60 ]; then
  echo "FAIL: $ROOT_CLAUDE is $lines lines (> 60-line 1-page cap)"
  status=1
else
  echo "PASS: $ROOT_CLAUDE is $lines lines (<= 60-line 1-page cap)"
fi

# --- (c) AGENTS.md mirrors CLAUDE.md beyond its format header ---
if [ ! -f "$AGENTS" ]; then
  echo "FAIL: $AGENTS missing"
  status=1
elif diff -q <(tail -n +2 "$AGENTS") "$ROOT_CLAUDE" >/dev/null 2>&1; then
  echo "PASS: $AGENTS matches $ROOT_CLAUDE beyond its format header"
else
  echo "FAIL: $AGENTS drifted from $ROOT_CLAUDE (diff beyond format header)"
  status=1
fi

# --- (d) cross-reference-as-link criterion: review-time only ---
echo "NOTICE: 'new cross-references in touched files are markdown links' is a review-time criterion, not statically checkable — not evaluated by this script."

exit "$status"
