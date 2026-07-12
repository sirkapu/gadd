#!/usr/bin/env bash
set -euo pipefail
ADAPTER=""
for a in "$@"; do case "$a" in --adapter=*) ADAPTER="${a#*=}";; esac; done
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
case "$ADAPTER" in
  lv) exec bash "$ROOT/adapters/lv/bin/install.sh" ;;
  cc) echo "gadd-cc extraction in progress — see adapters/cc/README.md"; exit 1 ;;
  *)  echo "usage: install.sh --adapter=lv|cc"; exit 1 ;;
esac
