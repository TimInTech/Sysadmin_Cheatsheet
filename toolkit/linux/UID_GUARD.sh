#!/usr/bin/env bash
set -euo pipefail
check_config() {
  local file=$1 lines
  lines=$(awk '/^[[:space:]]*passwd[[:space:]]*:/ {sub(/#.*/, ""); sub(/^[^:]*:[[:space:]]*/, ""); $1=$1; print}' "$file")
  [[ $lines == files || $lines == 'files systemd' ]]
}
if [[ ${1:-} == --check-config ]]; then check_config "${2:?}"; exit; fi
[[ $# == 3 && ( $1 == --available || $1 == --owned || $1 == --no-processes ) && $2 =~ ^[0-9]+$ ]] || exit 1
mode=$1; uid=$2; username=$3
((uid >= 2000 && uid < 60000)) || exit 1
if [[ $mode == --available || $mode == --no-processes ]]; then
  python3 - "$uid" <<'PYPROC'
import pathlib, sys
uid = int(sys.argv[1])
for proc in pathlib.Path('/proc').iterdir():
    if not proc.name.isdigit():
        continue
    try:
        lines = (proc / 'status').read_text().splitlines()
    except FileNotFoundError:
        continue
    except OSError:
        sys.exit(2)
    uid_line = next((line for line in lines if line.startswith('Uid:')), None)
    if uid_line is None:
        sys.exit(2)
    if uid in map(int, uid_line.split()[1:]):
        sys.exit(1)
PYPROC
fi
[[ $mode != --no-processes ]] || exit 0
check_config /etc/nsswitch.conf || { echo 'Nicht unterstützte NSS-Benutzerquellen.' >&2; exit 1; }
# Only the systemd DynamicUser backend is accepted. It allocates 61184..65519.
if grep -Eq '^[[:space:]]*passwd[[:space:]]*:[[:space:]]*files[[:space:]]+systemd' /etc/nsswitch.conf; then
  for dir in /etc/userdb /run/userdb /usr/lib/userdb; do
    [[ ! -L $dir ]] || { echo 'UserDB-Pfad ist ein Symlink.' >&2; exit 1; }
    if [[ -d $dir ]]; then
      items=$(find "$dir" -mindepth 1 -maxdepth 1 -print -quit) || { echo 'UserDB-Daten nicht prüfbar.' >&2; exit 1; }
      [[ -z $items ]] || { echo 'Zusätzliche systemd-UserDB-Daten vorhanden.' >&2; exit 1; }
    fi
  done
  if [[ -d /run/systemd/userdb ]]; then
    [[ ! -L /run/systemd/userdb ]] || { echo 'UserDB-Pfad ist ein Symlink.' >&2; exit 1; }
    items=$(find /run/systemd/userdb -mindepth 1 -maxdepth 1 ! -name io.systemd.DynamicUser ! -name io.systemd.Multiplexer -print -quit) || { echo 'UserDB-Anbieter nicht prüfbar.' >&2; exit 1; }
    [[ -z $items ]] || { echo 'Zusätzlicher systemd-UserDB-Anbieter vorhanden.' >&2; exit 1; }
  fi
  for service in systemd-homed.service systemd-machined.service; do
    rc=0
    timeout 5 systemctl is-active --quiet "$service" || rc=$?
    if ((rc != 3 && rc != 4)); then echo "$service ist aktiv oder sein Status nicht prüfbar." >&2; exit 1; fi
  done
  result=''; rc=0
  result=$(timeout 5 getent -s systemd passwd "$uid") || rc=$?
  if [[ $rc != 0 && $rc != 2 ]]; then echo 'systemd-NSS nicht zuverlässig prüfbar.' >&2; exit 1; fi
  if [[ $mode == --available && $rc == 0 ]]; then echo 'UID in systemd-NSS bereits belegt.' >&2; exit 1; fi
  if [[ $mode == --owned && $rc == 0 && ${result%%:*} != "$username" ]]; then echo 'UID-Konflikt in systemd-NSS.' >&2; exit 1; fi
fi
if [[ $mode == --available ]]; then
  rc=0
  timeout 5 getent -s files passwd "$uid" >/dev/null || rc=$?
  if ((rc != 2)); then echo 'UID lokal belegt oder nicht zuverlässig prüfbar.' >&2; exit 1; fi
else
  awk -F: -v u="$uid" -v n="$username" '$3 == u {count++; if ($1 != n) bad=1} END {exit !(count==1 && !bad)}' /etc/passwd || { echo 'UID lokal nicht eindeutig.' >&2; exit 1; }
fi
