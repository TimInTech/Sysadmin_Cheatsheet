# Log-Analyse und Monitoring

Ein wesentlicher Teil der Systemadministration ist das Lesen und Auswerten von Logs, um Fehler, Angriffe und Leistungseinbrüche zu finden.

## 1. Linux Log-Analyse

Unter modernen Linux-Systemen (wie Linux Mint, Ubuntu, Debian) werden Systemlogs über `systemd` (journalctl) oder klassisch in `/var/log` verwaltet.

### 1.1 System-Logs auslesen (journalctl)
```bash
# Alle Logs vom aktuellen Bootvorgang anzeigen
journalctl -b

# Logs in Echtzeit mitverfolgen (wie tail -f)
journalctl -f

# Nur Fehlermeldungen (Errors) anzeigen
journalctl -p err -b

# Logs eines bestimmten Dienstes (z.B. Nginx) anzeigen
journalctl -u nginx

# Logs von heute anzeigen
journalctl --since today
```

### 1.2 Klassische Log-Dateien auslesen
```bash
# Systemlog live verfolgen
tail -f /var/log/syslog

# Authentifizierungs-Logs (Login-Versuche, SSH) überwachen
tail -f /var/log/auth.log

# Nach bestimmten Fehlern in Logs suchen (z.B. "error" in Apache-Logs)
grep -i "error" /var/log/apache2/error.log
```

### 1.3 Kernel-Meldungen (dmesg)
Wenn es Treiber- oder Hardwareprobleme gibt (z.B. USB-Stick wird nicht erkannt), hilft `dmesg`.
```bash
# Kernel-Meldungen anzeigen
dmesg

# Live verfolgen
dmesg -w

# Nur Fehlermeldungen anzeigen
dmesg -l err
```

---

## 2. Windows Log-Analyse (PowerShell)

Windows protokolliert Ereignisse in der Ereignisanzeige (Event Viewer). Mit der PowerShell lassen sich diese effizient durchsuchen.

### 2.1 Event Logs abfragen
```powershell
# Die neuesten 20 System-Ereignisse anzeigen
Get-EventLog -LogName System -Newest 20

# Nur Fehler (Error) im System-Log der letzten 24 Stunden anzeigen
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddDays(-1)

# Logs einer bestimmten Anwendung abfragen
Get-EventLog -LogName Application -Newest 50 | Where-Object {$_.Source -eq "Outlook"}
```

### 2.2 Live-Monitoring in PowerShell
Es gibt kein direktes Äquivalent zu `tail -f` für das Windows Event Log, aber du kannst Log-Dateien von Applikationen live verfolgen:
```powershell
# Logdatei in Echtzeit überwachen
Get-Content -Path "C:\Pfad\zur\Anwendung.log" -Wait -Tail 10
```
