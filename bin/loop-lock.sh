#!/usr/bin/env bash
# Mission loop single-instance lock: an atomic `mkdir .git/gadd-loop.lock`
# guards against two mission-loop instances running concurrently. The lock
# dir lives inside .git (never tracked) and holds a `pid` file naming the
# owning process. Liveness is checked with `kill -0`; a lock whose pid is
# dead (or whose pid file is missing/empty — a corrupt lock) is treated as
# stale and reclaimed automatically. (Operator-ratified monotonic guard,
# 2026-07-15.)
#
# USAGE: bin/loop-lock.sh acquire [pid] | release | status
#   acquire [pid]  -> take the lock for pid (default: $PPID). Exit 0 on
#                     success, 3 if another live process holds it (newcomer
#                     must no-op), 4 if a stale lock could not be reclaimed.
#   release        -> drop the lock unconditionally. Idempotent: exit 0
#                     whether or not a lock was present.
#   status         -> report "held by pid N (alive|dead)" or "free". Always
#                     exit 0.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

LOCK_DIR=".git/gadd-loop.lock"
PID_FILE="$LOCK_DIR/pid"

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

cmd="${1:-}"

case "$cmd" in
  acquire)
    pid="${2:-$PPID}"
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      echo "$pid" > "$PID_FILE"
      echo "lock acquired (pid $pid)"
      exit 0
    fi
    # Lock dir already exists — inspect the holder.
    held_pid="$(read_lock_pid)"
    if [ -n "$held_pid" ] && is_alive "$held_pid"; then
      echo "mission loop already active (pid $held_pid) — newcomer must no-op"
      exit 3
    fi
    # Stale (dead pid) or corrupt (missing/empty pid file) — reclaim once.
    if [ -z "$held_pid" ]; then
      echo "stale lock: corrupt lock dir (missing/empty pid file) — reclaiming"
    else
      echo "stale lock: pid $held_pid is dead — reclaiming"
    fi
    rm -rf "$LOCK_DIR"
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      echo "$pid" > "$PID_FILE"
      echo "lock acquired (pid $pid)"
      exit 0
    fi
    echo "failed to acquire lock after stale reclaim (pid $pid)" >&2
    exit 4
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
    if [ ! -d "$LOCK_DIR" ]; then
      echo "free"
      exit 0
    fi
    held_pid="$(read_lock_pid)"
    if [ -z "$held_pid" ]; then
      echo "held by pid <unknown — corrupt lock> (dead)"
      exit 0
    fi
    if is_alive "$held_pid"; then
      echo "held by pid $held_pid (alive)"
    else
      echo "held by pid $held_pid (dead)"
    fi
    exit 0
    ;;

  *)
    echo "usage: $(basename "$0") acquire [pid] | release | status" >&2
    exit 2
    ;;
esac
