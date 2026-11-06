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
failed=0
if [[ -f $unit/portable-sysadmin-ssh.service && ! -L $unit/portable-sysadmin-ssh.service && $(head -n 1 "$unit/portable-sysadmin-ssh.service") == "# portable-sysadmin $marker" ]]; then
  if ! timeout 10 systemctl stop portable-sysadmin-ssh.service; then
    echo 'SSH-Stopp fehlgeschlagen; versuche gezieltes Beenden.' >&2
    timeout 5 systemctl kill --kill-whom=all --signal=KILL portable-sysadmin-ssh.service || true
    timeout 10 systemctl stop portable-sysadmin-ssh.service || failed=1
  fi
  active=''; active=$(timeout 5 systemctl show -p ActiveState --value portable-sysadmin-ssh.service) || failed=1
  case $active in inactive|failed) ;; *) echo 'SSH-Dienst ist nicht nachweislich beendet.' >&2; failed=1;; esac
else
  echo 'Verwaltete SSH-Unit fehlt oder wurde verändert.' >&2
  failed=1
fi
# UID reuse is prevented while the marker is checked and this lock is held.
if [[ -d $lockdir && ! -L $lockdir && $(stat -c '%u:%a' "$lockdir") == 0:700 && ! -L $lockdir/identity ]]; then
  exec 8>"$lockdir/identity"
  if flock -w 10 -x 8; then
    entry=''; getent_rc=0
    entry=$(getent passwd "$username") || getent_rc=$?
    if ((getent_rc == 0)); then
      IFS=: read -r existing _ current_uid _ gecos _ _ <<< "$entry"
      if [[ $existing == "$username" && $current_uid == "$uid" && $gecos == "portable-sysadmin-$marker" ]]; then
        if ! "$state/uid-guard.sh" --owned "$uid" "$username"; then
          echo 'Benutzersitzungen nicht zuverlässig beendet.' >&2; failed=1
        elif [[ -f $state/processes-armed && ! -L $state/processes-armed && $(cat "$state/processes-armed") == "$marker" ]]; then
          "$state/terminate-user.sh" "$uid" || { echo 'Benutzersitzungen nicht zuverlässig beendet.' >&2; failed=1; }
        else
          "$state/uid-guard.sh" --no-processes "$uid" "$username" || { echo 'Fremde Prozesse mit dieser UID; keine beendet.' >&2; failed=1; }
        fi
      else
        echo 'Benutzeridentität stimmt nicht; keine Prozesse beendet.' >&2; failed=1
      fi
    elif ((getent_rc != 2)) || awk -F: -v n="$username" '$1 == n {found=1} END {exit !found}' /etc/passwd; then
      echo 'Benutzerauflösung fehlgeschlagen; Prozesse nicht beendet.' >&2; failed=1
    fi
    flock -u 8
  else
    echo 'Identitätsprüfung blockiert.' >&2; failed=1
  fi
else
  echo 'Unsicherer Identitäts-Lock.' >&2; failed=1
fi
if [[ -f $unit/portable-sysadmin-cleanup.service && ! -L $unit/portable-sysadmin-cleanup.service && $(head -n 1 "$unit/portable-sysadmin-cleanup.service") == "# portable-sysadmin $marker" ]]; then
  timeout 10 systemctl start --no-block portable-sysadmin-cleanup.service || { echo 'Rückbau konnte nicht angestoßen werden.' >&2; failed=1; }
else
  echo 'Rückbau-Unit fehlt oder wurde verändert.' >&2; failed=1
fi
exit "$failed"
