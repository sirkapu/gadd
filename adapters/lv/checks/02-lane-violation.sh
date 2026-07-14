#!/usr/bin/env bash
# Parses OWNERSHIP.md fenced block: lines under "```gadd-governed" are glob patterns.
# Exception: gadd/BASELINE.json may change ONLY via commits whose subject starts "gadd: accept"
# AND whose author email is in the ACCEPTED baseline's accept_authors allowlist (read from
# GADD_BASE, not the working tree, so an agent cannot self-enroll in the same push).
# No allowlist in the accepted baseline -> legacy subject-only check + a MINOR nudge.
source "$(dirname "$0")/lib/common.sh"
[ -f OWNERSHIP.md ] || { finding "lane-violation" "MAJOR" "OWNERSHIP.md missing — lanes unenforceable"; exit 0; }
globs="$(awk '/^```gadd-governed/{f=1;next}/^```/{f=0}f' OWNERSHIP.md | sed '/^\s*$/d;/^#/d')"
[ -z "$globs" ] && exit 0
viol=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if [ "$f" = "gadd/BASELINE.json" ]; then
    allow="$(git show "$GADD_BASE:gadd/BASELINE.json" 2>/dev/null | jq -r '.accept_authors[]? // empty' 2>/dev/null || true)"
    if [ -z "$allow" ]; then
      finding "lane-violation" "MINOR" "accept_authors not set in accepted baseline — accept-commit authorship unverifiable" "gadd/BASELINE.json"
    fi
    bad=0
    while IFS=$'\t' read -r subj ae; do
      case "$subj" in "gadd: accept"*) ;; *) bad=1; break ;; esac
      if [ -n "$allow" ]; then
        printf '%s\n' "$allow" | grep -qxF "$ae" || { bad=1; break; }
      fi
    done < <(git log --format='%s%x09%ae' "$GADD_BASE".."$GADD_HEAD" -- "$f")
    [ "$bad" -eq 0 ] && continue
  fi
  while IFS= read -r g; do
    case "$f" in $g) viol="$viol,$f"; break;; esac
  done <<< "$globs"
done < <(changed_files; deleted_files)
viol="${viol#,}"
[ -z "$viol" ] && exit 0
finding "lane-violation" "CRITICAL" "Governed-side files were modified (see OWNERSHIP.md lanes)" "$viol"
exit 0
