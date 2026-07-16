# 🏮 Lantern — gadd state ledger

Live state snapshot for work on gadd itself. Read at session start; update before ending
a session or handing off context. This file is only ever NOW — history lives in the log
below (append-only) and in git.

## Current state

| Field | Value |
|---|---|
| Version | v0.2 + v0.3 phase 1 CLOSED (2026-07-14, incl. the human push step) — next: /mission-loop on phases 1b + 2 |
| Coverage proxy | **1** — operator-verified 2026-07-14: first deployment live on upstream gadd (its origin tip `6b25ef5`; the gadd-ratchet workflow runs on its pushes) |
| Active mission branch | `mission/run-10-dogfood` (6 commits, tip `fb40408`, MERGE-READY — bench 5/5 green, Ratifier APPROVE-CONDITIONAL with 7 receipts named; merge+push PARKED for the operator: the harness permission layer requires explicit human approval of the merge itself, "approve Repair A" doesn't cover it — merge-tree verified clean). Prior: run-7 merged to main, pushed (wave "self-governing gadd": R5 wired · seed self-application bench-clean · Ratifier installed). Prior: PUBLIC HISTORY REWRITTEN from the root 2026-07-15 (double residue scrub + identity normalization) — every pre-rewrite SHA in log entries below is a stale pointer, disclosed not rewritten |
| Constitution | Ratifier-in-loop FULLY installed 2026-07-15 (operator: "go A, go B"): packets route to `gadd-ratifier` (isolated context, SR-1..8); only the charter's 7-item tier-3 list parks for the operator; item 7 at invariant wording (changes AFTER initial ratified installation). Nightly schedule LIVE: launchd `com.gadd.mission-loop`, 02:17, night-mode park-and-continue; installer `bin/schedule-loop.sh` (placeholder-only template tracked). Morning brief = the operator's surface (English, ≤1 page, decisions-first) |
| North Star | **FIRST MEASURED VALUE 2026-07-15: escaped_rate = 0 over 9 accepted pushes** — fleet of 2 clean repos, 17 verdicts admitted with ZERO anomalies across all 7 reason classes, 30 findings caught pre-acceptance (14 CRITICAL). Ledger caveat CLOSED 2026-07-15: `gadd/ESCAPED.jsonl` live on both governed repos' origins — the next measurement's zero is a measured zero |
| Packet rule | PERMANENT (2026-07-15): YOUR MOVE never contains terminal commands — packets end in "reply approve and I execute"; operator may reply in plain language (any language, incl. Spanish); the loop translates to protocol |
| Objective function | RATIFIED 2026-07-14: maximize escaped-regression catches across governed repos (proxy until instrumented: upstream-governed-repo coverage × verdicts retained), subject to guards G1–G5 (`audits/objective-audit-v1.md` §3). Internal-first; OSS milestones gate on ≥1 upstream-governed repo |
| Adapters | lv (boundary) shipped · cc (in-loop) in progress — installer + blocking CI/hooks are v0.3 |
| RED_TEAM | Bench split into `RED_TEAM/` — one definition file per adversary (role, attack surface, pass criteria, output contract) + `gate-matrix.md`. Gate runners dispatch each adversary as its OWN isolated invocation, in parallel (cc: five `gadd-rt-*` subagents; lv: five independent API calls). Adversaries never see each other's verdicts. Models: structural (CONTRACT_FIDELITY, TEST_HONESTY) → cheap tier (haiku); judgment (SECURITY, DATA_INTEGRITY, REGRESSION) → strong tier (opus) |
| Protocol invariants | VERDICT + max 3 blockers per adversary · re-run only failed adversaries on the new diff · 2-round cap (spec inv. 6) · Architect arbitrates at the cap |
| Graders | `RED_TEAM/**` is grader territory — executors and the Fixer never edit it |
| Roadmap next | Dogfood gadd-on-gadd COMPLETE on branch (run #11, bench 5/5) — merge+push = operator's button. NEXT-RUN PRIORITY (Ratifier-flagged): GADD_BASE silent-pass hardening (MAJOR red) + APEX-audit triage (operator-supplied external audit of the stale run-6 branch: fail-open gate modes + same-push defeat vectors; two vectors already narrowed by the dogfood branch — RED_TEAM/** governed, accept_authors live). QUEUED: sandbox→`tests/`, test-hardening notes (aggregation_failed class, MINOR tally, tsx ceiling, positive tool-metric tests), R3 watchdog automation in dispatch plumbing · SPEED RULINGS RATIFIED 2026-07-16 (log entry below; audit local-private): P1 context-ceiling enforcement (Standard, monotonic) + P3 composite receipts script (Standard, monotonic) + P4 LANTERN rotation (Trivial/Standard, archive-never-delete) APPROVED and queued; P2 `gadd-bench` runner TIER-3 CONDITIONAL — only after the dogfood merge, 3 receipts (equivalence both-ways · known-bad mutation through the script path · Ratifier verdict) before it goes live, manual dispatch until then; P7 Architect/Coordinator Director split REGISTERED-NOT-BUILT, evaluated only by SPEED AUDIT v2 numbers after P1/P3/P4 land (grader tiers stay a floor per R2, Ratifier untouched); SPEED AUDIT v2 re-measure mandatory after P1/P3/P4 · STARTUP-MODE DESIGN ROW (roadmap, Major — trigger changes are tier-3): tier profile targets Director ceremony (packet/receipt verbosity, turn count — 68% of weighted spend), never the bench (14%) or gates (2.4% wall) · run-10 deferrals (all OPEN reds, Ratifier receipt 5): hook HEAD-vs-pushed-ref coupling (MINOR), redteam `.txt` verdicts uncovered by `*.json` ignore (MINOR), GADD_BASE silent-pass in shipped checks (MAJOR — a garbage base ref makes every check swallow git errors and PASS vacuously; executor-demonstrated), OWNERSHIP.md not self-governed (MINOR), stale OWNERSHIP prose line re lane list (Trivial doc fix) · retro items: approval-matrix↔charter tier-3 seam · SR-8 flag: "disclosure-addition vs monotonic-tightening" boundary needs invariant wording · later: `gadd-accept` bot, Cursor/Replit adapters |

## Log (append-only, newest first)

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

- **2026-07-15 · run #9 (operator-attended) — phase 3 SHIPPED (`263934e`):** lock
  acquired per new bootstrap step 0 (this run's own guard). Trivial: exit-4 fail-closed
  doc line (Ratifier follow-up). Standard: cc one-command installer (root install.sh cc
  case dispatches; scratch-install verified BOTH adapters on the merged tree) +
  /mission-loop + /objective-audit shipped in `adapters/cc/commands/` with dependency
  closure (Ratifier agent, loop-lock, schedule wiring — all byte-identical to sources;
  one disclosed generalization: brief channel name → deployment convention). Bench 2/2
  triggered (CF PASS r1 — full verbatim diff audit; REGRESSION PASS r1 — live installs,
  40/40 + 81/81). Ratifier: APPROVE-CONDITIONAL, 7 receipts, all produced (two-parent
  no-ff, tree identity, scratch installs, gates, byte-identity, 12-file scope, FF push).
  R5 clean (tree+metadata+message, 12 patterns). Prior in-session: single-instance lock
  ratified+merged (`4063062`, Ratifier 7 receipts); brief-delivery amendment executed on
  the FIRST dispatch (this dispatch's item 1 was a transit duplicate — confirmed
  idempotent, not re-executed). QUEUED from bench notes: installer clobber-on-reinstall
  awareness; approval-matrix↔charter tier-3 seam (governance, deliberately not silently
  fixed). Stopped: context threshold — phase 4 remnants go to the scheduled chain.

- **2026-07-15 · run #8 — wave CLOSED, constitution live (operator: "go A, go B" +
  three ratifications):** loop rewired — packets → Ratifier, charter tier-3 list in
  mission-loop.md (go-A); nightly launchd job installed and loaded, receipt-verified,
  rendered plist outside the repo (go-B); charter item-7 invariant wording adopted;
  bench no-checkout ruling written (matrix #3 + gate-matrix); monotonic tightenings
  landed (residue message-surface scan + system-grep canary + explicit git-log errors +
  honest banner; seed-audit target-column parser) — TEST_HONESTY PASS with executed
  mutations. Ratifier verdict on the merge: APPROVE-CONDITIONAL, receipts 1–6, all
  produced; it judged the charter edit under the OLD stricter item-7 wording and
  verified monotonicity, path-leak absence, and both engine canaries with its own
  hands. Its lantern line, verbatim: "Run-8 rewiring approved conditional on receipts
  1-6 — charter item-7 invariant adopted under completed tier-3 grant, nightly loop
  wiring cleared with placeholder-only plist verified leak-free, and all guard changes
  proven strictly monotonic by the Ratifier's own hands." One R3 execution: the
  Ratifier's first invocation failed with the exact watchdog signature (0 tools, ~6 s);
  one auto-resume recovered it — 7/7 lifetime. Its STOP #5 stands as a standing guard:
  any scheduled run that merges or pushes without a logged Ratifier verdict → bootout
  the job, PARK-TIER-3. WAVE RECEIPTS: R-a seed-audit shown · R-b routing = ls-tree
  (two independent verifiers) · R-c 40/40 + 81/81 + R5 clean on all four pushes ·
  R-d demonstrated twice (both verdicts logged with receipts) · R-e first morning
  brief delivered ≤1 page. Remaining v0.3: phase 3 (cc installer + ship commands),
  phase 4 remnants (dogfood, sandbox→tests, R3 watchdog automation in dispatch
  plumbing).

- **2026-07-15 · mission-loop run #7 — wave "self-governing gadd" (dispatch arrived
  transit-damaged; repairs reconstructed from readable sources, manifest disclosed
  in-session):** R5 RATIFIED and wired (commit-metadata scan in residue-check range
  mode, verified against a known personal-email commit; ruling #2 in the matrix).
  Stale local branches pruned. ITEM E (seed self-application, Major): payload v2
  installed — root CLAUDE.md (37 lines) + 10 folder CLAUDE.mds + `context/` (ubc
  verbatim; tooling with the operator-supplied session half) + AGENTS.md mirror +
  `bin/seed-audit.sh` + §8 ledger row. Bench 5/5: SECURITY/DATA_INTEGRITY/
  TEST_HONESTY/REGRESSION PASS round 1 (TH mutation-EXECUTED), CONTRACT_FIDELITY FAIL
  round 1 (one verbatim-fidelity blocker) → standing-ruling-#1 Fixer round (scope: the
  named file) → CF PASS round 2. RATIFIER INSTALLED (`.claude/agents/gadd-ratifier.md`).
  R-d DEMONSTRATED end-to-end: merge packet → Ratifier APPROVE-CONDITIONAL with 5
  receipts + 6 STOP conditions — it independently caught that the branch installs its
  own charter (tier-3 item 7) and refused to self-ratify without the operator's
  readable-source authorization (produced: the dispatch + the charter file's own
  install directive); its SR-8 flag ("change to the charter" vs "first install") goes
  to the retro. Its lantern line, verbatim: "A merge that installs the Ratifier's own
  charter cannot be self-ratified into main on the Ratifier's word alone — the
  deterministic gates and the operator's item-7 authorization are the receipts, and a
  degraded residue scan is a red guard, not a pass." All receipts produced; merged
  --no-ff, pushed under R5 (content+metadata clean, canary passing). QUEUED (monotonic
  tightenings from bench notes): metadata scan → commit-message surface + system-grep
  canary + honest banner wording (DI); seed-audit parser keyed to target column (DI);
  explicit git-log status check (SEC); bench-contract line "adversaries never
  checkout — `git show` only" (one adversary switched the session's branch mid-bench;
  restored, nothing lost — the run's single anomaly). PARKED ON OPERATOR: the two
  permission-layer-declined items in the Constitution state row.

- **2026-07-15 · PUBLIC HISTORY REWRITTEN (F(a) + identity, operator-ratified, receipts
  green):** one filter-branch pass from the root over all 47 commits closed three
  residue classes: (1) register-token — 10 commits carried one bare deployment token in
  LANTERN.md history, published inside the phase-2 merge because scanning was tip-only;
  (2) retired-path — 23 commits (2026-07-11→14; 12 of them ancestors of v0.2, incl. the
  root) carried the deployment-era blocker/prompts path root in installer + templates
  since v0.1; (3) identity — 10 commits authored under a personal email (a blocklisted
  name in public commit METADATA, structurally invisible to blob scans) normalized to
  the ratified noreply identity; Q7's "accepted linkage" decision is superseded — the
  linked commit no longer exists. v0.2 recreated annotated on the rewritten ancestry:
  its tree differs from the old tag's tree by EXACTLY the 4 path-scrub lines (receipt
  diff shown in-session) — byte-identity there was mathematically incompatible with the
  clean-full-history criterion, and clean won as the ratified hard requirement; main's
  tip tree IS byte-identical to pre-rewrite. Receipts: F+ sweep 11 patterns × 47 commits
  clean, canary passing; metadata scan clean, single identity across all history; stale
  run-1 branch deleted from origin; pre-rewrite history preserved ONLY on local
  `private/*` refs, never pushed; accept_authors continuity vacuously safe (check 02
  unwired on gadd until phase-4 dogfood — the future-seeded allowlist email matches the
  normalized identity; deployment repos untouched); gates 40/40 + 81/81. PERMANENT
  CAVEATS: crawler-scraped copies of pre-rewrite history plausibly exist (33 unique
  cloners in the trailing 14-day window) and are not recallable — the rewrite protects
  the canonical source going forward, it does not erase the past everywhere; "zero
  engaged users" (0 forks/stars/watchers) is the measured claim, "zero copies" is never
  claimed; orphaned pre-rewrite objects may remain SHA-reachable on GitHub until GC.
  F+ range mode proposed as ruling R5 in the night-1 retro — the evidence is this very
  incident: hand-typed pattern subsets missed what the full-blocklist sweep caught.

- **2026-07-15 · DISPATCH RECONCILED — D executed, E queued (dispatch crossed in transit
  with the run-6 execution):** the operator's superseding dispatch sequenced D (residue
  emergency) before the merge; A/B/C had already executed. Outcome mapping: D(1) achieved
  pre-push (entries reworded, never-pushed branch history scrubbed — nothing new reached
  main). Executed now: D(2) blocklist word-boundary pattern rewritten POSIX-safe
  (validated against a known-leaked historical blob AND clean HEAD), second deployment
  token present; D(3) `bin/residue-check.sh` hardened — engine canary self-test (fail-loud
  exit 2 before any "clean" can be declared) + PCRE-escape dialect lint (rejects `\b`-class
  patterns loudly); D(4) genuinely green — canary passed, both failure modes demonstrated
  live (dialect lint fired; positive hit fired). NEW FINDING → parked packet: one register
  token was ALREADY public before this session — 10 intermediate commits reachable from
  public main (and from the stale pushed run-1 branch) carry one bare token each in
  LANTERN.md history; it shipped with the phase-2 merge because the gate scanned only the
  tip, never intermediate commits. Cleanup = public-history rewrite + force-push = tier-3
  hard stop, options packet with the operator. E RATIFIED (Standard, phase 4): seed
  self-application per `audits/gadd-seed-payload.md` — queued in roadmap row with its
  binding conditions.

