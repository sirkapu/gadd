# /mission-loop — Mission Driver (run-until-done, human-gated)

**What this is:** the autonomous driver for a governed repo (GADD or ACDD). Each run advances the mission toward the **ratified objective function** as far as it can, and stops ONLY at a defined stop condition — never out of confusion, never past a human gate. "Until done" is achieved by relaunching this loop (manually or scheduled) until the Definition of Done is *measured*, not declared. Lives at `.claude/commands/mission-loop.md`; runnable interactively or scheduled: `claude -p "$(cat .claude/commands/mission-loop.md)"`.

**Session role:** Director. Execute per the repo's orchestration table — dispatch executors/mechanics on their pinned models, bench per RED_TEAM contract; the Director plans, dispatches, arbitrates, and updates state. The Director writes no production code.

---

## Iteration 0 — Bootstrap (every run)

0. **Single-instance lock (ratified 2026-07-15, LEASE-BASED since run-30 A3
   2026-07-17):** run `bin/loop-lock.sh acquire` BEFORE anything else. If it exits 3
   (a live loop holds the lock) OR 4 (lost a stale-reclaim race — fail closed, same
   treatment), log one line — "mission loop already active — no-op exit" — and end
   the session cleanly: never run two loops on one tree. Staleness is LEASE AGE PAST
   TTL (default 3600s, `GADD_LOOP_LEASE_TTL` overridable) — NEVER pid-death alone;
   run `bin/loop-lock.sh refresh <pid>` (the pid printed by acquire) at every phase
   boundary of this loop to keep the lease alive; exit 5 means the lock was
   lost/reclaimed — treat it as a lost lock, never retry blind (a long-running loop
   that skips refresh risks a legitimate reclaim by a newcomer once the lease ages
   out). Release with `bin/loop-lock.sh release`
   after the final STATUS block / brief delivery.
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
6. **Check parks and stop conditions** (below). Every iteration first runs `bin/loop-heartbeat.sh check` (deterministic context-ceiling enforcement, ratified SPEED AUDIT v1 P1, 2026-07-16): exit 3 fires stop condition 3 (CONTEXT THRESHOLD) mechanically — measured, not felt; exit 2 (cannot measure) is treated the same as exit 3, fail-closed. Item parked → pick the next unblocked item. No global stop fired → next iteration.

## Packet routing — the Ratifier (constitutional amendment, operator-ratified 2026-07-15)

The operator is no longer the per-packet relay. When an item reaches a decision packet —
arbitration at repair-cap, ratification-needed, merge/push candidates, anything the old
rules parked — the Director routes the packet to the **Ratifier** (`gadd-ratifier`
agent): an isolated context, separate from every executor, that applies standing rulings
SR-1..SR-8 and returns APPROVE / APPROVE-CONDITIONAL / REJECT / PARK-TIER-3. Verdicts
are logged in the lantern with the receipts they named. Standing rulings in the approval
matrix still pre-approve their patterns directly (log, don't ask).

**Only the charter's tier-3 list parks for the operator** (exhaustive; per the Ratifier
charter in [.claude/agents/gadd-ratifier.md](../agents/gadd-ratifier.md)):
(1) public-history rewrites / force-push to a public ref; (2) identity and pseudonym
changes; (3) secrets and credentials; (4) money; (5) launch and anything facing external
humans (publication, outreach, external-facing products); (6) grader / gate / baseline
modifications beyond monotonic ratchet-tightening; (7) charter changes after its initial
ratified installation. Everything else flows through the Ratifier without the operator.

Parked tier-3 items still follow night mode: the ITEM parks with its packet prepared,
and the loop continues with the next unblocked ratified item.

## Stop conditions — the ONLY legitimate global exits

