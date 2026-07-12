#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
hits=""
for f in $(changed_files 'supabase/functions' || true); do
  git show "$GADD_HEAD:$f" 2>/dev/null | grep -nEi 'console\.(log|error|warn)\(.*(key|token|secret|authorization|password|api_?key)' >/dev/null && hits="$hits,$f"
done
hits="${hits#,}"
[ -n "$hits" ] && finding "secret-leakage" "CRITICAL" "console logging of credentials-like values in edge functions" "$hits"
lit="$(diff_added_lines | grep -cE '(sk-[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{20,}\.)' || true)"
[ "${lit:-0}" -gt 0 ] && finding "secret-leakage" "CRITICAL" "Hardcoded credential-shaped literal added ($lit occurrence(s))"
exit 0
