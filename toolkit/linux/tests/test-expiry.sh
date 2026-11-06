#!/usr/bin/env bash
set -euo pipefail
script=$(cd "$(dirname "$0")/.." && pwd)/START_HIER.sh
now=$(date +%s)
"$script" --check-expiry "$((now+60))"
if "$script" --check-expiry "$((now-1))"; then echo 'expired deadline accepted' >&2; exit 1; fi
if "$script" --check-expiry invalid; then echo 'invalid deadline accepted' >&2; exit 1; fi
echo 'expiry validation passed'
