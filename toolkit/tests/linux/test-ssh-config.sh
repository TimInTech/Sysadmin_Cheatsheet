#!/usr/bin/env bash
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
ssh-keygen -q -t ed25519 -N '' -f "$work/key"
cat > "$work/sshd_config" <<CONFIG
Port 22222
HostKey $work/key
Match User remotehelp Address !192.168.5.0/24,*
    DenyUsers remotehelp
    PasswordAuthentication no
    PubkeyAuthentication no
    KbdInteractiveAuthentication no
Match User remotehelp Address 192.168.5.0/24
    PasswordAuthentication yes
    PubkeyAuthentication no
    KbdInteractiveAuthentication no
    PermitEmptyPasswords no
CONFIG
sshd -t -f "$work/sshd_config"
inside=$(sshd -T -f "$work/sshd_config" -C user=remotehelp,host=localhost,addr=192.168.5.3)
outside=$(sshd -T -f "$work/sshd_config" -C user=remotehelp,host=localhost,addr=192.168.6.3)
outside6=$(sshd -T -f "$work/sshd_config" -C user=remotehelp,host=localhost,addr=2001:db8::1)
grep -Fxq 'passwordauthentication yes' <<< "$inside"
for output in "$outside" "$outside6"; do
  grep -Fxq 'denyusers remotehelp' <<< "$output"
  grep -Fxq 'passwordauthentication no' <<< "$output"
  grep -Fxq 'pubkeyauthentication no' <<< "$output"
  grep -Fxq 'kbdinteractiveauthentication no' <<< "$output"
done
echo 'SSH access restrictions verified.'