On ANY of these: write the handoff (lantern + one-paragraph state; regenerate BRIEF.md to this run's state and run `bin/brief-check.sh` — a FAIL blocks the close), emit the STATUS block, end the session.

1. **QUEUE EMPTY** — no unblocked ratified work remains (everything is done or parked awaiting the human).
2. **NO-PROGRESS (anti-thrash)** — two consecutive no-progress strikes. Stop and escalate with a diagnosis; grinding the same wall burns budget and hides the real blocker.
3. **CONTEXT THRESHOLD** — ~40% context used. Hand off; the next run resumes from the lantern with full quality. One mission, many sessions, zero dumb-zone work.
4. **TASK BUDGET** — default cap: 5 completed items per run (override per repo). Bounded runs keep each session reviewable.
5. **DoD CANDIDATE** — the North Star, *measured by its instrument*, meets the ratified Definition of Done. Prepare the closure report (evidence, metrics history, guard status) and **STOP: AWAITING CLOSURE RATIFICATION.** The loop never declares its own victory — Goodhart applies to the loop itself, so "done" is verified against the counter-metrics too.

## Scheduled chain (night mode)

The loop may be relaunched on a schedule (launchd/cron): `claude -p "$(cat .claude/commands/mission-loop.md)"`. Each run resumes from the lantern; runs are bounded by the existing global stops (task budget, context threshold, no-progress). The chain reads this loop from the checked-out working tree: if a scheduled run finds itself on the default branch while the lantern names an active mission branch pre-merge, it checks out that branch FIRST, then proceeds. Tier-3 hard stops never widen — merge/push/deploy/graders/baselines/secrets stay human, day or night. A scheduled run that finds only parked work reports QUEUE EMPTY and exits — that is the system working, not failing.

**Retro cadence (ratified 2026-07-15):** every scheduled-chain night ends with a night
retro — local-private, in `audits/` — reviewing all standing-ruling executions, Director
judgment calls, and session anomalies; its proposals surface for ratification in the next
morning brief.

## STATUS block (mandatory, last output of every run)

```
MISSION-LOOP RUN #N — [date]
Objective: [North Star @ current value → DoD target]
Completed this run: [items, tiers, commits]
Parked this run: [item → park reason → one-tap decision]
Metrics moved: [deltas with guard status]
Standing rulings executed: [ruling → item → outcome, or "none"]
Stopped because: [global stop condition #]
YOUR MOVE: [the exact human action(s), phrased for one-tap decisions —
  approve/reject items, answer Q, or "relaunch the loop"]
```

**Packet rule (permanent, ratified 2026-07-15):** YOUR MOVE never contains terminal
commands — packets end in "reply approve and I execute"; execution is the loop's job on
approval. The operator may reply in plain language, any language (incl. Spanish); the
loop translates the reply to protocol.

**Morning brief:** when a run detects prior same-night runs in the lantern, its final
STATUS aggregates the whole night instead: merge-ready branches, all parked decisions
(one-tap each), metrics deltas, anomalies, and every standing-ruling execution.

**Brief delivery (charter amendment, operator-ratified 2026-07-15):** every run that
emits a brief (1) WRITES it to `BRIEF.md` at the repo root — gitignored, local-only,
overwritten each run; the fixed, predictable file and the source of truth — and then
(2) ATTEMPTS Slack delivery via the Slack MCP: DM to the operator — the concrete user
id is recorded ONLY in the local-private charter (never in tracked files; resolve live
via the Slack user search if absent); if a dedicated brief channel exists in this
deployment's Slack workspace at send time (gadd's own convention names it
`#gadd-brief`; a deployment may wire its own name), prefer it. Slack delivery is
best-effort: headless/scheduled runs may lack the interactively-authenticated MCP; on
any failure the file remains the source of truth and the failure is noted in the NEXT
brief. Truth-only caveat: messages sent from the operator's own Slack session do not
push-notify their phone (Slack suppresses own-message notifications) — the DM/channel
is a persistent visible surface, not a pager.

## Standing safety rules (inherit; restated because the loop runs unattended)

- Approval matrix and separation of powers apply in full: no self-enrollment in allowlists, no grader edits, no test-weakening, adversaries isolated per the bench contract.
- All work on branches; main is human territory.
- Truth-only in the STATUS block: unmeasured is reported as unmeasured; a red guard is reported red. The loop's credibility is the operator's ability to trust the block without re-auditing it.
- Scheduled runs (cron/launchd) are allowed for repos whose next-work is autonomous-tier; a run that immediately hits a human gate simply reports and exits — that's the system working, not failing.
