#!/usr/bin/env bash
# Release-audit residue check: greps TRACKED files against a local, gitignored
# blocklist of private names (deployment repos, product names, sibling-repo paths).
# The blocklist lives at audits/residue-blocklist.txt and is NEVER committed — a
# committed blocklist would leak the very names it protects. One case-insensitive
# extended-regex pattern per line; blank lines and # comments ignored.
# Absent or empty blocklist -> notice, exit 0 (degraded). Any hit -> exit 1.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
BLOCKLIST="audits/residue-blocklist.txt"
if [ ! -f "$BLOCKLIST" ]; then
  echo "notice: $BLOCKLIST absent — residue check skipped (local-only file; create it before a release audit)"
  exit 0
fi
patterns="$(sed -e '/^[[:space:]]*$/d' -e '/^#/d' "$BLOCKLIST")"
if [ -z "$patterns" ]; then
  echo "notice: $BLOCKLIST empty — residue check skipped"
  exit 0
fi
status=0
while IFS= read -r p; do
  if hits="$(git grep -n -i -E -- "$p" 2>/dev/null)"; then
    echo "RESIDUE: pattern '$p' matches tracked files:"
    printf '%s\n' "$hits"
    status=1
  fi
done <<< "$patterns"
[ "$status" -eq 0 ] && echo "residue check: clean ($(printf '%s\n' "$patterns" | wc -l | tr -d ' ') patterns, 0 hits)"
exit "$status"
