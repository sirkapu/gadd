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
#
# SWALLOWED-ERROR HARDENING (run-31, ratified A2, Major tier, run-28 bench
# anomaly A2): the jq type probes above (jq -r 'type' at the exit-1 branch
# and the not-object branch, jq -r '.accept_authors | type', and the
# array-of-strings membership probe) and the four trust-anchor git reads
# (OWNERSHIP.md, gadd/allowed_signers at base and head, gadd/BASELINE.json
# at base) all used `2>/dev/null || true` / bare `|| true` to swallow ANY
# failure -- including a TRANSIENT tool failure, not just the intended
# "absent / does-not-parse" case. Two consequences: (1) a jq invocation
# failure at a type probe fell back to an empty string, rendering
# blank-typed messages ("top level is a JSON , not an object"); (2) a git
# read failure on a trust anchor was indistinguishable from the anchor
# being definitively absent, so an ENROLLED deployment silently degraded
# to the LEGACY path (skipping signature verification entirely) or the
# OWNERSHIP fence silently downgraded from the base to the working tree.
#   jq (R1): every type-probe call site now captures jq's OWN exit code
#   (never `|| true`-discarded) and routes a nonzero rc to a distinct,
#   explicitly-worded fail-closed CRITICAL ("... (jq failure during ...
#   probe) -- fail-closed"), never a message built from an empty type
#   string. The array-of-strings membership probe (jq -e '[...] | all')
#   distinguishes its own three outcomes: rc=0 all-strings (unchanged
#   healthy path), rc=1 a genuine non-string member found (unchanged
#   message), any other rc = jq itself failed (new, distinctly worded).
#   git (R2/R3): a new git_read_trust_anchor() helper replaces every bare
#   `git show REF:PATH 2>/dev/null || true` with a two-step, empirically
#   measured probe (exact exit-code taxonomy in the run-31 A2 feat commit
#   body): (1) REF must resolve to a commit
#   (git rev-parse --verify -q "REF^{commit}") or the read is AMBIGUOUS;
#   (2) given a valid ref, git rev-parse --verify -q "REF:PATH" must
#   cleanly exit 1 (no stderr) -- confirmed by a passing `git ls-tree`
#   probe as of G1 below -- for the path to be DEFINITIVELY ABSENT -- any
#   other exit code (a corrupt tree, a repo-level fatal, etc.) is
#   AMBIGUOUS; (3) only once existence is confirmed does the real content
#   read (git show) run, and if THAT still fails despite existence being
#   confirmed (a corrupt/unreadable BLOB -- invisible to every cheap
#   existence probe, since none of them read blob content) the read is
#   AMBIGUOUS too, not absent. "Definitively absent" reproduces the exact
#   pre-hardening semantics (working-tree OWNERSHIP fallback, LEGACY path,
#   accept_authors "not set", etc.) unchanged; any AMBIGUOUS outcome is a
#   new CRITICAL fail-closed finding naming the unreadable path and trust
#   source, and (inside the accept-verification block) sets accept_bad=1,
#   short-circuiting the ENROLLED/LEGACY per-commit analysis entirely for
#   that push rather than attempting it on a known-unreliable read -- a
#   deliberately conservative simplification (strictly more fail-closed
#   than a narrower per-check gate, never less). Per R3 this means the
#   ratchet rule's own "emptied/deleted" message is never reached when it
#   is specifically the head-signers read that is unreadable -- the
#   read-failure message fires in its place, and the emptied/deleted
#   message keeps meaning exactly what it says.
#   G1 hardening (run-31 A2 repair round 1, SECURITY note): step (2)'s rc=1
#   alone is NOT sufficient for DEFINITIVELY ABSENT. An empirically measured
#   taxonomy (mktemp scratch repos; exit-code table in the fix commit body)
#   showed a genuinely MISSING (not corrupt) tree object -- including a
#   missing SUBtree object, the shape that matters here since every path
#   this helper is called with (gadd/allowed_signers, gadd/BASELINE.json) is
#   a subdirectory path -- ALSO yields rc=1 from
#   `git rev-parse --verify -q "REF:PATH"`, indistinguishable at that probe
#   alone from a clean absence; unpatched, this would silently route an
#   ENROLLED base's signers read to the signature-skipping LEGACY path (a
#   corrupt tree was already correctly AMBIGUOUS via a different, >=2 exit
#   code -- it is specifically the MISSING-object rc=1 case this closes).
#   rc=1 is now provisional: `git ls-tree "$ref" -- "$path"` must ALSO exit 0
#   before the read is trusted as absent. A missing tree/subtree object
#   makes ls-tree itself fail nonzero (it must read the tree to answer a
#   path query), where a genuine absence still exits 0 with empty output --
#   any ls-tree outcome other than a clean exit 0 reclassifies the read as
#   AMBIGUOUS (unreadable) instead.
# Disclosed residual: jq -e 'type == "object"' itself (the boolean check
# immediately above the type probes) still conflates "ran fine, evaluated
# false" with "jq itself failed" -- the same swallow shape, but not one of
# the three probes this hardening's ratified scope named. The code path
# re-derives the type via the now-hardened jq -r 'type' probe regardless of
# which of the two ways it got there, so a jq failure at that boolean check
# can only ever manifest as a (correctly fail-closed) type-probe failure
# downstream -- never a wrong PASS.
source "$(dirname "$0")/lib/common.sh"

