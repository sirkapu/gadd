# CLAUDE.md — adapters/cc/

- In-loop adapter: /gadd-loop contract, subagent roles, gate dispatch.
- The loop runs end-to-end on a work branch; hard stops at tier-3 (merge/
  push to main, deploys, graders, baselines, weakened tests, secrets).
- Commands shipped to deployments live here (phase 3 landed):
  [commands/gadd-loop.md](commands/gadd-loop.md),
  [commands/mission-loop.md](commands/mission-loop.md), and
  [commands/objective-audit.md](commands/objective-audit.md) all ship via
  [bin/install.sh](bin/install.sh) (`bin/install.sh --adapter=cc` at the
  repo root). `/mission-loop`'s own dependencies (`gadd-ratifier` agent,
  `bin/loop-lock.sh`, `bin/schedule-loop.sh`) ship alongside it so the
  command is self-contained in the target repo.
