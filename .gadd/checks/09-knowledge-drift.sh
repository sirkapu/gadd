#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"
[ -f AGENTS.md ] || { finding "knowledge-drift" "MAJOR" "AGENTS.md missing from repo"; exit 0; }
recorded="$(baseline_get '.agents_md_sha')"
[ -z "$recorded" ] && exit 0
current="$(sha256sum AGENTS.md | awk '{print $1}')"
[ "$current" != "$recorded" ] && \
  finding "knowledge-drift" "MAJOR" "AGENTS.md changed since last knowledge sync — re-sync Lovable Knowledge and update baseline" "AGENTS.md"
exit 0
