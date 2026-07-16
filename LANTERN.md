# 🏮 Lantern — gadd state ledger

Live state snapshot for work on gadd itself. Read at session start; update before ending
a session or handing off context. This file is only ever NOW — history lives in the log
below (append-only) and in git.

## Current state

| Field | Value |
|---|---|
| Version | v0.2 + v0.3 phase 1 CLOSED (2026-07-14, incl. the human push step) — next: /mission-loop on phases 1b + 2 |
| Coverage proxy | **2** — MEASURED 2026-07-16: (1) first deployment live on upstream gadd (origin tip `6b25ef5`); (2) gadd itself governed — dogfood merge `8a3f679` pushed and `gadd-ratchet` ran on origin, completed success (run 29474552876; `gadd-redteam` chained, success/keyless-degrade). Same criterion as deployment 1: the ratchet workflow runs on its pushes |
| Active mission branch | `mission/run-17-heartbeat-siblings` MERGE-READY at `ddbc4df` (Ratifier APPROVE-CONDITIONAL — second item-6 L-class ruling, 6 receipts, 5 STOPs; merge at the operator's button) + `e6cf994` Trivial docs commit on top DISCLOSED as post-verdict (docs-only; verdict STOP-2 re-runs receipts at the actual merge commit either way). run-16 chain DONE 2026-07-16 (operator-approved full chain): main pushed `253d381..2a7ec6a`, run-16-heartbeat MERGED --no-ff `2aeae9f` + pushed, all merge receipts green, origin ratchet+redteam success on `2aeae9f`. Prior: run-14-p1 MERGED+PUSHED 2026-07-17 (`65a9f91` on origin; operator-approved full chain; all 6 Ratifier receipts produced; pre-push hook gated PASS; the heartbeat is now LIVE in loop step 6). Prior: run-13-failclosed MERGED+PUSHED 2026-07-16 (`bb2b699`, operator-approved full chain; 5 reds closed on main). Prior: run-12-speed MERGED+PUSHED 2026-07-16 (`b74c389`, operator-approved; one-hunk union resolution in LANTERN.md disclosed, both sides byte-receipt). Prior: run-10-dogfood MERGED+PUSHED 2026-07-16 (`8a3f679`, operator-approved with re-verify condition honored; all 7 Ratifier receipts produced; pre-push hook fired live and gated the push PASS; origin ratchet ran, success). Prior: run-7 merged to main, pushed (wave "self-governing gadd": R5 wired · seed self-application bench-clean · Ratifier installed). Prior: PUBLIC HISTORY REWRITTEN from the root 2026-07-15 (double residue scrub + identity normalization) — every pre-rewrite SHA in log entries below is a stale pointer, disclosed not rewritten |
| Constitution | Ratifier-in-loop FULLY installed 2026-07-15 (operator: "go A, go B"): packets route to `gadd-ratifier` (isolated context, SR-1..**9**); only the charter's 7-item tier-3 list parks for the operator; item 7 at invariant wording. NAMING (operator-ratified 2026-07-17, item 7): "mesa-in-loop" branding RETIRED — the in-loop context is "the Ratifier" full stop; "Mesa" = operator-side counsel space ONLY; SR-9 added (in-loop products attributed to the Ratifier; mesa/operator attributions require verbatim-quotable text). ITEM-6 VERBATIM WRITE DONE (run #16, `53801cd`): V/L/O receipt-gated classes live in the charter, byte-exact from the run-15 brief (SHA-1 receipt `8005f17b`), quoting the run-16 dispatch; local-private canonical synced; FIRST L-CLASS EXERCISE same run (heartbeat fix — Ratifier classified, approved in-loop, merge still parked). Nightly schedule LIVE: launchd `com.gadd.mission-loop`, 02:17, night-mode park-and-continue; installer `bin/schedule-loop.sh` (placeholder-only template tracked). Morning brief = the operator's surface (English, ≤1 page, decisions-first) |
| North Star | **FIRST MEASURED VALUE 2026-07-15: escaped_rate = 0 over 9 accepted pushes** — fleet of 2 clean repos, 17 verdicts admitted with ZERO anomalies across all 7 reason classes, 30 findings caught pre-acceptance (14 CRITICAL). Ledger caveat CLOSED 2026-07-15: `gadd/ESCAPED.jsonl` live on both governed repos' origins — the next measurement's zero is a measured zero |
| Packet rule | PERMANENT (2026-07-15): YOUR MOVE never contains terminal commands — packets end in "reply approve and I execute"; operator may reply in plain language (any language, incl. Spanish); the loop translates to protocol |
| Objective function | RATIFIED 2026-07-14: maximize escaped-regression catches across governed repos (proxy until instrumented: upstream-governed-repo coverage × verdicts retained), subject to guards G1–G5 (`audits/objective-audit-v1.md` §3). Internal-first; OSS milestones gate on ≥1 upstream-governed repo |
| Adapters | lv (boundary) shipped · cc (in-loop) in progress — installer + blocking CI/hooks are v0.3 |
| RED_TEAM | Bench split into `RED_TEAM/` — one definition file per adversary (role, attack surface, pass criteria, output contract) + `gate-matrix.md`. Gate runners dispatch each adversary as its OWN isolated invocation, in parallel (cc: five `gadd-rt-*` subagents; lv: five independent API calls). Adversaries never see each other's verdicts. Models: structural (CONTRACT_FIDELITY, TEST_HONESTY) → cheap tier (haiku); judgment (SECURITY, DATA_INTEGRITY, REGRESSION) → strong tier (opus) |
| Protocol invariants | VERDICT + max 3 blockers per adversary · re-run only failed adversaries on the new diff · 2-round cap (spec inv. 6) · Architect arbitrates at the cap |
| Graders | `RED_TEAM/**` is grader territory — executors and the Fixer never edit it |
| Roadmap next | PR-FLOW READINESS AUDIT DONE run #18 (`audits/pr-flow-audit-v1.md`, local-private; GATES EXTERNAL-REPO ADOPTION — operator-ratified item): Q1 merge-commit WORKS · Q2 squash BREAKS-LOUD (fail-closed wedge, never fail-open) · Q3 baseline target narrow-break (squash widens the queued base_sha red; post-approval TOCTOU window) · Q4 CODEOWNERS MISSING. FIVE QUEUE ITEMS AWAITING OPERATOR RULING (jurisdiction flagged): (a) base_sha canonicalization + ancestry + squash-incompat error — tier-3/item-6; (b) CODEOWNERS for tier-3 surfaces — operator governance act, proposed text in the audit; (c) verifiable accept-signer replacing %ae — tier-3/item-6; (d) adoption note (merge-commit-only, integration ≠ acceptance) — Standard; (e) PR-time advisory ratchet run — Standard. RUN-16 RESULTS NOW STANDING: SPEED AUDIT v2 DONE (`audits/speed-audit-v2.md`, local-private; parser-parity receipt vs v1 bit-for-bit) — P1 REALIZED (deep-context tail eliminated: 0% turns >400k vs 26.4%; max ctx 394,006 under the ceiling; Director weighted/run −44%), P4 realized, P3 partially visible; total/run −7% because subagent work/run rose 68% (more Major throughput, not overhead); P7 stays REGISTERED-NOT-BUILT — no unexplained residual; v3 trigger = ≥3 fully-post-P1 runs (parser scripts preserved in `audits/*.py`). FIRST-MESSAGE TAX measured: ~47k tokens (not ~30k — in-app estimate understates), structure ≈20.2k cached prefix + ~27k per-session write; ~12–15k of the write is non-gadd plugin/skill/MCP surface; trim = operator-side project plugin/MCP config hygiene, second-order lever (~1–2% of spend). RUN-16 BENCH NOTES n1+n2 FIX BUILT run #17 (`2aeae9f..ddbc4df`, MERGE-READY — closed only when merged; fixtures 11+12, suite 52/52, DI PASS r3 after two SR-1 repair rounds AT CAP, Ratifier L-class APPROVE-CONDITIONAL). NEW OPEN (run-17 DI r3 hardening notes, Ratifier STOP-5 stay-open rule): h1+h2 as ONE queued refactor — status-mode measured emission should guard its OWN jq exit status and fail closed, retiring the probe proxy (probe flag-surface can never mirror every real-call flag; no real jq exhibits the residual today). CLOCK DRIFT disclosed: system clock measured 2026-07-16 during run #16 while run-15 artifacts carry 2026-07-17 — dates in prior entries are as-written, not rewritten. DECISION-3 STANDING CONDITION (operator 2026-07-17): stale deployment-name intermediates (`a451a43` + run-15 local intermediates carrying the descriptive pattern in-tree) are LEFT until the pre-launch scrub gate, which runs a FULL-HISTORY residue audit and re-decides; if ANY history rewrite happens before launch for any reason, those commits ride along in the same pass; anonymity is enforced binary the moment the repo faces external readers. HARDENING A–G reds CLOSED on main (run-13 merged): GADD_BASE silent-pass (MAJOR), crash-demote, malformed-line wipe, shared-/tmp substrate (F-12), OWNERSHIP self-governance + working-tree fence spoof. ORIGIN BENCH RULING (operator, 2026-07-16): keyless degrade is a DELIBERATE ACCEPTANCE — deterministic half runs, adversary half discloses itself as not-run; activation condition = first external contributor OR the second deployment's pilot launch, whichever first; subscription-vs-API decision deferred to that moment, stays tier-3 (secrets+money). ORIGIN BENCH RULING (operator, 2026-07-16): keyless degrade is a DELIBERATE ACCEPTANCE — deterministic half runs, adversary half discloses itself as not-run; activation condition = first external contributor OR the second deployment's pilot launch, whichever first; subscription-vs-API decision deferred to that moment, stays tier-3 (secrets+money). QUEUED from run-13 bench notes: base_sha canonicalization + ancestry check · hang timeout (gate) · trap EXIT INT TERM hygiene · stale docs/metric-parity.md /tmp reference · lib/common.sh standalone /tmp default · ::error:: base sanitize-if-untrusted. STILL QUEUED (APEX residuals): crafted-filename evasion (F-03) · RLS parser gaps (F-04) · %ae provenance + verdict-planting residuals · TOCTOU same-push pinning · redteam token parse + head_sha pin · hook stdin refspecs · gitignore widen `gadd/verdicts/*` · DX queue (installer clobber/reseed, jq preflight, CI runs tests/*.sh, version stamps). QUEUED: sandbox→`tests/`, test-hardening notes (aggregation_failed class, MINOR tally, tsx ceiling, positive tool-metric tests), R3 watchdog automation in dispatch plumbing · SPEED RULINGS RATIFIED 2026-07-16 (log entry below; audit local-private): P1 context-ceiling enforcement (Standard, monotonic) + P3 composite receipts script (Standard, monotonic) + P4 LANTERN rotation (Trivial/Standard, archive-never-delete) APPROVED and queued; P2 `gadd-bench` runner TIER-3 CONDITIONAL — only after the dogfood merge, 3 receipts (equivalence both-ways · known-bad mutation through the script path · Ratifier verdict) before it goes live, manual dispatch until then; P7 Architect/Coordinator Director split REGISTERED-NOT-BUILT, evaluated only by SPEED AUDIT v2 numbers after P1/P3/P4 land (grader tiers stay a floor per R2, Ratifier untouched); SPEED AUDIT v2 re-measure mandatory after P1/P3/P4 · STARTUP-MODE DESIGN ROW (roadmap, Major — trigger changes are tier-3): tier profile targets Director ceremony (packet/receipt verbosity, turn count — 68% of weighted spend), never the bench (14%) or gates (2.4% wall) · run-10 deferrals (all OPEN reds, Ratifier receipt 5): hook HEAD-vs-pushed-ref coupling (MINOR), redteam `.txt` verdicts uncovered by `*.json` ignore (MINOR), GADD_BASE silent-pass in shipped checks (MAJOR — a garbage base ref makes every check swallow git errors and PASS vacuously; executor-demonstrated), OWNERSHIP.md not self-governed (MINOR), stale OWNERSHIP prose line re lane list (Trivial doc fix) · retro items: approval-matrix↔charter tier-3 seam · SR-8 flag: "disclosure-addition vs monotonic-tightening" boundary needs invariant wording · later: `gadd-accept` bot, Cursor/Replit adapters |

## Log (append-only, newest first)

Rotation (P4, run #12, 2026-07-16): entries older than run #10 moved verbatim to [LANTERN-ARCHIVE.md](LANTERN-ARCHIVE.md) — append-only, oldest at bottom, never edited or deleted; NOW + recent runs stay here.

- **mission-loop run #18 DECLARED (same session; operator dispatch: "approve merge —
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
