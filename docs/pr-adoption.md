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

## Known open residuals under PR flow (tracked in the lantern; honesty, not fine print)

- The `accept_authors` check reads git author metadata, which an external
  contributor can spoof; a verifiable accept-signer is operator-approved and
  in the build queue. Until it lands, accept commits from untrusted external
  PRs deserve human eyes.
- Commits pushed to a PR branch after approval are graded on the next ratchet
  run, not at merge time (post-approval TOCTOU window).
- CODEOWNERS protection for grader/tier-3 surfaces is pending operator
  ratification of the mapping text.
