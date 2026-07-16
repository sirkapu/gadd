#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
MIG_DIR="${GADD_MIGRATIONS_DIR:-supabase/migrations}"
newmigs="$(added_files "$MIG_DIR" | grep -E '\.sql$' || true)"
[ -z "$newmigs" ] && exit 0
allsql="$(cat $newmigs 2>/dev/null | tr '[:upper:]' '[:lower:]')"
tables="$(echo "$allsql" | grep -oE 'create table (if not exists )?(public\.)?[a-z0-9_]+' | awk '{print $NF}' | sed 's/^public\.//' | sort -u)"
for t in $tables; do
  echo "$allsql" | grep -q "alter table.*${t}.*enable row level security" || \
    finding "rls-presence" "CRITICAL" "New table '$t' created without ENABLE ROW LEVEL SECURITY" "$(echo "$newmigs" | paste -sd, -)"
  echo "$allsql" | grep -q "create policy.*on.*${t}" || \
    finding "rls-presence" "CRITICAL" "New table '$t' has no CREATE POLICY" "$(echo "$newmigs" | paste -sd, -)"
done

exit 0
