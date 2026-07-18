#!/usr/bin/env bash
# Mission loop single-instance lock: an atomic `mkdir .git/gadd-loop.lock`
# guards against two mission-loop instances running concurrently. The lock
# dir lives inside .git (never tracked) and holds a `pid` file (the holder
# pid, advisory only) and a `lease` marker file whose FILESYSTEM MTIME is
# the sole staleness clock.
#
# LEASE MODEL (ratified 2026-07-17, run-30 A3 — supersedes the pid-liveness
# design of 2026-07-15): staleness is lease age past a TTL, refreshed at
# phase boundaries by the loop calling `refresh` — NEVER pid-death. In this
# harness every Bash-call shell pid dies at call end, so a live loop's
# recorded holder pid is routinely "dead" mid-run by the time a second
# session inspects it; treating pid-death as staleness wrongly reclaimed a
# live loop's lock (anomaly A3, demonstrated 2026-07-17). pid liveness
# (`kill -0`) is retained ONLY as an advisory display field in `status` — it
# is never consulted by any acquire/reclaim decision.
#
# Lease age is the age of the `lease` marker's mtime (refresh = `touch`, no
# timestamp text to parse, so no malformed-timestamp failure class exists).
# A lock dir with no lease marker (old-format or corrupt lock) falls back to
# the lock dir's own mtime, so pre-lease-era locks age out on the same clock
# instead of wedging forever or being instantly reclaimed.
#
# USAGE: bin/loop-lock.sh acquire [pid] | release | status | refresh
#   acquire [pid]  -> take the lock for pid (default: $PPID). Exit 0 on
#                     success, 3 if the existing lock's lease age is <= TTL
#                     (newcomer must no-op — REGARDLESS of recorded-pid
#                     liveness), 4 if a stale lease could not be reclaimed
#                     (lost a reclaim race — fail closed).
#   release        -> drop the lock unconditionally. Idempotent: exit 0
#                     whether or not a lock was present.
#   status         -> report holder pid, advisory pid-liveness (display
#                     only), lease age, effective TTL, and FRESH/STALE.
#                     Always exit 0.
#   refresh        -> touch the lease marker (phase-boundary duty of a live
#                     loop). Exit 0 if a lock is held, 5 (loud) if not — a
#                     loop that lost its lock must find out.
#
# TTL: default 3600s, overridable via env GADD_LOOP_LEASE_TTL (positive
# integer seconds). An invalid value (non-numeric, zero, negative, empty) is
# rejected LOUDLY on stderr and the default is used — invalid config may
# only make reclaim harder, never easier (fail-closed): it is never treated
# as 0.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

LOCK_DIR=".git/gadd-loop.lock"
PID_FILE="$LOCK_DIR/pid"
LEASE_FILE="$LOCK_DIR/lease"
DEFAULT_TTL=3600

