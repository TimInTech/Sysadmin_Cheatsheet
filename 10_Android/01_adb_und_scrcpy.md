# 01 Android per Computer steuern: adb und scrcpy

Mit **adb** (Android Debug Bridge) sprichst du von Windows oder Linux aus mit deinem Android-Handy: Dateien kopieren, Apps installieren, Fehlerprotokolle lesen. Mit **scrcpy** (gesprochen "Screen Copy") siehst du den Handy-Bildschirm auf dem Computer und bedienst ihn mit Maus und Tastatur. Beide Programme sind kostenlos, brauchen keine App auf dem Handy und laufen auch ohne Root.

> **Hinweis:** Die Befehle wurden mit adb 37.0.1 und scrcpy 3.3.4 unter Ubuntu gegen die Hilfe der Programme geprüft. Es war kein Handy angeschlossen. Alles, was ein echtes Gerät braucht, ist als *nicht getestet* gekennzeichnet.

> **Warnung:** Mit adb kannst du Apps und Daten auf dem Handy löschen. Befehle mit `uninstall`, `clear` und `rm` nie ungeprüft kopieren und vorher ein Backup (Abschnitt 5) machen.

## 1. Einrichten

### Schritt 1: Programme installieren

Windows (PowerShell):

```powershell
winget install --id Google.PlatformTools -e
winget install --id Genymobile.scrcpy -e
```

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install adb scrcpy
```

Kontrolle (beide Systeme):

```bash
adb version
scrcpy --version
```

> **Hinweis:** Die Ubuntu-Pakete können älter sein als die Windows-Version. Das reicht für alles auf dieser Seite. Aktuelle Pakete: [Platform-Tools](https://developer.android.com/tools/releases/platform-tools) und [scrcpy auf GitHub](https://github.com/Genymobile/scrcpy).

### Schritt 2: USB-Debugging am Handy einschalten

1. **Einstellungen -> Über das Telefon** öffnen und siebenmal auf die **Build-Nummer** tippen. Die Meldung "Du bist jetzt Entwickler" erscheint. (Bei manchen Herstellern liegt die Build-Nummer unter *Softwareinformationen*.)
2. **Einstellungen -> System -> Entwickleroptionen** öffnen und **USB-Debugging** einschalten.
3. Handy per USB-Kabel anschließen. Ein **Datenkabel** ist nötig, reine Ladekabel funktionieren nicht.
4. Auf dem Handy erscheint "USB-Debugging zulassen?". **Immer von diesem Computer zulassen** antippen und bestätigen.

### Schritt 3: Verbindung prüfen

```bash
adb devices
```

Ergebnis in der Liste:

| Anzeige | Bedeutung |
| --- | --- |
| `device` | Alles in Ordnung. |
| `unauthorized` | Die Abfrage am Handy wurde noch nicht bestätigt. |
| `offline` | Kabel abziehen und neu anstecken, danach `adb kill-server` und `adb start-server`. |
| (leer) | Kabel, USB-Modus (Dateiübertragung) und Treiber prüfen. |

> **Hinweis (Windows):** Wenn das Handy nicht auftaucht, fehlt oft der USB-Treiber des Herstellers (Samsung, Xiaomi, Google). Google-Pixel-Geräte brauchen meist nichts.

> **Hinweis (Linux):** Taucht das Gerät als `no permissions` auf, hilft meist ein anderer USB-Port oder ein Neustart des adb-Servers: `adb kill-server && adb start-server`. Nicht getestet.

Sind mehrere Geräte verbunden, wähle das Ziel mit `-s SERIENNUMMER` (aus `adb devices`), `-d` (das USB-Gerät) oder `-e` (das WLAN-Gerät):

```bash
adb -s SERIENNUMMER shell
```

## 2. scrcpy: Handy-Bildschirm am Computer

### Per Kabel

```bash
scrcpy
```

Es öffnet sich ein Fenster mit dem Handy. Mausklick ist Fingertipp, die Tastatur schreibt ins Handy. Mit dem Schließen des Fensters endet die Übertragung.

Nützliche Optionen (alle in `scrcpy --help` vorhanden):

```bash
# Handy-Bildschirm aus lassen und wach halten (spart Akku, schützt vor Mitsehen)
scrcpy --turn-screen-off --stay-awake

# Nur ansehen, nichts steuern
scrcpy --no-control

# Ohne Ton (falls Audio Probleme macht)
scrcpy --no-audio

# Flüssiger bei schwacher Verbindung: kleinere Auflösung, begrenzte Bildrate
scrcpy --max-size 1024 --max-fps 30 --video-bit-rate 4M

# Bildschirm als Video aufnehmen
scrcpy --record aufnahme.mp4

