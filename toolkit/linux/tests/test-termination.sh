#!/usr/bin/env bash
set -euo pipefail
script=$(cd "$(dirname "$0")/.." && pwd)/TERMINATE_USER.sh
tmp=$(mktemp -d)
trap 'rm -f "$tmp/loginctl" "$tmp/pkill" "$tmp/ps"; rmdir "$tmp"' EXIT
printf '#!/bin/sh\nexit 1\n' > "$tmp/loginctl"
printf '#!/bin/sh\nexit 2\n' > "$tmp/pkill"
printf '#!/bin/sh\nexit 1\n' > "$tmp/ps"
chmod 700 "$tmp/loginctl" "$tmp/pkill" "$tmp/ps"
if PATH="$tmp:$PATH" "$script" 2000 2>/dev/null; then echo 'pkill error not propagated' >&2; exit 1; fi
printf '#!/bin/sh\nexit 0\n' > "$tmp/pkill"
printf '#!/bin/sh\nprintf "S\\n"\n' > "$tmp/ps"
if PATH="$tmp:$PATH" "$script" 2000 2>/dev/null; then echo 'living process not detected' >&2; exit 1; fi
printf '#!/bin/sh\nexit 1\n' > "$tmp/ps"
PATH="$tmp:$PATH" "$script" 2000
echo 'termination failure handling passed'
