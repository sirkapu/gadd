#!/usr/bin/env bash
# bin/bench-tree-guard.sh — tree-fingerprint guard for RED_TEAM bench dispatch
# (bench scratch-copy mutation discipline, tightened 2026-07-17 — see the
# isolation rule in RED_TEAM/gate-matrix.md; bench r1 blockers folded in:
# staged-index content + ignored-path residue coverage). The gate runner takes
# `snapshot` immediately before dispatching the bench and runs `verify
# <fingerprint>` as each adversary returns; ANY delta voids the bench round,
# fail-closed (exit 2, never 0, never silent).
#
# FINGERPRINT (gadd-bench-fp-v1) covers, deterministically (LC_ALL=C pinned so
# sort order and byte comparison never drift between invocations):
#   a. HEAD commit id (`git rev-parse --verify HEAD`) — catches a moved HEAD /
#      new commits.
#   b. full index+worktree status (`git status --porcelain=v1 -z`, untracked
#      included via default settings) — catches staged / unstaged / untracked /
#      deleted path-level changes.
#   c. worktree-vs-HEAD content of tracked modifications
#      (`git diff HEAD --binary`) — catches content deltas, not just paths.
#   d. index-vs-HEAD content (`git diff --cached --binary`) — catches a
#      poisoned INDEX behind a restored worktree: stage vX then revert the
#      worktree to HEAD content and (b)+(c) are identical for every X; only
#      the staged content itself distinguishes them (bench r1 DATA_INTEGRITY
#      blocker).
#   e. content of every untracked file, IGNORED ONES INCLUDED (`git ls-files
#      -o -z` with NO --exclude-standard, sorted null-safe, each entry hashed)
#      — catches same-name/different-bytes untracked swaps AND residue parked
#      under any ignore rule (.gitignore, .git/info/exclude, core.excludesFile
#      — an exclude pattern an adversary plants cannot hide a file from this
#      enumeration, which consults no excludes at all; bench r1 SECURITY
#      blocker). Fingerprint cost therefore scales with the ignored payload
#      present in the tree — correctness over speed, fail-closed ethos. The
#      empty set hashes deterministically.
#      Non-regular entries are NEVER opened (no FIFO/device hang, no symlink
#      follow): symlinks contribute their TARGET STRING (readlink), anything
#      else only a type marker. Git itself never enumerates FIFOs/sockets/
#      devices (`ls-files -o` skips non-regular files), so their mere presence
#      is invisible to any git-based fingerprint — disclosed, not pretended.
#
# TRUTH-ONLY LIMITATIONS (disclosed):
#   - This is a state fingerprint compared at two points in time. A transient
#     write that is exactly restored between snapshot and verify is INVISIBLE
#     to it. The gate-matrix prohibition (bench members never write any
#     tracked path, even transiently) covers that case — the guard detects
#     residue at return time; it does not replace the rule.
#   - Latent, for reuse elsewhere: content flows through git's diff/status
#     machinery, so changes that .gitattributes/EOL normalization erases from
#     a diff are fingerprinted as git sees them, not byte-for-byte; and
#     submodule inner content is covered only as far as the recorded gitlink /
#     status summary goes — a dirty submodule worktree is not deep-hashed.
#
# The instrument itself writes NOTHING in the repo: GIT_OPTIONAL_LOCKS=0 stops
# git from opportunistically refreshing the index on status/diff reads, and no
# temp files are used at all. Defense-in-depth: ALL inherited GIT_* environment
# (GIT_INDEX_FILE, GIT_DIR, GIT_WORK_TREE, GIT_CONFIG_COUNT/GIT_CONFIG_KEY_n/
# GIT_CONFIG_VALUE_n, etc.) is neutralized at startup so a poisoned caller
# environment cannot redirect what this instrument measures — the only git
# vars in effect are the ones this script sets itself.
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

# Neutralize ALL inherited git environment before anything else touches git
# (defense-in-depth, bench r1 note): a caller-poisoned GIT_INDEX_FILE /
# GIT_DIR / GIT_WORK_TREE / GIT_CONFIG_* must not redirect the measurement.
for _gv in $(compgen -e GIT_ || true); do
  unset "$_gv"
done
unset _gv

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
  local head_id status_hash worktree_hash index_hash untracked_hash
  head_id="$(g rev-parse --verify HEAD 2>/dev/null)" || return 1
  status_hash="$(g status --porcelain=v1 -z 2>/dev/null | sha256_stream)" || return 1
  worktree_hash="$(g diff HEAD --binary 2>/dev/null | sha256_stream)" || return 1
  index_hash="$(g diff --cached --binary 2>/dev/null | sha256_stream)" || return 1
  # Untracked content, ignored files included: null-delimited path list with
  # NO exclude processing, sorted under the pinned locale, each entry emitted
  # as path + type + content hash into one stream. Non-regular entries are
  # never opened: symlinks contribute their target string (readlink, never
  # followed), anything else a bare type marker — no FIFO/device can hang the
  # guard. An unreadable regular file aborts the stream (exit 9 -> pipefail)
  # rather than being silently skipped — fail-closed, never a fingerprint
  # that ignores a file.
  untracked_hash="$(
    g ls-files -o -z 2>/dev/null \
      | sort -z \
      | while IFS= read -r -d '' path; do
          printf '%s\0' "$path"
          if [ -L "$TOPLEVEL/$path" ]; then
            printf 'symlink\0'
            printf '%s' "$(readlink "$TOPLEVEL/$path")" | sha256_stream || exit 9
          elif [ -f "$TOPLEVEL/$path" ]; then
            printf 'file\0'
            sha256_stream < "$TOPLEVEL/$path" || exit 9
          else
            printf 'nonregular\0unopened\n'
          fi
        done \
      | sha256_stream
  )" || return 1
  printf 'head:%s\nstatus:%s\ndiff:%s\nindex:%s\nuntracked:%s\n' \
    "$head_id" "$status_hash" "$worktree_hash" "$index_hash" "$untracked_hash" | sha256_stream
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
  loud "tracked-content deltas vs HEAD, worktree side (git diff HEAD --name-status):"
  g diff HEAD --name-status >&2 || true
  loud "tracked-content deltas vs HEAD, index side (git diff --cached --name-status):"
  g diff --cached --name-status >&2 || true
  loud "untracked entries incl. ignored (git ls-files -o):"
  g ls-files -o >&2 || true
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