- **2026-07-15 · run #6 approvals EXECUTED (operator-delegated):** R1–R4 RATIFIED and
  written in: standing ruling #1 rewritten at invariant grade (scope = the files the
  verdict's blockers demonstrate failures in; convergence guard folded in); tier-floor
  line added to gate-matrix (grader edit under explicit ratification); retro cadence in
  mission-loop; R3 dispatch watchdog queued phase-4. PRE-PUSH LEAK CAUGHT: two deployment
  names in run-6 lantern entries — and the residue guard's word-boundary pattern was
  silently DEAD (`git grep -E` lacks `\b` support here; only `-P` matches — a
  fabricated-clean in the guard itself). Local-only branch history rebuilt with the lines
  scrubbed at their introduction (phase-1b commit `078894f` → `cee8f3a`; final-tree diff
  vs original = the 2 anonymized lines only); every pushed commit PCRE-verified clean.
  Merged `84f77ba` (--no-ff), post-merge gate green (parity 40/40 · fleet 81/81 · residue
  clean), pushed. Ledger pushes: first deployment `6f33ea4` pushed; second's `0fb485a`
  was already on its origin. North Star ledger caveat CLOSED — both ledgers live.
  PARKED (guard change = tier-3): switch `bin/residue-check.sh` to `git grep -P` and
  fail loud when PCRE is unavailable — a guard that cannot run never passes silently.