# Installierte Apps auflisten und direkt eine starten
scrcpy --list-apps
scrcpy --start-app=+org.mozilla.firefox
```

Bedienung im Fenster: Rechtsklick ist die Zurück-Taste, `Alt+H` ist Home, `Alt+F` schaltet Vollbild um (`Alt` ist die Standard-Modifier-Taste von scrcpy). Die komplette Liste steht in der [scrcpy-Dokumentation](https://github.com/Genymobile/scrcpy).

### Per WLAN

Der einfachste Weg: einmal per Kabel starten, scrcpy schaltet das Gerät in den WLAN-Modus und verbindet sich:

```bash
scrcpy --tcpip
```

Danach das Kabel abziehen. Handy und Computer müssen im selben WLAN sein. Das ist in `scrcpy --help` dokumentiert, mit echtem Gerät *nicht getestet*.

Der manuelle Weg mit adb (klassisch, funktioniert bei allen Android-Versionen):

```bash
# 1. Handy per Kabel anschließen, IP-Adresse des Handys herausfinden
adb shell ip route

# 2. adb auf TCP-Port 5555 umschalten
adb tcpip 5555

# 3. Kabel abziehen und per WLAN verbinden (HANDY_IP durch die Adresse aus Schritt 1 ersetzen)
adb connect HANDY_IP:5555

# 4. Prüfen und scrcpy starten
adb devices
scrcpy --select-tcpip
```

Ab **Android 11** geht es ohne Kabel über die Kopplung:

1. Am Handy: **Entwickleroptionen -> Kabelloses Debugging** einschalten, dann **Pairing mit Kopplungscode** antippen. Das Handy zeigt IP-Adresse, Port und einen sechsstelligen Code.
2. Am Computer:

```bash
adb pair HANDY_IP:PAIRING_PORT
# danach den Code eingeben
adb connect HANDY_IP:VERBINDUNGS_PORT
```

Der Pairing-Port und der Verbindungs-Port sind **verschieden**. Den Verbindungs-Port zeigt der Hauptbildschirm von "Kabelloses Debugging". Nicht getestet.

Verbindung beenden:

```bash
adb disconnect
```

> **Warnung:** adb über WLAN ist nur im eigenen, vertrauten Netz sinnvoll. Schalte "Kabelloses Debugging" nach der Arbeit wieder aus. Nie im öffentlichen WLAN verwenden.

## 3. Dateien kopieren

```bash
# Vom Handy auf den Computer (Ordner wird mit Inhalt kopiert, -a behält das Datum)
adb pull -a /sdcard/DCIM/Camera ./Handy-Fotos

# Vom Computer aufs Handy
adb push ./Dokumente /sdcard/Download/

# Ordnerinhalt ansehen
adb shell ls -l /sdcard/Download
```

Typische Ordner im internen Speicher:

| Pfad | Inhalt |
| --- | --- |
| `/sdcard/DCIM/` | Fotos und Videos der Kamera |
| `/sdcard/Pictures/` | Bilder, Screenshots |
| `/sdcard/Download/` | Downloads |
| `/sdcard/Documents/` | Dokumente |

> **Hinweis:** Seit Android 11 sperrt das System den Zugriff auf `/sdcard/Android/data` für adb-Pull teilweise. Fehlermeldungen wie `Permission denied` dort sind normal.

> **Warnung:** `adb shell rm` und `adb push` überschreiben ohne Rückfrage. Bei `rm -r` nie einen Pfad ungeprüft eingeben.

## 4. Apps verwalten

```bash
# Alle selbst installierten Apps (Paketnamen)
adb shell pm list packages -3

# Nach einer App suchen
adb shell pm list packages | grep -i firefox

# APK installieren (-r ersetzt eine vorhandene Version, Daten bleiben)
adb install -r meine-app.apk

# Mehrere APK-Teile (Split-APKs) einer App gemeinsam installieren
adb install-multiple basis.apk teil1.apk teil2.apk

# App starten und beenden
adb shell monkey -p org.mozilla.firefox -c android.intent.category.LAUNCHER 1
adb shell am force-stop org.mozilla.firefox

# Version einer App
adb shell dumpsys package org.mozilla.firefox | grep versionName
```

> **Warnung:** `adb uninstall PAKET` löscht die App **und ihre Daten**. `adb shell pm clear PAKET` löscht nur die Daten (wie "Speicher löschen"). Beides ist nicht rückgängig zu machen.

Systemapps entfernen, ohne sie zu löschen (nur für den aktuellen Nutzer abschalten):

```bash
# Deinstallieren für Nutzer 0 (Hersteller-Apps)
adb shell pm uninstall --user 0 PAKETNAME

