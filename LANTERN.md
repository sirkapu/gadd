# 🏮 Lantern — gadd state ledger

Live state snapshot for work on gadd itself. Read at session start; update before ending
a session or handing off context. This file is only ever NOW — history lives in the log
below (append-only) and in git.

## Current state

| Field | Value |
|---|---|
| Version | v0.2 — tagged and pushed to origin (publication option b: audits local-private, main rewritten pre-push) |
| Objective function | RATIFIED 2026-07-14: maximize escaped-regression catches across governed repos (proxy until instrumented: upstream-governed-repo coverage × verdicts retained), subject to guards G1–G5 (`audits/objective-audit-v1.md` §3). Internal-first; OSS milestones gate on ≥1 upstream-governed repo |
| Adapters | lv (boundary) shipped · cc (in-loop) in progress — installer + blocking CI/hooks are v0.3 |
| RED_TEAM | Bench split into `RED_TEAM/` — one definition file per adversary (role, attack surface, pass criteria, output contract) + `gate-matrix.md`. Gate runners dispatch each adversary as its OWN isolated invocation, in parallel (cc: five `gadd-rt-*` subagents; lv: five independent API calls). Adversaries never see each other's verdicts. Models: structural (CONTRACT_FIDELITY, TEST_HONESTY) → cheap tier (haiku); judgment (SECURITY, DATA_INTEGRITY, REGRESSION) → strong tier (opus) |
| Protocol invariants | VERDICT + max 3 blockers per adversary · re-run only failed adversaries on the new diff · 2-round cap (spec inv. 6) · Architect arbitrates at the cap |
| Graders | `RED_TEAM/**` is grader territory — executors and the Fixer never edit it |
| Roadmap next | v0.3 (horizon set at v0.2 retro): measurement loop (escaped-regression ledger + verdict aggregation) · first upstream-governed repo · cc installer · dogfood gadd on gadd · ts_errors/test_files/lint metrics · then `gadd-accept` bot, Cursor/Replit adapters |

## Log (append-only, newest first)

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
