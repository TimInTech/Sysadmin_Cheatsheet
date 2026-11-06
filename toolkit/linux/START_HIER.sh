#!/usr/bin/env bash
set -euo pipefail
validate_network() {
  python3 - "$1" <<'PY'
import ipaddress, sys
try:
    iface = ipaddress.IPv4Interface(sys.argv[1])
    allowed = [ipaddress.IPv4Network(x) for x in ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16')]
    if iface.network.prefixlen < 16 or not any(iface.network.subnet_of(x) for x in allowed):
        raise ValueError()
    print(iface.ip, iface.network)
except ValueError:
    sys.exit(1)
PY
}
if [[ ${1:-} == --check-network ]]; then validate_network "${2:-}"; exit; fi
if [[ ${1:-} == --check-expiry ]]; then
  [[ ${2:-} =~ ^[0-9]+$ ]] && (( $(date +%s) < $2 )); exit
fi
[[ $# == 0 ]] || { echo 'Aufruf: sudo bash START_HIER.sh' >&2; exit 1; }
[[ $EUID == 0 ]] || { echo 'Bitte mit sudo starten.' >&2; exit 1; }
[[ -d /run/systemd/system ]] || { echo 'systemd ist erforderlich.' >&2; exit 1; }
command -v flock >/dev/null || { echo 'flock fehlt.' >&2; exit 1; }
lockdir=/run/lock/portable-sysadmin-ssh
mkdir -m 700 "$lockdir" 2>/dev/null || true
[[ -d $lockdir && ! -L $lockdir && $(stat -c '%u:%a' "$lockdir") == 0:700 && ! -L $lockdir/lock ]] || { echo 'Unsicherer Lock-Pfad.' >&2; exit 1; }
exec 9>"$lockdir/lock"
flock -x 9
state=/var/lib/portable-sysadmin-ssh
runtime=/run/portable-sysadmin-ssh
unit=/etc/systemd/system
for path in "$state" "$runtime" "$unit/portable-sysadmin-ssh.service" "$unit/portable-sysadmin-stop.service" "$unit/portable-sysadmin-cleanup.service" "$unit/portable-sysadmin-stop.timer" "$unit/portable-sysadmin-boot-cleanup.service"; do
  [[ ! -e $path && ! -L $path ]] || { echo "Bereits vorhanden: $path. Erst STOP ausführen." >&2; exit 1; }
done
for cmd in python3 ip systemctl ssh-keygen openssl ss getent; do
  command -v "$cmd" >/dev/null || { echo "$cmd fehlt; bitte zuerst installieren." >&2; exit 1; }
done
policy_marker='# portable-sysadmin temporary mount target; not executable'
if [[ -f /usr/sbin/policy-rc.d && ! -L /usr/sbin/policy-rc.d && $(stat -c '%u:%a' /usr/sbin/policy-rc.d) == 0:644 && $(cat /usr/sbin/policy-rc.d) == "$policy_marker" ]]; then
  rm -- /usr/sbin/policy-rc.d
fi
if ! command -v sshd >/dev/null; then
  for cmd in apt-get unshare mount; do
    command -v "$cmd" >/dev/null || { echo "$cmd fehlt." >&2; exit 1; }
  done
  if systemctl cat ssh.service >/dev/null 2>&1 || systemctl cat ssh.socket >/dev/null 2>&1 || [[ -e /usr/sbin/policy-rc.d || -L /usr/sbin/policy-rc.d ]]; then
    echo 'Vorhandene SSH-Diensteinrichtung oder policy-rc.d: Installation abgebrochen.' >&2; exit 1
  fi
  echo 'OpenSSH-Server wird installiert; sein Standarddienst bleibt deaktiviert.'
  install_tmp=$(mktemp -d /run/portable-ssh-install.XXXXXXXX)
  printf '#!/bin/sh\nexit 101\n' > "$install_tmp/policy"
  chmod 700 "$install_tmp/policy"
  # The host sees only a non-executable placeholder; the policy is mounted only for apt.
  (umask 022; set -o noclobber; printf '%s\n' "$policy_marker" > /usr/sbin/policy-rc.d) || { echo 'policy-rc.d bereits vorhanden.' >&2; exit 1; }
  chmod 644 /usr/sbin/policy-rc.d
  policy_id=$(stat -c '%d:%i' /usr/sbin/policy-rc.d)
  cleanup_install() {
    if [[ -f /usr/sbin/policy-rc.d && $(stat -c '%d:%i' /usr/sbin/policy-rc.d) == "$policy_id" && $(cat /usr/sbin/policy-rc.d) == "$policy_marker" ]]; then rm -f /usr/sbin/policy-rc.d; fi
    rm -f "$install_tmp/policy"
    rmdir "$install_tmp" 2>/dev/null || true
  }
  trap cleanup_install EXIT
  trap 'exit 1' INT TERM
  # shellcheck disable=SC2016
  if ! unshare --mount --propagation private bash -c 'set -e; mount --bind "$1" /usr/sbin/policy-rc.d; apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server' -- "$install_tmp/policy"; then
    echo 'OpenSSH-Installation fehlgeschlagen.' >&2; exit 1
  fi
  systemctl disable --now ssh.service ssh.socket >/dev/null 2>&1 || true
  cleanup_install
  trap - EXIT INT TERM
fi
[[ -f /etc/pam.d/sshd && -f /etc/ssh/ssh_host_ed25519_key ]] || { echo 'OpenSSH-PAM-Konfiguration oder Hostschlüssel fehlt.' >&2; exit 1; }
mapfile -t candidates < <(ip -o -4 addr show scope global | awk '{print $2, $4}')
choices=()
for candidate in "${candidates[@]}"; do
  dev=${candidate%% *}; cidr=${candidate#* }
  [[ $dev != tun* && $dev != tap* && $dev != wg* && $dev != tailscale* && $dev != docker* && $dev != br-* && $dev != veth* ]] || continue
  [[ -e /sys/class/net/$dev/device ]] || continue
  if validate_network "$cidr" >/dev/null; then choices+=("$candidate"); fi
done
((${#choices[@]})) || { echo 'Keine geeignete private Netzwerkschnittstelle gefunden.' >&2; exit 1; }
printf 'Lokales Netzwerk auswählen:\n'
for i in "${!choices[@]}"; do printf '%s) %s\n' "$((i+1))" "${choices[$i]}"; done
read -r -p 'Nummer: ' selection
if [[ ! $selection =~ ^[0-9]+$ ]] || ((selection < 1 || selection > ${#choices[@]})); then echo 'Ungültige Auswahl.' >&2; exit 1; fi
candidate=${choices[$((selection-1))]}; dev=${candidate%% *}; cidr=${candidate#* }
read -r address network < <(validate_network "$cidr")
username=remotehelp
if getent passwd "$username" >/dev/null; then username="remotehelp$(python3 -c 'import secrets; print(secrets.token_hex(3))')"; fi
getent passwd "$username" >/dev/null && { echo 'Benutzername belegt.' >&2; exit 1; }
port=22222
if ss -H -ltn "sport = :$port" | grep -q .; then echo "Port $port ist bereits belegt." >&2; exit 1; fi
# Reserve identity metadata before account creation; a random GECOS marker prevents deletion of replacements.
marker=$(python3 -c 'import secrets; print(secrets.token_hex(16))')
uid=$(python3 -c 'import pwd; used={p.pw_uid for p in pwd.getpwall()}; print(next(i for i in range(2000,60000) if i not in used))')
expiry=$(($(date +%s)+7200))
mkdir -m 700 "$state" "$runtime"
trap 'PORTABLE_SSH_LOCK_HELD=1 "$state/stop.sh" --rollback || true' ERR
trap 'PORTABLE_SSH_LOCK_HELD=1 "$state/stop.sh" --rollback || true; exit 1' INT TERM
cp "$(dirname "$(readlink -f "$0")")/STOP_HIER.sh" "$state/stop.sh"
chmod 700 "$state/stop.sh"
cp "$(dirname "$(readlink -f "$0")")/DEADLINE.sh" "$state/deadline.sh"
chmod 700 "$state/deadline.sh"
printf '%s\n' "$username" > "$state/user"
printf '%s\n' "$uid" > "$state/uid"
printf '%s\n' "$marker" > "$state/marker"
printf '%s\n' "$expiry" > "$state/expiry"
cat > "$state/check-expiry.sh" <<'CHECK'
#!/usr/bin/env bash
set -euo pipefail
expiry=$(cat /var/lib/portable-sysadmin-ssh/expiry)
[[ $expiry =~ ^[0-9]+$ ]] && (( $(date +%s) < expiry ))
CHECK
chmod 700 "$state/check-expiry.sh"
target=$(date -d "@$expiry" '+%Y-%m-%d %H:%M:%S')
cat > "$unit/portable-sysadmin-stop.service" <<SERVICE
# portable-sysadmin $marker
[Unit]
Description=Immediately revoke expired Portable Sysadmin SSH access
[Service]
Type=oneshot
ExecStart=$state/deadline.sh
SERVICE
cat > "$unit/portable-sysadmin-cleanup.service" <<SERVICE
# portable-sysadmin $marker
[Unit]
Description=Remove expired Portable Sysadmin SSH resources
[Service]
Type=oneshot
ExecStart=$state/stop.sh --timer
SERVICE
cat > "$unit/portable-sysadmin-stop.timer" <<TIMER
# portable-sysadmin $marker
[Unit]
Description=Expire Portable Sysadmin SSH access
[Timer]
OnCalendar=$target
Persistent=true
AccuracySec=1s
[Install]
WantedBy=timers.target
TIMER
cat > "$unit/portable-sysadmin-boot-cleanup.service" <<SERVICE
# portable-sysadmin $marker
[Unit]
Description=Remove interrupted Portable Sysadmin access after boot
After=local-fs.target
[Service]
Type=oneshot
ExecStart=$state/stop.sh --boot
[Install]
WantedBy=multi-user.target
SERVICE
systemctl daemon-reload
systemctl enable --now portable-sysadmin-stop.timer >/dev/null
systemctl enable portable-sysadmin-boot-cleanup.service >/dev/null
# The real account remains password-locked, so other daemons cannot use this password.
useradd -M -N -g nogroup -u "$uid" -c "portable-sysadmin-$marker" -d /nonexistent -s /bin/bash "$username"
password=$(python3 -c 'import secrets,string; print("".join(secrets.choice(string.ascii_letters+string.digits) for _ in range(20)))')
hash=$(printf '%s\n' "$password" | openssl passwd -6 -stdin)
printf '%s:%s:20000:0:99999:7:::\n' "$username" "$hash" > "$runtime/shadow"
chmod 600 "$runtime/shadow"
printf 'account requisite pam_exec.so quiet %s/check-expiry.sh\n' "$state" > "$runtime/pam"
cat /etc/pam.d/sshd >> "$runtime/pam"
chmod 600 "$runtime/pam"
cat > "$runtime/sshd_config" <<CONFIG
Port $port
ListenAddress $address
PidFile $runtime/sshd.pid
HostKey /etc/ssh/ssh_host_ed25519_key
PasswordAuthentication yes
PubkeyAuthentication no
KbdInteractiveAuthentication no
UsePAM yes
PermitRootLogin no
PermitEmptyPasswords no
AllowUsers $username@$network
AllowTcpForwarding no
AllowAgentForwarding no
X11Forwarding no
PermitTunnel no
CONFIG
install -d -m 755 /run/sshd
sshd -t -f "$runtime/sshd_config"
cat > "$unit/portable-sysadmin-ssh.service" <<SERVICE
# portable-sysadmin $marker
[Unit]
Description=Portable Sysadmin temporary SSH
After=network-online.target
Wants=network-online.target
[Service]
Type=simple
PrivateMounts=yes
BindReadOnlyPaths=$runtime/shadow:/etc/shadow
BindReadOnlyPaths=$runtime/pam:/etc/pam.d/sshd
ExecStartPre=$state/check-expiry.sh
ExecStart=/usr/sbin/sshd -D -e -f $runtime/sshd_config
SERVICE
systemctl daemon-reload
"$state/check-expiry.sh" || { echo 'Einrichtung dauerte zu lange; Zugang abgelaufen.' >&2; false; }
systemctl start portable-sysadmin-ssh.service
sleep 1
systemctl is-active --quiet portable-sysadmin-ssh.service
"$state/check-expiry.sh" || { echo 'Zugang bereits abgelaufen.' >&2; false; }
trap - ERR INT TERM
printf '\nAdresse: %s\nBenutzer: %s\nPasswort: %s\nSSH: ssh -p %s %s@%s\n' "$address" "$username" "$password" "$port" "$username" "$address"
printf 'Ablauf: %s. Nach einem Neustart wird der Zugang beendet.\n' "$(date -d "@$expiry")"
printf 'Das Netz %s auf %s ist zugelassen. Vorhandene Firewalls können den Port blockieren.\n' "$network" "$dev"
echo 'In dieser Sitzung funktionieren Wechsel zu anderen lokalen Konten sowie sudo-Passwortprüfungen wegen der isolierten Kontodaten nicht wie gewohnt.'
unset password hash
