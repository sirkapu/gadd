# CLAUDE.md — adapters/lv/

- Boundary adapter: deterministic checks + workflows for Lovable-synced
  repos; verdicts at push time.
- Substrate: bash checks; measurement engines are zero-dep Node
  (checks/lib/parity-metrics.mjs) per the substrate ruling.
- Deployment-owned vs upstream-owned split: defined by the installer +
  docs/metric-parity.md (deployment adopt/retire of parity.gating) + the
  OQ2 lantern entries. Never write deployment-real paths into upstream files.
