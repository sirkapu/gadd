# AGENTS.md — standing rules for the building agent

1. Contracts in `src/contracts/**` are law. Implement to them verbatim; never edit them.
2. Never modify paths listed in `OWNERSHIP.md` governed lanes.
3. Every new table ships WITH row-level security enabled and at least one policy, same migration.
4. Never delete, skip, or weaken tests to make a build pass. A failing test is a blocker report.
5. Use `_shared/` utilities (CORS, JSON recovery, cost tracking); do not reimplement them.
6. Migrations: `YYYYMMDDHHMMSS_snake_case.sql`, UTC, one concern per file, never edit applied ones.
7. Never log secrets, tokens, user PII, or domain-sensitive data (e.g., geolocation, user images — define your product's list).
8. End every task with a Response Report: files touched, migrations, decisions, known issues.