- **2026-07-15 · run #6 CLOSED — phase 1b bench-green (`078894f`, now `cee8f3a` after the
  pre-push scrub):** metric-parity gate
  shipped: engine + check 10 + schema block + 15-scenario/40-assertion corpus. Major-tier
  full bench 5/5 — DI PASS round 3 (4 demonstrated fabrication paths fixed: spawn-fail,
  crash-exit, typed-config silent-skip, exempt-prefix swallow), TH PASS round 2
  (eslint_disables + .d.ts exemption pinned), SECURITY/CF/REGRESSION round 1. Standing
  ruling #1 executed 3× this run (DI×2, TH×1; two disclosed interpretations: multi-file
  verdict scope, and the R1 convergence pattern observed at DI 2→2 — round granted on
  narrowing class, would PARK on a third). Fleet corpus untouched (81/81). Adoption
  notes for deployments: parity gating goes dark if source lives outside src/ (by-spec,
  flagged); any-pattern misses positional generics (spec-level, shared with parity
  source). PARKED ON OPERATOR: merge run-6 branch → main; R1–R4 ratification; pushes of
  the two governed-repo ledger commits. Deployment-side next: the first deployment adopts
  parity.gating → its 90-extension retires.

- **2026-07-15 · mission-loop run #6 (post-merge):** operator confirms merge `051c6bc` +
  post-merge gate green. **NORTH STAR FIRST MEASURED VALUE logged: escaped_rate = 0 over
  9 accepted pushes** (17 verdicts, 0 anomalies, 30 findings caught pre-acceptance) —
  with the instrument's own caveat: zero is "nothing recorded" until the ledgers exist.
  Trivial item DONE: `gadd/ESCAPED.jsonl` committed in both governed repos (first
  deployment `6f33ea4`, second `0fb485a`; pushes = operator). Packet rule made permanent (state row +
  mission-loop.md). NIGHT-1 RETRO OPEN: `audits/retro-night-1.md` (local-private) — six
  ruling-#1 executions reviewed (incl. the Fixer's evidence-based refusal, the system's
  best moment), tier-upgrade call assessed correct-but-unilateral, invocation-failure
  class documented (5/5 recovered), TH note-gaps queued. FOUR PROPOSALS R1–R4 awaiting
  ratification (convergence guard, tier-floor rule, dispatch watchdog, retro cadence).
  Next item: phase 1b (metric parity).

