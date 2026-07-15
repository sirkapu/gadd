#!/usr/bin/env bash
# Release-audit residue check: greps TRACKED files against a local, gitignored
# blocklist of private names (deployment repos, product names, sibling-repo paths).
# The blocklist lives at audits/residue-blocklist.txt and is NEVER committed — a
# committed blocklist would leak the very names it protects. One case-insensitive
# extended-regex pattern per line; blank lines and # comments ignored.
# Absent or empty blocklist -> notice, exit 0 (degraded). Any hit -> exit 1.
#
# PATTERN DIALECT: POSIX ERE ONLY. PCRE-style escapes (\b \d \w \s ...) are REJECTED
# loudly below — `git grep -E` treats them as dead syntax on some platforms (proven
# 2026-07-15: a \bevo\b pattern silently matched nothing, a fabricated-clean in this
# very guard). Word boundaries: use (^|[^[:alnum:]_])name([^[:alnum:]_]|$).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
BLOCKLIST="audits/residue-blocklist.txt"

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
  if hits="$(git grep -n -i -E -- "$p" 2>/dev/null)"; then
    echo "RESIDUE: pattern '$p' matches tracked files:"
    printf '%s\n' "$hits"
    status=1
  fi
done <<< "$patterns"
[ "$status" -eq 0 ] && echo "residue check: clean ($(printf '%s\n' "$patterns" | wc -l | tr -d ' ') patterns, 0 hits; engine canary passed)"
exit "$status"
