# 🏮 Lantern — gadd state ledger

Live state snapshot for work on gadd itself. Read at session start; update before ending
a session or handing off context. This file is only ever NOW — history lives in the log
below (append-only) and in git.

## Current state

| Field | Value |
|---|---|
| Version | v0.2 + v0.3 phase 1 CLOSED (2026-07-14, incl. the human push step) — next: /mission-loop on phases 1b + 2 |
| Coverage proxy | **2** — MEASURED 2026-07-16: (1) first deployment live on upstream gadd (origin tip `6b25ef5`); (2) gadd itself governed — dogfood merge `8a3f679` pushed and `gadd-ratchet` ran on origin, completed success (run 29474552876; `gadd-redteam` chained, success/keyless-degrade). Same criterion as deployment 1: the ratchet workflow runs on its pushes |
| Active mission branch | RUN-23 adds two more MERGE-READY branches (operator's buttons; suggested execution order: run-22 chain first as ancestry-pinned, then run-23-ci, then run-23-ownership + its accept LAST, one push): (3) `mission/run-23-ci` tip `7729b2d` — CI red-guard repair (fetch-depth 0 on gadd-tests both copies `fa61f624…`, fail-loud signer red-run extraction, timeout-minutes 10 on gadd-tests+advisory both copies `f6142fdf…`; SECURITY+TEST_HONESTY PASS r1; Ratifier APPROVE-CONDITIONAL, 5 receipts, 5 STOPs). (4) `mission/run-23-ownership` tip `9673960` — OWNERSHIP corpus note, O-class (payload `8e81b4a9` byte-verified vs pinned lantern text, fence `fc932f70` unchanged; Ratifier APPROVE-CONDITIONAL, 6 receipts, 5 STOPs); its accept commit is PREPARED-NOT-EXECUTED (session permission classifier denied the loop's BASELINE commit — accepted_sha → `9673960add311143f80e9b551eee75105b5c443f`, subject "gadd: accept 9673960"). PRIOR: RUN-22 UBC WAVE MERGE-READY at the operator's buttons, chain order ancestry-pinned: (1) `mission/run-22-ubc` tip `903ac05` — ITEM 2 proportional-UBC rewrite (MAJOR, bench 5/5 round 1 zero blockers, Ratifier APPROVE-CONDITIONAL, 6 receipts + 5 STOPs, payload SHA `03dcee0e…` byte-verified); merges FIRST. (2) `mission/run-22-ubc-installer` tip `3f688ca` (base = ITEM 2 tip) — ITEM 1 installer ships ubc.md (Standard, SECURITY FAIL r1 → SR-1 symlink-fence repair → PASS r2; REGRESSION PASS r1; Ratifier APPROVE-CONDITIONAL, 6 merge-chain receipts + 5 STOPs incl. never-merge-out-of-order and shipped-SHA `e7dcc663…` == post-ITEM-2); merges SECOND. Gate PASS one designed MINOR at both tips, base `8947b1f`. Origin Actions status UNMEASURED all run (GitHub API 503 throughout — declaration ×2, mid-run poll ×20, close ×1). PRIOR: run-21 chain LIVE on origin — origin/main == local main at `8c8a248` verified at run-22 declaration (`git ls-remote`): the operator pressed the push button between sessions; both merges (signer `19d3243`, citests `923906d`) + run-21 lantern closes published. `mission/run-21-signer`/`-citests` branches deleted (`-d`, merged-only) per the standing retain-until-push-confirmed rule. Prior detail of that chain: BOTH run-21 merges LANDED on local main (operator-approved "approve merge run-21-signer and run-21-citests"). (1) signer merge `19d3243` --no-ff (parent branch tip `6cd5411`): ALL 5 RATIFIER STOPS VERIFIED — STOP-1 no-squash (6cd5411 ancestor of HEAD ✓), STOP-2 post-merge gate PASS base `8947b1f` exactly one MINOR / 0 CRIT / 0 MAJOR ✓, STOP-3 both `02-lane-violation.sh` copies == `a8a94e7…bdc01` ✓, STOP-4 no forbidden surface in `44f09ed..6cd5411` ✓, STOP-5 operator pressed ✓. (2) citests merge `923906d` --no-ff (branch tip `eaa5396`): `gadd-tests.yml` both copies == `227c0d4…`, full corpus simulation of the CI job GREEN (failclosed 32 · fleet 81 · heartbeat 52 · inapplicability 8 · parity 40 · signer 48), gate still PASS on final HEAD, residue clean. Final local main tip `923906d`; branches `mission/run-21-signer`/`-citests` retained until push confirmed. Prior: run-19 chain MERGED `d2106f5` LIVE on origin; origin main AT `02f9165` (run-20 close + CODEOWNERS + post-run-20 ratifications pushed; verified `origin/main..main` empty at run-21 start, then local main advanced with run-21 lantern commits — unpushed). Stale detail of the merged run-19 packet: `mission/run-19-prflow` was MERGE-READY at `cd37bc0` (PR-flow items 1+4+5 + accept commit, one packet; Ratifier APPROVE-CONDITIONAL — THIRD item-6 L-class ruling, 6 receipts, 4 STOPs incl. no-squash fence; merge = operator's button). Local main also carries the unpushed run-18/19 lantern closes. Prior chains all LIVE on origin: run-17 merged `2fbb39d` (n1+n2 heartbeat), run-16 merged `2aeae9f`, receipts green throughout. Prior: run-14-p1 MERGED+PUSHED 2026-07-17 (`65a9f91` on origin; operator-approved full chain; all 6 Ratifier receipts produced; pre-push hook gated PASS; the heartbeat is now LIVE in loop step 6). Prior: run-13-failclosed MERGED+PUSHED 2026-07-16 (`bb2b699`, operator-approved full chain; 5 reds closed on main). Prior: run-12-speed MERGED+PUSHED 2026-07-16 (`b74c389`, operator-approved; one-hunk union resolution in LANTERN.md disclosed, both sides byte-receipt). Prior: run-10-dogfood MERGED+PUSHED 2026-07-16 (`8a3f679`, operator-approved with re-verify condition honored; all 7 Ratifier receipts produced; pre-push hook fired live and gated the push PASS; origin ratchet ran, success). Prior: run-7 merged to main, pushed (wave "self-governing gadd": R5 wired · seed self-application bench-clean · Ratifier installed). Prior: PUBLIC HISTORY REWRITTEN from the root 2026-07-15 (double residue scrub + identity normalization) — every pre-rewrite SHA in log entries below is a stale pointer, disclosed not rewritten |
| Constitution | Ratifier-in-loop FULLY installed 2026-07-15 (operator: "go A, go B"): packets route to `gadd-ratifier` (isolated context, SR-1..**9**); only the charter's 7-item tier-3 list parks for the operator; item 7 at invariant wording. NAMING (operator-ratified 2026-07-17, item 7): "mesa-in-loop" branding RETIRED — the in-loop context is "the Ratifier" full stop; "Mesa" = operator-side counsel space ONLY; SR-9 added (in-loop products attributed to the Ratifier; mesa/operator attributions require verbatim-quotable text). ITEM-6 VERBATIM WRITE DONE (run #16, `53801cd`): V/L/O receipt-gated classes live in the charter, byte-exact from the run-15 brief (SHA-1 receipt `8005f17b`), quoting the run-16 dispatch; local-private canonical synced; FIRST L-CLASS EXERCISE same run (heartbeat fix — Ratifier classified, approved in-loop, merge still parked). Nightly schedule LIVE: launchd `com.gadd.mission-loop`, 02:17, night-mode park-and-continue; installer `bin/schedule-loop.sh` (placeholder-only template tracked). Morning brief = the operator's surface (English, ≤1 page, decisions-first) |
| North Star | **FIRST MEASURED VALUE 2026-07-15: escaped_rate = 0 over 9 accepted pushes** — fleet of 2 clean repos, 17 verdicts admitted with ZERO anomalies across all 7 reason classes, 30 findings caught pre-acceptance (14 CRITICAL). Ledger caveat CLOSED 2026-07-15: `gadd/ESCAPED.jsonl` live on both governed repos' origins — the next measurement's zero is a measured zero |
| Packet rule | PERMANENT (2026-07-15): YOUR MOVE never contains terminal commands — packets end in "reply approve and I execute"; operator may reply in plain language (any language, incl. Spanish); the loop translates to protocol |
| Objective function | RATIFIED 2026-07-14: maximize escaped-regression catches across governed repos (proxy until instrumented: upstream-governed-repo coverage × verdicts retained), subject to guards G1–G5 (`audits/objective-audit-v1.md` §3). Internal-first; OSS milestones gate on ≥1 upstream-governed repo |
| Adapters | lv (boundary) shipped · cc (in-loop) in progress — installer + blocking CI/hooks are v0.3 |
| RED_TEAM | Bench split into `RED_TEAM/` — one definition file per adversary (role, attack surface, pass criteria, output contract) + `gate-matrix.md`. Gate runners dispatch each adversary as its OWN isolated invocation, in parallel (cc: five `gadd-rt-*` subagents; lv: five independent API calls). Adversaries never see each other's verdicts. Models: structural (CONTRACT_FIDELITY, TEST_HONESTY) → cheap tier (haiku); judgment (SECURITY, DATA_INTEGRITY, REGRESSION) → strong tier (opus) |
| Protocol invariants | VERDICT + max 3 blockers per adversary · re-run only failed adversaries on the new diff · 2-round cap (spec inv. 6) · Architect arbitrates at the cap |
| Graders | `RED_TEAM/**` is grader territory — executors and the Fixer never edit it |
| Roadmap next | PR-FLOW READINESS AUDIT DONE run #18 (`audits/pr-flow-audit-v1.md`, local-private; GATES EXTERNAL-REPO ADOPTION — operator-ratified item): Q1 merge-commit WORKS · Q2 squash BREAKS-LOUD (fail-closed wedge, never fail-open) · Q3 baseline target narrow-break (squash widens the queued base_sha red; post-approval TOCTOU window) · Q4 CODEOWNERS MISSING. FIVE QUEUE ITEMS AWAITING OPERATOR RULING (jurisdiction flagged): (a) base_sha canonicalization + ancestry + squash-incompat error — tier-3/item-6; (b) CODEOWNERS for tier-3 surfaces — operator governance act, proposed text in the audit; (c) verifiable accept-signer replacing %ae — tier-3/item-6; (d) adoption note (merge-commit-only, integration ≠ acceptance) — Standard; (e) PR-time advisory ratchet run — Standard. RUN-16 RESULTS NOW STANDING: SPEED AUDIT v2 DONE (`audits/speed-audit-v2.md`, local-private; parser-parity receipt vs v1 bit-for-bit) — P1 REALIZED (deep-context tail eliminated: 0% turns >400k vs 26.4%; max ctx 394,006 under the ceiling; Director weighted/run −44%), P4 realized, P3 partially visible; total/run −7% because subagent work/run rose 68% (more Major throughput, not overhead); P7 stays REGISTERED-NOT-BUILT — no unexplained residual; v3 trigger = ≥3 fully-post-P1 runs (parser scripts preserved in `audits/*.py`). FIRST-MESSAGE TAX measured: ~47k tokens (not ~30k — in-app estimate understates), structure ≈20.2k cached prefix + ~27k per-session write; ~12–15k of the write is non-gadd plugin/skill/MCP surface; trim = operator-side project plugin/MCP config hygiene, second-order lever (~1–2% of spend). RUN-16 BENCH NOTES n1+n2 FIX BUILT run #17 (`2aeae9f..ddbc4df`, MERGE-READY — closed only when merged; fixtures 11+12, suite 52/52, DI PASS r3 after two SR-1 repair rounds AT CAP, Ratifier L-class APPROVE-CONDITIONAL). NEW OPEN (run-17 DI r3 hardening notes, Ratifier STOP-5 stay-open rule): h1+h2 as ONE queued refactor — status-mode measured emission should guard its OWN jq exit status and fail closed, retiring the probe proxy (probe flag-surface can never mirror every real-call flag; no real jq exhibits the residual today). CLOCK DRIFT disclosed: system clock measured 2026-07-16 during run #16 while run-15 artifacts carry 2026-07-17 — dates in prior entries are as-written, not rewritten. DECISION-3 STANDING CONDITION (operator 2026-07-17): stale deployment-name intermediates (`a451a43` + run-15 local intermediates carrying the descriptive pattern in-tree) are LEFT until the pre-launch scrub gate, which runs a FULL-HISTORY residue audit and re-decides; if ANY history rewrite happens before launch for any reason, those commits ride along in the same pass; anonymity is enforced binary the moment the repo faces external readers. HARDENING A–G reds CLOSED on main (run-13 merged): GADD_BASE silent-pass (MAJOR), crash-demote, malformed-line wipe, shared-/tmp substrate (F-12), OWNERSHIP self-governance + working-tree fence spoof. ORIGIN BENCH RULING (operator, 2026-07-16): keyless degrade is a DELIBERATE ACCEPTANCE — deterministic half runs, adversary half discloses itself as not-run; activation condition = first external contributor OR the second deployment's pilot launch, whichever first; subscription-vs-API decision deferred to that moment, stays tier-3 (secrets+money). ORIGIN BENCH RULING (operator, 2026-07-16): keyless degrade is a DELIBERATE ACCEPTANCE — deterministic half runs, adversary half discloses itself as not-run; activation condition = first external contributor OR the second deployment's pilot launch, whichever first; subscription-vs-API decision deferred to that moment, stays tier-3 (secrets+money). QUEUED from run-13 bench notes: base_sha canonicalization + ancestry check · hang timeout (gate) · trap EXIT INT TERM hygiene · stale docs/metric-parity.md /tmp reference · lib/common.sh standalone /tmp default · ::error:: base sanitize-if-untrusted. STILL QUEUED (APEX residuals): crafted-filename evasion (F-03) · RLS parser gaps (F-04) · %ae provenance + verdict-planting residuals · TOCTOU same-push pinning · redteam token parse + head_sha pin · hook stdin refspecs · gitignore widen `gadd/verdicts/*` · DX queue (installer clobber/reseed, jq preflight, CI runs tests/*.sh, version stamps). QUEUED: sandbox→`tests/`, test-hardening notes (aggregation_failed class, MINOR tally, tsx ceiling, positive tool-metric tests), R3 watchdog automation in dispatch plumbing · SPEED RULINGS RATIFIED 2026-07-16 (log entry below; audit local-private): P1 context-ceiling enforcement (Standard, monotonic) + P3 composite receipts script (Standard, monotonic) + P4 LANTERN rotation (Trivial/Standard, archive-never-delete) APPROVED and queued; P2 `gadd-bench` runner TIER-3 CONDITIONAL — only after the dogfood merge, 3 receipts (equivalence both-ways · known-bad mutation through the script path · Ratifier verdict) before it goes live, manual dispatch until then; P7 Architect/Coordinator Director split REGISTERED-NOT-BUILT, evaluated only by SPEED AUDIT v2 numbers after P1/P3/P4 land (grader tiers stay a floor per R2, Ratifier untouched); SPEED AUDIT v2 re-measure mandatory after P1/P3/P4 · STARTUP-MODE DESIGN ROW (roadmap, Major — trigger changes are tier-3): tier profile targets Director ceremony (packet/receipt verbosity, turn count — 68% of weighted spend), never the bench (14%) or gates (2.4% wall) · run-10 deferrals (all OPEN reds, Ratifier receipt 5): hook HEAD-vs-pushed-ref coupling (MINOR), redteam `.txt` verdicts uncovered by `*.json` ignore (MINOR), GADD_BASE silent-pass in shipped checks (MAJOR — a garbage base ref makes every check swallow git errors and PASS vacuously; executor-demonstrated), OWNERSHIP.md not self-governed (MINOR), stale OWNERSHIP prose line re lane list (Trivial doc fix) · retro items: approval-matrix↔charter tier-3 seam · SR-8 flag: "disclosure-addition vs monotonic-tightening" boundary needs invariant wording · OWNERSHIP-WORDING O-CLASS EDIT OPERATOR-RATIFIED run #21 (BUILDABLE run #22 — exact text = BRIEF.md §3 "On `tests/` and `RED_TEAM/`" note + amendment marking tests/** "(see note below)"; governed-file accept dance + Ratifier O-class receipt; resolves the charter-item-6-vs-OWNERSHIP.md "own" overload without enforcement change) · RUN-21 NEW QUEUE: valid-JSON-wrong-TYPE base BASELINE.json slips the parse guard → author factor silently dropped to MAJOR nudge (L-class tightening candidate; base trust-pinned, enrolled path still signature-gates) · `timeout-minutes` on PR-triggered CI jobs (gadd-tests AND live gadd-advisory — uniform hardening, generic public-repo abuse class) · additive-MINOR stacking awareness (external adopters at 2 pre-existing MINORs newly FAIL a legacy accept until signer enrollment — design-accepted) · h1/h2 heartbeat-emission-exit hardening still open · WAVE "UBC PORTABILITY" OPERATOR-RATIFIED 2026-07-16 (log entry below carries the pinned payload, SHA-1 `03dcee0e7d711e66d9923e8284cebcd7e53d3d5a`): RUN-22 FIRST PICKS — ITEM 2 proportional-UBC rewrite of context/ubc.md (Major, byte-exact text pinned in the log entry, title stays) THEN ITEM 1 cc-installer ships context/ubc.md (Standard, skip-if-exists, never touches pre-existing CLAUDE.md/context files, suggestion-only import line, R6 shipped-SHA==post-ITEM-2-SHA); rejection-ledger row (Karpathy origin, adapted; unconditional ultrathink retired — primary-semantic / keyword-plausible-unmeasured) rides the ITEM 2 packet; lv scope gap accepted as chosen · later: `gadd-accept` bot, Cursor/Replit adapters |

