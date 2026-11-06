#!/usr/bin/env bash
set -euo pipefail
config=/etc/ssh/sshd_config
folder=/usr/local/lib/sysadmin-toolkit
unit=/etc/systemd/system
[[ $EUID == 0 ]] || { echo 'Bitte mit sudo ausführen.' >&2; exit 1; }
[[ -d /run/systemd/system ]] || { echo 'Dieses Skript benötigt systemd.' >&2; exit 1; }
stop_access() {
  local entry user uid expected_uid gecos token marker begin end
  [[ -f $folder/owner ]] || { echo 'Kein Toolkit-Zugang gefunden.'; return 0; }
  read -r user token expected_uid < "$folder/owner"
  [[ $user =~ ^remotehelp[0-9]*$ && $token =~ ^[0-9a-f]{32}$ ]] || { echo 'Toolkit-Metadaten ungültig.' >&2; return 1; }
  marker="SysadminToolkit-$token"; begin="# BEGIN SYSADMIN TOOLKIT REMOTEHELP $token"; end="# END SYSADMIN TOOLKIT REMOTEHELP $token"
  if entry=$(getent passwd "$user"); then
    IFS=: read -r _ _ uid _ gecos _ _ <<< "$entry"
    [[ $gecos == "$marker" && ( -z $expected_uid || $uid == "$expected_uid" ) ]] || { echo 'Benutzeridentität geändert; Konto bleibt erhalten.' >&2; return 1; }
    passwd -l "$user" >/dev/null
    userdel "$user" || { echo 'Konto konnte nicht entfernt werden. Offene Sitzungen beenden und STOP wiederholen.' >&2; return 1; }
  fi
  if [[ -f $config ]] && grep -Fxq "$begin" "$config"; then
    [[ $(grep -Fxc "$begin" "$config") == 1 && $(grep -Fxc "$end" "$config") == 1 ]] || { echo 'SSH-Markierungen unvollständig; bitte manuell prüfen.' >&2; return 1; }
    sed -i "/^$begin$/,/^$end$/d" "$config"
    sshd -t
    if systemctl is-active --quiet ssh.service; then
      if [[ -f $folder/service-started ]]; then systemctl stop ssh.service; else systemctl reload ssh.service; fi
    fi
  fi
  for file in "$unit/sysadmin-toolkit-stop.timer" "$unit/sysadmin-toolkit-stop.service"; do
    [[ ! -e $file ]] || [[ $(head -n 1 "$file") == "# SysadminToolkit-$token" ]] || { echo "Fremde Unit bleibt erhalten: $file" >&2; return 1; }
  done
  if [[ -f $unit/sysadmin-toolkit-stop.timer ]]; then systemctl disable --now sysadmin-toolkit-stop.timer >/dev/null; fi
  if [[ -f $unit/sysadmin-toolkit-stop.service ]]; then systemctl disable sysadmin-toolkit-stop.service >/dev/null; fi
  if [[ -f $folder/service-enabled ]] && systemctl is-enabled --quiet ssh.service; then systemctl disable ssh.service >/dev/null; fi
  rm -f "$unit/sysadmin-toolkit-stop.timer" "$unit/sysadmin-toolkit-stop.service"
  systemctl daemon-reload
  rm -f "$folder/owner" "$folder/START_HIER.sh" "$folder/service-started" "$folder/service-enabled"
  rmdir "$folder" 2>/dev/null || true
  echo 'Toolkit-Zugang entfernt. SSH-Dienst, Pakete und persönliche Dateien bleiben erhalten.'
}
if [[ ${1:-} == --stop ]]; then stop_access; exit; fi
[[ $# == 0 ]] || { echo 'Aufruf: sudo bash START_HIER.sh' >&2; exit 1; }
if [[ -e $folder || -e $unit/sysadmin-toolkit-stop.timer || -e $unit/sysadmin-toolkit-stop.service ]] || { [[ -f $config ]] && grep -Fq '# BEGIN SYSADMIN TOOLKIT REMOTEHELP' "$config"; }; then
  echo 'Ein Toolkit-Zugang existiert bereits. Erst STOP_HIER.sh ausführen.' >&2; exit 1
fi
for command in python3 ip systemctl; do command -v "$command" >/dev/null || { echo "$command fehlt." >&2; exit 1; }; done
if ! command -v sshd >/dev/null; then
  command -v apt-get >/dev/null || { echo 'apt-get fehlt.' >&2; exit 1; }
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server
fi
if grep -Eiq '^[[:space:]]*Match[[:space:]]+' "$config" ||
   grep -Ei '^[[:space:]]*Include[[:space:]]+' "$config" | grep -Ev '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/\*\.conf[[:space:]]*$' >/dev/null ||
   grep -Eiq '^[[:space:]]*(Match|Include)[[:space:]]+' /etc/ssh/sshd_config.d/*.conf 2>/dev/null; then
  echo 'Bestehende Match-/Include-Regeln bitte vor der Einrichtung manuell prüfen.' >&2
  exit 1
fi
mapfile -t choices < <(ip -o -4 addr show scope global | awk '{print $2, $4}')
networks=()
for item in "${choices[@]}"; do
  dev=${item%% *}; cidr=${item#* }
  [[ -e /sys/class/net/$dev/device ]] || continue
  if network=$(python3 - "$cidr" <<'PY'
import ipaddress, sys
try:
    interface = ipaddress.IPv4Interface(sys.argv[1])
    allowed = [ipaddress.ip_network(n) for n in ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16')]
    if not 16 <= interface.network.prefixlen <= 30 or not any(interface.network.subnet_of(n) for n in allowed):
        raise ValueError()
    print(interface.ip, interface.network)
except ValueError:
    sys.exit(1)
PY
  ); then networks+=("$dev $network"); fi
done
((${#networks[@]})) || { echo 'Kein geeignetes physisches privates IPv4-Netz gefunden.' >&2; exit 1; }
for i in "${!networks[@]}"; do printf '%s) %s\n' "$((i+1))" "${networks[$i]}"; done
read -r -p 'Netznummer: ' selection
if [[ ! $selection =~ ^[0-9]+$ ]] || ((selection < 1 || selection > ${#networks[@]})); then echo 'Ungültige Auswahl.' >&2; exit 1; fi
read -r dev address network <<< "${networks[$((selection-1))]}"
read -r -p '1 = temporär (2 Stunden), 2 = dauerhaft: ' mode
[[ $mode == 1 || $mode == 2 ]] || { echo 'Ungültige Auswahl.' >&2; exit 1; }
name=remotehelp; suffix=0
while getent passwd "$name" >/dev/null; do suffix=$((suffix+1)); name="remotehelp$suffix"; ((suffix <= 99)) || { echo 'Kein freier Benutzername.' >&2; exit 1; }; done
[[ ! -e /home/$name ]] || { echo 'Das vorgesehene Homeverzeichnis existiert bereits.' >&2; exit 1; }
token=$(python3 -c 'import secrets; print(secrets.token_hex(16))')
marker="SysadminToolkit-$token"; begin="# BEGIN SYSADMIN TOOLKIT REMOTEHELP $token"; end="# END SYSADMIN TOOLKIT REMOTEHELP $token"
password=$(python3 -c 'import secrets,string; print("".join(secrets.choice(string.ascii_letters+string.digits) for _ in range(20))+"aA1!")')
install -d -m 700 "$folder"
printf '%s %s\n' "$name" "$token" > "$folder/owner"
install -m 700 "$0" "$folder/START_HIER.sh"
trap 'stop_access || echo "Rückbau fehlgeschlagen: STOP_HIER.sh erneut ausführen." >&2' ERR
useradd -m -c "$marker" -s /bin/bash "$name"
printf '%s %s %s\n' "$name" "$token" "$(id -u "$name")" > "$folder/owner"
cat >> "$config" <<CONFIG

$begin
Match User $name Address !$network,*
    DenyUsers $name
    PasswordAuthentication no
    PubkeyAuthentication no
    KbdInteractiveAuthentication no
Match User $name Address $network
    PasswordAuthentication yes
    PubkeyAuthentication no
    KbdInteractiveAuthentication no
    PermitEmptyPasswords no
$end
CONFIG
install -d -m 755 /run/sshd
sshd -t
inside=$(sshd -T -C "user=$name,host=localhost,addr=$address")
outside=$(sshd -T -C "user=$name,host=localhost,addr=8.8.8.8")
outside6=$(sshd -T -C "user=$name,host=localhost,addr=2001:db8::1")
grep -Fxq 'passwordauthentication yes' <<< "$inside" || { echo 'Passwortanmeldung im LAN nicht wirksam.' >&2; false; }
if ! grep -Fxq "denyusers $name" <<< "$outside" || ! grep -Fxq 'passwordauthentication no' <<< "$outside" || ! grep -Fxq 'pubkeyauthentication no' <<< "$outside" || ! grep -Fxq 'kbdinteractiveauthentication no' <<< "$outside"; then echo 'Zugang außerhalb des LAN nicht sicher gesperrt.' >&2; false; fi
if ! grep -Fxq "denyusers $name" <<< "$outside6" || ! grep -Fxq 'passwordauthentication no' <<< "$outside6" || ! grep -Fxq 'pubkeyauthentication no' <<< "$outside6" || ! grep -Fxq 'kbdinteractiveauthentication no' <<< "$outside6"; then echo 'IPv6-Zugang nicht sicher gesperrt.' >&2; false; fi
port=$(awk '$1 == "port" { print $2; exit }' <<< "$inside")
[[ $port =~ ^[0-9]+$ ]] || { echo 'SSH-Port konnte nicht ermittelt werden.' >&2; false; }
if [[ $mode == 1 ]]; then
  target=$(date -d '+2 hours' '+%Y-%m-%d %H:%M:%S')
  cat > "$unit/sysadmin-toolkit-stop.service" <<SERVICE
# SysadminToolkit-$token
[Unit]
Description=Remove Sysadmin Toolkit SSH access
After=local-fs.target
Before=ssh.service ssh.socket
[Service]
Type=oneshot
ExecStart=$folder/START_HIER.sh --stop
[Install]
WantedBy=multi-user.target
SERVICE
  cat > "$unit/sysadmin-toolkit-stop.timer" <<TIMER
# SysadminToolkit-$token
[Unit]
Description=Expire Sysadmin Toolkit SSH access
[Timer]
OnCalendar=$target
OnBootSec=1min
Persistent=true
[Install]
WantedBy=timers.target
TIMER
  systemctl daemon-reload
  systemctl enable sysadmin-toolkit-stop.service >/dev/null
  systemctl enable --now sysadmin-toolkit-stop.timer >/dev/null
fi
if [[ $mode == 2 ]] && ! systemctl is-enabled --quiet ssh.service && ! systemctl is-enabled --quiet ssh.socket; then
  : > "$folder/service-enabled"
  systemctl enable ssh.service >/dev/null
fi
if systemctl is-active --quiet ssh.service; then systemctl reload ssh.service; else : > "$folder/service-started"; systemctl start ssh.service; fi
printf '%s:%s\n' "$name" "$password" | chpasswd
trap - ERR
printf '\nIP: %s\nBenutzer: %s\nPasswort: %s\nSSH-Befehl: ssh -p %s %s@%s\n' "$address" "$name" "$password" "$port" "$name" "$address"
[[ $mode != 1 ]] || echo "Ablauf: $target; nach Neustart erfolgt der Rückbau früher."
echo "Zugriff nur aus $network; vorhandene Firewall kann Port $port blockieren."
unset password
