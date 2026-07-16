#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
CONTRACT_DIR="${GADD_CONTRACT_DIR:-src/contracts}"
[ ! -d "$CONTRACT_DIR" ] && \
  echo "::notice::contract-drift inapplicable — $CONTRACT_DIR absent (available:false)" >&2
changed="$(changed_files "$CONTRACT_DIR"; deleted_files "$CONTRACT_DIR")"
[ -z "$changed" ] && exit 0
finding "contract-drift" "CRITICAL" \
  "Contract files changed since accepted baseline — contracts are governed-side law" \
  "$(echo "$changed" | paste -sd, -)"

exit 0
