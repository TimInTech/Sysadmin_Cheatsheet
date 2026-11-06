#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Bitte mit sudo starten.' >&2; exit 1; }
command -v flock >/dev/null || { echo 'flock fehlt.' >&2; exit 1; }
lockdir=/run/lock/portable-sysadmin-ssh
mkdir -m 700 "$lockdir" 2>/dev/null || true
[[ -d $lockdir && ! -L $lockdir && $(stat -c '%u:%a' "$lockdir") == 0:700 && ! -L $lockdir/lock ]] || { echo 'Unsicherer Lock-Pfad.' >&2; exit 1; }
if [[ ${PORTABLE_SSH_LOCK_HELD:-} != 1 ]]; then exec 9>"$lockdir/lock"; fi
flock -x 9
policy_marker='# portable-sysadmin temporary mount target; not executable'
if [[ -f /usr/sbin/policy-rc.d && ! -L /usr/sbin/policy-rc.d && $(stat -c '%u:%a' /usr/sbin/policy-rc.d) == 0:644 && $(cat /usr/sbin/policy-rc.d) == "$policy_marker" ]]; then
  rm -- /usr/sbin/policy-rc.d
fi
state=/var/lib/portable-sysadmin-ssh
runtime=/run/portable-sysadmin-ssh
unit=/etc/systemd/system
[[ -d $state && ! -L $state ]] || { echo 'Kein verwalteter Zugang vorhanden.'; exit 0; }
username=$(cat "$state/user" 2>/dev/null || true)
uid=$(cat "$state/uid" 2>/dev/null || true)
marker=$(cat "$state/marker" 2>/dev/null || true)
[[ $username =~ ^remotehelp([0-9a-f]{6})?$ && $uid =~ ^[0-9]+$ && $marker =~ ^[0-9a-f]{32}$ ]] || { echo 'Unvollständiger Zustand; manueller Rückbau erforderlich.' >&2; exit 1; }
((uid >= 2000 && uid < 60000)) || { echo 'Ungültige UID.' >&2; exit 1; }
for name in portable-sysadmin-ssh.service portable-sysadmin-stop.service portable-sysadmin-cleanup.service portable-sysadmin-stop.timer portable-sysadmin-boot-cleanup.service; do
  if [[ -e $unit/$name || -L $unit/$name ]]; then
    [[ ! -L $unit/$name && $(head -n 1 "$unit/$name") == "# portable-sysadmin $marker" ]] || { echo "Fremde oder veränderte Unit $name bleibt erhalten." >&2; exit 1; }
  fi
done
if entry=$(getent passwd "$username"); then
  IFS=: read -r existing _ current_uid _ gecos _ _ <<< "$entry"
  [[ $existing == "$username" && $current_uid == "$uid" && $gecos == "portable-sysadmin-$marker" ]] || { echo 'Benutzeridentität stimmt nicht; kein Benutzer entfernt.' >&2; exit 1; }
fi
if [[ -f $unit/portable-sysadmin-ssh.service ]]; then
  systemctl stop portable-sysadmin-ssh.service || { echo 'SSH-Dienst konnte nicht gestoppt werden.' >&2; exit 1; }
  if systemctl is-active --quiet portable-sysadmin-ssh.service; then echo 'SSH-Dienst läuft weiterhin.' >&2; exit 1; fi
fi
if [[ -f $unit/portable-sysadmin-stop.timer ]]; then systemctl disable --now portable-sysadmin-stop.timer >/dev/null; fi
if [[ -f $unit/portable-sysadmin-boot-cleanup.service ]]; then systemctl disable portable-sysadmin-boot-cleanup.service >/dev/null; fi
if getent passwd "$username" >/dev/null; then
  awk -F: -v u="$uid" -v n="$username" '$3 == u {count++; if ($1 != n) bad=1} END {exit !(count==1 && !bad)}' /etc/passwd || { echo 'UID nicht eindeutig; keine Prozesse beendet.' >&2; exit 1; }
  timeout 5 loginctl terminate-user "$uid" >/dev/null 2>&1 || true
  pkill -KILL -u "$uid" 2>/dev/null || true
  [[ ! -L $lockdir/identity ]] || { echo 'Unsicherer Identitäts-Lock.' >&2; exit 1; }
  exec 8>"$lockdir/identity"
  flock -x 8
  entry=$(getent passwd "$username") || { echo 'Konto während Rückbau verändert.' >&2; exit 1; }
  IFS=: read -r existing _ current_uid _ gecos _ _ <<< "$entry"
  [[ $existing == "$username" && $current_uid == "$uid" && $gecos == "portable-sysadmin-$marker" ]] || { echo 'Benutzeridentität geändert.' >&2; exit 1; }
  for _ in 1 2 3 4 5; do
    if userdel "$username" 2>/dev/null; then break; fi
    sleep 1
  done
  if getent passwd "$username" >/dev/null; then echo 'Konto konnte nicht gelöscht werden; Zustand bleibt für erneuten STOP erhalten.' >&2; exit 1; fi
fi
rm -f -- "$unit/portable-sysadmin-ssh.service" "$unit/portable-sysadmin-stop.service" "$unit/portable-sysadmin-cleanup.service" "$unit/portable-sysadmin-stop.timer" "$unit/portable-sysadmin-boot-cleanup.service"
systemctl daemon-reload
if [[ -d $runtime && ! -L $runtime ]]; then
  rm -f -- "$runtime/shadow" "$runtime/pam" "$runtime/sshd_config" "$runtime/sshd.pid"
  rmdir "$runtime" || { echo 'Zusätzliche Laufzeitdateien bleiben erhalten.' >&2; exit 1; }
fi
rm -f -- "$state/user" "$state/uid" "$state/marker" "$state/expiry" "$state/check-expiry.sh" "$state/deadline.sh" "$state/stop.sh"
rmdir "$state" || { echo 'Zusätzliche Zustandsdateien bleiben erhalten.' >&2; exit 1; }
echo 'Der verwaltete SSH-Zugang wurde beendet.'
