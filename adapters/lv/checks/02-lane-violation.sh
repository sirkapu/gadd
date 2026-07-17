#!/usr/bin/env bash
# Parses OWNERSHIP.md fenced block: lines under "```gadd-governed" are glob patterns.
# Exception: gadd/BASELINE.json may change ONLY via commits whose subject starts "gadd: accept"
# AND whose author email is in the ACCEPTED baseline's accept_authors allowlist (read from
# GADD_BASE, not the working tree, so an agent cannot self-enroll in the same push).
# No allowlist in the accepted baseline -> legacy subject-only check + a MINOR nudge.
#
# Fail-closed hardening E: the governed-glob fence itself is read from the
# ACCEPTED BASE (git show "$GADD_BASE:OWNERSHIP.md") — the same trust-source
# discipline as accept_authors above, so an agent cannot widen or empty its
# own lanes in the same push it is trying to smuggle a governed-file edit
# through. Working-tree OWNERSHIP.md is consulted ONLY when the base has no
# OWNERSHIP.md at all (fresh installs, nothing accepted yet to read).
#
# ACCEPT-SIGNER (run #21, ratified design: ../../../audits/accept-signer-design-v1.md;
# repair round 1, RED_TEAM-demonstrated blockers fixed):
# a second, stronger anchor on top of accept_authors — SSH commit signing
# (`gpg.format ssh`) verified by `git verify-commit` against `gadd/allowed_signers`,
# read EXCLUSIVELY from GADD_BASE (never the working tree or HEAD) so the trust
# anchor cannot be self-enrolled or widened in the same push it is meant to gate
# — the same base-pinning discipline as the OWNERSHIP fence above. Verification
# walks EVERY commit touching EITHER gadd/BASELINE.json OR gadd/allowed_signers
# (a single commit range, one combined pathspec) — narrowing to BASELINE.json
# alone let a commit that touches ONLY gadd/allowed_signers (e.g. an attacker
# appending their own pubkey, riding alongside a separate legit signed accept
# in the same push) slip through unverified while still inheriting the "clean"
# exemption from the other commit's passing check (repair round 1, blocker 1 —
# SECURITY + DATA_INTEGRITY demonstrated this end to end: full accept-gate
# compromise on a fully-enrolled deployment). Two paths:
#   ENROLLED (base's gadd/allowed_signers is non-empty): every commit touching
#     either governed accept-file must pass three factors — subject, author
#     (accept_authors, kept permanently as a second factor per operator answer
#     b), and signature (verify-commit against the base-pinned signers file) —
#     any factor failing is CRITICAL, naming which factor failed. A git < 2.34
#     runner cannot run verify-commit's plumbing — fail-closed CRITICAL rather
#     than silently skipping enforcement. The RATCHET RULE (a STATE comparison,
#     not a per-commit one, because rotation commits legitimately ride pre-accept
#     in the same push) flags only a base-present signers file going empty/absent
#     at HEAD ("only-tightens"); a head file that is merely non-empty-and-DIFFERENT
#     is key rotation (add-new-then-remove-old across two signed accepts) and is
#     not flagged. gadd/allowed_signers itself is exempted from the generic
#     governed-fence violation below only when every commit touching it (and
#     gadd/BASELINE.json) in range passed all three factors, so a legitimate
#     rotation accept does not double-flag the signers file it just rotated,
#     but a smuggled edit denies the exemption and falls through to the
#     generic CRITICAL (in addition to its own factor-named one).
#   LEGACY (base's gadd/allowed_signers is empty/absent): today's %ae-only check
#     is UNCHANGED (now also walking commits touching gadd/allowed_signers, for
#     the same smuggling-closure reason as above), plus disclosure nudges (SR-8
#     reading, disclosed to the Ratifier): accept_authors unset AND head still
#     lacks signers -> the existing "not set" nudge escalates MINOR->MAJOR;
#     accept_authors unset but head IS adding signers (a genesis-enrollment
#     push) -> nudge stays MINOR (enrollment in flight, the pre-existing legacy
#     window one last time, no new one); accept_authors set but no signer
#     anywhere -> an ADDITIVE MINOR disclosure only (never MAJOR — gating this
#     on the operator's own unenrolled deployment would be a flag day,
#     contradicting the design's own "no flag day" migration text). A base
#     lacking a signers file but whose OWNERSHIP fence ALREADY governs
#     gadd/allowed_signers (the real fresh-install shape once the template
#     ships the fence line unconditionally — repair round 1, blocker 2) is
#     handled the same way: a first-enrollment commit that ADDS the file,
#     passes the legacy subject+author check, is exempted without requiring a
#     signature (there is no base anchor yet to verify against — the
#     documented pre-existing %ae window, design migration step 2).
# A base gadd/BASELINE.json that exists but fails to parse is CRITICAL
# fail-closed (repair round 1, DATA_INTEGRITY note) rather than a silent
# skip of the author factor — `jq`'s `// empty` fallback previously made a
# malformed base indistinguishable from "accept_authors not set".
#
# WRONG-TYPE base guard (run-21 bench note, operator-ratified queue item):
# the parse-only guard above (`jq -e .`) passes VALID JSON that is the WRONG
# TYPE — a top-level array/string/number, or an object whose .accept_authors
# is present but not an array of strings — and `.accept_authors[]? // empty`
# then silently yields empty, degrading to the "not set" legacy-nudge /
# enrolled-skip semantics. Both shapes are now folded into the same
# base_baseline_malformed fail-closed branch (naming the specific type
# violation) rather than a parallel path. accept_authors absent or null, and
# an empty array, are unchanged — legitimate not-set / no-op shapes.
#
# WRONG-TYPE wording tightening (run-28 h3, ratified, wording-only): `jq -e
# .`'s exit status tracks the TRUTHINESS of the last output value, not parse
# validity, so a base file whose content is valid JSON `null` or `false`
# exited nonzero at the parse guard and got the generic "does not parse"
# message instead of the type-named one. Now branched on jq's own exit-code
# taxonomy (1 = valid-but-falsy top level -> type-named; 4/5/other = no
# output or a genuine syntax error -> "does not parse"), so a whitespace-only
# empty stream (jq -e . exit 4, jq -r 'type' would print nothing) is never
# mistaken for a parsed null/false and can never produce a blank-typed
# message. Both routes remain CRITICAL fail-closed — no severity changes.
source "$(dirname "$0")/lib/common.sh"

