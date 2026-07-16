# PR-flow adoption note — required GitHub settings for gadd-governed repos

**Status: NORMATIVE for deployments whose `main` moves via pull requests**
(PR-flow item 4, operator-approved run #19; findings and probes in the PR-flow
readiness audit). If your repo only ever takes direct operator-approved pushes,
nothing here applies yet.

## The one rule: merge commits only

| GitHub setting (Settings → General → Pull Requests) | Required value |
|---|---|
| Allow merge commits | **ON** |
| Allow squash merging | **OFF** |
| Allow rebase merging | **OFF** |

**Why:** gadd's baseline pins `accepted_sha` to a real commit in your history.
A squash (or rebase) merge REPLACES the PR's commits with new ones, leaving
`accepted_sha` pointing at a commit that no longer exists on `main`. The gate
then refuses to run — loudly and by design (hardening A + H: unresolvable or
non-ancestor base → CRITICAL `gate-integrity`, message names the squash
incompatibility). Nothing fails silently, but your ratchet is wedged until the
baseline is re-accepted against real history. Don't wedge it: disable squash
and rebase merging before the first governed PR.

## Integration ≠ acceptance (read this before wiring branch protection)

gadd is boundary governance ([spec/BOUNDARY-GOVERNANCE.md](../spec/BOUNDARY-GOVERNANCE.md)):
merging a PR *integrates* code; it never *accepts* it. Acceptance happens only
when the deterministic gate passes and an authorized `gadd: accept` commit
advances `gadd/BASELINE.json`. Consequences:

- **Do not mark gadd workflows as required status checks.** `gadd-ratchet`
  (post-merge, on `main`) and `gadd-advisory` (PR-time preview) are signals.
  A red advisory job tells the reviewer "this PR as merged goes red on main's
  ratchet" — the reviewer decides; the gate never blocks integration, and a
  bad merge simply never advances the baseline (recovery = revert to
  `accepted_sha`).
- **There is no preventive gate on GitHub's server.** The fail-closed pre-push
  hook runs only on contributors' machines; server-side enforcement is
  detective (ratchet run + non-advancing baseline), not preventive. That is
  the designed model, not a gap — but adopters must know it.

## PR-time visibility

Ship [`gadd-advisory.yml`](../adapters/lv/workflows/gadd-advisory.yml)
(installed automatically by `adapters/lv/bin/install.sh` alongside the other
workflows). It runs the full deterministic suite against the PR's synthetic
merge commit (`fetch-depth: 0` — full history is required for `accepted_sha`
resolution and the ancestry assertion) and uploads the verdict as an artifact.
Advisory only; see the rule above.

## Accept-signer verification runs in CI automatically (run #21, operator answer c)

`gadd-ratchet` and `gadd-advisory` both execute the full deterministic suite
via `bash .gadd/checks/run-all.sh` (see the workflow files) — this includes
check 02's accept-signer verification (SSH commit signing via
`git verify-commit` against the base-pinned `gadd/allowed_signers`;
[audits/accept-signer-design-v1.md](../audits/accept-signer-design-v1.md)).
No new CI wiring was needed: the check reads `gadd/allowed_signers` from
`GADD_BASE` via `git show`, and that file holds public keys only — nothing
secret — so ordinary `fetch-depth: 0` checkout access is sufficient; no
repository secret is configured or required for signature verification itself.
Consequences for adopters:

- **Enrollment is a one-time, per-deployment step**, not a CI configuration
  step: run `adapters/lv/bin/install.sh` with `GADD_SIGNER_PUBKEY` set (fresh
  installs), or commit `gadd/allowed_signers` as a signed `gadd: accept`
  genesis commit (existing deployments) — see the design doc's migration
  steps 2 and 5. Once enrolled, every subsequent CI run of `run-all.sh`
  enforces it automatically, on GitHub's runners exactly as it does locally.
- **Runner git version**: `ubuntu-latest` ships a git well above the 2.34
  floor `git verify-commit`'s SSH-signature plumbing requires; check 02
  fails closed (CRITICAL) if it ever detects an older git rather than
  silently skipping enforcement, so a stale runner image would surface
  loudly, not silently.
- **Merge-commit-only still applies** (the rule above) — the signer check
  verifies the `gadd: accept` commit itself, which only exists as a real
  commit in history under merge-commit flow; a squashed/rebased PR still hits
  the ancestry refusal (hardening H) before signature verification is ever
  reached.

## Known open residuals under PR flow (tracked in the lantern; honesty, not fine print)

- The `accept_authors` check reads git author metadata, which an external
  contributor can spoof; run #21 shipped a verifiable accept-signer
  (`git verify-commit` against a base-pinned `gadd/allowed_signers` — see
  [audits/accept-signer-design-v1.md](../audits/accept-signer-design-v1.md))
  as a second, stronger factor. It is opt-in per deployment (enroll via the
  installer's `GADD_SIGNER_PUBKEY` or a signed genesis commit); until a given
  deployment enrolls, accept commits from untrusted external PRs on THAT
  deployment still deserve human eyes.
- Commits pushed to a PR branch after approval are graded on the next ratchet
  run, not at merge time (post-approval TOCTOU window).
- CODEOWNERS protection for grader/tier-3 surfaces is pending operator
  ratification of the mapping text.
