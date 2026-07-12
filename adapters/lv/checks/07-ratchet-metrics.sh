#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
b_skip=$(baseline_get '.metrics.skipped_tests'); b_loc=$(baseline_get '.metrics.max_file_loc')
cur_skip=$(grep -rE '\.(skip|only)\(|xit\(|xdescribe\(' --include='*.test.*' --include='*.spec.*' -c src 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')
cur_loc=$(find src -name '*.ts' -o -name '*.tsx' 2>/dev/null | xargs -r wc -l 2>/dev/null | sort -rn | awk 'NR==1{print $1+0}')
echo "{\"skipped_tests\":${cur_skip:-0},\"max_file_loc\":${cur_loc:-0}}" > /tmp/gadd-metrics.json
[ -n "$b_skip" ] && [ "${cur_skip:-0}" -gt "$b_skip" ] && \
  finding "ratchet-metrics" "MAJOR" "Skipped tests grew: $b_skip → $cur_skip"
[ -n "$b_loc" ] && [ "${cur_loc:-0}" -gt $((b_loc + 150)) ] && \
  finding "ratchet-metrics" "MINOR" "Max file size grew: ${b_loc} → ${cur_loc} LOC"
exit 0