- **2026-07-15 · BENCH FULLY GREEN — MERGE PACKET READY:** TEST_HONESTY PASS after 6
  rounds (final two at strong tier, mutation-executed verification; its last catches
  included a flipped North-Star rate formula that survived 76/76 green assertions —
  caught hours before the first real measurement). Final bench: DATA_INTEGRITY PASS (7
  rounds) · SECURITY PASS · CONTRACT_FIDELITY PASS · REGRESSION PASS · TEST_HONESTY PASS.
  Corpus: 27 scenarios / 81 assertions, committed. Standing ruling #1 executed 6× total
  this night under the ratified per-verdict wording (all logged; first-execution +
  tier-upgrade judgment flagged for retro). MERGE PACKET: branch `mission/run-1-phase-2`,
  13 commits, tree clean — merge is the operator's button; post-merge: residue-check +
  fixture harness re-run, push, then the first fleet measurement. Remaining TH notes
  (aggregation_failed class unexercised; MINOR tally unpinned) queued as phase-4
  test-hardening candidates, not blockers.

- **2026-07-15 · run #5 CLOSED — night aggregate:** Node instrument committed (`1d01454`,
  bash deleted same commit per ratified condition). Full bench: DI PASS (round 7, after
  7 rounds total — the adversary empirically verified its own kill-list dead) · SECURITY
  PASS · CONTRACT_FIDELITY PASS · REGRESSION PASS (after vault-noise remediation it
  prescribed: 11 Obsidian files unstaged pre-commit, `.obsidian/`+`GAD/` gitignored,
  leak-probe clean) · TEST_HONESTY RED: 2 one-line assertion gaps (anomalies.total on
  non-malformed classes; north_star.clean_repos multi-clean) — **fix PARKED: standing
  ruling #1 ("ONE root-cause round per item") was already executed 2× on this item under
  a permissive per-adversary reading; a 3rd exceeds the letter. Ruling-scope reading
  needs the operator (retro item — the rider exists for exactly this).** Corpus at 25
  scenarios/68 assertions. Session anomalies: 4 subagent invocation failures, all
  recovered by direct resume. PARKED DECISIONS: (1) TH two-assertion fix + re-run,
  (2) ruling-#1 scope reading, (3) merge (HOLD until bench fully green), (4) operator
  fleet run, (5) phase 1b untouched — next run's first pick.