## Log (append-only, newest first)

Rotation (P4, run #12, 2026-07-16): entries older than run #10 moved verbatim to [LANTERN-ARCHIVE.md](LANTERN-ARCHIVE.md) — append-only, oldest at bottom, never edited or deleted; NOW + recent runs stay here.

- **mission-loop run #23 CLOSE (same session; 2 items completed, both MERGE-READY;
  heartbeat at close 37.0% of ceiling — the P1 wall, measured):** ITEM 1 CI
  RED-GUARD REPAIR (Standard) — `mission/run-23-ci` tip `7729b2d` (`fe15d62` +
  `7729b2d`): the origin-red gadd-tests (measured this run, closing run-22's
  unmeasured item: ratchet+redteam SUCCESS, gadd-tests FAILURE on `8c8a248`)
  repaired at root cause — `fetch-depth: 0` on both gadd-tests copies (the lone
  omission among siblings; byte pin `fa61f624…` both), signer-suite old-check
  extraction now FAILS LOUD on missing/empty history (corpus TIGHTENING, 59
  assert calls unchanged, vacuous-pass window closed), + run-21 queue item
  BUILT: `timeout-minutes: 10` on gadd-tests+gadd-advisory (both copies
  `f6142fdf…`). Both-direction receipt: shallow clone of the branch dies loud at
  extraction; full corpus green at tip (32·81·52·8·40·48). Bench: SECURITY PASS
  r1 + TEST_HONESTY PASS r1, zero blockers (triggered pair, isolated). RATIFIER:
  APPROVE-CONDITIONAL — FIFTH item-6 L-class ruling, receipts reproduced by its
  own hands, 5 STOPs; merge = operator button. ITEM 2 OWNERSHIP CORPUS NOTE
  (Standard, O-class) — `mission/run-23-ownership` tip `9673960`: the
  operator-ratified run-21 text + amendment written VERBATIM from the pinned
  lantern payload (byte receipt SHA-1 `8e81b4a9` both extractions; governed
  fence `fc932f70` byte-identical main↔tip; diff surface == OWNERSHIP.md only).
  Both-direction gate receipt: un-accepted edit → FAIL w/ CRITICAL on
  OWNERSHIP.md (fence bites); accept simulated in a discarded scratch clone →
  PASS with exactly the one designed MINOR. RATIFIER: APPROVE-CONDITIONAL,
  O-class CONFIRMED by its own hands, 6 receipts, 5 STOPs. **ACCEPT PARKED —
  new park class, disclosed:** the session's harness permission classifier
  DENIED the loop's `git commit` of the BASELINE accept edit (twice; honored as
  a hard fence, not worked around — the scratch sim was a discarded test). The
  accept is a prepared one-liner (accepted_sha → `9673960add…`, subject
  "gadd: accept 9673960"); operator executes it or grants the permission rule.
  Anomalies: (1) Director-caused, SELF-CAUGHT by the diff-surface receipt — the
  ownership branch was first cut while HEAD sat on `mission/run-23-ci` (executor
  left it there; run-21 anomaly class repeating — queue a standing rule:
  Director verifies HEAD==main before every branch cut); first commit `8641c60`
  left dangling-unreferenced, branch re-cut from main `9a867fd`, ALL receipts
  re-produced at `9673960`. (2) The three classifier denials (1 compound + 2
  accept), disclosed above. Subagent dispatches 5/5 clean (executor, 2
  adversaries, 2 Ratifier packets). Residue: clean (12 patterns, 0 hits, canary
  passed) before the close commit. Stopped: condition 3 (heartbeat 37% at the
  wall) + condition 1 (all four built items sit at operator buttons: run-22
  chain ×2, run-23 ×2 + accept + push). Task budget 2/5 used. Rolls to run #24:
  h1/h2 emission-exit hardening · DI wrong-TYPE base guard · run-22 UX notes
  (explicit REFUSED on regular-file `context`; hardlink comment) · the
  HEAD==main branch-cut standing-rule proposal.

