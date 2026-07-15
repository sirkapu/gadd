# Approval Matrix (TEMPLATE)

Who may do what without asking. Copy into your deployment (suggested:
`docs/gadd/approval-matrix.md`), replace `{{HUMAN}}` with the owner, name your agents, and
adapt each list to your platform's reality. Approval levels map to spec §6 task tiers:
autonomous ≈ Trivial/Standard in-lane work; tier-3 = Major — human, every time.

## Autonomous (no approval needed)

- Local commits and feature branches; docs; contract drafting; in-lane feature work.
- Running tests / lint / build / the gadd suite / the deployment ratchet.
- Read-only platform operations (reads, diffs, SELECT-only queries, analytics).
- Spec drafting; agent-prompt drafting; refactors within a task's declared scope.

## Pre-approved batches (log, don't ask)

- Dispatching work inside a {{HUMAN}}-approved milestone (log scope/cost in the loop ledger).
- Routine dependency PATCH updates that pass the full deterministic gate (log them).

### Standing rulings

Operator-ratified rulings that convert a would-be park (tier-3 / ratification-needed) into
autonomous execution of a SPECIFIC pattern. Every execution is logged in the lantern and
reported in the run's STATUS — audit after, not gate before. Rulings are revocable by
{{HUMAN}} at any retro. Tier-3 hard stops (merge/push/deploy/graders/baselines/secrets)
can never be converted by a standing ruling. A ruling's FIRST autonomous execution is
highlighted in the morning brief and reviewed at the next retro.

1. **(2026-07-14; wording ratified 2026-07-15)** ONE root-cause Fixer round per
   ADVERSARY-VERDICT per plan item is pre-approved — naturally capped by bench size —
   when: scope ≤ the failing file, tier ≤ Standard, and the failed adversary re-runs
   after. Beyond that = park.

## Tier-3 / Major — {{HUMAN}} approves, every time

- Merging or pushing to the default branch; deploys and publishes.
- Schema migrations touching real user data.
- New runtime dependencies (adversary-grade justification; dev deps a lighter yes/no).
- Secrets and credentials handling.
- Force-push, history rewrites, deletion of data or published artifacts.
- Anything touching payments or user PII flows.
- **Grader changes:** `RED_TEAM/**`, check suites, baselines, gate configs, or weakening /
  deleting existing tests (separation of powers).

## Managed-agent reality note

If a managed builder (Lovable-class) pushes to the default branch by design, that flow
stays — the gate is post-hoc, at acceptance (`spec/BOUNDARY-GOVERNANCE.md`). A ratchet
regression from a managed-agent push is a blocker: compile the repair prompt before
building anything on top of it.