- **2026-07-14/15 · run #5 — Node reimpl + FIRST STANDING-RULING EXECUTION (retro-review
  flag):** executor delivered `bin/gadd-fleet.mjs` (zero-dep, bash version deleted same
  commit-to-be) + `tests/fleet-fixtures.sh` (21 scenarios/46 assertions, rounds 1–5
  corpus); mechanic verified independently (46/46, node: built-ins only, no stale refs).
  DI round 6 vs the new substrate: FAIL — 3 demonstrated JS-class blockers (`__proto__`
  key pollution in escaped_by_check; EACCES swallowed as "no gadd/" dropping the repo
  from output; symlink-alias double-count). **Standing ruling #1 executed autonomously
  for the first time** (scope = failing file ✓, Standard ✓, DI re-runs after ✓): Fixer
  closed all 3 root-cause (Object.create(null); ENOENT-only skip, other errnos → emitted
  anomalous; realpathSync dedup) + corpus extended to 24 scenarios/63 assertions incl.
  exact escaped_by_check contents (the gap that let round 6 through). DI round 7 running.
  Session anomaly: 4 subagent invocation failures tonight (harness boilerplate, 0 tool
  uses), all recovered by direct resume — morning-brief item.

- **2026-07-14 · run #4 ARBITRATION recorded + night-mode riders:** option (b) RATIFIED —
  zero-dep Node reimplementation of gadd-fleet, conditions in state row; option (c)
  rejected and ledgered ("substrate classes get reimplemented, not waived"). Riders
  implemented: standing rulings' first autonomous execution highlighted in morning brief
  + reviewed at next retro (approval-matrix template); scheduled chain checks out the
  lantern's active mission branch if launched from main pre-merge (mission-loop). RUN #5
  QUEUE: Node reimpl → 16 fixtures green → DI re-run → full bench → merge packet
  (human button). Phase 1b in parallel per park-and-continue. Run #5 executes in a fresh
  session — this one is far past the context threshold (the global stop the loop
  enforces for exactly this reason).

- **2026-07-14 · NIGHT MODE ratified (Standard, applied on mission branch):**
  mission-loop amended — tier-3/ratification are now ITEM-LEVEL PARKS (decision packet
  prepared, loop continues with next unblocked item); global stops reduced to QUEUE
  EMPTY / no-progress / context / budget / DoD. STANDING RULINGS section added to the
  approval-matrix template (pre-approved-batches tier; logged + reported, audit-after,
  revocable at retro; can never convert tier-3 hard stops), seeded with: "one root-cause
  Fixer round per item pre-approved when scope ≤ failing file, tier ≤ Standard, failed
  adversaries re-run after." Scheduled chain + morning brief documented in the loop.
  Tier-3 hard stops unchanged, day or night. PARKED ITEM under the new semantics: the
  North Star instrument awaits the substrate ruling (a: mechanical round / b RECOMMENDED:
  zero-dep Node reimplementation gated on all 16 fixtures / c: waiver — argued against)
  — decision packet = run #4 STATUS. Next unblocked ratified item: phase 1b.

- **2026-07-14 · mission-loop run #4 STOPPED — DI round 5 red; substrate diagnosis:**
  schema-admission redesign applied + verified (round-4 killer fixed: nonconformant
  records become classified per-repo anomalies, anomalous repos carry NULL counts,
  north_star sums clean repos only; docs kept truthful, 2 lines). DI round 5 (after 2
  invocation failures — G3 data points — resolved by direct resume) demonstrated: (1)
  whitelist BYPASS via concatenated multi-document JSON — `jq -e` reflects only the last
  doc, `jq -s` later splits the stream into multiple admitted records, zero anomalies;
  (2) unreadable verdicts dir fabricates clean zeros; (3) unreadable-but-existing ledger
  emits clean escaped_total=0 into north_star (null ≠ 0 violated). Notes: bash `$(cat)`
  strips NUL bytes (silent mutation before validation); dir named `*.json` misclassified;
  duplicate repo args double-count. **Architect diagnosis: the residual class is the
  bash+jq SUBSTRATE — stream semantics, NUL stripping, exit-status quirks. Options for
  arbitration: (a) mechanical round on the 3 blockers (closes these, arms race
  continues); (b) RECOMMENDED — reimplement gadd-fleet as zero-dep Node (ratchet.mjs
  precedent: whole-file JSON.parse succeeds or throws, no multi-doc ambiguity, no NUL
  stripping), acceptance = ALL 16 accumulated DI fixtures rounds 1–5 pass before DI
  re-runs; (c) accept-with-waiver — rejected by recommendation, truth-only forbids a
  known-corruptible North Star instrument.** Cap held, merge HOLD, phase 1b untouched
  (fresh context). The fixture corpus is now the instrument's de-facto spec.

