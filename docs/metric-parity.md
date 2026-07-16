# Ratchet Metric Parity — v0.3 phase 1b spec

**Status: WIRED (phase 1b).** Ratified 2026-07-14: upstream inherits the *best*
deployment ratchet, not the minimum. The parity source is the richest ratchet running
in a production deployment (Node-based, tighten-only). This document previously stated
none of this was wired — that is no longer true; the mechanics below are implemented
in `adapters/lv/checks/lib/parity-metrics.mjs` (measurement engine) and
`adapters/lv/checks/10-ratchet-parity.sh` (gating check), covered by
`tests/parity-fixtures.sh` (standing rule: claim only what is wired and verified).

## Wired vs. roadmap

| Piece | Status |
|---|---|
| Scan-based gating metrics (`any_count`, `eslint_disables`, `oversized_files`, `duplicate_windows`) | **Wired.** Pure Node `node:` built-ins, no external tooling required — always measured. |
| Exemption list + per-type LOC ceilings, sourced from `gadd/BASELINE.json`'s `parity.exempt` / `parity.ceilings` | **Wired.** Defaults (300 for `.tsx` and `src/hooks/`, 200 otherwise) apply when unconfigured. |
| `eslint_errors` / `eslint_warnings` / `tsc_errors` | **Wired when tooling is present** (local `node_modules/.bin/eslint` or `.bin/tsc` resolves). When the tool isn't installed/resolvable, the metric reports `null` — never a fabricated `0`. |
| `tsc_strict_errors` (trend), `test_files` (trend), `source_file_count` (trend) | **Wired**, same null-honest rule for `tsc_strict_errors`. |
| Gating mechanics: regression-beyond-baseline → MAJOR; configured-but-unmeasurable → MAJOR ("a gate that cannot run never passes silently"); tighten-only baselines (never auto-loosened, never auto-written) | **Wired** in `10-ratchet-parity.sh`. |
| Graceful adoption: no `parity.gating` block in `gadd/BASELINE.json` → measure-only, notice to stderr, never gates | **Wired.** |
| `baseline.schema.json` optional `parity` block (`exempt`, `ceilings`, `gating`) | **Wired**, additive. |
| A deployment's own richer/older Node ratchet retiring in favor of this upstream parity check | **Roadmap — deployment-side.** That extension (`.gadd/checks/NN-*.sh` in the deployment's own repo) retires only after *that deployment* adopts a `parity.gating` baseline in its own `gadd/BASELINE.json` and verifies upstream parity covers what its extension covered. This task wires the upstream capability; adopting/retiring per deployment is a separate, deployment-owned action. |

## Gating metrics (regression beyond baseline = MAJOR)

Measured by `parity-metrics.mjs`, reported under `gating`. Gated by `10-ratchet-parity.sh`
only for the metrics a deployment has actually put in `gadd/BASELINE.json`'s
`parity.gating` block — unconfigured metrics are still measured and merged into
the run's metrics state file (`GADD_METRICS_FILE`, a mktemp-backed per-run path
threaded in by `run-all.sh` since the run-13 shared-/tmp hardening) but never
fail the check.

| Metric | Definition |
|---|---|
| `eslint_errors` / `eslint_warnings` | totals from `eslint --format json` over the repo — `null` if eslint isn't resolvable locally |
| `tsc_errors` | `error TS…` count from `tsc --noEmit` against the app tsconfig (`tsconfig.app.json` if present, else `tsconfig.json`) — `null` if tsc isn't resolvable locally or no tsconfig is found |
| `any_count` | occurrences of `: any`, `<any>`, `as any`, `any[]` in non-exempt source |
| `eslint_disables` | `eslint-disable` occurrences in non-exempt source |
| `oversized_files` | files over a per-type LOC ceiling (default 300 for `.tsx`/`src/hooks/`, 200 for `.ts`) — richer than the single `max_file_loc` |
| `duplicate_windows` | duplicate normalized 6-line sliding windows across non-exempt source |

## Trend metrics (reported, non-gating)

Measured by `parity-metrics.mjs`, reported under `trend`: `tsc_strict_errors` (distance
to `--strict`, `null` under the same tsc-unavailable rule), `test_files`, `source_file_count`.

## Required mechanics (from the parity source) — implemented

- **Exemption list** — path prefixes from `gadd/BASELINE.json`'s `parity.exempt`, plus
  `.d.ts` files always exempt, excluded from source-quality signals; the list is a
  grader (tier-3 to change) via that baseline file, not this repo.
- **Tighten-only baseline** — `10-ratchet-parity.sh` never writes `gadd/BASELINE.json`.
  A measured value below baseline is reported as a stderr notice only; tightening the
  baseline stays a human-invoked, deployment-side action (spec invariant 2).
- **Null-honest, not silently-passing** — a configured gating metric that comes back
  `null` (tool missing, or node itself missing) is a MAJOR finding, not a pass.

## Relationship to the existing `07-ratchet-metrics.sh` check

`07-ratchet-metrics.sh` (`skipped_tests`, fixed `max_file_loc`) predates this work and
is untouched by it — it writes its own keys into the shared `GADD_METRICS_FILE` before
`10-ratchet-parity.sh` runs and merges its own `parity` key in alongside them.
`baseline.schema.json`'s pre-existing top-level `metrics.ts_errors` / `metrics.test_files`
fields remain declared-but-unwired — no check populates those two specific keys; the
parity work's `tsc_errors` and `test_files` live under the new `parity.gating` /
`parity.trend` keys instead, not the legacy `metrics` ones.