# Rückgängig machen
adb shell cmd package install-existing PAKETNAME
```

> **Warnung:** Entferne nie Apps, deren Zweck du nicht kennst (Telefon, Einstellungen, Systemoberfläche). Das Handy kann sonst nicht mehr starten. Notiere dir jeden Paketnamen. Ein Werksreset stellt alles zurück, löscht aber alle Daten. Mit echtem Gerät *nicht getestet*.

## 5. Backup

`adb backup` ist **veraltet** und taucht in der Hilfe von adb 37 nicht mehr auf. Es sichert seit Android 12 nur noch wenig. Nutze stattdessen diese Wege:

1. **Fotos, Videos, Dokumente:** per `adb pull` (Abschnitt 3).
2. **Apps (APK-Dateien):** Pfade abfragen und kopieren.

```bash
adb shell pm path org.mozilla.firefox
# Ausgabe: package:/data/app/.../base.apk
adb pull /data/app/.../base.apk firefox.apk
```

   Den echten Pfad aus der Ausgabe einsetzen. Bei Apps aus mehreren Teilen (Split-APKs) alle aufgelisteten Dateien kopieren und mit `install-multiple` zurückspielen.
3. **App-Daten, Kontakte, Kalender, WhatsApp:** Das geht ohne Root nicht zuverlässig per adb. Nutze das Google-Konto-Backup (Einstellungen -> Google -> Sicherung) und die Export-Funktion der jeweiligen App.
4. **Komplette Sicherung vor einem Eingriff:** Fotos kopieren (1), App-Liste sichern:

```bash
adb shell pm list packages -3 > apps-liste.txt
```

Kontrolle: Dateigrößen und Anzahl vergleichen.

```bash
du -sh ./Handy-Fotos
adb shell du -sh /sdcard/DCIM/Camera
```

Unter Windows stattdessen:

```powershell
(Get-ChildItem .\Handy-Fotos -Recurse -File | Measure-Object Length -Sum).Sum / 1MB
```

## 6. Logcat: Fehler finden

Logcat ist das Systemprotokoll des Handys. Es ist sehr gesprächig, daher immer filtern.

```bash
# Bisheriges Protokoll ausgeben und beenden
adb logcat -d > logcat.txt

# Live mitlesen, nur Fehler (E) und schlimmer
adb logcat '*:E'

# Mit Zeitstempel
adb logcat -v time '*:W'

# Protokoll leeren, Problem nachstellen, dann auslesen
adb logcat -c
# ... Problem am Handy auslösen ...
adb logcat -d > fehler.txt

# Nach einer App oder einem Stichwort filtern
adb logcat -d | grep -i firefox
```

Stufen: `V` ausführlich, `D` Debug, `I` Info, `W` Warnung, `E` Fehler, `F` fatal. Das Protokoll kann Namen, Konten und Standortdaten enthalten. **Nicht ungeprüft** in Foren oder Tickets einstellen.

Vollständigen Fehlerbericht für Support oder Entwickler erzeugen:

```bash
adb bugreport fehlerbericht.zip
```

Der Bericht enthält viele persönliche Daten. Nur an Personen weitergeben, denen du vertraust. Nicht getestet.

Akku und Speicher schnell prüfen:

```bash
adb shell dumpsys battery
adb shell df -h /data
```

## 7. Wiederherstellung und Notfälle

| Problem | Lösung |
| --- | --- |
| Handy hängt, reagiert nicht | `adb reboot` |
| App hängt | `adb shell am force-stop PAKET` |
| Handy bootet nicht, Wiederherstellungsmodus nötig | `adb reboot recovery` |
| Bootloader / Fastboot-Modus | `adb reboot bootloader` |
| Entfernte System-App zurückholen | `adb shell cmd package install-existing PAKET` |
| Handy nicht mehr in `adb devices` | Kabel wechseln, `adb kill-server`, `adb start-server`, USB-Debugging prüfen |
| Bildschirm gesperrt, Sicherung nötig | Nicht umgehen. Der Hersteller-Support hilft. |

Ein Update-Paket des Herstellers (OTA-Datei) lässt sich im Wiederherstellungsmodus mit `adb sideload` einspielen:

```bash
adb reboot sideload
adb sideload update.zip
```

> **Warnung:** Sideload und Fastboot (`fastboot flash`, `fastboot flashing unlock`) ändern die Systemsoftware. Ein Bootloader-Unlock **löscht alle Daten** und kann die Garantie beenden. Verwende nur die offizielle Anleitung des Herstellers für dein Modell. Diese Befehle sind hier nicht getestet und bewusst nicht weiter ausgeführt.

Sichere vorher deine Daten (Abschnitt 5). Zum Abschluss das Debugging ausschalten: **Entwickleroptionen -> USB-Debugging aus** und unter **USB-Debugging-Autorisierungen widerrufen** alle gespeicherten Computer entfernen.

## Quellen

- [Android Debug Bridge (offiziell)](https://developer.android.com/tools/adb)
- [Platform-Tools Downloads](https://developer.android.com/tools/releases/platform-tools)
- [scrcpy auf GitHub](https://github.com/Genymobile/scrcpy)
- [scrcpy: Verbindung per Kabel und WLAN](https://github.com/Genymobile/scrcpy/blob/master/doc/connection.md)