- **2026-07-14 · mission-loop run #3 STOPPED — DI round 4 red, structural diagnosis:**
  root-cause fix applied + verified (verdict type guard, check-key coercion, repo-always-
  emitted fallback; all 9 prior fixtures green, fallback adversarially probed). DI then
  demonstrated two NEW paths — a stray scalar inside `findings[]` aborts aggregation and
  the fallback zeroes VALID ledger data into the north-star sum (truth 5 escaped,
  reported 2: the headline metric silently under-reports); non-array `findings` drops
  findings uncounted. **Architect diagnosis: guard-by-guard hardening loses structurally
  — the malformed-shape space is combinatorial. Proposed redesign (awaiting
  ratification): SCHEMA ADMISSION — validate every verdict against the shipped
  `verdict.schema.json` and every ledger line against `escaped.schema.json` before
  aggregation (whitelist known-good shapes, the run-all.sh validator pattern);
  non-conformant = anomaly with counts reported "unavailable", never zeros; north_star
  sums CLEAN repos only and discloses anomalous ones.** Cap discipline held: no
  self-granted round. Merge HOLD. Phase 1b not started (context). All DI rounds 1–4
  fixtures earmarked for `tests/` per the ratified "if it cost an arbitration, it's a
  regression test forever" rule.

- **2026-07-14 · mission-loop run #2 — arbitrated fixes applied, DI still red:** Fixer
  (separate instance) applied rulings 1–3, all mechanically verified: fleet verdict
  unreadable/empty anomaly guards (parse_errors + WARN, never vanished); OWNERSHIP
  template prompts-lane now a COMMENTED example (proven inert to check 02's parser;
  template prose + lv README note it); AGENTS rule 7 restored with generic examples
  ("e.g., geolocation, user images — define your product's list"). Bench re-run:
  REGRESSION PASS (all 3 branch workstreams verified; 2 notes: orphaned pre-rename files
  on re-install, schema fields unconstrained) · DATA_INTEGRITY FAIL round 3 with a NEW
  3-blocker set naming the ROOT CAUSE — the per-repo aggregation jq fails opaque on any
  structurally-unexpected input (non-object verdict files, non-string `check` values)
  and the empty `repo_obj` is never checked, silently erasing a repo from the rollup.
  Diagnosis: rounds 1–2 patched instances of one class; the class-closer is the
  `repo_obj` emptiness fallback + 2 type guards, one mechanical round. NOT self-granted —
  awaiting ratification. Merge still HOLD. Phase 1b deferred to run #3 (context budget).

- **2026-07-14 · mission-loop run #1 STOPPED — arbitration at cap:** bench round 2:
  CONTRACT_FIDELITY PASS · DATA_INTEGRITY FAIL (new blocker: unreadable/empty verdict
  file silently dropped, uncounted — `gadd-fleet.sh` verdict loop lacks the readability
  guard the ledger loop now has) · REGRESSION FAIL (phase-2 deliverables regression-clean;
  both blockers hit the parallel residue-sweep bundle: inert `{{AGENT_PROMPTS_DIR}}/*`
  glob shipped as enforcement in the OWNERSHIP template; AGENTS template rule-7 guard
  narrowed). 2-round cap consumed → surviving blockers to the human. Phase-2 work
  committed on `mission/run-1-phase-2` (residue files left uncommitted for their owning
  session; install.sh entangled, committed with attribution). Merge = tier-3 = human.
  SURVIVING BLOCKERS awaiting arbitration: (1) fleet verdict-readability guard,
  (2) inert placeholder glob, (3) rule-7 narrowing — options + recommendation in the
  run #1 STATUS block.
- **2026-07-14 · Blocker-notes lane renamed (Standard, ratified — residue follow-up):**
  the deployment-era blocker-notes path → `gadd/lv-blockers/`, consolidating gadd's
  entire target-repo footprint under the `gadd/` namespace it already owns (installer +
  repair template updated; the repair template now lands in `gadd/`). Existing
  deployments keep their local convention (deployment-owned); new installs get the
  neutral path. The retired path root added to the local residue blocklist so the guard
  enforces the retirement. Junk brace-expansion directory at repo root removed (empty,
  untracked).
- **2026-07-14 · mission-loop run #1 — phase 2 executed (Standard):** North Star
  instrument built on branch `mission/run-1-phase-2` by dispatched executor (Director
  wrote no production code): `gadd/ESCAPED.jsonl` per-repo ledger + escaped schema +
  `bin/gadd-fleet.sh` fleet aggregation (local-only output) + `docs/measurement.md`.
  Deterministic gate: mechanic-verified independently, 9/9 assertions + edge cases, zero
  disk writes. Bench round 1 (4 triggered adversaries, isolated): SECURITY PASS ·
  DATA_INTEGRITY FAIL (2 real blockers: non-object ledger line silently dropped a whole
  repo from the rollup; unreadable ledger read as healthy zero) · CONTRACT_FIDELITY FAIL
  (README/lantern done-pending contradiction) · REGRESSION invocation failed (no verdict
  = fail-closed, re-run). Fixer applied all three; round 2 re-ran only failed adversaries.