- **mission-loop run #23 DECLARED (2026-07-16 system clock; FRESH SESSION per run-22
  close; lock acquired pid-fresh 26499; heartbeat at declaration: 9.1% of ceiling,
  measured):** bootstrap observations — (a) origin/main still `8c8a248` (verified
  `git ls-remote`); local main 2 lantern commits ahead (unpushed); the run-22 UBC
  merge chain (`903ac05` → `3f688ca`) still parked at the operator's buttons,
  untouched between sessions. (b) ORIGIN CI NOW MEASURED (closes run-22's
  unmeasured item): on `8c8a248` gadd-ratchet SUCCESS · gadd-redteam SUCCESS ·
  **gadd-tests FAILURE — a red guard on origin main, diagnosed with receipts**:
  the workflow checkout is shallow (CI log: `fetch-depth: 1`) while
  `tests/signer-fixtures.sh`'s both-direction red-run extracts the pre-upgrade
  check-02 from history (`OLD_CHECK02_REF=44f09ed`) → CI log `fatal: invalid
  object name '44f09ed'` → empty old-check script → red-run S2–S5 "old check
  finds nothing" assertions passed VACUOUSLY; assertion 47 (the only one
  requiring a finding to EXIST) caught it and failed the suite — fail-visible,
  the corpus working, but the vacuous-pass window is a test-honesty gap to close
  in the same repair. Local runs were never affected (full clone; 48/48 in
  run-21/22 benches). Every sibling workflow (ratchet, redteam, advisory, both
  copies each) already pins `fetch-depth: 0`; gadd-tests is the lone omission.
  Plan by leverage: (1) RED-GUARD REPAIR of the shipped run-21 citests item
  (Standard) — `fetch-depth: 0` on gadd-tests (both copies byte-identical),
  fail-loud old-check extraction in the signer suite (corpus TIGHTENING, never
  narrowing), + the run-21 ratified queue item `timeout-minutes` on PR-triggered
  jobs (gadd-tests + gadd-advisory, uniform) as a separate commit on the same
  branch; SECURITY-triggered bench + deterministic receipts. (2) ITEM 3
  OWNERSHIP wording O-class edit (operator-ratified run #21 w/ amendment,
  payload pinned verbatim in the run-22 close entry below) — accept dance +
  Ratifier O-class receipt. (3) h1/h2 · DI wrong-TYPE base guard · run-22 UX
  notes, as budget allows.

