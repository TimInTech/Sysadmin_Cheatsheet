# 30 Monitoring und Healthchecks (Linux)

Ein einfacher Gesundheitscheck reicht für die meisten Heimserver: Er schaut einmal am Tag nach Plattenplatz, fehlgeschlagenen Diensten und freiem Arbeitsspeicher und meldet sich nur, wenn etwas nicht stimmt. Diese Seite zeigt zuerst die Befehle für den schnellen Blick, dann ein kleines Prüfskript mit systemd-Timer und am Ende den Weg zu Prometheus.

Quellen:

- Healthchecks.io Bash-Beispiele: <https://healthchecks.io/docs/bash/>
- Healthchecks.io Fehler melden: <https://healthchecks.io/docs/signaling_failures/>
- Prometheus Node Exporter: <https://prometheus.io/docs/guides/node-exporter/>

## 1. Schneller Überblick

Alles hier liest nur und ändert nichts.

```bash
# Laufzeit und Last der letzten 1, 5 und 15 Minuten
uptime

# Arbeitsspeicher und Swap
free -h

# Belegung der echten Dateisysteme
df -hT -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs

# Fehlgeschlagene Dienste (leere Liste = alles gut)
systemctl --failed

# Fehler seit dem letzten Start
journalctl -p err -b --no-pager | tail -n 30

# Temperaturen (Paket lm-sensors)
sensors
```

Getestet auf: Ubuntu 26.04.

## 2. Was überwacht werden sollte

| Was | Warnschwelle | Befehl oder Seite |
| --- | --- | --- |
| Plattenplatz | über 85 % belegt | `df -h`, [Speicher und Performance](05_Speicher_und_Performance.md) |
| Dienste | jeder fehlgeschlagene Dienst | `systemctl --failed` |
| Arbeitsspeicher | dauerhaft unter 10 % verfügbar | `free -h` |
| Plattengesundheit | jede SMART-Warnung | [SMART und Festplattendiagnose](../03_Datenrettung_und_Forensik/04_SMART_und_Festplattendiagnose.md) |
| Backups | letzter erfolgreicher Lauf älter als erwartet | [restic](10_Backup_mit_Restic.md), [BorgBackup](19_BorgBackup.md) |
| Erreichbarkeit | SSH, Web, DNS antworten | [DNS-Diagnose](23_DNS_Diagnose.md), [Netzwerk und Dienste](03_Netzwerk_und_Dienste.md) |

## 3. Eigenes Prüfskript

Das Skript prüft Plattenplatz, Dienste und Arbeitsspeicher. Es gibt Probleme aus und endet dann mit Exit-Code 1, sonst mit 0. Es ändert nichts am System.

`/usr/local/sbin/healthcheck.sh`:

```bash
#!/usr/bin/env bash
# Daily health check: disk usage, failed units, available memory.
set -u
SCHWELLE_DISK=85      # percent used
SCHWELLE_RAM=10       # percent available
probleme=0

# Disk usage of real file systems
while read -r ziel belegt; do
  belegt=${belegt%\%}
  case $belegt in ''|*[!0-9]*) continue ;; esac
  if [ "$belegt" -ge "$SCHWELLE_DISK" ]; then
    echo "WARNUNG: $ziel ist zu ${belegt} % belegt"
    probleme=1
  fi
done < <(df --output=target,pcent -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs | tail -n +2)

# Failed systemd units
fehlgeschlagen=$(systemctl --failed --no-legend --plain | awk '{print $1}')
if [ -n "$fehlgeschlagen" ]; then
  echo "WARNUNG: fehlgeschlagene Dienste: $(echo "$fehlgeschlagen" | tr '\n' ' ')"
  probleme=1
fi

# Available memory (/proc/meminfo is language independent, unlike free)
ram=$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {printf "%d", a * 100 / t}' /proc/meminfo)
if [ "$ram" -lt "$SCHWELLE_RAM" ]; then
  echo "WARNUNG: nur ${ram} % Arbeitsspeicher verfügbar"
  probleme=1
fi

[ "$probleme" -eq 0 ] && echo "OK: keine Auffälligkeiten"
exit "$probleme"
```

