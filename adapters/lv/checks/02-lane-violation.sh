#!/usr/bin/env bash
# Parses OWNERSHIP.md fenced block: lines under "```gadd-governed" are glob patterns.
# Exception: gadd/BASELINE.json may change ONLY via commits whose subject starts "gadd: accept".
source "$(dirname "$0")/lib/common.sh"
[ -f OWNERSHIP.md ] || { finding "lane-violation" "MAJOR" "OWNERSHIP.md missing — lanes unenforceable"; exit 0; }
globs="$(awk '/^```gadd-governed/{f=1;next}/^```/{f=0}f' OWNERSHIP.md | sed '/^\s*$/d;/^#/d')"
[ -z "$globs" ] && exit 0
viol=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if [ "$f" = "gadd/BASELINE.json" ]; then
    bad=$(git log --format='%s' "$GADD_BASE".."$GADD_HEAD" -- "$f" | grep -cv '^gadd: accept' || true)
    [ "${bad:-0}" -eq 0 ] && continue
  fi
  while IFS= read -r g; do
    case "$f" in $g) viol="$viol,$f"; break;; esac
  done <<< "$globs"
done < <(changed_files; deleted_files)
viol="${viol#,}"
[ -z "$viol" ] && exit 0
finding "lane-violation" "CRITICAL" "Governed-side files were modified (see OWNERSHIP.md lanes)" "$viol"
exit 0
