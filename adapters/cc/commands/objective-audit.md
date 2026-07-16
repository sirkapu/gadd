# Command — Architect Deep Audit: Goal Reconstruction & Objective Function

**Model gate:** this is an Architect run. Verify you are Claude Fable 5 at max effort (`/model`); if not, stop and say so — do not run this on a lesser tier.

**Prime directive: READ-ONLY.** This entire run modifies nothing — no edits, no fixes, no cleanup, no lantern changes beyond logging this audit session. Your only write is the findings report to `audits/objective-audit-v{N}.md`, where N is the next free version — never overwrite a prior report. Anything broken you find gets *reported*, not repaired. Fixes come later, ratified.

**Scope boundary:** the audit's subject is THIS repo. Reading outside it (sibling repos, other directories on the machine) is allowed ONLY if the operator grants it here: [OUT-OF-REPO READS: allowed / repo-only]. If allowed, every out-of-repo fact must be cited as out-of-repo evidence and its sections marked SENSITIVE in the sharing annex by default. If repo-only, references to external paths found inside the repo are reported as findings, never followed. If the bracket is unfilled at invocation, the default is REPO-ONLY; out-of-repo reads require an explicit per-run grant in the invocation message.

**Why this run exists:** before optimizing anything, we need three truths established with evidence: (1) what this repo actually IS, (2) what it is FOR, and (3) what function we should be maximizing — stated precisely enough that every future task can be judged by whether it moves that function. ultrathink throughout; every claim in your report must cite a file path, commit, or command output. No assumptions presented as findings.

**Session budget:** respect the ~40% context threshold. If the repo is too large for one pass, write the report incrementally per stage and hand off through the lantern — a fresh session resumes from the partial report, never from scratch.

---

## Stage 1 — Total Comprehension (what IS this repo)

1. **Full inventory:** walk the entire tree. Classify every file: framework / mission data / external-facing artifact / generated-regenerable / scratch / orphan (unreferenced from any CLAUDE.md, README, or contract). Note size and last-substantive-change date per area.
2. **Architecture as-is:** map the actual layer structure (root CLAUDE.md, imports, nested contexts, agents, RED_TEAM, scripts, pipelines) — as it EXISTS, not as documents claim. Where docs and reality diverge, record both sides verbatim.
3. **Git archaeology:** read the history — phases of work, conventions used and abandoned, velocity pattern (when was real progress made, when did work stall), and a secrets/PII scan across full history (flag with severity; do not remediate).
4. **State reality:** what does the lantern claim vs. what does the tree evidence? What's genuinely in-flight, what's abandoned-but-open, what's done-but-unmarked?

## Stage 2 — Goal Reconstruction (what is this repo FOR)

5. **Stated goal(s):** collect every goal statement across the repo — specs, README, briefs, lantern, phase contracts, commit messages. Quote each with its source. If they contradict each other, table the contradictions; do not harmonize them silently.
6. **Revealed goal:** independent of what's written, what does the *work itself* optimize? Where did the commits, the artifacts, and the effort actually go? The gap between stated and revealed goal is one of the most valuable findings this audit can produce.
7. **Goal verdict:** one of three — (a) goal is clear and consistent (quote it), (b) goal exists but is fuzzy/contradictory (propose the sharpened version, with the specific TBDs I must answer), (c) no real goal-spec exists (reconstruct 2–3 candidate goals from evidence, ranked, with what each would imply). Never invent a goal and present it as found.

## Stage 3 — Objective Function (what should we maximize)

8. **Derive and propose, for my ratification:**
   - **North Star:** the single metric that best captures the goal's real success (outcome, not output — "commissions collected," not "posts published"). State its current measurable value from repo evidence, or state that it's unmeasured (itself a top finding).
   - **Guard metrics (constraints):** what must NOT degrade while maximizing the North Star — quality ratchet signals, guardrail compliance, freshness, trust/credibility assets. The objective function is: *maximize North Star subject to guards holding.*
   - **Goodhart pairing:** for the North Star and each guard, name the counter-metric that catches gaming it (every target creates its own distortion; pair them at design time).
   - **Vanity list:** metrics present or implied in the repo that do NOT belong in the objective function, named explicitly so no future session optimizes them.
   - **Definition of done / horizon:** what value of the North Star, by when, would close the current mission or milestone.

## Stage 4 — Gap Analysis (what stands between here and the objective)

9. **Alignment sort:** classify every significant asset and workstream as advancing the objective / inert / actively working against it — with one line of evidence each.
10. **Framework health (light gap table):** context layering + thin root, lantern + session lifecycle, orchestration + fallback, RED_TEAM independence (separate contexts per adversary — verify implementation, not just docs), approval matrix, proportionality, metrics wiring, rejection ledger: present / partial / absent / drifted.
11. **Binding constraints:** the 2–3 bottlenecks that most limit progress toward the North Star right now (they may be missing data, an unbuilt loop, an unratified decision, or a human input only I can give — say which).

## Stage 5 — Findings Report

Write `audits/objective-audit-v{N}.md` (the next free version), structured for sharing:

1. **Executive summary** — ten lines max: what this repo is, its real state, the proposed objective function, the single highest-leverage move.
2. **Goal:** stated / revealed / verdict (Stage 2), with the contradictions table.
3. **Proposed objective function** (Stage 3) — presented as a proposal awaiting my ratification, with every TBD I must answer listed as direct questions.
4. **Evidence tables** (Stages 1 & 4): inventory summary, doc-vs-reality divergences, alignment sort, framework gap table, secrets findings.
5. **Prioritized action plan:** leverage-ordered, each item tiered per the proportionality rule (Trivial/Standard/Major), each traced to the objective function — **proposed, not executed.** Nothing in this plan runs until I ratify it item by item.
6. **Open questions for the human** — everything that blocks ratification, phrased so I can answer inline.
7. **Sharing annex:** mark each section SAFE-TO-SHARE or SENSITIVE (contains strategy, PII, partners, or credentials-adjacent findings), so the report can be shown externally without a second sanitization pass.

**Exit:** report committed, lantern logs the audit session, nothing else touched. Then stop and wait — the ratification conversation is the next turn, not yours to skip.
