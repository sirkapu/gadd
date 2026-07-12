# Contributing

The highest-value contribution right now is a **new adapter** (Cursor, Replit, Windsurf…).
An adapter must: (1) implement the invariants in `spec/GADD.md`, (2) declare its enforcement
point (in-loop or boundary), (3) emit verdicts conforming to `spec/schemas/verdict.schema.json`,
(4) install with one command. Open an issue with the enforcement analysis before coding.
Checks must stay deterministic — PRs adding LLM-judged gates will be declined (see anti-goals).
