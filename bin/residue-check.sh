#!/usr/bin/env bash
# Release-audit residue check: greps TRACKED files against a local, gitignored
# blocklist of private names (deployment repos, product names, sibling-repo paths).
# The blocklist lives at audits/residue-blocklist.txt and is NEVER committed — a
# committed blocklist would leak the very names it protects. One case-insensitive
# extended-regex pattern per line; blank lines and # comments ignored.
# Absent or empty blocklist -> notice, exit 0 (degraded). Any hit -> exit 1.
#
# USAGE: bin/residue-check.sh [<rev-range>]
#   No argument  -> scan tracked files in the working tree (release-audit mode).
#   <rev-range>  -> scan EVERY COMMIT in the range (e.g. origin/main..main): a push
#                   publishes every commit in it, not just the tip — tip-only scanning
#                   is how one leaked line reached the public remote inside intermediate
#                   commits (2026-07-15). Run this before every push.
#
# PATTERN DIALECT: POSIX ERE ONLY. PCRE-style escapes (\b \d \w \s ...) are REJECTED
# loudly below — `git grep -E` treats them as dead syntax on some platforms (proven
# 2026-07-15: a \bevo\b pattern silently matched nothing, a fabricated-clean in this
# very guard). Word boundaries: use (^|[^[:alnum:]_])name([^[:alnum:]_]|$).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
BLOCKLIST="audits/residue-blocklist.txt"
RANGE="${1:-}"
commits=""
if [ -n "$RANGE" ]; then
  commits="$(git rev-list "$RANGE")" || { echo "invalid rev-range '$RANGE'" >&2; exit 2; }
  if [ -z "$commits" ]; then
    echo "notice: rev-range '$RANGE' contains 0 commits — nothing new to publish"
  fi
fi

# --- Engine canary self-test: runs FIRST; no "clean" may be declared without it.
# The pattern below must match the canary token GADD_RESIDUE_CANARY_TOKEN in this
# tracked file using the same word-boundary idiom the blocklist relies on. If the
# grep engine cannot match it, results are unreliable — fail loud, never clean.
CANARY='(^|[^[:alnum:]_])GADD_RESIDUE_CANARY_TOKEN([^[:alnum:]_]|$)'
if ! git grep -q -i -E -- "$CANARY" -- bin/residue-check.sh 2>/dev/null; then
  echo "SELF-TEST FAILED: grep engine did not match the canary pattern — a guard that cannot run never passes silently." >&2
  exit 2
fi

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
  case "$p" in
    *'\b'*|*'\B'*|*'\d'*|*'\D'*|*'\w'*|*'\W'*|*'\s'*|*'\S'*)
      echo "UNSUPPORTED PATTERN '$p': PCRE-style escapes are silently dead under git grep -E — rewrite with POSIX classes (e.g. (^|[^[:alnum:]_])name([^[:alnum:]_]|$))." >&2
      status=1
      continue;;
  esac
  if [ -n "$RANGE" ]; then
    for c in $commits; do
      if hits="$(git grep -n -i -E -- "$p" "$c" 2>/dev/null)"; then
        echo "RESIDUE: pattern '$p' matches commit $c:"
        printf '%s\n' "$hits"
        status=1
      fi
    done
  else
    if hits="$(git grep -n -i -E -- "$p" 2>/dev/null)"; then
      echo "RESIDUE: pattern '$p' matches tracked files:"
      printf '%s\n' "$hits"
      status=1
    fi
  fi
done <<< "$patterns"
if [ "$status" -eq 0 ]; then
  if [ -n "$RANGE" ]; then
    echo "residue check: clean ($(printf '%s\n' "$patterns" | wc -l | tr -d ' ') patterns × $(printf '%s' "$commits" | grep -c . || true) commits in '$RANGE', 0 hits; engine canary passed)"
  else
    echo "residue check: clean ($(printf '%s\n' "$patterns" | wc -l | tr -d ' ') patterns, 0 hits; engine canary passed)"
  fi
fi
exit "$status"
