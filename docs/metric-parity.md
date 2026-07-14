# Ratchet Metric Parity — v0.3 phase 1b spec

**Status: ROADMAP — none of this is wired yet** (standing rule: claim only what is wired).
Ratified 2026-07-14: upstream inherits the *best* deployment ratchet, not the minimum. The
parity source is the richest ratchet running in a production deployment (Node-based,
tighten-only). Until upstream reaches parity, that deployment's ratchet stays gating as a
`.gadd/checks/NN-*.sh` extension — replace-with-extension, never loosen.

## Target gating metrics (regression beyond baseline = MAJOR)

| Metric | Definition |
|---|---|
| `eslint_errors` / `eslint_warnings` | totals from `eslint --format json` over the repo |
| `tsc_errors` | `error TS…` count from `tsc --noEmit` against the app tsconfig |
| `any_count` | occurrences of `: any`, `<any>`, `as any`, `any[]` in non-exempt source |
| `eslint_disables` | `eslint-disable` occurrences in non-exempt source |
| `oversized_files` | files over a per-type LOC ceiling (e.g. 300 for `.tsx`/hooks, 200 for `.ts`) — richer than the single `max_file_loc` |
| `duplicate_windows` | duplicate normalized 6-line sliding windows across non-exempt source |

## Target trend metrics (reported, non-gating)

`tsc_strict_errors` (distance to `--strict`), `test_files`, `source_file_count`.

## Required mechanics (from the parity source)

- **Exemption list** — generated/scaffolded paths (ui kits, generated types, `.d.ts`)
  excluded from source-quality signals; the list is a grader (tier-3 to change).
- **Tighten-only baseline** — `--init` and `--tighten` are human-invoked; the baseline
  never loosens (spec invariant 2).
- Wired today upstream, for contrast: `skipped_tests`, `max_file_loc` (fixed 2026-07-14 —
  it measured *total* LOC, not max; see rejection/lantern logs). `baseline.schema.json`'s
  declared-but-unwired `ts_errors` / `test_files` land with this parity work.
