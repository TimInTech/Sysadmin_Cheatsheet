#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$(readlink -f "$0")")/START_HIER.sh" --stop
