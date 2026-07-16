#!/usr/bin/env bash
# bin/loop-heartbeat.sh — deterministic context-ceiling enforcement (SPEED AUDIT v1,
# P1, ratified 2026-07-16, operator design ruling): "measure the real quantity —
# transcript-size heartbeat, deterministic read." Mechanical implementation of the
# existing mission-loop.md stop condition 3 (~40% context used -> hand off). The
# Director cannot reliably see its own context %, so this script reads it from the
# Claude Code session transcript instead of asking the model to "feel" it.
#
# MECHANISM (mirrors the speed-audit-v1 parser's per-turn context stat, NOT its
# cumulative cost-accounting sum): a Claude Code assistant-turn's `message.usage`
# carries input_tokens + cache_creation_input_tokens + cache_read_input_tokens for
# THAT turn's API call. Because context grows monotonically within a session (each
# turn's cache_read reflects the prior context re-read from cache), that per-turn sum
# IS the context size the model is currently carrying — the same per-turn snapshot
# the audit averaged/percentiled to find "289k/turn avg, 551k worst-decile, 624k max"
# (audits/speed-audit-v1.md §1.2 #1). We read the MOST RECENT such turn's usage
# fields — a live "how big is my context right now" reading, not a sum-to-date.
#
# TRANSCRIPT LOCATION: Claude Code writes session transcripts as JSONL under
# "$HOME/.claude/projects/<project-slug>/<session-id>.jsonl", where <project-slug>
# is the repo's git toplevel path with every non-alphanumeric character replaced by
# "-" (verified empirically against this project's own transcript directory). Never
# hardcode a machine path here — always resolve via $HOME + git toplevel at runtime.
#
# SESSION SELECTION: pass an explicit session id or transcript path as the second
# argument, or set env var GADD_HEARTBEAT_SESSION. If neither is given, this script
# falls back to the NEWEST *.jsonl file (by mtime) directly under the project's
# transcript dir — a HEURISTIC (the actively-written current session is usually, but
# not provably, the newest file; a concurrent second session would defeat it). The
# heuristic is disclosed in `status` output via "session_resolution" and noted on
# stderr in `check` mode. Prefer passing an explicit id when one is known.
#
# MEASUREMENT FALLBACKS (never silent — every tier is labeled in the output):
#   1. tokens  — the mechanism above. Preferred; exact.
#   2. bytes   — if no assistant usage field is found in the transcript, estimate
#                tokens from raw file size: value = bytes / GADD_CTX_BYTES_PER_TOKEN
#                (default 4 — the common bytes-per-token rule of thumb for
#                English/JSON-mixed text; a labeled heuristic, not a measurement).
#   3. turns   — if even the byte size is unavailable (unreadable/empty), estimate
#                tokens from a count of assistant-type JSONL lines:
#                value = turns * GADD_CTX_TOKENS_PER_TURN (default 500 — derived
#                from audits/speed-audit-v1.md: the run #1-#9 corpus crossed the
#                400k-token ceiling around turn ~790 of a 1,070-turn session, i.e.
#                ~506 tokens/turn average context growth; rounded down to a
#                conservative 500). This is a cruder proxy than bytes and is a
#                last resort.
#   unavailable — none of the above could be read. FAILS CLOSED: exit 2, never
#                reported as "under ceiling" (fail-closed doctrine).
#
# CEILING: env GADD_CTX_CEILING_TOKENS overrides; default 400000 = 40% of a 1M-token
# context window — the ratified stop-condition 3 threshold (mission-loop.md).
#
# USAGE: bin/loop-heartbeat.sh [check|status] [session-id-or-path]
#   check (default) -> compares the measurement to the ceiling.
#     exit 0 = under ceiling (one status line to stdout).
#     exit 3 = CEILING REACHED (one loud line to stdout instructing hand-off per
#              mission-loop.md stop condition 3 CONTEXT THRESHOLD).
#     exit 2 = cannot measure (one loud line to stdout AND stderr; fails closed —
#              the caller must treat this the same as exit 3, never as exit 0).
#   status -> prints one JSON object to stdout: source file, method used
#     [tokens|bytes|turns|unavailable], value, ceiling, pct, session_resolution.
#     Exit 0 if measured, exit 2 (JSON carries an "error" field) if not.
set -uo pipefail

MODE="${1:-check}"
SESSION_ARG="${2:-${GADD_HEARTBEAT_SESSION:-}}"

CEILING="${GADD_CTX_CEILING_TOKENS:-400000}"