# is_alive: ADVISORY ONLY (E8). Used exclusively by `status` for a display
# field. Never call this from an acquire/reclaim decision path — pid-death
# is not a staleness input anywhere in this script.
is_alive() {
  # $1: pid. Returns 0 (alive) / 1 (dead or invalid).
  local pid="$1"
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

read_lock_pid() {
  # Echoes the pid held by the lock, or empty string if corrupt (dir exists,
  # pid file missing/empty).
  if [ -s "$PID_FILE" ]; then
    cat "$PID_FILE"
  else
    echo ""
  fi
}

mtime_of() {
  # Echoes the epoch mtime of $1. Tries BSD/macOS `stat -f`, falls back to
  # GNU/Linux `stat -c` — no other timestamp source is consulted.
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null
}

lease_reference_mtime() {
  # E4: lease marker mtime if present; else the lock dir's own mtime
  # (old-format/corrupt-lock fallback — ages out on the same clock).
  if [ -f "$LEASE_FILE" ]; then
    mtime_of "$LEASE_FILE"
  else
    mtime_of "$LOCK_DIR"
  fi
}

lease_age_seconds() {
  local m now
  m="$(lease_reference_mtime)"
  now="$(date +%s)"
  echo $((now - m))
}

resolve_ttl() {
  # E5: stdout carries ONLY the resolved TTL (caller captures it); the
  # invalid-value warning goes to stderr, uncaptured. Unset (no override
  # attempted at all) falls back to DEFAULT_TTL silently — that's normal,
  # unconfigured operation. But an override that IS attempted (env var set,
  # even to "") and is non-numeric/zero/negative/empty falls back LOUDLY —
  # never to 0, never silently, since a set-but-invalid value is a
  # misconfiguration, not the absence of configuration.
  if [ -z "${GADD_LOOP_LEASE_TTL+set}" ]; then
    echo "$DEFAULT_TTL"
    return
  fi
  local raw="$GADD_LOOP_LEASE_TTL"
  if [[ "$raw" =~ ^[0-9]+$ ]] && [ "$raw" -gt 0 ]; then
    echo "$raw"
    return
  fi
  echo "[loop-lock] invalid GADD_LOOP_LEASE_TTL='$raw' — falling back to default ${DEFAULT_TTL}s (fail-closed: invalid config never makes reclaim easier)" >&2
  echo "$DEFAULT_TTL"
}

cmd="${1:-}"

case "$cmd" in
  acquire)
    pid="${2:-$PPID}"
    ttl="$(resolve_ttl)"
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      echo "$pid" > "$PID_FILE"
      touch "$LEASE_FILE"
      echo "lock acquired (pid $pid)"
      exit 0
    fi
    # Lock dir already exists — the ONLY question is lease age vs TTL.
    # Recorded-pid liveness is NEVER consulted here (E2/E8): a dead
    # recorded pid with a fresh lease is NOT stale.
    held_pid="$(read_lock_pid)"
    age="$(lease_age_seconds)"
    if [ "$age" -le "$ttl" ]; then
      echo "mission loop already active (pid ${held_pid:-<unknown>}, lease age ${age}s <= TTL ${ttl}s) — newcomer must no-op"
      exit 3
    fi
    echo "stale lease: age ${age}s > TTL ${ttl}s (held pid ${held_pid:-<unknown>}) — reclaiming"
    rm -rf "$LOCK_DIR"
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      echo "$pid" > "$PID_FILE"
      touch "$LEASE_FILE"
      echo "lock acquired (pid $pid)"
      exit 0
    fi
    echo "failed to acquire lock after stale reclaim (pid $pid)" >&2
    exit 4
    ;;

  refresh)
    if [ ! -d "$LOCK_DIR" ]; then
      echo "[loop-lock] cannot refresh — no lock held" >&2
      exit 5
    fi
    touch "$LEASE_FILE"
    echo "lease refreshed"
    exit 0
    ;;

  release)
    if [ ! -d "$LOCK_DIR" ]; then
      echo "notice: no lock held — release is a no-op"
      exit 0
    fi
    held_pid="$(read_lock_pid)"
    rm -rf "$LOCK_DIR"
    if [ -n "$held_pid" ]; then
      echo "lock released (was held by pid $held_pid)"
    else
      echo "lock released (was held by pid <unknown — corrupt lock>)"
    fi
    exit 0
    ;;

  status)
    ttl="$(resolve_ttl)"
    if [ ! -d "$LOCK_DIR" ]; then
      echo "free"
      exit 0
    fi
    held_pid="$(read_lock_pid)"
    age="$(lease_age_seconds)"
    if [ -n "$held_pid" ] && is_alive "$held_pid"; then
      liveness="alive"
    else
      liveness="dead"
    fi
    if [ "$age" -le "$ttl" ]; then
      freshness="FRESH"
    else
      freshness="STALE"
    fi
    echo "held by pid ${held_pid:-<unknown>} (advisory pid-liveness: $liveness) — lease age ${age}s / TTL ${ttl}s — $freshness"
    exit 0
    ;;

  *)
    echo "usage: $(basename "$0") acquire [pid] | release | status | refresh" >&2
    exit 2
    ;;
esac
