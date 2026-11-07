# 21 Audit Logs (Linux)

Auth-, sudo-, auditd- und Login-Logs fuer Sicherheitspruefungen.

Quellen:

- auditd Documentation: <https://linux.die.net/man/8/auditd>
- last(1) Manual: <https://man7.org/linux/man-pages/man1/last.1.html>

## 1. Auth-Logs

```bash
sudo journalctl -b --no-pager | grep -Ei 'sudo|su:|sshd|authentication|failed password|accepted password|accepted publickey' | tail -n 160
```

## 2. auditd

```bash
systemctl status auditd --no-pager 2>/dev/null || true
sudo ausearch -m USER_LOGIN,USER_AUTH,USER_ACCT 2>/dev/null | tail -n 120 || true
```

## 3. Login-Verlauf

```bash
last -a | head -n 40
lastb -a 2>/dev/null | head -n 40 || true
```

## 4. SUID-Dateien prüfen

Programme mit SUID-Bit laufen mit den Rechten ihres Besitzers, meist root. Das ist für `passwd`, `sudo` oder `mount` gewollt. Eine SUID-Datei, die zu keinem Paket gehört, sollte man sich aber genauer ansehen. Die Suche ändert nichts.

```bash
# Alle SUID-Dateien auf dem Root-Dateisystem (ohne Snapshot-Ordner)
sudo find / -xdev \( -path /timeshift -o -path /.snapshots \) -prune -o -perm -4000 -type f -print 2>/dev/null

# Nur die, die zu keinem Debian/Ubuntu-Paket gehören
sudo find / -xdev \( -path /timeshift -o -path /.snapshots \) -prune -o -perm -4000 -type f -print 2>/dev/null |
  while read -r f; do dpkg -S "$f" >/dev/null 2>&1 || echo "Nicht aus einem Paket: $f"; done
```

Typische harmlose Treffer sind `chrome-sandbox` in portablen Electron-Programmen oder AppImages. `-xdev` bleibt auf einem Dateisystem; weitere Partitionen wie `/home` getrennt prüfen, wenn sie eigene Mounts sind. Ohne den Ausschluss melden Timeshift- oder Snapper-Snapshots jede SUID-Datei ein zweites Mal.

Getestet auf: Ubuntu 26.04.
