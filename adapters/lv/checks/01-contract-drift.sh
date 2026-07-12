#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
CONTRACT_DIR="${GADD_CONTRACT_DIR:-src/contracts}"
changed="$(changed_files "$CONTRACT_DIR"; deleted_files "$CONTRACT_DIR")"
[ -z "$changed" ] && exit 0
finding "contract-drift" "CRITICAL" \
  "Contract files changed since accepted baseline — contracts are governed-side law" \
  "$(echo "$changed" | paste -sd, -)"

exit 0
