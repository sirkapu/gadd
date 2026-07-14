# /mission-loop — Mission Driver (run-until-done, human-gated)

**What this is:** the autonomous driver for a governed repo (GADD or ACDD). Each run advances the mission toward the **ratified objective function** as far as it can, and stops ONLY at a defined stop condition — never out of confusion, never past a human gate. "Until done" is achieved by relaunching this loop (manually or scheduled) until the Definition of Done is *measured*, not declared. Lives at `.claude/commands/mission-loop.md`; runnable interactively or scheduled: `claude -p "$(cat .claude/commands/mission-loop.md)"`.

**Session role:** Director. Execute per the repo's orchestration table — dispatch executors/mechanics on their pinned models, bench per RED_TEAM contract; the Director plans, dispatches, arbitrates, and updates state. The Director writes no production code.

---

## Iteration 0 — Bootstrap (every run)

1. Read root `CLAUDE.md` + lantern. Declare this session in the lantern: `mission-loop run #N`.
2. **Objective check:** does a ratified objective function exist (North Star + guards + DoD, marked RATIFIED)?
   - **NO →** run the Architect Objective Audit (per `.claude/commands/objective-audit.md`, honoring its READ-ONLY and scope-boundary rules), write the report, and **STOP: AWAITING RATIFICATION.** The loop never invents or self-ratifies its own objective.
   - **YES →** proceed.
3. **Plan check:** is there a ratified action plan / phase contract with remaining items? If the plan is exhausted but DoD is unmet, draft the next plan increment traced to the objective function and **STOP: AWAITING RATIFICATION.** The loop executes ratified scope; it proposes beyond it, never assumes.

## Iteration cycle (repeat until a stop condition fires)

1. **Pick:** the highest-leverage unblocked item from the ratified plan (leverage = objective-function trace; ties broken by unblocking-power).
2. **Declare tier** (Trivial / Standard / Major) in the item's lantern entry.
3. **Execute** per the build loop: spec per tier → dispatch executor(s) → deterministic gate → adversarial bench (if tiered) → Fixer, repair cap 2 → verdict.
4. **Record:** lantern update, conventional commit(s) on a branch, metrics touched (which guard/North-Star proxy moved, with numbers).
5. **Measure:** objective-function delta this iteration. An iteration that moved no metric and unblocked nothing counts as a no-progress strike.
6. **Check stop conditions** (below). None fired → next iteration.

## Stop conditions — the ONLY legitimate exits

On ANY of these: write the handoff (lantern + one-paragraph state), emit the STATUS block, end the session.

1. **TIER-3 REACHED** — the next action is a merge to main, deploy, publish/send, spend, schema migration on real data, or anything under the approval matrix's human tier. The loop prepares everything up to the button and stops. *Autonomy produces candidates; humans accept.*
2. **RATIFICATION NEEDED** — the work requires a spec change, a grader/gate/baseline change (always Major, never self-served), or exceeds ratified plan scope.
3. **NO-PROGRESS (anti-thrash)** — two consecutive no-progress strikes. Stop and escalate with a diagnosis; grinding the same wall burns budget and hides the real blocker.
4. **CONTEXT THRESHOLD** — ~40% context used. Hand off; the next run resumes from the lantern with full quality. One mission, many sessions, zero dumb-zone work.
5. **TASK BUDGET** — default cap: 5 completed items per run (override per repo). Bounded runs keep each session reviewable.
6. **DoD CANDIDATE** — the North Star, *measured by its instrument*, meets the ratified Definition of Done. Prepare the closure report (evidence, metrics history, guard status) and **STOP: AWAITING CLOSURE RATIFICATION.** The loop never declares its own victory — Goodhart applies to the loop itself, so "done" is verified against the counter-metrics too.

## STATUS block (mandatory, last output of every run)

```
MISSION-LOOP RUN #N — [date]
Objective: [North Star @ current value → DoD target]
Completed this run: [items, tiers, commits]
Metrics moved: [deltas with guard status]
Stopped because: [stop condition #]
YOUR MOVE: [the exact human action(s), phrased for one-tap decisions —
  approve/reject items, push X, answer Q, or "relaunch the loop"]
```

## Standing safety rules (inherit; restated because the loop runs unattended)

- Approval matrix and separation of powers apply in full: no self-enrollment in allowlists, no grader edits, no test-weakening, adversaries isolated per the bench contract.
- All work on branches; main is human territory.
- Truth-only in the STATUS block: unmeasured is reported as unmeasured; a red guard is reported red. The loop's credibility is the operator's ability to trust the block without re-auditing it.
- Scheduled runs (cron/launchd) are allowed for repos whose next-work is autonomous-tier; a run that immediately hits a human gate simply reports and exits — that's the system working, not failing.
