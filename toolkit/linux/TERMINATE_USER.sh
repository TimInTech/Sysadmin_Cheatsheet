#!/usr/bin/env bash
# Caller must verify the account marker, exclusive UID, and hold the identity lock.
set -euo pipefail
[[ $# == 1 && $1 =~ ^[0-9]+$ ]] || exit 1
uid=$1
((uid >= 2000 && uid < 60000)) || exit 1
timeout 5 loginctl terminate-user "$uid" >/dev/null 2>&1 || true
pkill_rc=0
pkill -KILL -u "$uid" 2>/dev/null || pkill_rc=$?
if ((pkill_rc > 1)); then echo 'Prozesse konnten nicht zuverlässig beendet werden.' >&2; exit 1; fi
for _ in 1 2 3 4 5 6 7 8 9 10; do
  status=''; ps_rc=0
  status=$(ps -u "$uid" -o stat=) || ps_rc=$?
  if ((ps_rc > 1)); then echo 'Prozessliste konnte nicht geprüft werden.' >&2; exit 1; fi
  if [[ -z $status ]] || ! grep -Eq '^[[:space:]]*[^ZX[:space:]]' <<< "$status"; then exit 0; fi
  sleep 0.2
done
echo 'Benutzerprozesse laufen nach dem Ablauf weiterhin.' >&2
exit 1
