#!/usr/bin/env bash
set -euo pipefail
ADAPTER=""
for a in "$@"; do case "$a" in --adapter=*) ADAPTER="${a#*=}";; esac; done
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
case "$ADAPTER" in
  lv) exec bash "$ROOT/adapters/lv/bin/install.sh" ;;
  cc) exec bash "$ROOT/adapters/cc/bin/install.sh" ;;
  *)  echo "usage: install.sh --adapter=lv|cc"; exit 1 ;;
esac
