<!-- AGENTS.md — mirror of CLAUDE.md for non-Claude agents; keep in content-sync (release audit enforces) -->
# CLAUDE.md — gadd (Layer 0 + 1)

gadd is a quality ratchet for agent-written code: acceptance is decided ONLY
by deterministic gates; RED_TEAM proposes repair, never decides. State lives
in [LANTERN.md](LANTERN.md). The law lives in [spec/GADD.md](spec/GADD.md).

## Ground rules (every session)
- Verify, never from memory: APIs, library behavior, file contents, and any
  claim about this repo are checked against the live source before use.
- Packets never hand the operator terminal commands — they end in "reply
  approve and I execute"; the operator may reply in plain language (any
  language, incl. Spanish); the loop translates to protocol.
- Truth-only: unmeasured is reported unmeasured; a red guard is reported red.
- Standards: see [context/ubc.md](context/ubc.md). Orchestration + fallback:
  see [context/tooling.md](context/tooling.md).
- Tiers: Trivial (direct + deterministic checks) · Standard (light spec +
  triggered adversaries) · Major (full cycle + full bench). Defined in
  [spec/GADD.md](spec/GADD.md) §6. Downgrading to skip ceremony = gate violation.

## Where do I go? (Layer-1 routing)
| Task | Folder | Loads |
|---|---|---|
| Change the law (invariants, tiers, schemas) | [spec/](spec/) | [spec/CLAUDE.md](spec/CLAUDE.md) |
| Grade or attack a diff | [RED_TEAM/](RED_TEAM/) | [RED_TEAM/CLAUDE.md](RED_TEAM/CLAUDE.md) |
| Adapt gadd to a platform | [adapters/](adapters/) | [adapters/CLAUDE.md](adapters/CLAUDE.md) |
| Copy governance into a deployment | [templates/](templates/) | [templates/CLAUDE.md](templates/CLAUDE.md) |
| Run instruments (fleet aggregator, residue check, audits) | [bin/](bin/) | [bin/CLAUDE.md](bin/CLAUDE.md) |
| Instrument acceptance corpora | [tests/](tests/) | [tests/CLAUDE.md](tests/CLAUDE.md) |
| Read what is wired / ledgers / measurement | [docs/](docs/) | [docs/CLAUDE.md](docs/CLAUDE.md) |
| Always-applied standards | [context/](context/) | [context/CLAUDE.md](context/CLAUDE.md) |

## Linking convention
Cross-references between files use explicit relative markdown links, not
bare path mentions in prose — agents navigate explicit paths more reliably,
and humans get a truthful graph view (path mentions don't render as edges;
links do). Apply opportunistically per surgical-changes: convert references
in any file you are already touching; no repo-wide rewrite sweep.
