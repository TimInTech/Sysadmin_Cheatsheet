# Sysadmin-Toolkit: Updates, Diagnose und SSH-Zugang

Drei voneinander **unabhängige** Werkzeuge in einem kleinen Paket. Du brauchst nur das, was du gerade willst. **SSH musst du für Updates und Diagnose nicht einrichten.**

## Was möchtest du tun?

| Ich möchte ... | Datei (im Ordner `windows`) | SSH nötig? |
| --- | --- | --- |
| Nach der Neuinstallation **alle Windows-Updates und Treiber** holen | `WINDOWS_AKTUALISIEREN.cmd` (Rechtsklick, *Als Administrator ausführen*) | Nein |
| Den Rechner **prüfen** (Systeminfo, Windows-Diagnose, Netzwerk-Diagnose) | im Unterordner `zusatz`: `SYSTEMINFO.cmd`, `WINDOWS_DIAGNOSE.cmd`, `NETZWERK_DIAGNOSE.cmd` | Nein |
| Den Rechner **reparieren** | im Unterordner `zusatz`: `SYSTEM_REPARIEREN.cmd` (verlangt eine Bestätigung) | Nein |
| Jemandem **Fernzugriff** geben (zum Beispiel einer KI oder einer helfenden Person) | `START_HIER.cmd`, später `STOP_HIER.cmd` | Das ist SSH |
| Den SSH-Dienst **reparieren** | im Unterordner `zusatz`: `SSH_REPARIEREN.cmd` | Nur wenn SSH genutzt wird |

Ein Doppelklick auf eine Datei reicht, ein anderes Programm muss vorher nicht laufen. Unter Ubuntu und Debian gibt es im Ordner `linux` nur den SSH-Zugang (`START_HIER.sh`, `STOP_HIER.sh`). Updates und Diagnose stehen dort in der [Linux-Sammlung](../02_Linux/01_Update_und_Bereinigung.md).

## Teil 1: Windows aktualisieren (nach Neuinstallation)

1. Rechtsklick auf **`WINDOWS_AKTUALISIEREN.cmd`** → **Als Administrator ausführen**, mit **Ja** bestätigen.
2. Mit `j` bestätigen. Das Programm lädt das Update-Modul und installiert bis zu vier Durchläufe Updates und Treiber über Microsoft Update.
3. Es startet **nicht von selbst neu**. Wenn es einen Neustart verlangt, starte neu und führe die Datei **noch einmal** aus, bis keine neuen Updates mehr erscheinen. Meist reichen ein bis zwei Neustarts.

Die Hintergründe und die einzelnen Befehle stehen in [Windows komplett aktualisieren](../01_Windows_11/01_Update_und_Upgrade.md#1-nach-der-neuinstallation-alles-in-einem-durchlauf). Dafür ist Windows PowerShell 5.1 nötig (das normale blaue Windows-PowerShell, das jedes Windows 10 und 11 mitbringt).

## Teil 2: Diagnose und Reparatur

Im Ordner `windows\zusatz` liegen kleine Programme, die einen Bericht im Fenster ausgeben. Sie ändern nichts, außer `SYSTEM_REPARIEREN.cmd` (verlangt eine Bestätigung) und `SSH_REPARIEREN.cmd`.

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

1. Rechtsklick auf **`START_HIER.cmd`** → **Als Administrator ausführen**.
2. Windows fragt, ob die App Änderungen vornehmen darf: **Ja**.
3. Das Programm sucht dein Heimnetz. Ist **nur ein Netzwerk** vorhanden (der Normalfall, zum Beispiel nur WLAN), wählt es das **automatisch**. Nur bei **mehreren** Netzwerken erscheint eine nummerierte Liste (zum Beispiel `1) Ethernet`, `2) WLAN`). Tippe dann die Zahl vor der Zeile ein, in der auch der andere Computer hängt, und drücke Enter.
4. Tippe **`1`** (zwei Stunden) oder **`2`** (dauerhaft) und drücke Enter.
5. Im Fenster stehen jetzt **IP-Adresse, Benutzername, Passwort** und eine Zeile, die mit `ssh` beginnt. Gib diese Angaben der Person, die sich verbinden soll. Das Passwort nur persönlich, per Telefon oder in einem sicheren Chat weitergeben.

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

- **Windows:** Rechtsklick auf **`STOP_HIER.cmd`** → *Als Administrator ausführen*.
- **Ubuntu/Debian:** `sudo bash STOP_HIER.sh`

Der zusätzliche Benutzer und die Freigabe werden entfernt. Deine Dateien und der installierte SSH-Dienst bleiben erhalten. Läuft noch eine SSH-Sitzung, vorher die Sitzung beenden und STOP danach noch einmal starten.

## Wenn etwas nicht klappt

| Problem | Lösung |
| --- | --- |
| Windows zeigt „Der Computer wurde durch Windows geschützt“ | **Weitere Informationen** → **Trotzdem ausführen**. Die Datei kommt aus dem Download. |
| „Bitte als Administrator ausführen“ | Nicht doppelklicken, sondern per **Rechtsklick → Als Administrator ausführen**. |
| Das Fenster schließt sich sofort | Die Datei liegt allein im Ordner. Den ganzen Ordner `windows` entpackt lassen. |
| Die andere Person kann sich nicht verbinden | Beide Computer müssen im **gleichen Heimnetz** sein, nicht im Gastnetz. Eine Firewall oder ein VPN kann die Verbindung blockieren. |
| Linux meldet „Match-/Include-Regeln prüfen“ | Es gibt eine eigene SSH-Konfiguration. Das Skript bricht dann zur Sicherheit ab. Siehe [TECHNIK.md](TECHNIK.md). |

## Weitere Werkzeuge

Im Ordner `windows/zusatz` liegen Hilfen für die Fehlersuche unter Windows (Systeminfo, Windows-Diagnose, Netzwerk-Diagnose, SSH reparieren, System reparieren). Sie sind für den Fernzugriff nicht nötig. `SYSTEM_REPARIEREN` verlangt eine ausdrückliche Bestätigung.

## Für Fachleute

Aufbau, Sicherheitsmerkmale, Tests und Grenzen: [TECHNIK.md](TECHNIK.md).

## Teststand

Praktisch getestet: Windows 10 (Einrichtung, Passwortanmeldung, STOP, automatischer Ablauf; Verbindung zu Ubuntu in beide Richtungen). **Nicht** praktisch getestet: Linux START/STOP und Windows 11.