# Validate the ceiling right where it's read (mirrors the -gt 0 2>/dev/null guard
# style used below for the other two env constants). Unlike those two — which have
# safe fallback tiers when their constant is garbage — CEILING is used directly in
# the check-mode -ge comparison with no fallback: a non-numeric value (e.g. "400k")
# makes `[ "$VALUE" -ge "$CEILING" ]` error, bash treats the error as false, and the
# script would print "OK" and exit 0 on a possibly-over-ceiling context. That is a
# fail-open bug. Fail closed instead: garbage/non-positive ceiling -> loud line on
# stdout+stderr, exit 2 (cannot-measure semantics; never compare against garbage,
# never exit 0).
if ! [ "$CEILING" -gt 0 ] 2>/dev/null; then
  MSG="[loop-heartbeat] CANNOT MEASURE — GADD_CTX_CEILING_TOKENS=\"$CEILING\" is not a positive integer — fail-closed: refusing to compare context against a garbage/non-positive ceiling (never exit 0 on unmeasurable input)."
  if [ "$MODE" = "status" ]; then
    jq -n --arg ceiling_raw "$CEILING" --arg reason "$MSG" \
      '{measured: false, error: $reason, ceiling_raw: $ceiling_raw, method: "unavailable"}'
    echo "$MSG" >&2
  else
    echo "$MSG"
    echo "$MSG" >&2
  fi
  exit 2
fi

BYTES_PER_TOKEN="${GADD_CTX_BYTES_PER_TOKEN:-4}"
TOKENS_PER_TURN="${GADD_CTX_TOKENS_PER_TURN:-500}"

TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SLUG="$(printf '%s' "$TOPLEVEL" | sed 's/[^A-Za-z0-9]/-/g')"
PROJECT_DIR="$HOME/.claude/projects/$SLUG"

# --- resolve the transcript file --------------------------------------------------
SOURCE_FILE=""
SESSION_RESOLUTION=""

if [ -n "$SESSION_ARG" ]; then
  if [ -f "$SESSION_ARG" ]; then
    SOURCE_FILE="$SESSION_ARG"
    SESSION_RESOLUTION="explicit-path"
  elif [ -f "$PROJECT_DIR/$SESSION_ARG.jsonl" ]; then
    SOURCE_FILE="$PROJECT_DIR/$SESSION_ARG.jsonl"
    SESSION_RESOLUTION="explicit-session-id"
  else
    SOURCE_FILE="$PROJECT_DIR/$SESSION_ARG.jsonl"  # nonexistent; caught below
    SESSION_RESOLUTION="explicit-session-id-not-found"
  fi
else
  NEWEST="$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | head -n 1 || true)"
  if [ -n "$NEWEST" ]; then
    SOURCE_FILE="$NEWEST"
    SESSION_RESOLUTION="heuristic-newest-file"
    echo "[loop-heartbeat] notice: no session id given — using newest transcript file (heuristic): $SOURCE_FILE" >&2
  else
    SESSION_RESOLUTION="no-transcript-dir-or-files"
  fi
fi

# --- measure -----------------------------------------------------------------------
METHOD="unavailable"
VALUE=""
RAW_VALUE=""
MEASURE_NOTE=""

