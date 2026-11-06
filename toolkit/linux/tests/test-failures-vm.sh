#!/usr/bin/env bash
# Run only in a disposable systemd VM with no existing toolkit access.
set -euo pipefail
[[ $EUID == 0 && ${PORTABLE_TEST_VM:-} == 1 ]] || { echo 'Only for a disposable VM.' >&2; exit 1; }
[[ ! -e /var/lib/portable-sysadmin-ssh && ! -e /run/systemd/userdb/io.portable-test ]] || exit 1
base=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d /run/portable-failure-test.XXXXXXXX)
chmod 700 "$tmp"
"$base/UID_GUARD.sh" --available 3500 remotehelp
touch /run/systemd/userdb/io.portable-test
if "$base/UID_GUARD.sh" --available 3500 remotehelp 2>/dev/null; then echo 'Additional userdb provider accepted' >&2; exit 1; fi
rm /run/systemd/userdb/io.portable-test
echo 'Additional UserDB provider rejected: OK'
useradd -M -N -g nogroup -u 3500 portablecheckone
useradd -M -N -g nogroup -o -u 3500 portablechecktwo
if "$base/UID_GUARD.sh" --owned 3500 portablecheckone 2>/dev/null; then echo 'Duplicate UID accepted' >&2; exit 1; fi
userdel portablechecktwo
userdel portablecheckone
echo 'Duplicate local UID rejected: OK'
setpriv --reuid 3501 --regid 65534 --clear-groups sleep 120 &
orphan_pid=$!
sleep 1
if "$base/UID_GUARD.sh" --available 3501 remotehelp 2>/dev/null; then
  kill "$orphan_pid" 2>/dev/null || true
  echo 'UID with existing orphan process accepted' >&2; exit 1
fi
kill "$orphan_pid" 2>/dev/null || true
wait "$orphan_pid" 2>/dev/null || true
echo 'UID used by an orphan process rejected: OK'
printf '1\n' | bash "$base/START_HIER.sh" > "$tmp/output" 2> "$tmp/error"
printf '1\n' > /var/lib/portable-sysadmin-ssh/expiry
cat > "$tmp/systemctl" <<'WRAP'
#!/usr/bin/env bash
if [[ ${1:-} == stop && ${2:-} == portable-sysadmin-ssh.service ]] || [[ ${1:-} == kill ]] || [[ ${1:-} == start && ${3:-} == portable-sysadmin-cleanup.service ]]; then exit 1; fi
exec /usr/bin/systemctl "$@"
WRAP
chmod 700 "$tmp/systemctl"
rc=0
PATH="$tmp:$PATH" bash /var/lib/portable-sysadmin-ssh/deadline.sh > "$tmp/deadline-output" 2> "$tmp/deadline-error" || rc=$?
[[ $rc != 0 ]] || { echo 'Stop and cleanup failures reported as success' >&2; exit 1; }
grep -q 'SSH-Stopp fehlgeschlagen' "$tmp/deadline-error"
grep -q 'Rückbau konnte nicht angestoßen werden' "$tmp/deadline-error"
test -d /var/lib/portable-sysadmin-ssh
echo 'Failed SSH stop and cleanup reported; state preserved: OK'
bash "$base/STOP_HIER.sh" > "$tmp/stop-output" 2>&1
[[ ! -d /var/lib/portable-sysadmin-ssh ]]
rm -f "$tmp/output" "$tmp/error" "$tmp/systemctl" "$tmp/deadline-output" "$tmp/deadline-error" "$tmp/stop-output"
rmdir "$tmp"
