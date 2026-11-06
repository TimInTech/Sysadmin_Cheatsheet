#!/usr/bin/env bash
# Run only in a disposable VM. This deliberately hangs START after sshd starts.
set -euo pipefail
[[ $EUID == 0 && ${PORTABLE_TEST_VM:-} == 1 ]] || { echo 'Only for a disposable VM.' >&2; exit 1; }
[[ ! -e /var/lib/portable-sysadmin-ssh ]] || { echo 'Existing access found.' >&2; exit 1; }
if getent passwd remotehelp >/dev/null; then echo 'Existing remotehelp account.' >&2; exit 1; fi
sshpass_bin=${SSHPASS_BIN:-sshpass}
command -v "$sshpass_bin" >/dev/null || { echo 'sshpass required.' >&2; exit 1; }
base=$(cd "$(dirname "$0")/.." && pwd)
test_dir=$(mktemp -d /run/portable-deadline-test.XXXXXXXX)
chmod 700 "$test_dir"
export TEST_DIR=$test_dir
cat > "$test_dir/openssl" <<'WRAP'
#!/usr/bin/env bash
tee "$TEST_DIR/password" | /usr/bin/openssl "$@"
WRAP
cat > "$test_dir/systemctl" <<'WRAP'
#!/usr/bin/env bash
if [[ ${1:-} == start && ${2:-} == portable-sysadmin-ssh.service ]]; then
  /usr/bin/systemctl "$@" || exit $?
  echo "$$" > "$TEST_DIR/hung-pid"
  exec 9>&-
  sleep 120
  exit 1
fi
exec /usr/bin/systemctl "$@"
WRAP
chmod 700 "$test_dir/openssl" "$test_dir/systemctl"
printf '1\n' | env PATH="$test_dir:$PATH" bash "$base/START_HIER.sh" > "$test_dir/start-output" 2> "$test_dir/start-error" &
start_pid=$!
cleanup() {
  [[ -f $test_dir/hung-pid ]] && kill "$(cat "$test_dir/hung-pid")" 2>/dev/null || true
  kill "$start_pid" 2>/dev/null || true
}
trap cleanup EXIT
for _ in $(seq 1 30); do [[ -s $test_dir/hung-pid ]] && break; sleep 1; done
[[ -s $test_dir/hung-pid ]] || { echo 'START did not reach test point.' >&2; exit 1; }
address=$(ip -o -4 addr show scope global | awk 'NR==1 {split($4,a,"/"); print a[1]}')
export SSHPASS
SSHPASS=$(cat "$test_dir/password")
"$sshpass_bin" -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=4 -p 22222 "remotehelp@$address" 'nohup sleep 120 >/dev/null 2>&1 & sleep 120' > "$test_dir/ssh-output" 2>&1 &
ssh_pid=$!
other_pid=''
if [[ -n ${SUDO_USER:-} ]] && id "$SUDO_USER" >/dev/null 2>&1; then
  runuser -u "$SUDO_USER" -- sleep 120 > /dev/null 2>&1 &
  other_pid=$!
fi
sleep 3
kill -0 "$ssh_pid"
test_uid=$(id -u remotehelp)
python3 - <<'PY'
import datetime, pathlib, time
expiry = int(time.time()) + 8
pathlib.Path('/var/lib/portable-sysadmin-ssh/expiry').write_text(str(expiry)+'\n')
p = pathlib.Path('/etc/systemd/system/portable-sysadmin-stop.timer')
lines = p.read_text().splitlines()
p.write_text('\n'.join('OnCalendar='+datetime.datetime.fromtimestamp(expiry).strftime('%Y-%m-%d %H:%M:%S') if x.startswith('OnCalendar=') else x for x in lines)+'\n')
PY
/usr/bin/systemctl daemon-reload
/usr/bin/systemctl restart portable-sysadmin-stop.timer
sleep 16
kill -0 "$start_pid" || { echo 'START did not remain hung.' >&2; exit 1; }
if kill -0 "$ssh_pid" 2>/dev/null; then echo 'SSH session survived deadline while START held lock.' >&2; kill "$ssh_pid" || true; exit 1; fi
if /usr/bin/systemctl is-active --quiet portable-sysadmin-ssh.service; then echo 'SSH daemon survived deadline.' >&2; exit 1; fi
# Ignore zombies, which are already terminated and cannot be killed.
# shellcheck disable=SC2009
if ps -u "$test_uid" -o stat= | grep -Eq '^[[:space:]]*[^Z[:space:]]'; then echo 'User processes survived deadline.' >&2; exit 1; fi
echo 'Deadline terminated active session and detached processes despite hung START: OK'
if [[ -n $other_pid ]]; then
  kill -0 "$other_pid" || { echo 'Unrelated user process was affected.' >&2; exit 1; }
  kill "$other_pid" 2>/dev/null || true
  echo 'Unrelated user process remains active: OK'
fi
kill "$(cat "$test_dir/hung-pid")" 2>/dev/null || true
wait "$start_pid" || true
for _ in $(seq 1 20); do [[ ! -d /var/lib/portable-sysadmin-ssh ]] && break; sleep 1; done
[[ ! -d /var/lib/portable-sysadmin-ssh ]] || { echo 'Cleanup did not finish.' >&2; exit 1; }
trap - EXIT
rm -f "$test_dir/openssl" "$test_dir/systemctl" "$test_dir/password" "$test_dir/hung-pid" "$test_dir/start-output" "$test_dir/start-error" "$test_dir/ssh-output"
rmdir "$test_dir"