ownership_source="base"
ownership_content="$(git show "$GADD_BASE:OWNERSHIP.md" 2>/dev/null || true)"
if [ -z "$ownership_content" ]; then
  if [ -f OWNERSHIP.md ]; then
    ownership_source="working-tree (fresh install — accepted base has no OWNERSHIP.md)"
    ownership_content="$(cat OWNERSHIP.md)"
  else
    finding "lane-violation" "MAJOR" "OWNERSHIP.md missing in accepted base and working tree — lanes unenforceable"
    exit 0
  fi
fi

globs="$(printf '%s\n' "$ownership_content" | awk '/^```gadd-governed/{f=1;next}/^```/{f=0}f' | sed '/^\s*$/d;/^#/d')"
if [ -z "$globs" ]; then
  echo "::notice::lane-violation — governed fence empty/missing in $ownership_source OWNERSHIP.md — nothing to enforce this run" >&2
  exit 0
fi

# --- accept-signer + accept_authors verification, computed once up front (not
# per loop-iteration) so gadd/BASELINE.json and gadd/allowed_signers share one
# outcome when either or both are touched across the commit range. ---
signers_base="$(git show "$GADD_BASE:gadd/allowed_signers" 2>/dev/null || true)"
head_signers="$(git show "$GADD_HEAD:gadd/allowed_signers" 2>/dev/null || true)"
baseline_touched="$(git log --format='%H' "$GADD_BASE".."$GADD_HEAD" -- gadd/BASELINE.json)"
signers_touched="$(git log --format='%H' "$GADD_BASE".."$GADD_HEAD" -- gadd/allowed_signers)"
accept_touched=""
if [ -n "$baseline_touched" ] || [ -n "$signers_touched" ]; then
  accept_touched=1
fi

