# GADD — Governed Agentic-Driven Development

**Catch your AI agent breaking your app — before you accept its code.**

Agentic coding tools ship fast and degrade quietly: weakened tests, missing RLS, drive-by edits to files they shouldn't touch. GADD is a quality **ratchet** for agent-written code. It governs any agent in one of two modes:

- **In-loop** (`adapters/cc`) — when you control the executor (Claude Code, local agents): blocking gates inside the agent's own workflow.
- **Boundary** (`adapters/lv`) — when you don't (Lovable and other managed builders): deterministic detection after every push, plus a repair loop that feeds findings back to the agent as its next prompt.

Same invariants, two enforcement points. That's the whole idea.

```
you cannot govern how a managed agent writes.
you can govern what goes in, and what gets accepted.
```

## Quickstart (Lovable)

```bash
git clone https://github.com/sirkapu/gadd /tmp/gadd
cd your-lovable-repo
bash /tmp/gadd/bin/install.sh --adapter=lv
git add -A && git commit -m "chore: install gadd-lv"
# accept the installation, then push both commits together:
jq --arg sha "$(git rev-parse HEAD)" '.accepted_sha=$sha' gadd/BASELINE.json > t && mv t gadd/BASELINE.json
git commit -am "gadd: accept $(git rev-parse --short HEAD)" && git push
```

Done. From now on, every push runs the check suite and produces a verdict (`PASS`/`FAIL` + findings). Your agent's code is **integrated** when it lands, but only **accepted** when the ratchet is green.

## What it catches (the 9 detectors)

| # | Check | Severity | What it means |
|---|-------|----------|---------------|
| 1 | Contract drift | CRITICAL | Agent edited `src/contracts/**` — the types you committed as law |
| 2 | Lane violation | CRITICAL | Agent touched files owned by you per `OWNERSHIP.md` |
| 3 | RLS missing | CRITICAL | New table in a migration without row-level security |
| 4 | Test weakening | MAJOR | Deleted/skipped tests, loosened assertions |
| 5 | Shared-util reimplementation | MAJOR | Agent rewrote CORS/JSON/util code instead of importing `_shared/` |
| 6 | Migration hygiene | MAJOR | Bad filenames, edits to already-applied migrations |
| 7 | Ratchet metrics | MAJOR | Skipped-test count, max file size, type errors — regressions vs baseline |
| 8 | Secret/PII leakage | CRITICAL | Tokens, keys, or user data logged in edge functions |
| 9 | Knowledge drift | MAJOR | Repo `AGENTS.md` no longer matches what the agent was synced with |

Every check is **deterministic** — grep/diff/AST, no LLM in the gate. The optional RED_TEAM step — five LLM adversaries, each launched as its own isolated invocation on the diff (definitions in [`RED_TEAM/`](RED_TEAM/)) — only *proposes* fixes; it never arbitrates.

## The loop

```
contract committed ─▶ agent prompted ─▶ agent pushes to main
                                            │
                            ratchet: 9 deterministic checks
                                            │
                          ┌───── PASS ──────┴────── FAIL ──────┐
                          ▼                                    ▼
                 baseline advances                findings → repair prompt
                 (code ACCEPTED)                  (max 2 rounds, then human)
```

## Why not just protect `main`?

Because managed builders like Lovable sync directly to `main`; branch protection breaks the platform. GADD-lv doesn't fight the platform — it moves enforcement to the only place you actually control: **acceptance**. Full rationale in [`spec/BOUNDARY-GOVERNANCE.md`](spec/BOUNDARY-GOVERNANCE.md).

## Repo layout

```
spec/            the invariants — tool-agnostic (severity ladder, ratchet semantics,
                 roles matrix, acceptance model)
RED_TEAM/        the adversary bench — one definition file per adversary (role, attack
                 surface, pass criteria, output contract) + gate-matrix.md
templates/       governance pack — orchestration (roles × model placeholders + the
                 fallback-chain rule) and approval-matrix templates for deployments
bin/             gadd-fleet.mjs — escaped-regression + verdict aggregation across governed
                 repos (zero-dependency Node, measurement, local-only output — never commit
                 it, docs/measurement.md)
adapters/cc/     in-loop enforcement for Claude Code
adapters/lv/     boundary enforcement for Lovable (checks, workflows, templates)
bin/install.sh   one-command installer, --adapter=cc|lv
```

## Roadmap

Priorities are driven by real governed repos; OSS milestones (releases, new adapters)
activate once ≥1 repo runs upstream gadd end-to-end with verdict data.

- [x] Boundary adapter for Lovable (`adapters/lv`)
- [ ] In-loop adapter for Claude Code (`adapters/cc`) — agents + `/gadd-loop` + `/mission-loop` +
      `/objective-audit` + one-command installer (`bin/install.sh --adapter=cc`) shipped; blocking
      CI/hooks extraction pending
- [x] v0.3 — measurement instrument wired: escaped-regression ledger (`gadd/ESCAPED.jsonl`) + `bin/gadd-fleet.mjs` aggregation (docs/measurement.md)
- [x] v0.3 cont'd — first repo governed by upstream gadd (live, verdict data flowing)
- [ ] v0.3 cont'd — gadd dogfooding itself
- [ ] `gadd-accept` bot: auto-advance baseline on green
- [ ] Cursor / Replit adapters — [contributions welcome](CONTRIBUTING.md)

## License

MIT — see [LICENSE](LICENSE).