# git_read_trust_anchor REF PATH -> multi-step probe (measured taxonomy in
# the run-31 A2 feat commit body and the repair-round-1 fix commit body).
# Sets GADD_TA_STATUS to present / absent / unreadable, and GADD_TA_CONTENT
# (meaningful only when present). "absent" reproduces the exact
# pre-hardening semantics; "unreadable" is a NEW, distinct outcome the
# caller must fail closed on -- never treat as absent. A missing (not
# corrupt) tree/subtree object is one of the "unreadable" cases (G1,
# confirmed via ls-tree), not just a corrupt one.
git_read_trust_anchor() {
  local ref="$1" path="$2" rc
  GADD_TA_CONTENT=""
  git rev-parse --verify -q "${ref}^{commit}" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    GADD_TA_STATUS="unreadable"   # ref itself does not resolve to a commit
    return
  fi
  git rev-parse --verify -q "${ref}:${path}" >/dev/null 2>&1
  rc=$?
  if [ "$rc" -eq 1 ]; then
    # G1 (run-31 A2 repair round 1): rc=1 alone is not sufficient -- a
    # missing (not corrupt) tree/subtree object also yields rc=1 here.
    # Confirm with ls-tree, which must itself read the tree to answer, so
    # a missing tree/subtree object makes IT fail nonzero where a genuine
    # absence still exits 0 with empty output.
    if git ls-tree "$ref" -- "$path" >/dev/null 2>&1; then
      GADD_TA_STATUS="absent"     # clean, definitive: valid ref, no such path
      return
    else
      GADD_TA_STATUS="unreadable" # rev-parse rc=1 but ls-tree could not
      return                      # confirm absence -- fail-closed
    fi
  fi
  if [ "$rc" -ne 0 ]; then
    GADD_TA_STATUS="unreadable"   # e.g. a corrupt tree object mid-walk
    return
  fi
  GADD_TA_CONTENT="$(git show "${ref}:${path}" 2>/dev/null)"
  if [ $? -ne 0 ]; then
    GADD_TA_STATUS="unreadable"   # existence confirmed, but the content read
    GADD_TA_CONTENT=""            # still failed (e.g. a corrupt blob -- no
    return                        # cheap existence probe reads blob content)
  fi
  GADD_TA_STATUS="present"
}

ownership_source="base"
git_read_trust_anchor "$GADD_BASE" "OWNERSHIP.md"
case "$GADD_TA_STATUS" in
  present) ownership_content="$GADD_TA_CONTENT" ;;
  unreadable)
    finding "lane-violation" "CRITICAL" "cannot read OWNERSHIP.md from accepted base $GADD_BASE (ambiguous git read failure, not definitively absent) -- fail-closed, refusing to fall back to the working tree" "OWNERSHIP.md"
    exit 0
    ;;
  absent) ownership_content="" ;;
esac
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
git_read_trust_anchor "$GADD_BASE" "gadd/allowed_signers"
signers_base_status="$GADD_TA_STATUS"; signers_base="$GADD_TA_CONTENT"
git_read_trust_anchor "$GADD_HEAD" "gadd/allowed_signers"
head_signers_status="$GADD_TA_STATUS"; head_signers="$GADD_TA_CONTENT"
baseline_touched="$(git log --format='%H' "$GADD_BASE".."$GADD_HEAD" -- gadd/BASELINE.json)"
signers_touched="$(git log --format='%H' "$GADD_BASE".."$GADD_HEAD" -- gadd/allowed_signers)"
accept_touched=""
if [ -n "$baseline_touched" ] || [ -n "$signers_touched" ]; then
  accept_touched=1
fi