- **2026-07-14 · RESIDUE SWEEP (Standard, ratified — closes audit contradiction C6):**
  private names removed from tracked files: the v0.2 RETRO entry below now uses the
  anonymous register; `templates/OWNERSHIP.md` carries a `{{AGENT_PROMPTS_DIR}}/*`
  placeholder lane instead of a deployment's real path; `templates/AGENTS.md` rule 7
  generalized to domain-sensitive data. Recurrence guard: release audits now run
  `bin/residue-check.sh`, which greps tracked files against the local, gitignored
  `audits/residue-blocklist.txt` (absent blocklist degrades to a notice — committing it
  would leak the very names it protects). **STANDING RULE: public lantern entries use
  the deployment-anonymous register; private names only ever appear in local-private
  audits.**
- **2026-07-14 · v0.3 PHASE 1 CLOSED (operator-verified cross-repo state):** the human
  push step is done — migration commits, gadd accept, and RED_TEAM tier mapping are live
  on the first deployment's origin (tip `6b25ef5`); the gadd-ratchet workflow runs on its
  pushes. **Coverage proxy 0→1 — first North-Star proxy movement of the mission.** Phases
  1b (metric parity) + 2 (escaped-regression ledger + aggregation) are unblocked against
  live verdict data and queued for the next /mission-loop run.
- **2026-07-14 · Repair manifest accepted, wrinkles fixed (Trivial, one commit):** zero
  vetoes on the reconstruction repairs; union-reconstruction logged in the rejection
  ledger as the standard response to paste truncation. Wrinkles: mission-loop title now
  `/mission-loop`; audit report path versioned (`audits/objective-audit-v{N}.md`, never
  overwrite); scope-boundary bracket defaults to REPO-ONLY when unfilled. Follow-up
  RATIFIED as Standard, scheduled with phase 3: ship both commands in
  `adapters/cc/commands/` so deployments inherit them at install time.
- **2026-07-14 · Commands installed (Trivial, ratified inline):** `/mission-loop` (the
  run-until-done human-gated Mission Driver) + `/objective-audit` (the Architect audit it
  bootstraps from) live at `.claude/commands/`. Seeds v0.3 phase-4 dogfooding — gadd now
  has its own `.claude/`. Paste-truncation repairs to both documents disclosed in the
  session report (reconstructed from the two in-session pastes; no design changes). The
  audit was NOT re-run: objective function is RATIFIED, so the loop's bootstrap proceeds.
- **2026-07-14 · OQ5 governance pack (pulled forward, parallel to phase 2):**
  `templates/ORCHESTRATION.md` (roles × model PLACEHOLDERS; fallback-chain rule: workers
  may fall back down, graders never do) + `templates/APPROVAL-MATRIX.md` (autonomous /
  pre-approved / tier-3-human, mapped to spec §6 tiers). `/gadd-loop` gains the autonomy
  contract: end-to-end on work branches, no permission-seeking between steps, hard stops
  at tier-3 (merge/deploy/graders/baseline/secrets always human). Deployment side: Tier
  lines added to the reference deployment's five adversaries so the redteam workflow maps
  structural→cheap / judgment→strong instead of running everything strong.
- **2026-07-14 · v0.3 PHASE 1 executed (OQ1–OQ7 ratified):** standing rule OQ6 written into
  spec preamble + CONTRIBUTING. Wart fixed: installer/quickstart now do the two-commit
  install-then-accept dance (OQ1). Extension mechanism: run-all executes `[0-9]*.sh` so a
  deployment ratchet can gate as `90-*.sh`. First deployment migrated onto upstream
  (replace-with-extension per OQ2): its richer ratchet stays gating as an extension, its
  tuned bench and OWNERSHIP preserved (+ machine-readable gadd-governed block added),
  baseline metrics measured not defaulted, local full-suite PASS. **Live data found two
  latent upstream bugs in one run** — check 07 measured total LOC not max; the schema
  validator broke on any verdict with findings (sandbox had only covered finding-free
  verdicts) — both fixed + regression-tested; release-audit lesson logged. Phase 1b
  started: `docs/metric-parity.md` is the parity spec (deployment's gating metrics become
  upstream targets). Deployment push = operator step (deploy-adjacent, tier-3 human).

- **2026-07-14 · v0.2 RETRO:** `audits/retro-v0.2.md` (local-private). Key lessons: name
  the decision not the output ("verdict" ambiguity); constants cited not restated; docs
  written as intention read as claims; publication review must include tag/commit
  messages; release audits keep a functional sandbox pass. Guards: G1 HOLDS, G2 HARDENED,
  G5 PUBLISHED; G3 unmeasured, G4 red (v0.3). v0.3 sequencing hypothesis CONFIRMED with
  two amendments (wart→phase 1; the reference deployment migrates replace-with-extension
  so its ratchet never loosens); horizon proposed ≈2026-08-18 at 5 op-h/wk, milestones gate. 7 open questions
  (OQ1–OQ7) awaiting ratification — v0.3 does not start until then.
