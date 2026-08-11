# Bazzite Gaming-Linux – einfache Befehle

Diese Seite ist für Linux-Anfänger. Kopiere immer nur **einen Befehl**, drücke `Enter` und warte, bis er fertig ist.

> Wenn nach dem Passwort gefragt wird, bleibt das Feld beim Tippen leer. Das ist normal.

## Die drei wichtigsten Regeln

1. Installiere normale Apps über **Bazaar** oder als **Flatpak**.
2. Nutze auf Bazzite nicht einfach Befehle aus Ubuntu-Anleitungen wie `sudo apt install`.
3. Ändere Startoptionen eines Spiels nur, wenn du damit ein bestimmtes Problem lösen willst.

## 1. Alles aktualisieren

Terminal öffnen und ausführen:

```bash
ujust update
```

Dadurch werden Bazzite und die installierten Flatpak-Apps aktualisiert. Wenn am Ende ein Neustart verlangt wird:

```bash
systemctl reboot
```

## 2. Apps installieren und entfernen

Am einfachsten: **Bazaar** öffnen, App suchen und auf **Installieren** klicken.

Diese Programme sind fürs Gaming nützlich:

| Zweck | App |
|---|---|
| Epic Games, GOG und Amazon Games | Heroic Games Launcher |
| Zusätzliche Proton-Versionen | ProtonPlus |
| Chat mit Freunden | Discord |

Installation im Terminal:

```bash
flatpak install flathub com.heroicgameslauncher.hgl
flatpak install flathub com.vysp3r.ProtonPlus
flatpak install flathub com.discordapp.Discord
```

Alle Flatpak-Apps aktualisieren:

```bash
flatpak update
```

Eine App wieder entfernen, Beispiel Heroic:

```bash
flatpak uninstall com.heroicgameslauncher.hgl
```

## 3. Epic Games starten

1. Installiere den **Heroic Games Launcher**.
2. Öffne Heroic und melde dich bei Epic Games an.
3. Installiere das Spiel in Heroic.
4. Wenn es nicht startet, wähle in den Spieleinstellungen eine andere Proton-Version.

Nicht jedes Windows-Spiel läuft unter Linux. Prüfe das Spiel bei [ProtonDB](https://www.protondb.com/). **Fortnite läuft wegen seines Anti-Cheat-Systems nicht lokal unter Linux.** Cloudflare WARP ändert daran nichts.

## 4. Cloudflare WARP installieren

Cloudflare WARP leitet die Internetverbindung über Cloudflare. Das kann bei einem Anschluss mit Routing-Problemen helfen, macht aber keine inkompatiblen Spiele Linux-tauglich.

> WARP ist ein systemnahes Programm. Deshalb ist hier ausnahmsweise `rpm-ostree` nötig. Die Installation ist für normale PCs mit `x86_64` gedacht.

Architektur prüfen:

```bash
uname -m
```

Wenn `x86_64` erscheint, nacheinander ausführen:

```bash
curl -fsSL https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
```

```bash
sudo rpm-ostree install cloudflare-warp
```

Danach neu starten:

```bash
systemctl reboot
```

Nach dem Neustart:

```bash
sudo systemctl enable --now warp-svc
warp-cli registration new
warp-cli connect
warp-cli status
```

Beim ersten Start die Nutzungsbedingungen bestätigen. Bei `warp-cli status` sollte `Connected` stehen.

Verbindung testen:

```bash
curl https://www.cloudflare.com/cdn-cgi/trace
```

In der Ausgabe muss `warp=on` stehen.

WARP später ein- oder ausschalten:

```bash
warp-cli connect
warp-cli disconnect
```

WARP wird zusammen mit Bazzite aktualisiert:

```bash
ujust update
```

### WARP verbindet sich nicht

Status prüfen und Dienst neu starten:

```bash
warp-cli status
sudo systemctl restart warp-svc
warp-cli connect
```

Wenn es weiter nicht geht, die letzten Fehlermeldungen anzeigen:

```bash
journalctl -u warp-svc -b -n 50 --no-pager
```

Ein anderes Verbindungsprotokoll testen:

```bash
warp-cli tunnel protocol set WireGuard
warp-cli disconnect
warp-cli connect
```

Zurück zum Cloudflare-Standard:

```bash
warp-cli tunnel protocol set MASQUE
```

## 5. Steam: Spiel startet nicht

Diese Schritte der Reihe nach testen:

1. Steam vollständig schließen und neu öffnen.
2. Beim Spiel **Eigenschaften → Installierte Dateien → Dateien auf Fehler überprüfen** wählen.
3. **Eigenschaften → Kompatibilität** öffnen und **Proton Experimental** testen.
4. Wenn nötig, ProtonPlus installieren und danach eine aktuelle GE-Proton-Version testen.
5. Auf [ProtonDB](https://www.protondb.com/) prüfen, ob das Spiel unter Linux läuft.

### Zwei nützliche Steam-Startoptionen

Eintragen unter **Spiel → Eigenschaften → Allgemein → Startoptionen**.

Leistung und Temperaturen im Spiel anzeigen:

```text
MANGOHUD=1 %command%
```

Bei einem Proton-Fehler ein Protokoll erstellen:

```text
PROTON_LOG=1 %command%
```

Die Logdatei landet im persönlichen Ordner. Nach der Fehlersuche die Startoption wieder löschen.

## 6. Schnelle Hilfe, wenn etwas klemmt

Flatpak-Apps reparieren:

```bash
flatpak repair --user
flatpak update
```

Freien Speicher prüfen:

```bash
df -h
```

Fehlgeschlagene Systemdienste anzeigen:

```bash
systemctl --failed
```

Fehler seit dem letzten Start anzeigen:

```bash
journalctl -b -p err -n 50 --no-pager
```

Aktuellen Bazzite-Systemstand anzeigen:

```bash
rpm-ostree status
```

Wenn ein Fehler direkt nach einem Systemupdate begonnen hat, kann das vorherige System gestartet werden:

```bash
sudo rpm-ostree rollback
systemctl reboot
```

Persönliche Dateien und Spielstände werden dadurch nicht zurückgesetzt.

## 7. Wenn der PC hängt

1. Warte zwei Minuten, weil ein Update noch arbeiten könnte.
2. Drücke einmal `Strg` + `Alt` + `Entf` und warte.
3. Halte den Power-Knopf nur als letzten Ausweg gedrückt. Dabei können ungespeicherte Daten verloren gehen.

## Nicht benutzen

Diese Befehle passen nicht zu normalen Installationen auf Bazzite:

```text
sudo apt install ...
sudo dnf install ...
```

Nutze zuerst Bazaar, Flatpak oder einen vorhandenen `ujust`-Befehl. `rpm-ostree` ist nur für systemnahe Programme wie Cloudflare WARP gedacht.

## Quellen und weitere Hilfe

- [Bazzite: Programme installieren](https://docs.bazzite.gg/Installing_and_Managing_Software/)
- [Bazzite: Game Launcher](https://docs.bazzite.gg/Gaming/Game_Launchers/)
- [Bazzite: Steam-Startoptionen](https://docs.bazzite.gg/Gaming/launch-options-env-variables/)
- [Cloudflare: WARP unter Linux](https://developers.cloudflare.com/warp-client/get-started/linux/)

Die übrigen Dateien in diesem Ordner enthalten ausführlichere Befehle für Fortgeschrittene.
