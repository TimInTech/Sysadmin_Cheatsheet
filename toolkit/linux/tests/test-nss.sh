#!/usr/bin/env bash
set -euo pipefail
script=$(cd "$(dirname "$0")/.." && pwd)/UID_GUARD.sh
tmp=$(mktemp -d)
trap 'rm -f "$tmp/nss"; rmdir "$tmp"' EXIT
printf 'passwd: files systemd\n' > "$tmp/nss"
"$script" --check-config "$tmp/nss"
printf 'passwd: files\n' > "$tmp/nss"
"$script" --check-config "$tmp/nss"
printf 'passwd: files sss systemd\n' > "$tmp/nss"
if "$script" --check-config "$tmp/nss"; then echo 'Unexpected NSS source accepted' >&2; exit 1; fi
printf 'passwd: files [NOTFOUND=return] systemd\n' > "$tmp/nss"
if "$script" --check-config "$tmp/nss"; then echo 'Unsupported NSS action accepted' >&2; exit 1; fi
echo 'NSS configuration validation passed'