base_baseline_content="$(git show "$GADD_BASE:gadd/BASELINE.json" 2>/dev/null || true)"
accept_allow=""
base_baseline_malformed=0
base_baseline_malformed_msg="does not parse"
if [ -n "$base_baseline_content" ]; then
  printf '%s' "$base_baseline_content" | jq -e . >/dev/null 2>&1
  base_jq_rc=$?
  if [ "$base_jq_rc" -eq 1 ]; then
    # Valid JSON whose single top-level value is the JSON literal null or
    # false (jq -e's ONLY way to exit 1 on the identity filter `.`) — never
    # a parse failure. Route straight to the type-named message.
    base_type="$(printf '%s' "$base_baseline_content" | jq -r 'type' 2>/dev/null || true)"
    base_baseline_malformed=1
    base_baseline_malformed_msg="top level is a JSON $base_type, not an object"
  elif [ "$base_jq_rc" -ne 0 ]; then
    # exit 4 (empty/whitespace-only stream — no JSON value produced at all)
    # or 5 (genuine syntax error), or any other nonzero: does not parse.
    # Guarded ahead of the object-type check below so an empty stream can
    # never reach `jq -r 'type'` (which would print nothing there too) and
    # surface a blank-typed message.
    base_baseline_malformed=1
  elif ! printf '%s' "$base_baseline_content" | jq -e 'type == "object"' >/dev/null 2>&1; then
    base_type="$(printf '%s' "$base_baseline_content" | jq -r 'type' 2>/dev/null || true)"
    base_baseline_malformed=1
    base_baseline_malformed_msg="top level is a JSON $base_type, not an object"
  else
    aa_type="$(printf '%s' "$base_baseline_content" | jq -r '.accept_authors | type' 2>/dev/null || true)"
    case "$aa_type" in
      null) : ;; # absent or null — legitimate not-set, behavior unchanged
      array)
        if printf '%s' "$base_baseline_content" | jq -e '[.accept_authors[] | type == "string"] | all' >/dev/null 2>&1; then
          accept_allow="$(printf '%s' "$base_baseline_content" | jq -r '.accept_authors[]? // empty' 2>/dev/null || true)"
        else
          base_baseline_malformed=1
          base_baseline_malformed_msg=".accept_authors is an array containing non-string member(s)"
        fi
        ;;
      *)
        base_baseline_malformed=1
        base_baseline_malformed_msg=".accept_authors is a $aa_type, not an array of strings"
        ;;
    esac
  fi
fi

accept_bad=0

