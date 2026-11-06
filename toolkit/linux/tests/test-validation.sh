#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
check() { "$root/START_HIER.sh" --check-network "$1" >/dev/null 2>&1; }
check 192.168.1.12/24
check 10.0.2.15/24
if check 8.8.8.8/24; then echo 'public address accepted' >&2; exit 1; fi
if check 10.1.2.3/8; then echo 'network too broad accepted' >&2; exit 1; fi
if check invalid; then echo 'invalid input accepted' >&2; exit 1; fi
echo 'network validation passed'
