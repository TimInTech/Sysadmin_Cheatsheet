#!/usr/bin/env bash
# Run by systemd when the temporary access expires; never wait for the setup lock.
set -euo pipefail
[[ $EUID == 0 ]] || exit 1
state=/var/lib/portable-sysadmin-ssh
unit=/etc/systemd/system
lockdir=/run/lock/portable-sysadmin-ssh
[[ -d $state && ! -L $state ]] || exit 0
username=$(cat "$state/user" 2>/dev/null || true)
uid=$(cat "$state/uid" 2>/dev/null || true)
marker=$(cat "$state/marker" 2>/dev/null || true)
expiry=$(cat "$state/expiry" 2>/dev/null || true)
[[ $username =~ ^remotehelp([0-9a-f]{6})?$ && $uid =~ ^[0-9]+$ && $marker =~ ^[0-9a-f]{32}$ && $expiry =~ ^[0-9]+$ ]] || { echo 'Ungültiger Ablaufzustand.' >&2; exit 1; }
((uid >= 2000 && uid < 60000)) || { echo 'Ungültige UID.' >&2; exit 1; }
(( $(date +%s) >= expiry )) || { echo 'Ablaufzeit noch nicht erreicht.' >&2; exit 1; }
if [[ -f $unit/portable-sysadmin-ssh.service && ! -L $unit/portable-sysadmin-ssh.service && $(head -n 1 "$unit/portable-sysadmin-ssh.service") == "# portable-sysadmin $marker" ]]; then
  timeout 10 systemctl stop --no-block portable-sysadmin-ssh.service || echo 'SSH-Stopp konnte nicht angefordert werden.' >&2
fi
# STOP takes this short identity lock only after terminating the user's processes.
[[ -d $lockdir && ! -L $lockdir && $(stat -c '%u:%a' "$lockdir") == 0:700 && ! -L $lockdir/identity ]] || { echo 'Unsicherer Identitäts-Lock.' >&2; exit 1; }
exec 8>"$lockdir/identity"
flock -w 10 -x 8 || { echo 'Identitätsprüfung blockiert.' >&2; exit 1; }
if entry=$(getent passwd "$username"); then
  IFS=: read -r existing _ current_uid _ gecos _ _ <<< "$entry"
  if [[ $existing == "$username" && $current_uid == "$uid" && $gecos == "portable-sysadmin-$marker" ]]; then
    awk -F: -v u="$uid" -v n="$username" '$3 == u {count++; if ($1 != n) bad=1} END {exit !(count==1 && !bad)}' /etc/passwd || { echo 'UID nicht eindeutig; keine Prozesse beendet.' >&2; exit 1; }
    timeout 5 loginctl terminate-user "$uid" >/dev/null 2>&1 || true
    pkill -KILL -u "$uid" 2>/dev/null || true
  else
    echo 'Benutzeridentität stimmt nicht; keine Prozesse beendet.' >&2
    exit 1
  fi
fi
flock -u 8
if [[ -f $unit/portable-sysadmin-cleanup.service && ! -L $unit/portable-sysadmin-cleanup.service && $(head -n 1 "$unit/portable-sysadmin-cleanup.service") == "# portable-sysadmin $marker" ]]; then
  timeout 10 systemctl start --no-block portable-sysadmin-cleanup.service || { echo 'Rückbau konnte nicht angestoßen werden.' >&2; exit 1; }
fi