if [ -n "$SOURCE_FILE" ] && [ -f "$SOURCE_FILE" ] && [ -r "$SOURCE_FILE" ]; then
  # Tier 1: tokens — most recent assistant turn's usage fields.
  LAST_USAGE="$(jq -R -c 'fromjson? | select(.type=="assistant" and (.message.usage != null)) | .message.usage' "$SOURCE_FILE" 2>/dev/null | tail -n 1)"
  if [ -n "$LAST_USAGE" ]; then
    # A usage OBJECT whose three context fields are all null/absent carries no
    # measurement — coercing it to 0 via `// 0` would fabricate a tokens-method
    # "context 0" reading (fail-open; run #14 bench note). Emit nothing in that
    # case so the chain falls through to the labeled bytes tier. Explicit numeric
    # zeros remain a measured zero; string-typed fields still error out of the
    # addition and degrade to bytes (disclosed run #14 behavior, unchanged).
    COMPUTED="$(jq -n --argjson u "$LAST_USAGE" 'if ($u.input_tokens == null and $u.cache_creation_input_tokens == null and $u.cache_read_input_tokens == null) then empty else (($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0)) end' 2>/dev/null || true)"
    if [ -n "$COMPUTED" ] && [ "$COMPUTED" -ge 0 ] 2>/dev/null; then
      METHOD="tokens"
      VALUE="$COMPUTED"
      RAW_VALUE="$COMPUTED"
    fi
  fi

  # Tier 2: bytes — raw transcript file size, converted via documented heuristic.
  # Guarded against a misconfigured (non-positive) conversion constant: a bad env
  # override must fall through to tier 3, never divide by zero / crash.
  if [ "$METHOD" = "unavailable" ] && [ "$BYTES_PER_TOKEN" -gt 0 ] 2>/dev/null; then
    BYTES="$(wc -c < "$SOURCE_FILE" 2>/dev/null | tr -d ' ')"
    if [ -n "$BYTES" ] && [ "$BYTES" -gt 0 ] 2>/dev/null; then
      METHOD="bytes"
      RAW_VALUE="$BYTES"
      VALUE="$((BYTES / BYTES_PER_TOKEN))"
      MEASURE_NOTE="no assistant usage field found; estimated from file size (${BYTES} bytes / ${BYTES_PER_TOKEN} bytes-per-token)"
    fi
  fi

  # Tier 3: turns — count of assistant-type JSONL lines, converted via documented
  # heuristic. Last resort: reached if tier 1 found no usage fields AND tier 2's
  # byte-size path was unavailable (unreadable size, or a non-positive
  # GADD_CTX_BYTES_PER_TOKEN override). Same non-positive-constant guard as tier 2.
  if [ "$METHOD" = "unavailable" ] && [ "$TOKENS_PER_TURN" -gt 0 ] 2>/dev/null; then
    TURNS="$(jq -R -c 'fromjson? | select(.type=="assistant") | 1' "$SOURCE_FILE" 2>/dev/null | wc -l | tr -d ' ')"
    if [ -n "$TURNS" ] && [ "$TURNS" -gt 0 ] 2>/dev/null; then
      METHOD="turns"
      RAW_VALUE="$TURNS"
      VALUE="$((TURNS * TOKENS_PER_TURN))"
      MEASURE_NOTE="no usable byte size; estimated from turn count (${TURNS} assistant turns x ${TOKENS_PER_TURN} tokens/turn)"
    fi
  fi
fi

# --- report --------------------------------------------------------------------
if [ "$METHOD" = "unavailable" ]; then
  REASON="transcript unreadable or not found (source: ${SOURCE_FILE:-<none>}; resolution: $SESSION_RESOLUTION)"
  MSG="[loop-heartbeat] CANNOT MEASURE — $REASON — fail-closed: treat as CEILING REACHED, never as under-ceiling (mission-loop.md stop condition 3 amendment)."
  if [ "$MODE" = "status" ]; then
    # status mode: stdout carries ONLY the JSON object (never mixed with the loud
    # text line) so callers can always pipe it straight into jq; the loud line
    # still goes to stderr so a human tailing the run sees it.
    jq -n --arg source "${SOURCE_FILE:-}" --arg resolution "$SESSION_RESOLUTION" \
      --arg reason "$REASON" --argjson ceiling "$CEILING" \
      '{measured: false, error: $reason, source_file: $source, session_resolution: $resolution, method: "unavailable", ceiling: $ceiling}'
    echo "$MSG" >&2
  else
    echo "$MSG"
    echo "$MSG" >&2
  fi
  exit 2
fi

PCT="$(awk -v v="$VALUE" -v c="$CEILING" 'BEGIN{ if (c>0) printf "%.1f", (v/c)*100; else print "n/a" }')"

if [ "$MODE" = "status" ]; then
  jq -n --arg source "$SOURCE_FILE" --arg resolution "$SESSION_RESOLUTION" \
    --arg method "$METHOD" --argjson value "$VALUE" --argjson raw_value "${RAW_VALUE:-0}" \
    --argjson ceiling "$CEILING" --arg pct "$PCT" --arg note "$MEASURE_NOTE" \
    '{measured: true, source_file: $source, session_resolution: $resolution, method: $method,
      value: $value, raw_value: $raw_value, ceiling: $ceiling, pct: ($pct | tonumber),
      note: (if $note == "" then null else $note end)}'
  exit 0
fi

# check mode
if [ "$VALUE" -ge "$CEILING" ]; then
  echo "[loop-heartbeat] CEILING REACHED — context ${VALUE}/${CEILING} tokens (${PCT}%) via ${METHOD} method (source: ${SOURCE_FILE}) — HAND OFF NOW: write the lantern handoff + STATUS block and end this session per mission-loop.md stop condition 3 (CONTEXT THRESHOLD). Measured, not felt."
  exit 3
fi

echo "[loop-heartbeat] OK — context ${VALUE}/${CEILING} tokens (${PCT}%) via ${METHOD} method (source: ${SOURCE_FILE})"
exit 0
