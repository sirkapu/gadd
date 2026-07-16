#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
TEST_GLOB='*.test.*|*.spec.*|__tests__/*'
del="$(deleted_files | grep -E '\.(test|spec)\.[jt]sx?$|__tests__/' || true)"
[ -n "$del" ] && finding "test-weakening" "MAJOR" "Test files deleted" "$(echo "$del" | paste -sd, -)"
skips="$(diff_added_lines | grep -cE '\.(skip|only)\(|xit\(|xdescribe\(' || true)"
[ "${skips:-0}" -gt 0 ] && finding "test-weakening" "MAJOR" "Added $skips skipped/focused test marker(s) (.skip/.only/xit)"
# assertion count drop in modified test files
for f in $(changed_files | grep -E '\.(test|spec)\.[jt]sx?$' || true); do
  before=$(git show "$GADD_BASE:$f" 2>/dev/null | grep -cE 'expect\(|assert' || true)
  after=$(git show "$GADD_HEAD:$f" 2>/dev/null | grep -cE 'expect\(|assert' || true)
  if [ "${after:-0}" -lt "${before:-0}" ]; then
    finding "test-weakening" "MAJOR" "Assertions dropped in $f (${before}→${after})" "$f"
  fi
done

exit 0
