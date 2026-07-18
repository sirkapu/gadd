# RED_TEAM Gate Matrix

Adversarial review layer. Runs AFTER the deterministic gate passes — deterministic checks
are free, adversaries cost tokens, humans review what survives. This file is the bench
config: who runs, on what model tier, under which protocol.

## The bench

One definition file per adversary in this directory. Dispatch scales with the task tier
(spec §6): Trivial skips the bench, Standard runs the adversaries the diff triggers, Major
runs all five. A deployment may tune the trigger column in its own copy of this matrix —
but the always-on triggers can never be skipped, whatever the tier.

| Adversary | Tier | Always-on trigger (never skip when…) |
|---|---|---|
| `SECURITY.md` | judgment | diff touches auth, input handling, secrets, payments, or migrations |
| `DATA_INTEGRITY.md` | judgment | diff touches migrations, schema, or persistence code |
| `CONTRACT_FIDELITY.md` | structural | diff touches the repo's contract paths (`src/contracts/**` or per OWNERSHIP.md) |
| `TEST_HONESTY.md` | structural | diff adds, changes, or deletes any test |
| `REGRESSION.md` | judgment | diff touches files outside the task's declared scope |

## Isolation rule

**One adversary = one isolated invocation.** The gate runner launches each triggered
adversary as its own subagent/API call, in parallel, each with an independent context.
Adversaries never see — and never ask for — each other's verdicts. Never run the bench as
a single agent role-playing five perspectives, and never inline in the session that wrote
the code: one context has one set of blind spots, and role-played "adversaries" produce
correlated verdicts. The bench's value is uncorrelated failure detection, not persona
prose. (Origin of this rule: `docs/rejection-ledger.md`.)

Adversaries are READ-ONLY in the strong sense (ratified 2026-07-15; tightened
2026-07-17): never `git checkout`/`switch`/`reset`/`update-index` (incl. its
assume-unchanged / skip-worktree bits) or anything that mutates the shared working tree,
the index, or moves HEAD — inspect other revisions via `git show <ref>:<path>` /
`git diff` only. Bench members NEVER write ANY tracked path, even transiently — a
self-reverted edit is still a violation, and any adversary output derived from mutating
the tracked tree is void. Executed mutation tests an adversary needs (e.g. TEST_HONESTY)
run ONLY on scratch copies under `mktemp` OUTSIDE the tracked tree; the tracked tree is
never the mutation substrate. The gate runner records a tree fingerprint immediately
before dispatching the bench and verifies it as each adversary returns; any delta voids
the bench round, fail-closed. Reference implementation in gadd itself:
[bin/bench-tree-guard.sh](../bin/bench-tree-guard.sh) — deployments without the
instrument still owe the before/after verification by equivalent means. Truth-only
honesty: the guard detects residue at return time — a transient self-reverted write is
invisible to it; the prohibition itself, not the guard, covers that case.

## Model mapping (Phase 0 orchestration)

Structural checks — mostly diff-vs-artifact comparison — run on the cheap tier; judgment
calls run on the strong tier. Each adversary declares its tier in its `Tier:` line;
concrete models are an adapter/deployment concern (spec §3):

| Tier | cc adapter (agent frontmatter) | lv adapter default (API model id) |
|---|---|---|
| structural | `haiku` | `claude-haiku-4-5-20251001` |
| judgment | `opus` | `claude-opus-4-8` |

**Tier floor, not ceiling (ratified 2026-07-15):** the mapped tier is a MINIMUM. A
verification or final-judgment pass of any adversary MAY run above its mapped tier, never
below — consistent with the fallback-chain rule (workers may fall back down, graders never
do). Every above-tier run is logged in the lantern.

## Protocol

1. Launch each triggered adversary in parallel, read-only, with exactly: its
   `RED_TEAM/<NAME>.md` definition, the diff range, and the task's EARS criteria.
2. Each returns `VERDICT: PASS` or `VERDICT: FAIL` + at most 3 blockers, each with a
   one-line fix (+ at most 3 non-blocking notes).
3. Aggregation is mechanical: any adversary FAIL dispatches repair work. RED_TEAM verdicts
   never decide acceptance — that is the deterministic gate's alone (spec invariant 3).
4. On FAIL: the Fixer applies the blockers, then re-run ONLY the failed adversaries on
   the new diff. The Fixer never grades its own fix.
5. 2-round cap (spec invariant 6). Still failing → the Architect arbitrates (re-scope /
   revert / accept-with-waiver) and the arbitration is logged.
6. Files in `RED_TEAM/` are graders: executors and the Fixer never edit them
   (spec §3 roles matrix, OWNERSHIP.md).
