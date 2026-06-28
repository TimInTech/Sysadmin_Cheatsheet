# Automatisierung und Cronjobs

Zeitgesteuerte Aufgaben sind essenziell für Backups, Wartungsskripte und System-Updates.

## 1. Linux Cronjobs

Unter Linux wird die Zeitsteuerung durch den `cron`-Daemon erledigt. Jeder Benutzer hat seine eigene Crontab (Cron-Tabelle).

### 1.1 Crontab verwalten
```bash
# Eigene Crontab bearbeiten (öffnet den Standard-Editor)
crontab -e

# Crontab des Root-Benutzers bearbeiten (für systemweite Aufgaben)
sudo crontab -e

# Eigene Crontab anzeigen
crontab -l
```

### 1.2 Syntax eines Cronjobs
Ein Cronjob besteht aus 5 Zeit-Parametern, gefolgt vom auszuführenden Befehl:
`* * * * * Befehl`
(Minute) (Stunde) (Tag des Monats) (Monat) (Wochentag)

**Beispiele:**
```bash
# Jeden Tag um 03:00 Uhr nachts ein Backup-Skript ausführen
0 3 * * * /pfad/zum/backup.sh

# Alle 15 Minuten
*/15 * * * * /pfad/zum/skript.sh

# Jeden Montag um 08:30 Uhr
30 8 * * 1 /pfad/zum/skript.sh
```

---

## 2. Windows Aufgabenplanung (Task Scheduler)

Unter Windows übernimmt die "Aufgabenplanung" diese Rolle. In der CLI lässt sich das über `schtasks` steuern.

### 2.1 Aufgaben erstellen und verwalten (CMD / PowerShell)
```cmd
:: Eine tägliche Aufgabe erstellen, die um 03:00 Uhr ein Skript ausführt
schtasks /create /tn "TäglichesBackup" /tr "C:\Skripte\backup.bat" /sc daily /st 03:00

:: Aufgabe manuell sofort starten
schtasks /run /tn "TäglichesBackup"

:: Status einer Aufgabe abfragen
schtasks /query /tn "TäglichesBackup"

:: Aufgabe wieder löschen (ohne Bestätigungsrückfrage)
schtasks /delete /tn "TäglichesBackup" /f
```