git_read_trust_anchor "$GADD_BASE" "gadd/BASELINE.json"
baseline_status="$GADD_TA_STATUS"; base_baseline_content="$GADD_TA_CONTENT"
accept_allow=""
base_baseline_malformed=0
base_baseline_malformed_msg="does not parse"
if [ -n "$base_baseline_content" ]; then
  printf '%s' "$base_baseline_content" | jq -e . >/dev/null 2>&1
  base_jq_rc=$?
  need_type_probe=0
  if [ "$base_jq_rc" -eq 1 ]; then
    # Valid JSON whose single top-level value is the JSON literal null or
    # false (jq -e's ONLY way to exit 1 on the identity filter `.`) — never
    # a parse failure. Route to the type-named message below.
    need_type_probe=1
  elif [ "$base_jq_rc" -ne 0 ]; then
    # exit 4 (empty/whitespace-only stream — no JSON value produced at all)
    # or 5 (genuine syntax error), or any other nonzero: does not parse.
    # Guarded ahead of the object-type check below so an empty stream can
    # never reach `jq -r 'type'` (which would print nothing there too) and
    # surface a blank-typed message.
    base_baseline_malformed=1
  elif ! printf '%s' "$base_baseline_content" | jq -e 'type == "object"' >/dev/null 2>&1; then
    need_type_probe=1
  fi

  if [ "$need_type_probe" -eq 1 ]; then
    # jq's OWN exit code is captured here (never `|| true`-discarded, run-31
    # A2 R1): a genuine jq invocation failure is distinguishable from a
    # legitimately-empty type string — never rendered as a blank type.
    base_type="$(printf '%s' "$base_baseline_content" | jq -r 'type' 2>/dev/null)"
    base_type_rc=$?
    base_baseline_malformed=1
    if [ "$base_type_rc" -ne 0 ]; then
      base_baseline_malformed_msg="cannot determine top-level type of accepted baseline (jq failure during type probe) — fail-closed"
    else
      base_baseline_malformed_msg="top level is a JSON $base_type, not an object"
    fi
  elif [ "$base_jq_rc" -eq 0 ]; then
    aa_type="$(printf '%s' "$base_baseline_content" | jq -r '.accept_authors | type' 2>/dev/null)"
    aa_type_rc=$?
    if [ "$aa_type_rc" -ne 0 ]; then
      base_baseline_malformed=1
      base_baseline_malformed_msg="cannot determine type of .accept_authors in accepted baseline (jq failure during type probe) — fail-closed"
    else
      case "$aa_type" in
        null) : ;; # absent or null — legitimate not-set, behavior unchanged
        array)
          printf '%s' "$base_baseline_content" | jq -e '[.accept_authors[] | type == "string"] | all' >/dev/null 2>&1
          members_rc=$?
          if [ "$members_rc" -eq 0 ]; then
            accept_allow="$(printf '%s' "$base_baseline_content" | jq -r '.accept_authors[]? // empty' 2>/dev/null)"
            if [ $? -ne 0 ]; then
              base_baseline_malformed=1
              base_baseline_malformed_msg="cannot extract .accept_authors from accepted baseline (jq failure during extraction) — fail-closed"
              accept_allow=""
            fi
          elif [ "$members_rc" -eq 1 ]; then
            base_baseline_malformed=1
            base_baseline_malformed_msg=".accept_authors is an array containing non-string member(s)"
          else
            # jq itself failed the membership check (not a clean rc=1 "found
            # a non-string member") — distinguishable message (run-31 A2 R1).
            base_baseline_malformed=1
            base_baseline_malformed_msg="cannot verify .accept_authors array members are strings (jq failure during membership probe) — fail-closed"
          fi
          ;;
        *)
          base_baseline_malformed=1
          base_baseline_malformed_msg=".accept_authors is a $aa_type, not an array of strings"
          ;;
      esac
    fi
  fi
fi

accept_bad=0

if [ -n "$accept_touched" ]; then
  anchor_unreadable=0
  if [ "$baseline_status" = "unreadable" ]; then
    finding "lane-violation" "CRITICAL" "cannot read gadd/BASELINE.json from accepted base $GADD_BASE (ambiguous git read failure, not definitively absent) — fail-closed" "gadd/BASELINE.json"
    anchor_unreadable=1
  fi
  if [ "$signers_base_status" = "unreadable" ]; then
    finding "lane-violation" "CRITICAL" "cannot read gadd/allowed_signers from accepted base $GADD_BASE (ambiguous git read failure, not definitively absent) — fail-closed" "gadd/allowed_signers"
    anchor_unreadable=1
  fi
  if [ "$head_signers_status" = "unreadable" ]; then
    finding "lane-violation" "CRITICAL" "cannot read gadd/allowed_signers from HEAD $GADD_HEAD (ambiguous git read failure, not definitively absent) — fail-closed" "gadd/allowed_signers"
    anchor_unreadable=1
  fi

  if [ "$anchor_unreadable" -eq 1 ]; then
    # run-31 A2 R2/R3: at least one trust-anchor read is AMBIGUOUS (not
    # definitively absent) — deny the exemption outright rather than run
    # the ENROLLED/LEGACY per-commit analysis below on a known-unreliable
    # read. This also means the ratchet rule's "emptied/deleted" message is
    # never reached when it is specifically the head-signers read that is
    # unreadable (R3) — the read-failure message above fires in its place.
    accept_bad=1
  else
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
