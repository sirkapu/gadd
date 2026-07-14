# gadd-lv — boundary adapter for Lovable

Enforcement point: **after the push, at acceptance** — never against Lovable's sync.
See `spec/BOUNDARY-GOVERNANCE.md` for the model; this adapter ships:

- `checks/` — the 9 deterministic detectors + `run-all.sh` verdict aggregator
- `workflows/` — `gadd-ratchet.yml` (every push to main) and `gadd-redteam.yml` (LLM adversaries,
  only on deterministic PASS, optional `ANTHROPIC_API_KEY`)
- `templates/` — `AGENTS.md`, `OWNERSHIP.md` (machine-readable lanes), repair-prompt template
- `bin/install.sh` — one command on any Lovable repo

Config via env in the workflow if your layout differs: `GADD_CONTRACT_DIR`, `GADD_MIGRATIONS_DIR`,
`GADD_SHARED_DIR`.

## Accepting a green push
On PASS, advance the baseline (this is the acceptance act). The accept commit's subject must
start `gadd: accept` AND its author email must be in the accepted baseline's `accept_authors`
allowlist (the installer seeds it with your git email):
```bash
jq --arg sha "$(git rev-parse HEAD)" '.accepted_sha=$sha' gadd/BASELINE.json > t && mv t gadd/BASELINE.json
git commit -am "gadd: accept $(git rev-parse --short HEAD)" && git push
```
