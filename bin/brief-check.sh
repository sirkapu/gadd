#!/usr/bin/env bash
# bin/brief-check.sh — brief-freshness close-check (ratified mechanism,
# audits/brief-freshness-eval-v1.md §5, operator run-25 decision-2 amendment).
# Enforces the loop's close law: a run close may not proceed on a stale
# BRIEF.md. Zero-dependency bash, no external engine beyond grep ERE (same
# dialect rule as bin/residue-check.sh: POSIX ERE only, no PCRE escapes).
#
# MECHANISM (audits/brief-freshness-eval-v1.md §2/§3):
#   1. Derive the closing run number N from LANTERN.md: the TOPMOST line
#      matching the anchored ERE `^- \*\*mission-loop run #([0-9]+) DECLARED`.
#      A run-N CLOSE entry never carries "DECLARED", so close-entry timing
#      cannot perturb derivation. No match at all -> cannot derive N -> fail
#      closed (exit 2); a session with no DECLARED entry has no business
#      closing a run.
#   2. Read BRIEF.md's HEADER LINE (line 1 only) — stable format
#      `# gadd brief — mission-loop run #N (date)`. The header must carry
#      `run #N` with a word boundary immediately after the digits, so a
#      header of "run #250" does NOT satisfy a derived N of 25.
#   3. PASS (exit 0) iff the header run number equals the derived N.
#      FAIL (exit 1) if they differ — message names BOTH numbers.
#      FAIL (exit 1) if BRIEF.md is missing or unreadable — a missing brief
#      is stale by definition.
#      Exit 2 is reserved ONLY for the cannot-derive-N case above.
#
# USAGE: bin/brief-check.sh
#   Paths are overridable (for the acceptance corpus to point at fixtures),
#   mirroring the tests/heartbeat-fixtures.sh -> bin/loop-heartbeat.sh
#   parameterization pattern (env vars, script argument fallback):
#     GADD_LANTERN_FILE — path to LANTERN.md (default: repo-root LANTERN.md)
#     GADD_BRIEF_FILE   — path to BRIEF.md (default: repo-root BRIEF.md)
#   Exit codes: 0 = PASS (fresh). 1 = FAIL (stale header, or missing/unreadable
#   BRIEF.md). 2 = cannot derive N from LANTERN.md (fail-closed).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LANTERN_FILE="${GADD_LANTERN_FILE:-$REPO_ROOT/LANTERN.md}"
BRIEF_FILE="${GADD_BRIEF_FILE:-$REPO_ROOT/BRIEF.md}"

# --- Step 1: derive N from LANTERN.md (topmost DECLARED entry). -------------
if [ ! -f "$LANTERN_FILE" ] || [ ! -r "$LANTERN_FILE" ]; then
  echo "[brief-check] cannot derive run number — LANTERN.md not found or unreadable at '$LANTERN_FILE' — fail-closed" >&2
  exit 2
fi

DECLARED_LINE="$(grep -m 1 -E -- '^- \*\*mission-loop run #([0-9]+) DECLARED' "$LANTERN_FILE" 2>/dev/null || true)"
if [ -z "$DECLARED_LINE" ]; then
  echo "[brief-check] cannot derive run number — no DECLARED entry" >&2
  exit 2
fi

N="$(printf '%s\n' "$DECLARED_LINE" | grep -o -E 'run #[0-9]+' | head -n 1 | grep -o -E '[0-9]+' || true)"
if [ -z "$N" ]; then
  echo "[brief-check] cannot derive run number — no DECLARED entry" >&2
  exit 2
fi

# --- Step 2: read BRIEF.md's header line (line 1 only). --------------------
if [ ! -f "$BRIEF_FILE" ] || [ ! -r "$BRIEF_FILE" ]; then
  echo "[brief-check] FAIL — BRIEF.md not found or unreadable at '$BRIEF_FILE' — a missing brief is stale by definition" >&2
  exit 1
fi

HEADER="$(head -n 1 "$BRIEF_FILE")"

# Word-boundary extraction: match "run #<digits>" followed by a non-digit (or
# end of line) so "run #250" can never satisfy a derived N of 25. POSIX ERE
# has no \b, so the boundary is expressed with an explicit non-digit class
# (mirrors bin/residue-check.sh's (^|[^[:alnum:]_]) idiom).
HEADER_RUN="$(printf '%s\n' "$HEADER" | grep -o -E 'run #[0-9]+([^0-9]|$)' | head -n 1 | grep -o -E '[0-9]+' || true)"

if [ -z "$HEADER_RUN" ]; then
  echo "[brief-check] FAIL — BRIEF.md header line does not carry a 'run #<N>' token (derived run #$N): '$HEADER'" >&2
  exit 1
fi

if [ "$HEADER_RUN" != "$N" ]; then
  echo "[brief-check] FAIL — BRIEF.md header names run #$HEADER_RUN but the closing run is run #$N (derived from LANTERN.md's topmost DECLARED entry) — regenerate BRIEF.md before closing" >&2
  exit 1
fi

echo "[brief-check] PASS — BRIEF.md header matches closing run #$N"
exit 0
