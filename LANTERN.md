# 🏮 Lantern — gadd state ledger

Live state snapshot for work on gadd itself. Read at session start; update before ending
a session or handing off context. This file is only ever NOW — history lives in the log
below (append-only) and in git.

## Current state

| Field | Value |
|---|---|
| Version | v0.2 + v0.3 phase 1 CLOSED (2026-07-14, incl. the human push step) — next: /mission-loop on phases 1b + 2 |
| Coverage proxy | **1** — operator-verified 2026-07-14: first deployment live on upstream gadd (its origin tip `6b25ef5`; the gadd-ratchet workflow runs on its pushes) |
| North Star instrument | WIRED (phase 2, mission-loop run #1, branch `mission/run-1-phase-2`): per-repo `gadd/ESCAPED.jsonl` ledger + `spec/schemas/escaped.schema.json` + `bin/gadd-fleet.sh` aggregation (output local-only). First measurement pending live data + operator's first fleet run — until then the North Star reads "unmeasured" honestly |
| Objective function | RATIFIED 2026-07-14: maximize escaped-regression catches across governed repos (proxy until instrumented: upstream-governed-repo coverage × verdicts retained), subject to guards G1–G5 (`audits/objective-audit-v1.md` §3). Internal-first; OSS milestones gate on ≥1 upstream-governed repo |
| Adapters | lv (boundary) shipped · cc (in-loop) in progress — installer + blocking CI/hooks are v0.3 |
| RED_TEAM | Bench split into `RED_TEAM/` — one definition file per adversary (role, attack surface, pass criteria, output contract) + `gate-matrix.md`. Gate runners dispatch each adversary as its OWN isolated invocation, in parallel (cc: five `gadd-rt-*` subagents; lv: five independent API calls). Adversaries never see each other's verdicts. Models: structural (CONTRACT_FIDELITY, TEST_HONESTY) → cheap tier (haiku); judgment (SECURITY, DATA_INTEGRITY, REGRESSION) → strong tier (opus) |
| Protocol invariants | VERDICT + max 3 blockers per adversary · re-run only failed adversaries on the new diff · 2-round cap (spec inv. 6) · Architect arbitrates at the cap |
| Graders | `RED_TEAM/**` is grader territory — executors and the Fixer never edit it |
| Roadmap next | QUEUED for next /mission-loop: phase 1b (metric parity per `docs/metric-parity.md`) · then phase 3 (cc installer; ship /mission-loop + /objective-audit in `adapters/cc/commands/`) · phase 4 (dogfood, sandbox→`tests/`) · later: `gadd-accept` bot, Cursor/Replit adapters |

## Log (append-only, newest first)

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