- **mission-loop run #22 CLOSE (same session; 2 items completed, both MERGE-READY at
  the operator's tier-3 buttons; heartbeat at close ≈40% of ceiling — the P1 wall,
  measured):** ITEM 2 PROPORTIONAL-UBC (Major, full bench) — `mission/run-22-ubc`
  `903ac05`: line 3 replaced by the 4 ratified lines, SHA `03dcee0e…` reproduced
  independently by the Director, DATA_INTEGRITY, and the Ratifier; every other
  byte incl. title unchanged; rejection-ledger row (Karpathy origin, adapted;
  primary-semantic / keyword-plausible-UNMEASURED) rode the packet. Bench 5/5
  ROUND 1 zero blockers (CF · TH · SECURITY · DI · REGRESSION, isolated;
  REGRESSION ran all six suites green: failclosed 32 · fleet 81 · heartbeat 52 ·
  inapplicability 8 · parity 40 · signer 48). RATIFIER: APPROVE-CONDITIONAL,
  item-6 classified OUT-OF-SCOPE by its own hands (agent-owned lanes, not a
  grader), 6 receipts, 5 STOPs (no-squash; one-designed-MINOR gate; SHA pin at
  merge HEAD; two-file surface; ITEM 1 never rides this verdict). ITEM 1
  INSTALLER-SHIPS-UBC (Standard) — `mission/run-22-ubc-installer` `e9114b8` +
  SR-1 repair `3f688ca`: skip-if-exists, never overwrites CLAUDE.md/context
  files, ONE suggestion-only line (a two-line first draft was Director-caught as
  deviating from the ratified "ONE line" and repaired pre-bench, disclosed);
  receipts R1–R7 reconstructed from the in-repo lantern summary (R5 residue-grep
  and R6 shipped-SHA at their lantern-named positions; Ratifier judged the
  reconstruction faithful per SR-6). Bench: SECURITY FAIL r1 with a REAL
  demonstrated CWE-59 blocker (symlinked `context`/dangling `context/ubc.md` →
  cp writes through the link OUTSIDE the target repo) → SR-1 fail-closed
  refusal fence → SECURITY PASS r2 (7 probe classes dead, canary intact);
  REGRESSION PASS r1 (26 pre-existing artifacts byte-identical, +1 file only,
  idempotent). RATIFIER: APPROVE-CONDITIONAL, tier-3 item-5 examined NOT
  engaged, 6 merge-chain receipts, 5 STOPs. ITEM 3 OWNERSHIP WORDING **DEFERRED
  to run #23** (ceiling, not blockage) — PAYLOAD PINNED HERE verbatim per the
  payload rule (BRIEF.md gets rewritten; this entry is now the in-repo source).
  Ratified text = append to OWNERSHIP.md's Agent-owned section, plus the
  operator's amendment marking the `tests/**` mention "(see note below)":

  > **On `tests/` and `RED_TEAM/`:** "agent-owned" above means *not gated by the
  > deterministic lane check (#2)* — agents add and refine fixtures during normal
  > ratified development. It does NOT mean ungoverned. The `tests/` and `RED_TEAM/`
  > fixture corpus is the operator-owned *ratified corpus* (charter item-6): the
  > Ratifier's L-class whole-corpus-preservation receipt forbids narrowing it,
  > CODEOWNERS requires operator review of external-PR changes to it, and CI
  > (`gadd-tests`) re-runs it. A proposer may extend or tighten the corpus; only the
  > operator may narrow or weaken it.

  Anomalies (all disclosed, none repo-impacting): harness flagged the ITEM 1
  executor's `--amend` (its own unpushed commit, Director-instructed — benign);
  SECURITY r1 adversary's scratch cleanup used a shared-/tmp glob (harness-
  flagged hygiene, tree access stayed read-only); an orphan background CI poller
  in the session task dir burned 20 attempts against the GitHub 503 wall
  (read-only, benign). 13/13 substantive subagent dispatches clean on the work
  itself (the SECURITY r1 FAIL is the bench working). SR-1 executions: 1 (ITEM 1
  symlink fence) + 1 Director-caught pre-bench deviation repair. Residue: clean
  (12 patterns, 0 hits, canary passed) before the close commit. NEW QUEUE from
  run-22 bench notes: (a) regular-file `context` in a target repo aborts the cc
  install mid-run via set -e with no message (safe/fail-closed but partial-
  install UX — add explicit REFUSED); (b) comment the hardlink case in the skip
  logic so a refactor doesn't reopen it (its safety is incidental to the -f
  branch). Stopped: condition 1 (TIER-3 — both merges at the operator's button)
  + condition 4 (heartbeat ≈40%, the P1 wall). Task budget 2/5 used. h1/h2 +
  run-21 queue items (DI wrong-TYPE base, timeout-minutes) roll to run #23.

- **mission-loop run #22 DECLARED (2026-07-16 system clock; FRESH SESSION per run-21
  close; lock acquired pid-fresh 9718; heartbeat at declaration: 18.9% of ceiling,
  measured):** bootstrap observations — (a) origin/main == local main at `8c8a248`
  VERIFIED live (`git ls-remote`): the operator pressed the PUSH button between
  sessions; the run-21 chain (signer merge `19d3243` + citests merge `923906d` +
  lantern closes) is LIVE on origin. That tier-3 button is CLOSED. (b) Origin
  Actions status UNMEASURED at declaration (GitHub API 503 twice) — re-check
  queued within this run; reported unmeasured until then. (c) Untracked local
  `reports/` dir observed (operator-side visual-report artifacts, e.g.
  `ubc-portabilidad-decision.html`) — not repo content, left untracked, no action.
  (d) Pinned UBC payload SHA-1 re-verified at declaration: `03dcee0e…` reproduced
  byte-exact from the log entry below. Plan by leverage (all picks
  operator-ratified, nothing new): (1) ITEM 2 proportional-UBC rewrite of
  [context/ubc.md](context/ubc.md) — MAJOR (always-applied standards layer; full
  bench + Ratifier packet; exact bytes already operator-ratified, merge still the
  operator's button); wave order pinned ITEM 2 → ITEM 1, not reordered.
  (2) ITEM 1 cc-installer ships ubc.md (Standard, R1–R7 incl. R6 shipped-SHA ==
  post-ITEM-2 SHA). (3) OWNERSHIP wording O-class edit (co-ratified run-22 pick,
  leverage-ordered AFTER the UBC wave: the wave feeds the external-shipping
  surface of the coverage-proxy growth path; the OWNERSHIP edit is
  disclosure-only, unblocks nothing). Then h1/h2 + run-21 queue items (DI
  wrong-TYPE base guard · timeout-minutes on PR CI jobs) as budget allows.

- **2026-07-16 (system clock) · RUN #21 MERGES EXECUTED + OWNERSHIP WORDING RATIFIED
  (operator, mid-turn: "approve merge run-21-signer and run-21-citests", then
  "Approve the OWNERSHIP wording as drafted, with one amendment: the Agent-owned
  table row for tests/** gains the marker '(see note below)' so a table-only reader
  is routed to the clarification. Nothing else changes."):** BOTH MERGES LANDED on
  local main (unpushed) — signer `19d3243` (5 STOPs verified: no-squash, gate PASS
  one-MINOR, byte-identity `a8a94e7…bdc01`, no forbidden surface, operator button)
  + citests `923906d` (gadd-tests.yml `227c0d4…` both copies, full corpus green
  incl. signer 48/48, gate PASS, residue clean). Final local tip `923906d`. PUSH
  is the next operator button (not assumed — narrow approval was "approve merge",
  and push publishes + fires the pre-push hook and origin ratchet; main = human
  territory). ITEM-3 OWNERSHIP WORDING now OPERATOR-RATIFIED with amendment —
  BUILDABLE run #22 (governed-file edit → needs the `gadd: accept` dance; prose/
  disclosure-only, no fence-glob or enforcement change → O-class, Ratifier O-class
  receipt: byte-identical verdicts across the ratified corpus + diff-outside-
  verdict-computation). EXACT RATIFIED TEXT = the BRIEF.md §3 draft (the "On
  `tests/` and `RED_TEAM/`" note appended to OWNERSHIP.md's Agent-owned section),
  VERBATIM. AMENDMENT (pinned, with a faithful-execution note): mark `tests/**`
  where it appears in the Agent-owned listing with "(see note below)" so a reader
  who scans only the listing is routed to the clarification — NOTE the listing is
  inline prose, not a literal table (the operator said "table row"); the intent is
  the marker on the tests/** entry, nothing else changes. NOT built this session:
  context at 47.4% (past the 40% ceiling) — starting a governed O-class packet here
  would be dumb-zone work; run #22 (fresh session) builds it. Sequencing: does NOT
  reorder the UBC-portability wave's pinned ITEM 2→ITEM 1 first-picks; the OWNERSHIP
  O-class edit is a co-ratified run-22 pick, leverage-ordered at the run-22
  declaration without touching the UBC pin.

- **2026-07-16 (system clock) · WAVE "UBC PORTABILITY" OPERATOR-RATIFIED (verbatim:
  "Approve the wave as packeted: ITEM 2 exact text ratified as quoted (title
  stays), rejection-ledger placement accepted, lv scope gap accepted as chosen,
  truth-note on the ultrathink rationale accepted as primary-semantic /
  keyword-plausible-unmeasured. Queue position behind run-21's ratified picks
  confirmed — do not reorder.or run 22 if is already shipped"):** queue resolved
  to RUN-22 FIRST PICKS — run #21 closed before this approve landed (its two
  merges park at the operator's tier-3 buttons, which are operator actions, not
  loop picks; the "run 22" fallback the approve itself names). SEQUENCE PINNED:
  ITEM 2 lands BEFORE ITEM 1 in the same wave, so the first UBC ever shipped
  externally is already the proportional version. ITEM 2 (MAJOR — [context/](context/)
  is the always-applied standards layer; full bench + Ratifier packet + operator
  ratifies the exact bytes before merge): [context/ubc.md](context/ubc.md) line 3
  ("For EVERY task, ultrathink before coding.") is replaced by the ratified block,
  pinned verbatim here as the in-repo payload source (rejection-ledger rule:
  payloads never live only in conversation); byte-exact receipt SHA-1
  `03dcee0e7d711e66d9923e8284cebcd7e53d3d5a` (the 4 lines below, LF line endings,
  trailing newline):

  ```
  Think in proportion to the task's tier:
  - Trivial — the standing rules below; no extended-thinking trigger.
  - Standard — think before coding or writing.
  - Major — ultrathink before coding.
  ```

  Every other line of ubc.md byte-for-byte INCLUDING the title line (operator:
  "title stays" — still truthful, ultrathink remains the Major form). Retired-
  wording rationale recorded per the ratified truth-note: PRIMARY = instruction
  semantics (an unconditional "ultrathink every task" order contradicts §6
  proportionality however the keyword mechanics resolve); the keyword-budget
  effect via CLAUDE.md-imported text = plausible, UNMEASURED — reported as such,
  never as fact. Rejection-ledger row (origin: Karpathy's "think before coding"
  principle, adapted; unconditional variant retired) rides the ITEM 2 packet,
  written then, not before. ITEM 1 (STANDARD):
  [adapters/cc/bin/install.sh](adapters/cc/bin/install.sh) ships `context/ubc.md`
  skip-if-exists (the RED_TEAM guard pattern already on its line 12); NEVER
  overwrites any pre-existing CLAUDE.md or context file (skip + say so in the
  install output); output gains ONE suggestion-only line (the deployment applies
  its own import — no automated edit of the target's CLAUDE.md). Receipts as
  packeted R1–R7, incl. R6 shipped-SHA == post-ITEM-2 ubc.md SHA (mechanically
  impossible to ship the unconditional wording) and R5 residue grep (current
  file verified clean live — zero gadd paths; "the ratchet"/"tier" vocabulary is
  deployment-generic, disclosed). lv SCOPE GAP ACCEPTED AS CHOSEN: UBC ships only
  via cc (culture applies where the agent loop runs); extending to lv-only
  deployments = separate future ruling. Root `bin/install.sh` verified a pure
  dispatcher (execs the adapter script) — no second surface to touch.

- **mission-loop run #21 CLOSE (same session; 2 items completed, both MERGE-READY at
  the operator's tier-3 button; heartbeat at close ~31% of ceiling, measured):**
  ITEM 1 ACCEPT-SIGNER (item-6, Major, full bench) — built to
  `audits/accept-signer-design-v1.md` under the operator's 3 ratified answers.
  Round-1 bench: CF PASS · TH PASS (48-scenario suite + mutation battery) ·
  SECURITY/DATA_INTEGRITY/REGRESSION FAIL with 3 REAL demonstrated blockers
  (trust-anchor smuggling: an unsigned commit touching ONLY `gadd/allowed_signers`
  alongside a legit signed accept widened the base anchor — full accept-gate
  compromise on an ENROLLED deployment, proven MISSED by the round-1 check; +
  enroll-later path bricked; + installer 3-field-`.pub` misclassification wrote
  `ssh-ed25519` as the principal so no accept ever verified). SR-1 repair round 1
  (`8947b1f`): combined pathspec `-- gadd/BASELINE.json gadd/allowed_signers` so
  every signers-touching commit is itself accept-verified; legacy-first-enrollment
  exemption (subject+author only, no signature, when base has no signers);
  malformed-base-BASELINE fail-closed CRITICAL. Round-2 re-bench of the 3 failed
  adversaries: ALL PASS (SECURITY also probed evil-merge/history-simplification,
  delete-re-add, ratchet-dodge — all fail closed). NET BENCH 5/5. RATIFIER:
  APPROVE-CONDITIONAL, **item-6 L-class (4th such ruling)**, 10 receipts
  reproduced by its own hands (incl. round-1 smuggle proven MISSED-then-closed,
  git<2.34 fail-closed, monotonicity manifest — no corpus input flips red→green),
  5 STOPs; merge = operator button. Post-accept live gate PASS with exactly one
  MINOR (the designed "enroll a signer, second factor only" disclosure on gadd's
  own unenrolled deployment). Files: both `02-lane-violation.sh` copies
  (byte-identical `a8a94e7ae67f…bdc01`), `adapters/lv/bin/install.sh`,
  `adapters/lv/templates/OWNERSHIP.md` (+`gadd/allowed_signers` fence line),
  `docs/pr-adoption.md`, new `tests/signer-fixtures.sh` (48/48). Prior suites all
  green (failclosed 32 · inapplicability 8 · parity 40 · heartbeat 52 · fleet 81).
  ITEM 2 CI-RUNS-TESTS (Standard) — `mission/run-21-citests` `eaa5396`:
  `gadd-tests.yml` runs every `tests/*.sh` on push+PR, fails the job after running
  all, glob-based (auto-picks up new suites), signal-only, dual-located
  byte-identical, ships via the existing installer glob. SECURITY PASS (plain
  `pull_request` not `pull_request_target`, `contents: read`, no secrets, no
  `${{}}` injection, injection-safe glob, strict subset of the ratified advisory
  pattern). NO accept commit (not a governed-lane edit). ITEM 3 OWNERSHIP-vs-item-6
  WORDING drafted as a RATIFICATION PROPOSAL, NOT self-served (invariant-grade,
  SR-8): the tension is that the charter (item-6) names `tests/`+`RED_TEAM/` the
  operator-owned ratified corpus ("proposer may not narrow it") while gadd's own
  OWNERSHIP.md lists `tests/**` under "Agent-owned (free to modify)" and the
  gadd-governed fence omits `tests/` (lane check blind). Root cause: "own" is
  overloaded — OWNERSHIP.md means "not gated by the deterministic lane check #2",
  the charter means "operator-owned corpus, protected from NARROWING by the L-class
  whole-corpus-preservation receipt + CODEOWNERS + CI". Proposed reconciliation
  text quoted in BRIEF.md; both readings are honest and enforcement is UNCHANGED —
  it's a clarifying disclosure edit to OWNERSHIP.md (a governed file → needs accept
  + it's charter-adjacent) so it parks for the operator. Anomalies: one
  Director-caused, self-caught — the first close commit landed on
  `mission/run-21-signer` (HEAD had followed the executor onto that branch) instead
  of main, which would have injected LANTERN.md into the Ratifier-verified signer
  packet (breaking STOP-4). Caught immediately on branch inspection; repaired by
  cherry-picking the close onto main (`7a2d147`) and `git branch -f`-ing the signer
  branch back to its ratified tip `6cd5411`; re-verified the packet
  `44f09ed..6cd5411` has zero LANTERN content. 12/12 subagent invocations clean
  (the 3 round-1 bench FAILs are the bench WORKING, not anomalies; the SR-1 repair
  is logged). SR-1 executions: 1 (repair round 1). Residue: clean (12 patterns, 0
  hits, engine canary passed) — run before the close commit. Stopped: condition 1 (TIER-3 — both items
  at operator merge buttons) + condition 2 (RATIFICATION NEEDED — the OWNERSHIP
  wording proposal). Task budget 2/5 used; context healthy (~31%) but a tier-3
  wall is the right close. NEW QUEUE from run-21: (a) DI note — valid-JSON-but-
  wrong-TYPE base BASELINE.json (e.g. `[1,2,3]`, or accept_authors as a string)
  slips the parse guard and silently drops the author factor to a MAJOR nudge
  (low impact — base trust-pinned, enrolled path still gates on signature; L-class
  tightening candidate); (b) `timeout-minutes` on PR-triggered CI jobs (gadd-tests
  AND the already-merged gadd-advisory — uniform hardening, generic public-repo
  abuse class, SECURITY note, not introduced by this run); (c) additive-MINOR
  stacking awareness — external adopters carrying 2 pre-existing MINORs newly FAIL
  on a legacy accept until they enroll a signer (design-accepted, operator-aware
  at merge). h1/h2 heartbeat-emission-exit hardening still QUEUED, deferred to
  next run.

- **mission-loop run #21 DECLARED (2026-07-16 system clock; FRESH SESSION per run-20
  close; lock acquired pid-fresh; heartbeat at declaration: 19.5% of ceiling):**
  standing ratifications loaded (post-run-20 entry below). Plan by leverage:
  (1) ACCEPT-SIGNER BUILD — first pick, item-6 (Ratifier classifies), declared
  tier MAJOR (grader change, always Major; full bench): build to
  `audits/accept-signer-design-v1.md` under the operator's 3 ratified answers
  (dedicated gadd-accept keypair / accept_authors permanent second factor / CI
  also runs the signature check pubkeys-only). INTERPRETATION PINNED PRE-BUILD
  (SR-8 flavor, disclosed for the Ratifier + operator veto): design step-1
  "nudge escalated MINOR→MAJOR" read literally as escalating the EXISTING
  accept_authors-missing nudge; a deployment with accept_authors SET but no
  enrolled signer gets an ADDITIVE MINOR disclosure nudge, not MAJOR — the
  alternative reading (MAJOR whenever base lacks signers) would gate-FAIL this
  very packet's own accept commit and hard-block naked deployments' genesis
  enrollment push, contradicting the design's own "no flag day / step-2 gated
  by the old %ae check one last time" text; genesis-window suppression (head
  enrolls → escalation suppressed to disclosure) pinned for the same reason.
  Ratchet rule pinned as STATE comparison (base signers non-empty AND head
  signers empty/absent → CRITICAL), since rotation commits ride pre-accept in
  the same push. (2) CI-runs-tests wiring (Standard, promoted). (3) OWNERSHIP
  wording fix. Then h1/h2 + queues as budget allows. Origin-state observation
  logged in the branch row above.

- **2026-07-16 · POST-RUN-20 OPERATOR RATIFICATIONS (all three, verbatim-quoted in
  the dispatch):** (1) ACCEPT-SIGNER DESIGN RATIFIED with answers — (a) DEDICATED
  gadd-accept keypair, never the personal GitHub key; "the private key is a tier-3
  secret with its own lifecycle"; (b) accept_authors KEPT PERMANENTLY as second
  factor; (c) CI ALSO runs the signature check, pubkeys only. BUILD = RUN #21
  FIRST PICK (item-6, Ratifier classifies; design + probe receipts in
  audits/accept-signer-design-v1.md). (2) CODEOWNERS RATIFIED as a PRECISE DELTA
  (run-19 text + /tests/ + /bin/, nothing else) — WRITTEN + COMMITTED `11a2fce`,
  receipt DELTA-EXACT (empty diff vs run-19 text + the two lines); "CI runs
  tests/*.sh" DX item PROMOTED (approved, queue → build). (3) OWNERSHIP.md-vs-
  item-6 wording tension APPROVED for the queue, invariant-grade fix. RUN #21 =
  FRESH SESSION (confirmed), first picks: signer build (Standard/Major, full
  ceremony, with the three answers as constraints) · CI-runs-tests wiring ·
  OWNERSHIP wording fix · then h1/h2 + remaining queues. Local main now 2 ahead
  of origin unpushed (`b373410` run-20 close + `11a2fce` CODEOWNERS) — next
  chain or "push main" carries them.

- **mission-loop run #20 DECLARED (same session, 86% ceiling at declaration —
  compact run; operator: "approve merge — execute the run-19 chain… CODEOWNERS: read
  in full. One question before I ratify — [tests/ corpus vs agent-owned lane]…
  Relaunch the loop (next pick: item 3 accept-signer, design-first as planned).")**
  — run-19 chain EXECUTED: merged `d2106f5` --no-ff, ALL 6 receipts green at the
  merge commit (gate PASS 0 findings base `aa0b9e3` · failclosed 32/32 · fleet
  81/81 · parity 40/40 · byte pins ×2 · accept diff 1-line · main not
  branch-protected so advisory trivially non-required), pushed `2fbb39d..d2106f5`
  hook PASS. CODEOWNERS QUESTION ANSWERED WITH RECEIPTS (operator's concern
  CONFIRMED): tests/ fixture-weakening via external PR is caught by NOTHING
  deterministic today — OWNERSHIP.md lists tests/** agent-owned (lane check blind),
  zero workflows/hooks execute tests/*.sh (grep receipt), Ratifier sees packets not
  PRs; CODEOWNERS AMENDED to add /tests/ + /bin/ (same logic, North Star
  instruments), pending ratification; flagged: promote DX item "CI runs tests/*.sh"
  (deterministic complement) + OWNERSHIP-vs-item-6 wording tension (SR-8 flavor,
  invariant rewrite queued). Run-20 plan: accept-signer DESIGN PASS (isolated
  design agent, read-only; proposal → operator ratification, build next run).
  **CLOSE (same entry):** DESIGN PASS DONE — `audits/accept-signer-design-v1.md`
  (local-private): RECOMMENDED = SSH commit signing verified against a BASE-PINNED
  `gadd/allowed_signers` (trust anchor read from GADD_BASE only — probe showed a
  working-tree anchor loses to self-enrollment, the base-pinned anchor defeats it;
  audit probe-F spoof dead; spoof+sign dead via principal matching); GPG rejected,
  token-file = git<2.34 fallback, GitHub API = CI supplement only; 5-step
  monotonic migration (legacy %ae fallback with escalated nudge, signed genesis
  accept, installer closes the fresh-install window); 3 open questions for the
  operator (design file + brief). AWAITING RATIFICATION — build = next run's
  first pick once ratified (item-6, Ratifier classifies). LOG-REPAIR DISCLOSED:
  the run-20 declaration edit accidentally consumed the run-19 entry's header
  line; restored verbatim in this same edit — append-only intent preserved, the
  defect and repair both named. Anomalies: that one (Director-caused, self-caught)
  — 1/1 subagent invocation clean. Stopped: conditions 2 (RATIFICATION NEEDED:
  signer design + amended CODEOWNERS await the operator) + 4 (88% of ceiling at
  design return — NEXT RUN MUST BE A FRESH SESSION). Session totals runs #16–#20:
  5 runs, 3 merges landed on origin (`2aeae9f` `2fbb39d` `d2106f5`) + run-16
  charter/close pushes, 3 item-6 L-class rulings, 2 audits, 1 design pass, 12/12
  subagent invocations clean, residue clean at every close.

- **mission-loop run #19 DECLARED (same session; operator ruled on the PR-flow queue,
  verbatim: "1. APPROVED — base_sha canonicalization + ancestry + explicit
  squash-incompatibility error. Ratifier classifies under item-6 with receipts.
  2. PENDING MY READ — quote the proposed CODEOWNERS text verbatim in your next
  brief (or reply). I ratify governance text only after reading it. 3. APPROVED —
  verifiable accept-signer replacing %ae. Ratifier classifies under item-6 with
  receipts. 4. APPROVED — build the adoption note (Standard). 5. APPROVED — build
  the PR-time advisory ratchet run, non-gating (Standard). Relaunch the loop.
  Tier-3 merges remain my button as always.")** — CODEOWNERS text quoted verbatim
  in the reply + brief per ruling 2. Run-19 plan by leverage: (1) item-1 gate
  hardening first (full ceremony), then items 4+5 (Standard builds) as budget
  allows; item-3 accept-signer DEFERRED to a design-first pass next run (grader
  redesign deserves fresh-session ceremony, not end-of-session context — disclosed,
  not silent). **CLOSE (same entry):** ITEMS 1+4+5 BUILT on `mission/run-19-prflow`
  (`7b66d5a` hardening H + `aa0b9e3` advisory workflow + adoption note + `cd37bc0`
  accept commit — one packet per item 6's own text). Hardening H: base
  canonicalization + ancestry assertion, non-ancestor → loud CRITICAL squash-
  incompat refusal; scenario-5 fixtures both-direction (red 4/4 pre-H; one fixture
  bugfix disclosed: `git checkout -` after orphan checkout), failclosed 32/32,
  prior 23 byte-stable, installed copy byte-identical `81c07fdb`, live gate PASS
  post-accept (base `aa0b9e3` canonical). Advisory workflow byte-identical
  `34fc0c93` both copies, ships via existing installer glob; adoption note
  normative (merge-commit only, integration ≠ acceptance). BENCH: DI PASS r1 +
  REGRESSION PASS r1, zero blockers (REGRESSION confirmed fleet 81/81, parity
  40/40, installer end-to-end, shallow-clone false-negative unreachable from
  shipped paths; DI confirmed canonicalization spelling-only, no red→green).
  RATIFIER: APPROVE-CONDITIONAL — THIRD item-6 L-class ruling (canonicalization
  nuance judged: verdict-field byte-delta on non-canonical spellings trips no
  escape trigger, pinned by 5b), 6 receipts, 4 STOPs (no-squash fence; gate re-run
  at merge HEAD). ITEM 2 (CODEOWNERS) still PENDING operator read — text quoted
  verbatim in reply + brief. ITEM 3 accept-signer DEFERRED to design-first next
  run. Anomalies: none — 3/3 subagent invocations clean; one own-fixture bug
  caught by the pre-fix red run (the receipts discipline working on the Director).
  SR-1 executions: 0 repairs (bench passed r1 both). Stopped: condition 1 (TIER-3
  — merge at the operator's button) with condition 4 approaching (82% of ceiling
  at close, measured). Heartbeat dogfooded throughout. (same session; operator dispatch: "approve merge —
  execute the run-17 chain per the Ratifier's receipts and STOPs. Then relaunch the
  loop for run #18. Also add to the standing queue if not already there: PR-flow
  readiness audit — verify gadd's acceptance chain works when merges to main happen
  via approved PRs (merge commit and squash): accept_authors allowlist attribution,
  baseline advance target, and CODEOWNERS mapping for tier-3 surfaces. This gates
  external-repo adoption.")** — run-17 chain EXECUTED first: merged --no-ff
  `2fbb39d` (all verdict receipts re-run green at the merge commit: 52/52 ·
  baseline-38 vs merged script 38/38 zero flips · parity `4c610410` · residue
  clean), pushed `2aeae9f..2fbb39d` hook PASS, origin ratchet success. PR-FLOW
  READINESS AUDIT queued (new item, operator-ratified) AND picked as run-18 first
  item — leverage trace: it gates external-repo adoption, the coverage-proxy growth
  path of the ratified objective function; ties-by-unblocking-power over h1/h2
  (hardens an already-safe path). Audit is read-only investigation (Standard
  rigor); report local-private per standing rule. **CLOSE (same entry):** AUDIT
  EXECUTED by isolated read-only subagent — 10 surfaces read, 6 merge/squash flows
  simulated in scratch repos, zero repo changes. Verdicts Q1 WORKS / Q2 BREAKS-LOUD
  / Q3 narrow-break / Q4 MISSING; 6 findings (2 CRITICAL: squash wedge fail-closed,
  CODEOWNERS absent fail-open; %ae spoof+self-enroll MAJOR confirmed live by
  probe); 5 queue items with jurisdiction flags → roadmap row, ALL await operator
  ruling (2 are tier-3/item-6, CODEOWNERS is an operator governance act — the loop
  builds none of them unratified). Report: `audits/pr-flow-audit-v1.md`
  (local-private), proposed CODEOWNERS text preserved verbatim. Anomalies: none —
  1/1 subagent invocation clean. Stopped: condition 1 (TIER-3 — every next action
  on this item is an operator ruling). Update also standing: mission-loop.md
  two-copy byte-identity, adapters/cc dep list, run-13 stale-doc fix all LIVE on
  origin via `2fbb39d`.

- **mission-loop run #17 DECLARED (same session as run #16, operator relaunch:
  "push main approved. approve merge for run-16-heartbeat per the Ratifier's receipts
  and STOPs. Then relaunch the loop for run #17.")** — run-16 chain EXECUTED first:
  main pushed (`253d381..2a7ec6a`, hook PASS), merge `2aeae9f` --no-ff (STOP-2
  byte-identity verified pre-merge; post-merge receipts 38/38 + `91cb487f` both
  copies; residue clean), pushed (`2a7ec6a..2aeae9f`, hook PASS); origin
  `gadd-ratchet` + `gadd-redteam` both completed success on `2aeae9f`. Run-17 plan:
  (1) heartbeat sibling fail-opens n1+n2 (Standard, one item — boolean-false
  fabricated tokens-0 + status-mode jq-absent exit 0), (2) Trivial queue docs, close
  on context/budget. **CLOSE (same entry per declaration):** (1) n1+n2 BUILT on
  `mission/run-17-heartbeat-siblings` (`1d93b04` fix + `d50cf7f` repair-1 +
  `ddbc4df` repair-2-at-cap): both defects demonstrated live pre-fix; tier-1
  all-numbers rule + status-mode jq fail-closed; fixtures 11+12 both-direction
  (pre-fix reds 5/5, 4/4, 2/2 per round), mutation demo 4 = the run-16 guard as
  mutant (CONFIRMED insufficient), demo-3 sed retarget DISCLOSED (SR-5, preserved
  its bite); suite 52/52; prior 38 assertions byte-stable. BENCH: DI FAIL r1
  (presence-only jq guard — broken/non-exec jq bypass) → SR-1 repair 1 → DI FAIL r2
  (identity-probe bypass, jq-1.4 generation-broken class — REAL catches both
  rounds) → SR-1 repair 2 AT CAP → DI PASS r3 zero blockers (adversary re-executed
  the bypass classes itself). RATIFIER: APPROVE-CONDITIONAL — SECOND item-6 L-class
  ruling, 6 receipts reproduced by its own hands (incl. baseline-fixtures-38
  against new script: zero flips), 5 STOPs; h1/h2 emission-exit refactor queued
  OPEN (STOP-5). (2) docs/metric-parity.md stale /tmp refs fixed (`e6cf994`,
  Trivial, DISCLOSED post-verdict docs-only rider). Anomalies: none in dispatch —
  5/5 subagent invocations clean (2 DI FAILs are the bench working, not
  anomalies). SR-1 executions: 2 (both repair rounds, receipts in commits).
  Stopped: condition 1 (TIER-3 — merge at the operator's button). Heartbeat at
  close: measured in-session, under ceiling.

- **2026-07-16 (system clock; see drift disclosure in roadmap row) · run #16 CLOSED —
  item-6 LIVE and exercised same run; speed audit v2 measured; 5/5 task budget:**
  operator dispatch: "Proceed with run #16 as agendaed: 1. Item-6 verbatim
  charter-write … (ratified text from brief #15, byte-exact). 2. SPEED AUDIT v2 —
  include the ~30k first-message tax question… 3. Standing queues as listed. Tier-3
  remains human as always." EXECUTED: (1) ITEM-6 VERBATIM WRITE (`53801cd`, local
  main, unpushed): byte-exact receipt SHA-1 `8005f17b` (stripped brief blockquote ==
  written charter block), commit quotes the dispatch; local-private canonical synced.
  (2) SPEED AUDIT v2 (results in roadmap row; audit local-private per standing rule;
  the ORIGINAL v1 parser survived and ran unmodified — parity receipt bit-for-bit).
  (3) STANDING QUEUE: mission-loop.md two-copy reconciliation (live copy adopts
  shipped deployment-neutral wording; byte-identical `a688a601` both) · adapters/cc/
  CLAUDE.md stale dep list fixed (adds heartbeat + plist, matches install.sh) ·
  HEARTBEAT NULL-USAGE FAIL-OPEN CLOSED (`173e3f7` on `mission/run-16-heartbeat`,
  Standard): defect demonstrated live pre-fix ("OK 0/400000 via tokens" on an
  all-null usage object); minimal jq null-guard → labeled bytes degrade; scenario-10
  fixtures both-direction (3/3 FAIL pre-fix), mutation demo 3 bites, suite 38/38,
  prior 32 assertions byte-stable, shipped copy byte-identical `91cb487f`; DI
  adversary PASS r1 zero blockers (isolated, opus); RATIFIER APPROVE-CONDITIONAL —
  FIRST LIVE ITEM-6 L-CLASS RULING (classification the Ratifier's, 5 receipts
  re-verified by its own hands, 3 STOPs incl. n1/n2 stay-open honesty condition).
  Anomalies: none in dispatch — 2/2 subagent invocations clean; residue check run on
  close (result in close commit); Slack brief send SKIPPED as redundant (interactive
  operator dispatch — BRIEF.md written per standing surface; disclosed, not silent).
  Stopped: conditions 5 (task budget 5/5) + 1 (both next actions are operator
  buttons: push main ×2 commits, merge run-16-heartbeat). Heartbeat self-reading at
  close: measured in-session, well under ceiling (P1 dogfooded on its own fix run).

- **2026-07-17 · run #15 — P1 LANDED, charter naming ratified, three operator rulings
  executed:** operator superseding dispatch. (1) P1 heartbeat MERGED --no-ff + PUSHED
  (`65a9f91`), all 6 Ratifier receipts produced (composite all_green · heartbeat 32/32
  · byte-identity bin↔adapters/cc · 6-file scope no-grader · clean-install never-127 ·
  non-force append); the context-ceiling meter is now LIVE in loop step 6. (2) CHARTER
  NAMING AMENDMENT ratified (`33a1dab`, item 7, operator dispatch = ratification):
  "mesa-in-loop" retired → "the Ratifier"; "Mesa" = operator-side counsel ONLY; SR-9
  (attribution vocabulary) added to the live charter + local-private canonical synced;
  the run-14 item-6 review relabeled RATIFIER REVIEW per SR-9. (3) RESIDUE GUARD FIRED
  AGAIN — this time on the run-14 *close text itself*, which named the blocklist pattern
  verbatim while describing the run-13 catch; anonymized (`no literal pattern in prose`)
  and clean. Item-6 tier-3 verbatim charter-write DEFERRED to next run per the dispatch
  ("next run", quoting it). Decision 3 (leave the stale intermediate) ACCEPTED WITH
  CONDITION (roadmap). SPEED AUDIT v2 gains a measurable operator question (roadmap:
  ~30k first-message context tax). Anomalies: 2 merge/push vetoes on the P1 branch
  before the explicit approval landed (consent grammar, honored); residue self-catch #2
  (guard working). No subagents dispatched this run — direct execution of ratified work.

- **2026-07-16/17 · run #14 CLOSED — merge chain landed, P1 built + benched, mesa
  reviewed the item-6 draft; session hit its OWN new ceiling:** the authorized full
  chain executed — run-13 hardening MERGED+PUSHED (`bb2b699`, hook-gated PASS, 6
  receipts) closing 5 reds (GADD_BASE silent-pass MAJOR, crash-demote, malformed-line
  wipe, /tmp substrate, OWNERSHIP fence spoof). RESIDUE GUARD CAUGHT the Director:
  my run-13 roadmap edit wrote a real deployment name into LANTERN.md — the shipped
  `bin/residue-check.sh` fired on the merge tree (a blocklisted deployment-name
  pattern), I anonymized to the neutral register (`b128daa`) and re-pushed clean. The public-history-rewrite
  decision for that one intermediate commit is PARKED TIER-3 (item 1) — options in the
  brief; the standing rule held (public entries use the anonymous register). P1 heartbeat
  BUILT (`mission/run-14-p1`, `74dd9b0`): deterministic transcript-size context meter
  per the operator's design ruling, wired into loop step 6, ceiling 400k=40%/1M.
  Bench 3/3 after one SR-1 round: TH PASS r1; DI FAIL r1 (unvalidated ceiling env →
  fail-open "OK 112500%") → fixed → DI PASS r2 (break battery dead); REGRESSION FAIL
  r1 (cc installer didn't ship the script → exit 127 in deployments) → fixed via
  byte-identical dependency-closure copy → REGRESSION PASS r2. Ratifier
  APPROVE-CONDITIONAL, 6 receipts; merge parked at the button (consent grammar).
  LIVE PROOF the instrument works: it measured THIS dispatch session at 365,913 tokens
  = 91.5% of ceiling — P1 flagged its own session for hand-off, which is exactly why
  this run closes here (stop condition 3, now MECHANICAL). RATIFIER REVIEW of the charter
  item-6 rewrite (relabeled per SR-9, run #15 — an in-loop review is the Ratifier's,
  not the mesa's): SOUND-WITH-AMENDMENTS, 6 fixes (whole-corpus prior-verdict
  preservation closes a paired-loosening smuggle; operator-owned corpus; O-claim
  narrowed per SR-4; Ratifier-owns-classification; "lateral" pinned; accept-commit
  folded in) — amended draft in the brief for ratification. SR-1 executions: 1.
  Anomalies: the residue self-catch (above; a real guard firing on the Director — the
  system working); 3 merge vetoes honored (consent grammar); 15/15 subagent
  invocations clean. QUEUED from run-14: mission-loop.md two-copy reconciliation ·
  adapters/cc/CLAUDE.md stale dep list · heartbeat null-usage→0 + string-usage→bytes
  notes · SPEED AUDIT v2 (P1 now live-ready) — all deferred to the next (fresh) session.

- **2026-07-16 · run #13 CLOSED — five operator rulings executed; hardening bench-green
  5/5 round 1, merge at the button:** (declaration folded into this close — the tree
  was occupied by the executor branch from bootstrap onward; lock held throughout.)
  RULING 1 "approve speed merge" → EXECUTED: `b74c389` merged+pushed, hook gated PASS,
  all 6 receipts; ONE DISCLOSED DEVIATION: my merge-tree pre-check was flawed (bad
  grep) and reported clean — the merge conflicted in one hunk (both sides' inserts
  under `## Log`); resolved as a union of my own two writes, both sides byte-receipt
  verified, disclosed in the merge commit message. RULING 2 "approve hardening" →
  EXECUTED: A–G built on `mission/run-13-failclosed` (`19169ec` + accept `c54ef70`,
  11 files +610/−25, 23 new fixtures that fail 12/23 against pre-hardening scripts);
  all 7 pre-named receipts produced incl. healthy-state byte-equivalence and the
  monotonicity manifest. FULL BENCH 5/5 ROUND 1 — zero Fixer rounds, a first for a
  Major item: SECURITY (jq-arg escaping, env hard-assign, mktemp kills a symlink
  surface) · DATA_INTEGRITY (UTF-8/NUL degrade closed; confirmed the diff correctly
  FAILS its own gate pre-accept — the designed dance) · REGRESSION (the decisive
  shallow-clone question RESOLVED SAFE: shipped workflows use fetch-depth:0; fresh-
  deployment install dance end-to-end green) · CF (byte-identity sweep incl. the 8
  untouched checks) · TH (mutation receipt re-executed; 3 surgical reverse mutations
  each independently caught). Ratifier: APPROVE-CONDITIONAL, 6 merge receipts,
  monotonicity verified by its own hands. MERGE VETOED by the harness layer —
  consent grammar upheld ("approve hardening" = dispatch only; runs #10/#11
  precedent) → parked MERGE-READY at the operator's button, remote untouched.
  RULING 3 (P1 design: transcript-size heartbeat) + RULING 4 (item-6 rewrite
  drafted, in brief) + RULING 5 (keyless-degrade acceptance + activation condition)
  → logged in roadmap row. Anomalies: the merge-tree pre-check false-clean (above,
  method corrected: grep conflict markers is unreliable on merge-tree output — use
  a real `git merge` attempt or `merge-tree --write-tree` exit code); 9/9 subagent
  invocations clean. SR-1 executions: none this run (bench passed round 1).

- **2026-07-16 · run #12 CLOSED — 3 items advanced, 2 parked at operator buttons:**
  (1) APEX triage DONE (entry below). (2) Fail-closed hardening A–G PARKED TIER-3
  (item-6 jurisdiction; dispatch-ready). (3) Speed items P3+P4 BUILT on
  `mission/run-12-speed` (`9f600ab` receipts script · `4ca9056` lantern rotation,
  byte-verified verbatim · `af70231` DI fix): bench CF PASS r1, REGRESSION PASS r1,
  DATA_INTEGRITY FAIL r1 (real catch: suites lying with exit 0 fabricated green in
  the receipts aggregator) → SR-1 Fixer round, textbook scope → DI PASS r2 with
  monotonicity verified (new parsing only forces green→red) + 3 residual
  self-report-trust notes disclosed as by-design. Ratifier: APPROVE-CONDITIONAL,
  6 receipts; merge attempt VETOED by the harness permission layer (self-approval
  reading — "relaunch the loop" predates the branch) → STOP-2 executed: parked at
  the operator's button, remote untouched. P1 (context ceiling) NOT built — needs a
  design pass on how a session measures its own context deterministically; queued
  with that question named. SR-1 executions this run: 1 (logged above). Anomalies:
  none in dispatch — 8/8 subagent invocations clean this run. NOTE: LANTERN rotation
  (P4) exists only on the branch until merge; this file remains pre-rotation on main.

- **2026-07-16 · run #12 · APEX TRIAGE DONE + hardening packet PARKED TIER-3 (item-6
  two-reading):** every audit claim verified against main `77a9914`. CLOSED: bare-
  checkout worst case (schemas installed, hook fail-closed), checks-01/07 vacuousness
  (Repair A), RED_TEAM/** grader-edit vector (governed lane). NARROWED: TOCTOU vector
  (lane CRITICAL catches non-self-neutering edits; same-push self-modify residual
  open), %ae accept-spoof (allowlist live from base; spoofable-metadata residual
  open), malformed-line wipe (only via shared-/tmp corruption). OPEN-NEW (gold, now
  logged red): CRASH-DEMOTE fail-open — run-all.sh:20 discards check exit codes, a
  crashed check's detections vanish, verdict stays PASS (violates "a gate that cannot
  run never passes silently"); crafted-filename evasion of checks 03/05/06/08 (F-03);
  RLS parser gaps (F-04); verdict-planting via ungoverned gitignored gadd/verdicts/
  (vector-d residual); fixed world-shared /tmp state files (F-12). HARDENING ITEM
  SPEC'd (A–G: rev-parse base · exit-code ledger · per-line NDJSON validation ·
  mktemp substrate · lane base-read + OWNERSHIP self-governed · both-direction
  fixtures · self-reinstall+accept) → RATIFIER: PARK-TIER-3, merits verified sound,
  parked ONLY on charter item-6 jurisdiction ("monotonic ratchet-tightening": does
  the carve-out cover grader-LOGIC-that-only-tightens, or baseline-VALUEs only?) —
  7 receipts + 4 STOPs pre-named, dispatch-ready on one operator "approve". Item 6
  flagged (again) for invariant-grade rewrite. Loop continues per night mode.

- **2026-07-16 · DOGFOOD MERGED — gadd governs itself; coverage proxy 1→2 MEASURED:**
  operator approved the merge with a re-verify condition (main had advanced since the
  Ratifier's verdict base — measured: 2 docs-only commits, not 4 as estimated;
  merge-tree re-verified clean; branch touched neither advanced file). Merge
  `8a3f679` --no-ff (parents `c36e42a` + `fb40408`, exactly the 28 enumerated paths).
  ALL 7 RATIFIER RECEIPTS PRODUCED: R1 two-parent/scope/clean-tree ✓ · R2 gate PASS
  exit 0 on the merge commit ✓ · R3 inapplicability 8/8 + fleet 81/81 + parity 40/40
  + residue clean ✓ · R4 byte-identity 12 checks + 2 libs + 3 schemas ✓ · R5
  LANTERN.md identical to pre-merge main ✓ · R6 non-force append push
  `c36e42a..8a3f679`, THE PRE-PUSH HOOK FIRED LIVE and gated the push (gate PASS with
  the new disclosure notices visible) ✓ · R7 ESCAPED.jsonl 0 bytes, proxy moved only
  after measurement ✓. ORIGIN CI: `gadd-ratchet` ran on the merge push, completed
  SUCCESS (run 29474552876); `gadd-redteam` chained, success (keyless degrade —
  ANTHROPIC_API_KEY not configured on origin; documented behavior). Coverage proxy
  1→2 by the same criterion as deployment 1. P2 `gadd-bench` sequencing condition
  ("after the dogfood merge") is now satisfied — its 3 receipts remain owed before it
  goes live. Next-run priorities unchanged: GADD_BASE silent-pass hardening (MAJOR
  red) · APEX-audit triage · P1/P3/P4 speed items.

- **2026-07-16 · SPEED AUDIT v1 RATIFIED (operator-amended rulings; audit stays
  local-private per standing rule):** P1 deterministic context-ceiling enforcement
  APPROVED (Standard, monotonic) — mechanical heartbeat; at threshold the session
  HANDS OFF and a FRESH session resumes from repo state (lantern/BRIEF); sessions
  never run past the ratified ceiling again. P3 composite receipts script APPROVED
  (Standard, monotonic). P4 LANTERN rotation APPROVED (Trivial/Standard) — history
  archived, never deleted. P6 adversary re-run session continuation REJECTED per the
  auditor's own recommendation — adversary independence across rounds is
  load-bearing; the arms-race record is the receipt (row added to
  [docs/rejection-ledger.md](docs/rejection-ledger.md)). P2 `gadd-bench` runner
  APPROVED AS TIER-3, CONDITIONAL (charter item 6) — sequenced ONLY after the
  dogfood merge lands; before it becomes the live path, three receipts required:
  (1) equivalence — one full bench run BOTH ways on the same diff, identical
  verdict sets, with isolation, pinned models, verdict schema, and
  re-run-failed-only byte-identical; (2) one known-bad mutation surfaces the same
  blockers through the script path; (3) Ratifier verdict on the equivalence packet.
  Until all three land, manual dispatch remains the path. P5 no standalone action —
  numbers routed to the startup-mode design row (roadmap): the profile targets
  Director ceremony (68% of weighted spend), never the bench (14%) or gates (2.4%).
  NEW P7 REGISTERED, DO NOT BUILD: Architect/Coordinator split of the Director
  (operator hypothesis — the top model does FEW, deep, artifact-producing judgment
  passes: mission blueprints, JTBD/DoD docs, arbitrations, at-cap calls; the long
  coordination march runs one tier down; spend follows judgment, not presence).
  Evaluate ONLY after P1+P3+P4 land and SPEED AUDIT v2 re-measures the Director
  share — numbers decide, including the possibility that P7 is unnecessary; grader
  tiers remain a floor (R2); Ratifier untouched. RE-MEASURE directive: after
  P1/P3/P4 land, run SPEED AUDIT v2 (same parser, same axes) to verify realized vs
  estimated gains; any multi-agent hypothesis round is DEFERRED unless v2 shows an
  unexplained residual. Transmission repairs disclosed (union-reconstruction rule,
  operator may veto): "mutatie same blockers" read as "mutation surfaces the same
  blockers"; "unexplresidual" read as "unexplained residual" — both inferred from
  evident mid-word truncation, no design change.

- **2026-07-16 · run #11 CLOSED — dogfood bench-green 5/5, merge parked at the human
  button:** Repair A executed by Fixer under the operator's verbatim ratification
  (`8cf6400`: +2 lines each on checks 01+07 — `::notice::… (available:false)` to
  stderr when target dirs absent, never a finding; WITH-src behavior proven
  byte-identical pre/post in scratch repos; installed copies byte-identical to
  sources). TH round 2: B1/B2 closed but FAIL — disclosure had zero test coverage
  (adversary's mutation passed every harness). Round-2 repair at the cap (SR-1, run-7
  precedent reading, disclosed): `e52a3a3` adds `tests/inapplicability-fixtures.sh`
  (4 scenarios/8 assertions, both directions pinned) + `fb40408` accept — check 02
  correctly went CRITICAL on the unaccepted grader edit mid-round (the gate caught
  its own repair; accepted per the ratification). TH round 3 PASS — the adversary
  re-executed the mutation itself (2/8 assertions fail on the mutant), no escape
  hatches. BENCH FINAL: 5/5. Ratifier merge verdict: APPROVE-CONDITIONAL, 7 receipts
  named pre-execution, 5 STOPs; it verified gate/suites/byte-identity/merge-tree with
  its own hands and ruled both disclosed interpretations correct (additive tests in
  scope; deferred reds belong in the lantern, NOT ESCAPED.jsonl — SR-4). MERGE
  EXECUTION VETOED by the harness permission layer: "approve Repair A" ≠ approval of
  the merge itself — honored without workaround (STOP-3 spirit: no blind retry,
  remote untouched). Item parks MERGE-READY at `fb40408`. Slack brief delivery also
  permission-denied (run #10 + #11) — BRIEF.md is the standing surface until the
  operator allowlists Slack sends. Anomalies: none in dispatch — 12/12 subagent
  invocations clean across both runs. Coverage proxy stays 1 (SR-4: moves only when
  gadd-ratchet runs on origin post-merge).

- **2026-07-15 · mission-loop run #11 DECLARED (stale lock reclaimed — run-#10 release
  was permission-denied, documented recovery path worked):** OPERATOR RATIFIED Repair A
  verbatim ("approve Repair A — relaunch the loop") — the tier-3 item-6 park lifts.
  Plan: Fixer executes the grader disclosure fix on `adapters/lv/checks/{01,07}` +
  byte-reinstall, TEST_HONESTY re-runs on the new diff, merge packet → Ratifier.
  NEW OPERATOR INPUT: an external "APEX AUDIT" report attached (audited the stale
  run-6 branch) — triage queued this run; first read corroborates the logged MAJOR
  fail-open red + OWNERSHIP self-governance MINOR, adds same-push defeat vectors.

- **2026-07-15 · run #10 CLOSED — dogfood EXECUTED, parked tier-3 on one grader ruling:**
  phase-4 dogfood declared Major (spec §6 overrides the audit plan's Standard label —
  gate/baseline installation; tier floors, R2). Executor installed the lv suite on gadd
  itself, branch `mission/run-10-dogfood` (`ac82f3a` install + `8c376c9` accept +
  `fa61214` Repair B): measured baseline `{skipped_tests:0, max_file_loc:0}` (no `src/`
  — measured, not defaulted), OWNERSHIP lanes = grader territory, fail-closed
  `.githooks/pre-push` (deterministic gate only, local core.hooksPath — inert on main
  until merge since main lacks `.githooks/`), two-commit accept dance, workflows
  signal-only per invariant 3. Gate PASS post-accept · fleet 81/81 · parity 40/40 ·
  residue clean. FULL BENCH 4/5 round 1: SECURITY/DATA_INTEGRITY/CONTRACT_FIDELITY/
  REGRESSION PASS (DI probed the zero-baseline ratchet live: 0→1 skipped fired MAJOR;
  CF verified byte-identity of all 25 installed files) · TEST_HONESTY FAIL, 2 blockers:
  checks 01+07 silently vacuous on a no-`src/` repo (no `available:false` disclosure à
  la check 10). Repair = shipped-grader edit → routed to Ratifier. RATIFIER: Repair A
  (disclose inapplicability in `adapters/lv/checks/{01,07}`) **PARK-TIER-3** under SR-7
  — "never adjust a check because it breaks"; not the monotonic carve-out since
  deployment behavior is provably unchanged, blast radius = 2 live deployments;
  operator must rule. Repair B (govern `gadd/BASELINE.json`) APPROVE-CONDITIONAL —
  executed by Fixer, all 4 receipts held: diff = OWNERSHIP.md only; scenario A3
  (non-allowlisted `gadd: accept` author) now FAILS CRITICAL — the dead accept_authors
  enforcement REGRESSION demonstrated is wired live; legit accept `8c376c9` unaffected;
  full suites green. Deferrals accepted-with-disclosure, logged red in roadmap row
  (receipt 5; kept out of ESCAPED.jsonl to keep its escaped-regression schema honest —
  disclosed reading). Standing-ruling executions: none (the one repair ran under
  explicit Ratifier approval, not SR-1 pre-approval). Anomalies: none — 8/8 subagent
  invocations clean. Stopped: context threshold; item parks per night mode. YOUR MOVE
  is the Repair-A ruling — approve/reject in plain language and the loop executes.
