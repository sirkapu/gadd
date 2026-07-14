# GADD Core Specification (v0.1)

Tool-agnostic invariants. Adapters implement enforcement; this document defines *what* is enforced.

## 1. Invariants

1. **Contract-first.** Interfaces/types are committed by the governing side before the agent is
   prompted. The agent implements to the contract verbatim; any agent-authored change to a contract
   is a finding.
2. **The ratchet only tightens.** Quality baselines (tests, type errors, lint debt, file size caps)
   may improve or hold. Any regression is a finding — even if absolute values look "fine".
3. **Deterministic gates.** A verdict must be reproducible from the repo state alone. LLMs may
   propose (RED_TEAM) or compile (Fixer); they never decide PASS/FAIL. Acceptance is decided
   only by deterministic gates; RED_TEAM verdicts gate dispatch of repair work in-loop,
   never acceptance.
4. **Integration ≠ acceptance.** Code is *integrated* when it lands in the default branch. It is
   *accepted* only when the ratchet is green on it. The last accepted SHA is the recovery point.
5. **Findings close loops.** Every FAIL must produce an actionable artifact (repair prompt or
   blocking error) routed back to the executor. Unrouted findings are governance theater.
6. **Bounded repair.** Max 2 automated repair rounds per feature; then escalate to a human.

## 2. Severity ladder

| Severity | Meaning | Effect |
|----------|---------|--------|
| CRITICAL | Security, contract, or ownership breach | Verdict FAIL; repair round mandatory; baseline frozen |
| MAJOR    | Quality regression or process breach | Verdict FAIL; repair round mandatory |
| MINOR    | Hygiene (complexity growth, dead code, format) | Recorded; does not fail the verdict alone; 3+ MINORs escalate to MAJOR |

## 3. Roles matrix

| Role | Does | Never does |
|------|------|-----------|
| Director/Architect | Specs w/ EARS criteria, task decomposition, dispatch, arbitration at the round cap | Write production code |
| Executors | Features, components, contracts drafts, tests, agent prompt drafts | Touch RED_TEAM/, gate configs, ratchet baselines, weaken tests |
| Mechanics | Scaffolding, renames, doc formatting, running checks | Anything requiring judgment |
| RED_TEAM | One adversary per isolated invocation, in parallel on the diff (one definition file per adversary in `RED_TEAM/`); each returns VERDICT: PASS/FAIL + max 3 blockers + one-line fixes | Rewrite code; share context or verdicts with another adversary |
| Fixer | Applies blockers' fixes; reports back | Grade its own fix — failed adversaries re-run on the new diff |

Model assignment is an adapter/deployment concern, not a spec concern. Adversary
*independence* IS a spec concern: each RED_TEAM adversary runs as its own isolated
invocation and never sees another adversary's verdict. A single agent role-playing the
bench does not satisfy this matrix — one context has one set of blind spots, and
role-played adversaries produce correlated verdicts (see `docs/rejection-ledger.md`).

## 4. Acceptance model

- `gadd/BASELINE.json` records: `accepted_sha`, ratchet metrics at acceptance, `agents_md_sha`.
- The check suite always diffs `accepted_sha..HEAD`.
- On PASS, the baseline advances (manually or via an accept job). On FAIL, it does not.
- Reverting to `accepted_sha` is always a legal move and must never be penalized by the ratchet.

## 5. Verdict artifact

Verdicts are machine-readable JSON conforming to `spec/schemas/verdict.schema.json`:
`{ sha, base_sha, verdict: PASS|FAIL, findings: [{check, severity, message, paths[]}], metrics }`.
Adapters must emit one verdict per evaluated push and retain them (artifact, branch, or directory).