- **2026-07-14 · PUBLICATION (option b, ratified):** preconditions verified — origin/main
  at `f66d686`; all 11 rewritten commits proven local-only (both range directions checked).
  Full pre-rewrite history preserved on local branch `private/audits` (`3904463`). main
  rewritten: objective-audit commit dropped; release-audit file stripped from the tag
  commit (lantern half kept); `audits/` gitignored; both reports remain on disk as
  untracked local copies. Tag `v0.2` recreated annotated on the rewritten tip; main +
  tag pushed. Q7 DECIDED (delegated): existing `f66d686` linkage accepted as intentional;
  repo-local identity switched to `20259778+sirkapu@users.noreply.github.com` for all
  future commits; true pseudonym separation would need a ratified public-history rewrite
  — cheapest while external users = 0. **STANDING RULE: audits are local/private by
  default; public versions only ever as gate-passed redactions.**
- **2026-07-14 · v0.2 TAGGED:** release audit green (`audits/release-audit-v0.2.md`) —
  all 7 ratified items verified, forged-accept attack caught in sandbox, scripts
  syntax-clean, consistency sweep clean. Objective function ratified (Q1–Q6, Q8); Q7
  UNANSWERED (placeholder returned — INFO, no action). Tag `v0.2` created locally.
  **PUSH BLOCKED pending decision:** main carries `audits/` reports whose own sharing
  annex marks sections SENSITIVE — publishing to the public repo needs an explicit call
  (options presented in session report-back).
- **2026-07-14 · v0.2 item 11 (Goodhart gap closed):** `gadd: accept` exception hardened
  in check 02 — accept commits must ALSO be authored by an email in the ACCEPTED
  baseline's `accept_authors` allowlist (read from GADD_BASE, not the working tree, so an
  agent cannot self-enroll in the same push). Installer seeds the list with the
  installer's git email; legacy baselines get subject-only + a MINOR nudge.
- **2026-07-14 · v0.2 item 9 (orphans un-orphaned):** schema validation wired into
  `run-all.sh` — BASELINE.json checked against `baseline.schema.json` before the suite,
  the emitted verdict checked against `verdict.schema.json` after (jq validator driven by
  the schema files; required fields + enums); nonconformant verdict fails the job even on
  PASS. Installer now ships `spec/schemas/` → `.gadd/schemas/`; missing schemas degrade to
  a notice. `example-verdict.json` referenced from spec §5.
- **2026-07-14 · v0.2 item 12:** Trivial/Standard/Major task tiers defined in spec §6
  (proportionality: how much gate a task buys; grader changes always Major); gate-matrix
  dispatch now references the tiers instead of assuming them. Also un-orphans
  `docs/example-verdict.json` via a spec §5 reference (part of item 9).
- **2026-07-14 · v0.2 item 10a (C4 half-closed):** spec invariant 2 narrowed to the two
  wired ratchet metrics (skipped tests, max file LOC); ts_errors/test_files/lint named as
  unwired v0.3 work instead of implied capability.
- **2026-07-14 · v0.2 item 5 + Q1 (C3 half-closed):** README roadmap now honest — cc
  adapter marked in progress (installer still refuses `--adapter=cc`; fixing it is v0.3)
  — and reordered internal-first per Q1: OSS milestones gate on ≥1 upstream-governed repo
  with verdict data.
- **2026-07-14 · v0.2 item 4 (C2 closed):** repair cap unified at 2 rounds everywhere —
  `gadd-loop.md` step 6, `gate-matrix.md` protocol 5, cc README; spec invariant 6 was
  already 2 and is now cited at each site.
- **2026-07-14 · v0.2 item 3 (C1 closed):** ratified sentence added to spec invariant 3 —
  "Acceptance is decided only by deterministic gates; RED_TEAM verdicts gate dispatch of
  repair work in-loop, never acceptance." `gadd-loop.md` steps 4/7, `gate-matrix.md`
  protocol 3, and `gadd-redteam.yml` aligned to repair-dispatch semantics.

- **2026-07-14 · Architect deep audit (read-only):** full-repo goal reconstruction +
  objective-function proposal written to `audits/objective-audit-v1.md` (committed). Verdict:
  goal clear in function, unratified in audience; North Star (escaped-regression rate)
  UNMEASURED; 6 contradictions tabled (C1 LLM-verdict philosophy split is the deepest);
  secrets scan clean. Nothing modified beyond the report + this log line. NEXT: ratification
  conversation — 8 open questions in report §6; action plan §5 proposed, not executed.
- **2026-07-14 · RED_TEAM de-collapse:** v0.1 shipped `adapters/cc/agents/gadd-redteam.md`
  as ONE agent role-playing the 5-adversary bench (lv's `redteam.sh` had the same collapse
  in a single prompt), contradicting spec §3 "adversaries in parallel". Split into
  `RED_TEAM/` per-adversary definitions + isolated parallel dispatch in both adapters,
  models mapped per the Phase 0 orchestration (structural→cheap, judgment→strong). The
  ambiguity is closed in spec §3 (independence is now a spec concern); lesson logged in
  `docs/rejection-ledger.md`.
- **2026-07-11 · v0.1:** spec + lv adapter + cc adapter (`f66d686`).
