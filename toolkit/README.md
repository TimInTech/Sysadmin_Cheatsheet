# Fernzugriff per SSH – einfache Anleitung

Mit diesem Paket kann sich eine zweite Person über das **eigene Heimnetz** auf deinem Computer anmelden, zum Beispiel, um etwas zu reparieren oder ein System neu aufzusetzen. Die Verbindung heißt **SSH**: Man tippt Befehle in ein Textfenster, und sie werden auf deinem Computer ausgeführt.

## Das Wichtigste vorab

- Der Zugang gilt nur im **Heimnetz** (WLAN oder Kabel zu Hause), nicht aus dem Internet. Am Router musst du nichts einstellen.
- Es wird ein **zusätzlicher Benutzer** mit **zufälligem Passwort** angelegt. Dein eigenes Konto und deine Passwörter bleiben unberührt.
- Der Zugang endet **automatisch nach zwei Stunden** oder sofort, wenn du `STOP_HIER` startest.
- Nur auf Computern verwenden, die dir gehören oder die du verwalten darfst.

## 1. Herunterladen

1. Öffne die [Seite des Projekts](https://github.com/TimInTech/Sysadmin_Cheatsheet).
2. Klicke auf den grünen Knopf **Code** und dann auf **Download ZIP**.
3. Entpacke die ZIP-Datei (Rechtsklick → *Alle extrahieren*).
4. Öffne im entpackten Ordner: `toolkit`, danach `windows` (Windows) oder `linux` (Ubuntu/Debian).

Du brauchst den **ganzen** Ordner `windows` beziehungsweise `linux`, nicht nur eine einzelne Datei.

## 2. Zugang einschalten

### Windows 10 und 11

1. Rechtsklick auf **`START_HIER.cmd`** → **Als Administrator ausführen**.
2. Windows fragt, ob die App Änderungen vornehmen darf: **Ja**.
3. Es erscheint eine Liste deiner Netzwerke. Tippe die **Nummer** des Heimnetzes ein und drücke Enter.
4. Tippe **`1`** (zwei Stunden) oder **`2`** (dauerhaft) und drücke Enter.
5. Im Fenster stehen jetzt **IP-Adresse, Benutzername, Passwort** und eine Zeile, die mit `ssh` beginnt. Gib diese Angaben der Person, die sich verbinden soll. Das Passwort nur persönlich, per Telefon oder in einem sicheren Chat weitergeben.

Beim ersten Start lädt Windows eventuell die SSH-Komponente nach. Dafür muss der Computer online sein.

### Ubuntu und Debian

1. Öffne im Ordner `linux` ein Terminal (Rechtsklick → *Im Terminal öffnen*).
2. Tippe:

   ```bash
   sudo bash START_HIER.sh
   ```

3. Wähle die Nummer des Heimnetzes und danach `1` (zwei Stunden) oder `2` (dauerhaft).
4. Gib die angezeigten Angaben an die andere Person weiter.

## 3. Verbinden (auf dem anderen Computer)

Auf dem zweiten Computer ein Terminal (Linux) oder die PowerShell (Windows) öffnen und die angezeigte Zeile eingeben, zum Beispiel:

```text
ssh -p 22 remotehelp@192.168.178.50
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
