#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
SHARED_DIR="${GADD_SHARED_DIR:-supabase/functions/_shared}"
[ -d "$SHARED_DIR" ] || exit 0
for f in $(changed_files 'supabase/functions' | grep -v "_shared/" || true); do
  body="$(git show "$GADD_HEAD:$f" 2>/dev/null || true)"
  echo "$body" | grep -q "Access-Control-Allow-Origin" && ! echo "$body" | grep -q "_shared/cors" && \
    finding "shared-util-reimpl" "MAJOR" "Inline CORS headers instead of importing _shared/cors" "$f"
  echo "$body" | grep -qE 'replace\(.?```(json)?' && ! echo "$body" | grep -q "_shared/json-parser" && \
    finding "shared-util-reimpl" "MAJOR" "Ad-hoc JSON fence stripping instead of _shared/json-parser" "$f"
done

exit 0
