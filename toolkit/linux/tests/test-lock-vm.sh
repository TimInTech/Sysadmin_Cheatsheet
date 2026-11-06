#!/usr/bin/env bash
# Run only in a disposable systemd VM, never on the host.
set -euo pipefail
[[ $EUID == 0 && ${PORTABLE_TEST_VM:-} == 1 ]] || { echo 'Only for a disposable VM: run as root with PORTABLE_TEST_VM=1.' >&2; exit 1; }
[[ ! -e /var/lib/portable-sysadmin-ssh ]] || { echo 'Existing access found; aborting.' >&2; exit 1; }
if getent passwd remotehelp >/dev/null; then echo 'Existing remotehelp account; aborting.' >&2; exit 1; fi
base=$(cd "$(dirname "$0")/.." && pwd)
test_dir=$(mktemp -d /run/portable-lock-test.XXXXXXXX)
chmod 700 "$test_dir"
install -d -m 700 /run/lock/portable-sysadmin-ssh
exec 8>/run/lock/portable-sysadmin-ssh/lock
flock -x 8
printf '1\n' | bash "$base/START_HIER.sh" 8>&- > "$test_dir/start-output" 2> "$test_dir/start-error" &
start_pid=$!
sleep 2
[[ ! -d /var/lib/portable-sysadmin-ssh ]]
kill -0 "$start_pid"
echo 'START waits for lock: OK'
flock -u 8
wait "$start_pid"
flock -x 8
bash "$base/STOP_HIER.sh" 8>&- > "$test_dir/stop-output" 2>&1 &
stop_pid=$!
sleep 2
[[ -d /var/lib/portable-sysadmin-ssh ]]
kill -0 "$stop_pid"
echo 'STOP waits for lock: OK'
flock -u 8
wait "$stop_pid"
[[ ! -d /var/lib/portable-sysadmin-ssh ]]
if getent passwd remotehelp >/dev/null; then echo 'Account still present' >&2; exit 1; fi
echo 'STOP removes its account after release: OK'
rm -f "$test_dir/start-output" "$test_dir/start-error" "$test_dir/stop-output"
rmdir "$test_dir"
