#!/usr/bin/env bash
# 10-ratchet-parity.sh — upstream ratchet metric parity (docs/metric-parity.md).
# Graceful adoption: with no gadd/BASELINE.json `parity.gating` block, this check
# only measures (merges into /tmp/gadd-metrics.json) and never fails the gate.
# Once `parity.gating` is configured, any measured regression beyond baseline, or any
# CONFIGURED metric that comes back unmeasurable (tool missing, node missing), is a
# MAJOR finding — a gate that cannot run never passes silently.
source "$(dirname "$0")/lib/common.sh"

ENGINE="$(dirname "$0")/lib/parity-metrics.mjs"
METRICS_FILE="${GADD_METRICS_FILE:-/tmp/gadd-metrics.json}"
GATING_METRICS="eslint_errors eslint_warnings tsc_errors any_count eslint_disables oversized_files duplicate_windows"

gating_configured="false"
if [ -f gadd/BASELINE.json ] && \
   jq -e '(.parity.gating != null) and (.parity.gating | type == "object")' gadd/BASELINE.json >/dev/null 2>&1; then
  gating_configured="true"
fi

[ "$gating_configured" = "false" ] && \
  echo "::notice::parity baseline not configured — measuring only, not gating" >&2

# unmeasurable_all <reason> — a gate that cannot run never passes silently: every
# CONFIGURED gating metric gets its own MAJOR finding.
unmeasurable_all() {
  local reason="$1"
  [ "$gating_configured" != "true" ] && return 0
  for m in $GATING_METRICS; do
    local baseline_val
    baseline_val="$(baseline_get ".parity.gating.$m")"
    [ -z "$baseline_val" ] && continue
    finding "ratchet-parity" "MAJOR" "$m unmeasurable but gating — a gate that cannot run never passes silently ($reason)"
  done
}

if ! command -v node >/dev/null 2>&1; then
  echo "::warning::node unavailable — parity metrics cannot be measured" >&2
  unmeasurable_all "node unavailable"
  exit 0
fi

engine_stderr="$(mktemp)"
measured="$(node "$ENGINE" 2>"$engine_stderr")"
engine_rc=$?
engine_err="$(cat "$engine_stderr" 2>/dev/null)"
rm -f "$engine_stderr"

if [ "$engine_rc" -ne 0 ] || [ -z "$measured" ] || ! echo "$measured" | jq -e 'type == "object"' >/dev/null 2>&1; then
  echo "::warning::parity engine failed to run: $engine_err" >&2
  unmeasurable_all "engine failed to run"
  exit 0
fi

available="$(echo "$measured" | jq -r '.available')"
if [ "$available" != "true" ]; then
  # e.g. {"available":false,"reason":"no src"} — nothing to measure or merge, and
  # nothing to gate on; this is a disclosed non-finding, not a failure.
  exit 0
fi

# Merge measured values into the shared metrics file under a "parity" key, preserving
# whatever earlier checks (e.g. 07-ratchet-metrics.sh) already wrote there.
existing="$(cat "$METRICS_FILE" 2>/dev/null || echo '{}')"
echo "$existing" | jq -e 'type == "object"' >/dev/null 2>&1 || existing='{}'
merged="$(jq -cn --argjson e "$existing" --argjson p "$measured" '$e + {parity: $p}')"
printf '%s\n' "$merged" > "$METRICS_FILE"

[ "$gating_configured" = "false" ] && exit 0

for m in $GATING_METRICS; do
  baseline_val="$(baseline_get ".parity.gating.$m")"
  [ -z "$baseline_val" ] && continue   # metric not configured for gating — measure only

  # A non-integer baseline gating value (e.g. 0.5 or "abc") makes both `-gt` and
  # `-lt` integer comparisons fail silently (2>/dev/null), so neither the regression
  # branch nor the notice would fire — a real regression would pass. A gate that
  # cannot compare never passes silently: flag the malformed baseline as MAJOR.
  if ! printf '%s' "$baseline_val" | grep -Eq '^-?[0-9]+$'; then
    finding "ratchet-parity" "MAJOR" "malformed baseline gating value for $m: $baseline_val — gating disabled is not an option"
    continue
  fi

  current_val="$(echo "$measured" | jq -r ".gating.$m")"
  if [ "$current_val" = "null" ] || [ -z "$current_val" ]; then
    finding "ratchet-parity" "MAJOR" "$m unmeasurable but gating — a gate that cannot run never passes silently"
    continue
  fi

  if [ "$current_val" -gt "$baseline_val" ] 2>/dev/null; then
    finding "ratchet-parity" "MAJOR" "$m regressed: $baseline_val -> $current_val"
  elif [ "$current_val" -lt "$baseline_val" ] 2>/dev/null; then
    echo "::notice::$m improved ($baseline_val -> $current_val) — baselines only tighten via a human-invoked --tighten; not auto-written" >&2
  fi
done

exit 0
