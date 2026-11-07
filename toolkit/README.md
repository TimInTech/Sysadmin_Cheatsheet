# Sysadmin-Toolkit: Updates, Diagnose und SSH-Zugang

Drei voneinander **unabhängige** Werkzeuge in einem kleinen Paket. Du brauchst nur das, was du gerade willst. **SSH musst du für Updates und Diagnose nicht einrichten.**

## Was möchtest du tun?

| Ich möchte ... | Datei (im Ordner `windows`) | SSH nötig? |
| --- | --- | --- |
| Nach der Neuinstallation **alle Windows-Updates und Treiber** holen | `WINDOWS_AKTUALISIEREN.cmd` | Nein |
| Den Rechner **prüfen** (Systeminfo, Windows-Diagnose, Netzwerk-Diagnose) | im Unterordner `zusatz`: `SYSTEMINFO.cmd`, `WINDOWS_DIAGNOSE.cmd`, `NETZWERK_DIAGNOSE.cmd` | Nein |
| Den Rechner **reparieren** | im Unterordner `zusatz`: `SYSTEM_REPARIEREN.cmd` (verlangt eine Bestätigung) | Nein |
| Jemandem **Fernzugriff** geben (zum Beispiel einer KI oder einer helfenden Person) | `START_HIER.cmd`, später `STOP_HIER.cmd` | Das ist SSH |
| Den SSH-Zugang **reparieren** (prüft zuerst, repariert nach Bestätigung) | im Unterordner `zusatz`: `SSH_REPARIEREN.cmd` | Nur wenn SSH genutzt wird |

**Nur die `.cmd`-Dateien starten**, ein Doppelklick reicht. Die `.ps1`-Dateien sind die Programme dahinter. Braucht ein Werkzeug Administratorrechte, fragt Windows selbst nach: **Ja** wählen. Danach geht es in einem **neuen Fenster** weiter, das offen bleibt, bis du Enter drückst. Jeder Schritt wird mit `[OK]` oder `[PROBLEM]` angezeigt, und am Ende steht, was geändert wurde. Unter Ubuntu und Debian gibt es im Ordner `linux` nur den SSH-Zugang (`START_HIER.sh`, `STOP_HIER.sh`). Updates und Diagnose stehen dort in der [Linux-Sammlung](../02_Linux/01_Update_und_Bereinigung.md).

## Teil 1: Windows aktualisieren (nach Neuinstallation)

1. Doppelklick auf **`WINDOWS_AKTUALISIEREN.cmd`**. Windows fragt nach Administratorrechten: **Ja**.
2. Mit `j` bestätigen. Das Programm lädt das Update-Modul und installiert bis zu vier Durchläufe Updates und Treiber über Microsoft Update.
3. Es startet **nicht von selbst neu**. Wenn es einen Neustart verlangt, starte neu und führe die Datei **noch einmal** aus, bis keine neuen Updates mehr erscheinen. Meist reichen ein bis zwei Neustarts.

