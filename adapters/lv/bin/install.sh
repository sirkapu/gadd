#!/usr/bin/env bash
# Installs gadd-lv onto an existing Lovable-created repo. Run from the target repo root.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
[ -d .git ] || { echo "run me from the target repo root"; exit 1; }

mkdir -p .gadd/checks/lib .gadd/schemas .github/workflows gadd/verdicts gadd/lv-blockers
[ -f gadd/ESCAPED.jsonl ] || touch gadd/ESCAPED.jsonl   # escaped-regression ledger, one JSONL line per defect (see docs/measurement.md)
cp -r "$SRC/checks/." .gadd/checks/
cp "$SRC/../../spec/schemas/"*.json .gadd/schemas/
cp "$SRC/workflows/"gadd-*.yml .github/workflows/
[ -d RED_TEAM ] || cp -r "$SRC/../../RED_TEAM" RED_TEAM   # adversary bench (graders — never edited by executors)
for t in AGENTS.md OWNERSHIP.md; do [ -f "$t" ] || cp "$SRC/templates/$t" "$t"; done
cp "$SRC/templates/LV-REPAIR-TEMPLATE.md" gadd/ 2>/dev/null || true

EMAIL="$(git config user.email || true)"

# Accept-signer genesis (run #21, ratified design: accept-signer-design-v1.md,
# migration step 5 — write allowed_signers BEFORE the baseline so a fresh
# install's genesis baseline already anchors it, closing the fresh-install
# legacy window). GADD_SIGNER_PUBKEY may be a full allowed_signers line
# ("principal keytype base64...") or a bare/.pub key ("keytype base64
# [comment]"), in which case EMAIL is prefixed as the principal and any
# trailing comment is dropped. Classify by the FIRST TOKEN, not field count
# (repair round 1, blocker 3): a normal ssh-keygen .pub file has 3 fields
# (keytype, base64, comment), which the original field-count heuristic
# misread as an already-complete allowed_signers line — writing "ssh-ed25519"
# itself as the PRINCIPAL and silently bricking every future verify-commit.
if [ -n "${GADD_SIGNER_PUBKEY:-}" ]; then
  FIRST_TOKEN="$(printf '%s' "$GADD_SIGNER_PUBKEY" | awk '{print $1}')"
  case "$FIRST_TOKEN" in
    ssh-ed25519|ssh-rsa|ecdsa-sha2-*|sk-ssh-*|sk-ecdsa-*)
      [ -z "$EMAIL" ] && { echo "GADD_SIGNER_PUBKEY given as a bare/.pub key but git user.email is unset — cannot derive a principal"; exit 1; }
      KEY_NO_COMMENT="$(printf '%s' "$GADD_SIGNER_PUBKEY" | awk '{print $1, $2}')"
      printf '%s %s\n' "$EMAIL" "$KEY_NO_COMMENT" > gadd/allowed_signers
      ;;
    *)
      printf '%s\n' "$GADD_SIGNER_PUBKEY" > gadd/allowed_signers
      ;;
  esac
  echo "Signer enrolled: gadd/allowed_signers written — genesis baseline will anchor it."
else
  echo "WARNING: no GADD_SIGNER_PUBKEY given — accept-commit authorship is spoofable via git"
  echo "  author email (%ae) until a signer is enrolled. Enroll any time:"
  echo '    git config gpg.format ssh && git config user.signingkey <path-to-pub>'
  echo '    printf '"'"'%s %s\n'"'"' "$(git config user.email)" "$(cat <path-to-pub>)" > gadd/allowed_signers'
  echo '    (then commit it as a SIGNED "gadd: accept" genesis commit — see step 2 below)'
fi

AGENTS_SHA=$(sha256sum AGENTS.md | awk '{print $1}')
ACCEPT_AUTHORS="[]"; [ -n "$EMAIL" ] && ACCEPT_AUTHORS="[\"$EMAIL\"]"
cat > gadd/BASELINE.json << JSON
{
  "accepted_sha": "$(git rev-parse HEAD)",
  "agents_md_sha": "$AGENTS_SHA",
  "accept_authors": $ACCEPT_AUTHORS,
  "metrics": { "skipped_tests": 0, "max_file_loc": 400 }
}
JSON
echo "gadd-lv installed. Baseline = $(git rev-parse --short HEAD) (pre-install HEAD)."
echo "Next — commit the install, then ACCEPT it, then push BOTH commits together"
echo "(otherwise the first ratchet run flags the installation itself as a lane violation):"
echo '  1) git add -A && git commit -m "chore: install gadd-lv"'
echo '  2) jq --arg sha "$(git rev-parse HEAD)" '"'"'.accepted_sha=$sha'"'"' gadd/BASELINE.json > t && mv t gadd/BASELINE.json'
if [ -n "${GADD_SIGNER_PUBKEY:-}" ]; then
  echo '     git commit -S -am "gadd: accept $(git rev-parse --short HEAD)"   # SIGN this — a signer is enrolled'
else
  echo '     git commit -am "gadd: accept $(git rev-parse --short HEAD)"'
fi
echo '  3) git push'
echo "  4) paste AGENTS.md into Lovable Knowledge, then build."
