#!/usr/bin/env bash
# bin/bench-tree-guard.sh — tree-fingerprint guard for RED_TEAM bench dispatch
# (bench scratch-copy mutation discipline, tightened 2026-07-17 — see the
# isolation rule in RED_TEAM/gate-matrix.md). The gate runner takes `snapshot`
# immediately before dispatching the bench and runs `verify <fingerprint>` as
# each adversary returns; ANY delta voids the bench round, fail-closed.
#
# FINGERPRINT (gadd-bench-fp-v1) covers, deterministically (LC_ALL=C pinned so
# sort order and byte comparison never drift between invocations):
#   a. HEAD commit id (`git rev-parse --verify HEAD`) — catches a moved HEAD /
#      new commits.
#   b. full index+worktree status (`git status --porcelain=v1 -z`, untracked
#      included via default settings) — catches staged / unstaged / untracked /
#      deleted path-level changes.
#   c. content of all tracked modifications, staged and unstaged
#      (`git diff HEAD --binary`) — catches content deltas, not just paths.
#   d. content of every untracked non-ignored file (`git ls-files -o
#      --exclude-standard -z`, sorted null-safe, each file's bytes hashed) —
#      catches a same-name/different-bytes untracked swap that status output
#      alone cannot see. The empty set hashes deterministically.
#
# TRUTH-ONLY LIMITATION (disclosed): this is a state fingerprint compared at
# two points in time. A transient write that is exactly restored between
# snapshot and verify is INVISIBLE to it. The gate-matrix prohibition (bench
# members never write any tracked path, even transiently) covers that case —
# the guard detects residue at return time; it does not replace the rule.
#
# The instrument itself writes NOTHING in the repo: GIT_OPTIONAL_LOCKS=0 stops
# git from opportunistically refreshing the index on status/diff reads, and no
# temp files are used at all.
#
# USAGE: bin/bench-tree-guard.sh snapshot
#          -> stdout: exactly one line "gadd-bench-fp-v1:<sha256>"; exit 0.
#             Exit 2 + loud stderr if the fingerprint cannot be computed
#             (not a git repo, no HEAD commit, git failure, no sha256 tool).
#        bin/bench-tree-guard.sh verify <fingerprint>
#          -> exit 0 on exact match (one brief OK line). Exit 2 + loud stderr
#             naming what changed on mismatch. Exit 2 on cannot-measure,
#             malformed/missing fingerprint, wrong version prefix, or unknown
#             subcommand — every non-identical outcome is exit 2, never 0,
#             never silent (fail-closed doctrine).
set -euo pipefail

export LC_ALL=C
export GIT_OPTIONAL_LOCKS=0

PREFIX="gadd-bench-fp-v1"
TOPLEVEL=""

loud() { echo "[bench-tree-guard] $*" >&2; }
die2() {
  loud "$*"
  exit 2
}

# All repo reads go through one wrapper: pinned toplevel so cwd never changes
# what is measured, and quotepath pinned so path quoting never varies output.
g() { git -C "$TOPLEVEL" -c core.quotepath=false "$@"; }

sha256_stream() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    return 1
  fi
}

# Prints the bare 64-hex fingerprint body on stdout; nonzero on ANY
# measurement failure (caller fails closed — never a partial fingerprint).
compute_fingerprint() {
  local head_id status_hash diff_hash untracked_hash
  head_id="$(g rev-parse --verify HEAD 2>/dev/null)" || return 1
  status_hash="$(g status --porcelain=v1 -z 2>/dev/null | sha256_stream)" || return 1
  diff_hash="$(g diff HEAD --binary 2>/dev/null | sha256_stream)" || return 1
  # Untracked content: null-delimited path list, sorted under the pinned
  # locale, each path emitted with its content hash into one stream. An
  # unreadable file aborts the stream (exit 9 -> pipefail) rather than being
  # silently skipped — fail-closed, never a fingerprint that ignores a file.
  untracked_hash="$(
    g ls-files -o --exclude-standard -z 2>/dev/null \
      | sort -z \
      | while IFS= read -r -d '' path; do
          printf '%s\0' "$path"
          sha256_stream < "$TOPLEVEL/$path" || exit 9
        done \
      | sha256_stream
  )" || return 1
  printf 'head:%s\nstatus:%s\ndiff:%s\nuntracked:%s\n' \
    "$head_id" "$status_hash" "$diff_hash" "$untracked_hash" | sha256_stream
}

cmd_snapshot() {
  local fp
  fp="$(compute_fingerprint)" || die2 "CANNOT MEASURE — fingerprint computation failed (no HEAD commit, git failure, unreadable untracked file, or no sha256 tool) — fail-closed: exit 2, never 0."
  printf '%s:%s\n' "$PREFIX" "$fp"
}

cmd_verify() {
  local expected="$1" current
  [ -n "$expected" ] || die2 "verify requires a fingerprint argument (usage: bench-tree-guard.sh verify $PREFIX:<sha256>) — fail-closed: exit 2, never 0."
  case "$expected" in
    "$PREFIX:"*) : ;;
    *) die2 "wrong fingerprint version prefix — want '$PREFIX:<sha256>', got '$expected' — fail-closed: exit 2, never 0." ;;
  esac
  printf '%s' "$expected" | grep -Eq "^$PREFIX:[0-9a-f]{64}\$" \
    || die2 "malformed fingerprint '$expected' — want '$PREFIX:' followed by exactly 64 lowercase hex chars — fail-closed: exit 2, never 0."
  current="$PREFIX:$(compute_fingerprint)" || die2 "CANNOT MEASURE — fingerprint recomputation failed at verify time — fail-closed: exit 2, never 0."
  if [ "$current" = "$expected" ]; then
    echo "[bench-tree-guard] OK — tree fingerprint unchanged."
    exit 0
  fi
  loud "TREE FINGERPRINT MISMATCH — the tree changed between snapshot and verify; this VOIDS the bench round (fail-closed, exit 2)."
  loud "expected: $expected"
  loud "current:  $current"
  loud "HEAD now: $(g rev-parse --verify HEAD 2>/dev/null || echo '<unreadable>')"
  loud "git status --porcelain of the current tree (path-level state):"
  g status --porcelain=v1 >&2 || true
  loud "tracked-content deltas vs HEAD (git diff HEAD --name-status):"
  g diff HEAD --name-status >&2 || true
  exit 2
}

MODE="${1:-}"
case "$MODE" in
  snapshot | verify)
    TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null)" \
      || die2 "CANNOT MEASURE — not inside a git repository (git rev-parse --show-toplevel failed) — fail-closed: exit 2, never 0."
    ;;
esac
case "$MODE" in
  snapshot) cmd_snapshot ;;
  verify) cmd_verify "${2:-}" ;;
  *) die2 "unknown or missing subcommand '${MODE}' — usage: bench-tree-guard.sh snapshot | verify <fingerprint> — fail-closed: exit 2, never 0." ;;
esac