Die Hintergründe und die einzelnen Befehle stehen in [Windows komplett aktualisieren](../01_Windows_11/01_Update_und_Upgrade.md#1-nach-der-neuinstallation-alles-in-einem-durchlauf). Dafür ist Windows PowerShell 5.1 nötig (das normale blaue Windows-PowerShell, das jedes Windows 10 und 11 mitbringt).

## Teil 2: Diagnose und Reparatur

Im Ordner `windows\zusatz` liegen kleine Programme, die einen Bericht im Fenster ausgeben. Sie ändern nichts, außer `SYSTEM_REPARIEREN.cmd` und `SSH_REPARIEREN.cmd`. Beide prüfen zuerst und ändern erst, wenn du `JA` eintippst.

**`SSH_REPARIEREN.cmd`** prüft und behebt auf Wunsch:

1. OpenSSH-Server fehlt → wird nachgeladen (Internet nötig)
2. Hostschlüssel fehlt → wird erzeugt
3. SSH-Konfiguration fehlt oder ist fehlerhaft → die alte Datei wird gesichert, die Windows-Standardkonfiguration eingesetzt
4. `administrators_authorized_keys` hat zu offene Rechte → Rechte werden wie von Microsoft beschrieben beschränkt
5. SSH-Dienst deaktiviert oder gestoppt → wird auf „Manuell“ gestellt bzw. gestartet
6. Reste eines abgebrochenen `START_HIER` → werden entfernt

Danach prüft es noch einmal. Eine Firewall-Freigabe legt es **nicht** an; das macht `START_HIER` beim Einschalten, und zwar nur für das Heimnetz.

## Teil 3: Fernzugriff per SSH

Mit diesem Teil kann sich eine zweite Person (oder eine KI) über das **eigene Heimnetz** auf deinem Computer anmelden, zum Beispiel, um etwas zu reparieren oder ein System neu aufzusetzen. Die Verbindung heißt **SSH**: Man tippt Befehle in ein Textfenster, und sie werden auf deinem Computer ausgeführt.

## Das Wichtigste vorab

- Der Zugang gilt nur im **Heimnetz** (WLAN oder Kabel zu Hause), nicht aus dem Internet. Am Router musst du nichts einstellen.
- Es wird ein **zusätzlicher Benutzer** mit **zufälligem Passwort** angelegt. Dein eigenes Konto und deine Passwörter bleiben unberührt.
- Der Zugang endet **automatisch nach zwei Stunden** oder sofort, wenn du `STOP_HIER` startest.
- Nur auf Computern verwenden, die dir gehören oder die du verwalten darfst.

## 1. Herunterladen

1. **[Hier klicken: SSH-Toolkit.zip herunterladen](https://github.com/TimInTech/Sysadmin_Cheatsheet/releases/latest/download/SSH-Toolkit.zip)**. Der Download startet sofort (ca. 19 KB), es öffnet sich keine Webseite.
2. Die Datei `SSH-Toolkit.zip` im Ordner *Downloads* mit Rechtsklick → *Alle extrahieren* entpacken.
3. Öffne im entpackten Ordner `SSH-Toolkit`: `windows` (Windows) oder `linux` (Ubuntu/Debian).

Diese ZIP-Datei enthält nur das Toolkit. Wer die ganze Sammlung will: [komplettes Repository als ZIP](https://github.com/TimInTech/Sysadmin_Cheatsheet/archive/refs/heads/main.zip). Dort liegt das Toolkit im Ordner `toolkit`.

Du brauchst den **ganzen** Ordner `windows` beziehungsweise `linux`, nicht nur eine einzelne Datei.

## 2. Zugang einschalten

### Windows 10 und 11

1. Doppelklick auf **`START_HIER.cmd`**.
2. Windows fragt, ob die App Änderungen vornehmen darf: **Ja**. Es öffnet sich ein neues Fenster, das die sechs Schritte einzeln mit `[OK]` anzeigt.
3. Das Programm sucht dein Heimnetz. Ist **nur ein Netzwerk** vorhanden (der Normalfall, zum Beispiel nur WLAN), wählt es das **automatisch**. Nur bei **mehreren** Netzwerken erscheint eine nummerierte Liste (zum Beispiel `1) Ethernet`, `2) WLAN`). Tippe dann die Zahl vor der Zeile ein, in der auch der andere Computer hängt, und drücke Enter.
4. Tippe **`1`** (zwei Stunden) oder **`2`** (dauerhaft) und drücke Enter.
5. Am Ende steht **„FERTIG: Zugang ist eingeschaltet“**, eine Liste der Änderungen sowie **IP-Adresse, Benutzername, Passwort** und eine Zeile, die mit `ssh` beginnt. Gib diese Angaben der Person, die sich verbinden soll. Das Passwort nur persönlich, per Telefon oder in einem sicheren Chat weitergeben.

Beim ersten Start lädt Windows eventuell die SSH-Komponente nach. Dafür muss der Computer online sein.

### Ubuntu und Debian

1. Öffne im Ordner `linux` ein Terminal (Rechtsklick → *Im Terminal öffnen*).
2. Tippe:

   ```bash
   sudo bash START_HIER.sh
   ```

3. Bei einem einzelnen Netzwerk wählt das Programm es automatisch. Bei mehreren: Tippe die Zahl vor der Zeile deines Heimnetzes. Danach `1` (zwei Stunden) oder `2` (dauerhaft).
4. Gib die angezeigten Angaben an die andere Person weiter.

## 3. Verbinden (auf dem anderen Computer)

Auf dem zweiten Computer ein Terminal (Linux) oder die PowerShell (Windows) öffnen und die angezeigte Zeile eingeben, zum Beispiel:

```text
ssh -p 22 remotehelp@IP-ADRESSE
```

Dann das Passwort eingeben. Beim Tippen erscheint **nichts** auf dem Bildschirm, das ist normal. Beim allerersten Verbinden fragt SSH, ob man dem Computer vertraut: Mit `yes` bestätigen, wenn die Verbindung wirklich zu deinem Computer gehört.

## 4. Zugang ausschalten

- **Windows:** Doppelklick auf **`STOP_HIER.cmd`**, Windows-Abfrage mit **Ja** bestätigen. Jeder entfernte Teil wird mit `[OK]` angezeigt.
- **Ubuntu/Debian:** `sudo bash STOP_HIER.sh`

Der zusätzliche Benutzer und die Freigabe werden entfernt. Deine Dateien und der installierte SSH-Dienst bleiben erhalten. Läuft noch eine SSH-Sitzung, vorher die Sitzung beenden und STOP danach noch einmal starten.

## Wenn etwas nicht klappt

| Problem | Lösung |
| --- | --- |
| Windows zeigt „Der Computer wurde durch Windows geschützt“ | **Weitere Informationen** → **Trotzdem ausführen**. Die Datei kommt aus dem Download. |
| „Die Administratorrechte wurden nicht erteilt“ | Bei der Windows-Abfrage **Ja** wählen. Ohne Administratorrechte ändert das Toolkit nichts. |
| Das Fenster schließt sich sofort | Eine `.ps1`-Datei wurde angeklickt oder die Datei liegt allein im Ordner. Die `.cmd`-Datei starten und den ganzen Ordner `windows` entpackt lassen. |
| `FEHLER: Reste eines früheren Zugangs gefunden` | Zuerst `STOP_HIER.cmd`, dann `START_HIER.cmd` erneut. Hilft das nicht: `zusatz\SSH_REPARIEREN.cmd`. |
| Rote Zeile `FEHLER: ...` | Darunter steht, was zu tun ist. Bricht `START_HIER` ab, nimmt es seine Änderungen selbst wieder zurück. |
| Die andere Person kann sich nicht verbinden | Beide Computer müssen im **gleichen Heimnetz** sein, nicht im Gastnetz. Eine Firewall oder ein VPN kann die Verbindung blockieren. |
| Linux meldet „Match-/Include-Regeln prüfen“ | Es gibt eine eigene SSH-Konfiguration. Das Skript bricht dann zur Sicherheit ab. Siehe [TECHNIK.md](TECHNIK.md). |

## Weitere Werkzeuge

Im Ordner `windows/zusatz` liegen Hilfen für die Fehlersuche unter Windows (Systeminfo, Windows-Diagnose, Netzwerk-Diagnose, SSH reparieren, System reparieren). Sie sind für den Fernzugriff nicht nötig. `SYSTEM_REPARIEREN` und `SSH_REPARIEREN` ändern erst nach Eingabe von `JA`.

## Für Fachleute

Aufbau, Sicherheitsmerkmale, Tests und Grenzen: [TECHNIK.md](TECHNIK.md).

## Teststand

Praktisch getestet: Windows 10 (Einrichtung, Passwortanmeldung, STOP, automatischer Ablauf; Verbindung zu Ubuntu in beide Richtungen). **Nicht** praktisch getestet: Linux START/STOP und Windows 11.

Die automatische Abfrage der Administratorrechte, die Schrittanzeige und die Reparatur in `SSH_REPARIEREN` sind mit automatischen Tests (Pester, Windows-CI) geprüft, aber noch **nicht praktisch** auf einem Windows-Rechner getestet.
