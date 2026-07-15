# Orchestration — gadd's own instance

## Model-per-role (current)

| Role | Tier | cc adapter | lv adapter default |
|---|---|---|---|
| CONTRACT_FIDELITY, TEST_HONESTY | structural (cheap) | `haiku` | `claude-haiku-4-5-20251001` |
| SECURITY, DATA_INTEGRITY, REGRESSION | judgment (strong) | `opus` | `claude-opus-4-8` |
| Director / Architect sessions | — | Fable 5, high effort | — |
| Executor sessions | — | strong-general (sonnet) | — |
| Mechanic sessions | — | cheap (haiku) | — |

Source: adversary tiers are read from the `Tier:` lines in the five
[RED_TEAM/](../RED_TEAM/) definitions and [RED_TEAM/gate-matrix.md](../RED_TEAM/gate-matrix.md);
session roles are operator-supplied and not repo-readable.

## Fallback chain (rule — VERBATIM)
Never hardcode a model without a documented fallback chain. If the top
reasoning model becomes unavailable on the subscription, the Architect role
falls back to the best reasoning model available at that moment, and
executor roles shift down one tier accordingly. Grader tiers are a FLOOR,
not a ceiling (ruling R2, ratified in the same dispatch that carried this
payload): judgment passes may run above their tier, never below. Re-verify
this chain at every model audit and retro.