if [ -n "$accept_touched" ]; then
  if [ "$base_baseline_malformed" -eq 1 ]; then
    finding "lane-violation" "CRITICAL" "accepted baseline gadd/BASELINE.json $base_baseline_malformed_msg — cannot verify accept authorship (fail-closed)" "gadd/BASELINE.json"
    accept_bad=1
  fi

  if [ -n "$signers_base" ]; then
    # ENROLLED path — base-pinned signature verification is live.
    gitver_full="$(git version 2>/dev/null || true)"
    gitver="$(printf '%s' "$gitver_full" | grep -oE '[0-9]+\.[0-9]+' | head -n1)"
    gitmajor="${gitver%%.*}"
    gitminor="${gitver#*.}"
    ver_ok=0
    case "$gitmajor" in
      ''|*[!0-9]*) ver_ok=0 ;;
      *)
        case "$gitminor" in
          ''|*[!0-9]*) ver_ok=0 ;;
          *)
            if [ "$gitmajor" -gt 2 ] || { [ "$gitmajor" -eq 2 ] && [ "$gitminor" -ge 34 ]; }; then
              ver_ok=1
            fi
            ;;
        esac
        ;;
    esac

    if [ "$ver_ok" -eq 0 ]; then
      finding "lane-violation" "CRITICAL" "signature verification unavailable (git < 2.34) — fail-closed, refusing to skip signer enforcement" "gadd/BASELINE.json"
      accept_bad=1
    else
      signers_tmp="$(mktemp)"
      trap 'rm -f "$signers_tmp"' EXIT INT TERM
      printf '%s\n' "$signers_base" > "$signers_tmp"

      # Ratchet rule: only-tightens. A STATE comparison (base non-empty, head
      # empty/absent), not a per-commit one — rotation legitimately rides
      # pre-accept in the same push, so a head file that is merely non-empty
      # and different from base is NOT flagged here.
      if [ -z "$head_signers" ]; then
        finding "lane-violation" "CRITICAL" "accept-signer trust anchor emptied/deleted — only-tightens" "gadd/allowed_signers"
        accept_bad=1
      fi

      while IFS=$'\t' read -r csha csubj cae; do
        [ -z "$csha" ] && continue
        case "$csubj" in
          "gadd: accept"*) ;;
          *)
            finding "lane-violation" "CRITICAL" "accept commit $csha subject does not start 'gadd: accept' (factor: subject)" "gadd/BASELINE.json"
            accept_bad=1
            continue
            ;;
        esac
        if [ -n "$accept_allow" ]; then
          printf '%s\n' "$accept_allow" | grep -qxF "$cae" || {
            finding "lane-violation" "CRITICAL" "accept commit $csha author $cae not in accept_authors allowlist (factor: author)" "gadd/BASELINE.json"
            accept_bad=1
            continue
          }
        fi
        git -c gpg.ssh.allowedSignersFile="$signers_tmp" verify-commit "$csha" >/dev/null 2>&1 || {
          finding "lane-violation" "CRITICAL" "accept commit $csha failed signature verification against base-pinned allowed_signers (factor: signature)" "gadd/BASELINE.json"
          accept_bad=1
          continue
        }
      done < <(git log --format='%H%x09%s%x09%ae' "$GADD_BASE".."$GADD_HEAD" -- gadd/BASELINE.json gadd/allowed_signers)
    fi
  else
    # LEGACY path — no base trust anchor enrolled yet. %ae check UNCHANGED
    # (now walking both governed accept-files, for the same smuggling-closure
    # reason as the ENROLLED path); disclosure nudges added on top (never
    # affect accept_bad).
    if [ -z "$accept_allow" ]; then
      if [ -z "$head_signers" ]; then
        finding "lane-violation" "MAJOR" "accept authorship spoofable — enroll a signer (gadd/allowed_signers)" "gadd/BASELINE.json"
      else
        finding "lane-violation" "MINOR" "accept_authors not set in accepted baseline — accept-commit authorship unverifiable (enrollment in flight — enforcement live from next accepted base)" "gadd/BASELINE.json"
      fi
    elif [ -z "$head_signers" ]; then
      finding "lane-violation" "MINOR" "accept authorship spoofable (second factor only) — enroll a signer (gadd/allowed_signers)" "gadd/BASELINE.json"
    fi

    while IFS=$'\t' read -r csubj cae; do
      case "$csubj" in "gadd: accept"*) ;; *) accept_bad=1; break ;; esac
      if [ -n "$accept_allow" ]; then
        printf '%s\n' "$accept_allow" | grep -qxF "$cae" || { accept_bad=1; break; }
      fi
    done < <(git log --format='%s%x09%ae' "$GADD_BASE".."$GADD_HEAD" -- gadd/BASELINE.json gadd/allowed_signers)
  fi
fi

viol=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if [ "$f" = "gadd/BASELINE.json" ]; then
    [ -n "$baseline_touched" ] && [ "$accept_bad" -eq 0 ] && continue
  elif [ "$f" = "gadd/allowed_signers" ]; then
    if [ -n "$signers_base" ]; then
      # ENROLLED: exemption requires every touching commit to have passed
      # the full three-factor check above.
      [ -n "$signers_touched" ] && [ "$accept_bad" -eq 0 ] && continue
    else
      # LEGACY first-enrollment: base has no anchor yet, so no signature can
      # be required — but the file must actually be a genesis ADD (head has
      # it, base didn't) riding a passing subject+author accept.
      [ -n "$head_signers" ] && [ -n "$signers_touched" ] && [ "$accept_bad" -eq 0 ] && continue
    fi
  fi
  while IFS= read -r g; do
    case "$f" in $g) viol="$viol,$f"; break;; esac
  done <<< "$globs"
done < <(changed_files; deleted_files)
viol="${viol#,}"
[ -z "$viol" ] && exit 0
finding "lane-violation" "CRITICAL" "Governed-side files were modified (see OWNERSHIP.md lanes)" "$viol"
exit 0
