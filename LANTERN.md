# 🏮 Lantern — gadd state ledger

Live state snapshot for work on gadd itself. Read at session start; update before ending
a session or handing off context. This file is only ever NOW — history lives in the log
below (append-only) and in git.

## Current state

| Field | Value |
|---|---|
| Version | v0.2 + v0.3 phase 1 CLOSED (2026-07-14, incl. the human push step) — next: /mission-loop on phases 1b + 2 |
| Coverage proxy | **2** — MEASURED 2026-07-16: (1) first deployment live on upstream gadd (origin tip `6b25ef5`); (2) gadd itself governed — dogfood merge `8a3f679` pushed and `gadd-ratchet` ran on origin, completed success (run 29474552876; `gadd-redteam` chained, success/keyless-degrade). Same criterion as deployment 1: the ratchet workflow runs on its pushes |
| Active mission branch | `mission/run-14-p1` (3 commits, tip `74dd9b0`, MERGE-READY — P1 heartbeat, bench 3/3 after one SR-1 round, Ratifier APPROVE-CONDITIONAL w/ 6 receipts; merge vetoed per consent grammar → operator's button). Prior: run-13-failclosed MERGED+PUSHED 2026-07-16 (`bb2b699`, operator-approved full chain; 5 reds closed on main). Prior: run-12-speed MERGED+PUSHED 2026-07-16 (`b74c389`, operator-approved; one-hunk union resolution in LANTERN.md disclosed, both sides byte-receipt). Prior: run-10-dogfood MERGED+PUSHED 2026-07-16 (`8a3f679`, operator-approved with re-verify condition honored; all 7 Ratifier receipts produced; pre-push hook fired live and gated the push PASS; origin ratchet ran, success). Prior: run-7 merged to main, pushed (wave "self-governing gadd": R5 wired · seed self-application bench-clean · Ratifier installed). Prior: PUBLIC HISTORY REWRITTEN from the root 2026-07-15 (double residue scrub + identity normalization) — every pre-rewrite SHA in log entries below is a stale pointer, disclosed not rewritten |
| Constitution | Ratifier-in-loop FULLY installed 2026-07-15 (operator: "go A, go B"): packets route to `gadd-ratifier` (isolated context, SR-1..8); only the charter's 7-item tier-3 list parks for the operator; item 7 at invariant wording (changes AFTER initial ratified installation). Nightly schedule LIVE: launchd `com.gadd.mission-loop`, 02:17, night-mode park-and-continue; installer `bin/schedule-loop.sh` (placeholder-only template tracked). Morning brief = the operator's surface (English, ≤1 page, decisions-first) |
| North Star | **FIRST MEASURED VALUE 2026-07-15: escaped_rate = 0 over 9 accepted pushes** — fleet of 2 clean repos, 17 verdicts admitted with ZERO anomalies across all 7 reason classes, 30 findings caught pre-acceptance (14 CRITICAL). Ledger caveat CLOSED 2026-07-15: `gadd/ESCAPED.jsonl` live on both governed repos' origins — the next measurement's zero is a measured zero |
| Packet rule | PERMANENT (2026-07-15): YOUR MOVE never contains terminal commands — packets end in "reply approve and I execute"; operator may reply in plain language (any language, incl. Spanish); the loop translates to protocol |
| Objective function | RATIFIED 2026-07-14: maximize escaped-regression catches across governed repos (proxy until instrumented: upstream-governed-repo coverage × verdicts retained), subject to guards G1–G5 (`audits/objective-audit-v1.md` §3). Internal-first; OSS milestones gate on ≥1 upstream-governed repo |
| Adapters | lv (boundary) shipped · cc (in-loop) in progress — installer + blocking CI/hooks are v0.3 |
| RED_TEAM | Bench split into `RED_TEAM/` — one definition file per adversary (role, attack surface, pass criteria, output contract) + `gate-matrix.md`. Gate runners dispatch each adversary as its OWN isolated invocation, in parallel (cc: five `gadd-rt-*` subagents; lv: five independent API calls). Adversaries never see each other's verdicts. Models: structural (CONTRACT_FIDELITY, TEST_HONESTY) → cheap tier (haiku); judgment (SECURITY, DATA_INTEGRITY, REGRESSION) → strong tier (opus) |
| Protocol invariants | VERDICT + max 3 blockers per adversary · re-run only failed adversaries on the new diff · 2-round cap (spec inv. 6) · Architect arbitrates at the cap |
| Graders | `RED_TEAM/**` is grader territory — executors and the Fixer never edit it |
| Roadmap next | Fail-closed hardening A–G BUILT+BENCHED 5/5 on `mission/run-13-failclosed` — merge = operator's button; ON MERGE these reds CLOSE: GADD_BASE silent-pass (MAJOR), crash-demote, malformed-line wipe, shared-/tmp substrate (F-12), OWNERSHIP self-governance + working-tree fence spoof. ORIGIN BENCH RULING (operator, 2026-07-16): keyless degrade is a DELIBERATE ACCEPTANCE — deterministic half runs, adversary half discloses itself as not-run; activation condition = first external contributor OR the second deployment's pilot launch, whichever first; subscription-vs-API decision deferred to that moment, stays tier-3 (secrets+money). P1 DESIGN RULED (operator): transcript-size heartbeat, deterministic read (speed-audit parser mechanism); turn-count only as documented fallback; threshold enforces the ratified ~40% rule — BUILD NEXT RUN. CHARTER ITEM-6 REWRITE: draft delivered in run #13 brief, awaiting operator ratification (tier-3 item 7). SPEED AUDIT v2: due after P1 lands (P3/P4 live on main). QUEUED from run-13 bench notes: base_sha canonicalization + ancestry check · hang timeout (gate) · trap EXIT INT TERM hygiene · stale docs/metric-parity.md /tmp reference · lib/common.sh standalone /tmp default · ::error:: base sanitize-if-untrusted. STILL QUEUED (APEX residuals): crafted-filename evasion (F-03) · RLS parser gaps (F-04) · %ae provenance + verdict-planting residuals · TOCTOU same-push pinning · redteam token parse + head_sha pin · hook stdin refspecs · gitignore widen `gadd/verdicts/*` · DX queue (installer clobber/reseed, jq preflight, CI runs tests/*.sh, version stamps). QUEUED: sandbox→`tests/`, test-hardening notes (aggregation_failed class, MINOR tally, tsx ceiling, positive tool-metric tests), R3 watchdog automation in dispatch plumbing · SPEED RULINGS RATIFIED 2026-07-16 (log entry below; audit local-private): P1 context-ceiling enforcement (Standard, monotonic) + P3 composite receipts script (Standard, monotonic) + P4 LANTERN rotation (Trivial/Standard, archive-never-delete) APPROVED and queued; P2 `gadd-bench` runner TIER-3 CONDITIONAL — only after the dogfood merge, 3 receipts (equivalence both-ways · known-bad mutation through the script path · Ratifier verdict) before it goes live, manual dispatch until then; P7 Architect/Coordinator Director split REGISTERED-NOT-BUILT, evaluated only by SPEED AUDIT v2 numbers after P1/P3/P4 land (grader tiers stay a floor per R2, Ratifier untouched); SPEED AUDIT v2 re-measure mandatory after P1/P3/P4 · STARTUP-MODE DESIGN ROW (roadmap, Major — trigger changes are tier-3): tier profile targets Director ceremony (packet/receipt verbosity, turn count — 68% of weighted spend), never the bench (14%) or gates (2.4% wall) · run-10 deferrals (all OPEN reds, Ratifier receipt 5): hook HEAD-vs-pushed-ref coupling (MINOR), redteam `.txt` verdicts uncovered by `*.json` ignore (MINOR), GADD_BASE silent-pass in shipped checks (MAJOR — a garbage base ref makes every check swallow git errors and PASS vacuously; executor-demonstrated), OWNERSHIP.md not self-governed (MINOR), stale OWNERSHIP prose line re lane list (Trivial doc fix) · retro items: approval-matrix↔charter tier-3 seam · SR-8 flag: "disclosure-addition vs monotonic-tightening" boundary needs invariant wording · later: `gadd-accept` bot, Cursor/Replit adapters |

## Log (append-only, newest first)

Rotation (P4, run #12, 2026-07-16): entries older than run #10 moved verbatim to [LANTERN-ARCHIVE.md](LANTERN-ARCHIVE.md) — append-only, oldest at bottom, never edited or deleted; NOW + recent runs stay here.

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
  this run closes here (stop condition 3, now MECHANICAL). MESA REVIEW of the charter
  item-6 rewrite: SOUND-WITH-AMENDMENTS, 6 fixes (whole-corpus prior-verdict
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
