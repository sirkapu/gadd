# CLAUDE.md — RED_TEAM/

- Grader territory. Executors and the Fixer NEVER edit anything here.
- One definition file per adversary: role, attack surface, pass criteria,
  output contract (VERDICT + max 3 blockers + one-line fixes).
- Adversaries run as isolated invocations, blind to each other; models per
  structural → cheap (haiku) for CONTRACT_FIDELITY + TEST_HONESTY; judgment
  → strong (opus) for SECURITY + DATA_INTEGRITY + REGRESSION — see
  [gate-matrix.md](gate-matrix.md); tiers are a floor, not a ceiling (R2).
  Read-only tools.
- Changes here are Major and land as separate, operator-reviewed commits.
