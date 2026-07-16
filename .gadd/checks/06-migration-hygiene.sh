#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
MIG_DIR="${GADD_MIGRATIONS_DIR:-supabase/migrations}"
for f in $(added_files "$MIG_DIR" | grep -E '\.sql$' || true); do
  base="$(basename "$f")"
  echo "$base" | grep -qE '^[0-9]{14}_[a-z0-9_]+\.sql$' || \
    finding "migration-hygiene" "MAJOR" "Migration filename not YYYYMMDDHHMMSS_snake_case.sql: $base" "$f"
done
mod="$(git diff --name-only --diff-filter=MD "$GADD_BASE".."$GADD_HEAD" -- "$MIG_DIR" | grep -E '\.sql$' || true)"
[ -n "$mod" ] && finding "migration-hygiene" "MAJOR" "Previously-applied migrations modified or deleted" "$(echo "$mod" | paste -sd, -)"

exit 0