```bash
# Rechte setzen und einmal von Hand testen
sudo chmod 755 /usr/local/sbin/healthcheck.sh
sudo /usr/local/sbin/healthcheck.sh; echo "Exit-Code: $?"
```

Getestet auf: Ubuntu 26.04 (ShellCheck ohne Befund, Lauf mit Exit-Code 0 und mit künstlich gesenkter Schwelle mit Exit-Code 1).

## 4. Täglich per systemd-Timer ausführen

Die Grundlagen zu Timern stehen auf [systemd Timer und Journal](09_Systemd_Timer_und_Journal.md).

`/etc/systemd/system/healthcheck.service`:

```ini
[Unit]
Description=Taeglicher Gesundheitscheck

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/healthcheck.sh
```

`/etc/systemd/system/healthcheck.timer`:

```ini
[Unit]
Description=Gesundheitscheck taeglich um 07:00

[Timer]
OnCalendar=*-*-* 07:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now healthcheck.timer

# Verifikation
systemctl list-timers healthcheck.timer
sudo systemctl start healthcheck.service
journalctl -u healthcheck.service -n 20 --no-pager
```

Bei einem Problem steht der Dienst danach als fehlgeschlagen in `systemctl --failed` und die Warnungen im Journal.

**Rollback:**

```bash
sudo systemctl disable --now healthcheck.timer
sudo rm /etc/systemd/system/healthcheck.service /etc/systemd/system/healthcheck.timer /usr/local/sbin/healthcheck.sh
sudo systemctl daemon-reload
```

Nicht getestet (Timer und Service nicht installiert).

## 5. Benachrichtigung von außen (optional)

Ein lokaler Check merkt nicht, wenn der ganze Server aus ist. Dafür gibt es Dienste wie Healthchecks.io: Der Server meldet sich regelmäßig, und bleibt die Meldung aus, kommt eine Nachricht. Laut Doku zählt `/fail` oder ein Exit-Code ungleich 0 am Ende der Ping-Adresse als Fehler.

Die Ping-Adresse enthält eine geheime ID. Sie gehört deshalb in eine Datei mit eingeschränkten Rechten und nicht in die Unit-Datei.

```bash
# Ping-Adresse einmalig ablegen (PING_URL ist ein PLATZHALTER, aus dem eigenen Konto)
sudo install -m 600 /dev/null /etc/healthcheck.url
sudo nano /etc/healthcheck.url
```

Dann in `healthcheck.service` die `ExecStart`-Zeile ersetzen. In Unit-Dateien steht `$$` für ein einfaches `$`, weil systemd `$` sonst selbst als Variable auswertet:

```ini
ExecStart=/bin/bash -c '/usr/local/sbin/healthcheck.sh; rc=$$?; curl -fsS -m 10 --retry 5 -o /dev/null "$$(cat /etc/healthcheck.url)/$$rc"; exit $$rc'
```

Die `$$`-Schreibweise ist mit einer Test-Unit unter systemd 259 geprüft, der Ping selbst ist nicht getestet.

## 6. Mehr Kennzahlen: Prometheus Node Exporter

Wer Verläufe und Grafiken möchte, installiert den Node Exporter. Er liefert Messwerte auf Port 9100, die ein Prometheus-Server abholt und Grafana anzeigt. Unter Ubuntu und Debian gibt es ein Paket.

> **Warnung:** Port 9100 zeigt viele Systemdetails. Ihn nur im eigenen Netz freigeben und per Firewall auf den Prometheus-Server begrenzen (siehe [nftables Firewall](11_Nftables_Firewall.md)).

```bash
sudo apt install prometheus-node-exporter
systemctl status prometheus-node-exporter --no-pager

# Messwerte lokal abrufen (Ausschnitt)
curl -s http://localhost:9100/metrics | grep -m 5 '^node_filesystem_avail_bytes'
```

Nicht getestet. Paket `prometheus-node-exporter` ist in Ubuntu 26.04 in Version 1.10.2 verfügbar (`apt-cache policy` geprüft).
