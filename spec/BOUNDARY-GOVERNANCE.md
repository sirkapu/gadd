# Boundary Governance (normative, v0.1)

Applies when the executor is a managed agent you do not control (Lovable-class). Derived from the
core invariants in `GADD.md`; this document defines the three control planes.

## Plane 1 — Input governance (preventive)
- **Contracts** live in `src/contracts/**`, committed by the governing side before any agent prompt.
- **Prompt template** is law: Scope, Contract (verbatim), Rules, Do-Not-Modify lanes, Response
  Report, If-You-Get-Stuck. A prompt outside the template is a human-side violation.
- **Knowledge (`AGENTS.md`)** is versioned in-repo; its hash at last sync is recorded in the
  baseline. Drift = MAJOR.
- **`OWNERSHIP.md`** declares path lanes (`governed:` = agent must not touch). It is data, parsed
  by check #2 — keep the fenced block machine-readable.

## Plane 2 — Output audit (detective)
- The ratchet runs **post-push on the default branch** — never as branch protection (breaks
  managed-agent sync; see anti-goals).
- All checks are deterministic (diff/grep/AST). The suite diffs `accepted_sha..HEAD`.
- RED_TEAM (LLM adversaries) runs only after deterministic PASS, is read-only, and outputs
  VERDICT + max 3 blockers + one-line fixes.

## Plane 3 — Feedback loop (corrective)
- FAIL → findings are compiled into a repair prompt (`LV-REPAIR-TEMPLATE.md`), scoped to the
  blockers only.
- Two failed repair rounds → human arbitration: re-scope, revert to `accepted_sha`, or reassign
  the piece to the in-loop side.
- PASS → baseline advances; the push is accepted.

## Anti-goals
- No branch protection against the managed agent; no PR gates it cannot satisfy.
- No pre-commit hooks aimed at the managed agent (dead surface).
- No LLM-decided verdicts.
- No governance payload inside agent prompts beyond the template sections.
- The agent's self-report is traceability, never evidence — the ratchet is the evidence.
