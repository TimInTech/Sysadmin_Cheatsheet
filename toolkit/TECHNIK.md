# Technische Details zum SSH-Schnellzugriff

Dieses Dokument richtet sich an Personen mit IT-Kenntnissen. Die einfache Anleitung steht in der [README](README.md).

> **Wichtig:** Bestehende SSH-Sonderkonfigurationen oder weitere SSH-Server können die Netzbegrenzung beeinflussen. Vor dem Einsatz vorhandene SSH-Dienste und Firewallregeln prüfen.

## Aufbau

- `windows/START_HIER.cmd`, `windows/STOP_HIER.cmd`: Starter, rufen `SSH_EINRICHTEN.ps1` im selben Ordner auf.
- `windows/zusatz/`: Diagnose- und Reparaturwerkzeuge (`SYSTEMINFO`, `WINDOWS_DIAGNOSE`, `NETZWERK_DIAGNOSE`, `SSH_REPARIEREN`, `SYSTEM_REPARIEREN`). Jede `.cmd` braucht `DIAGNOSE.ps1` und `Repair.ps1` im selben Ordner.
- `linux/START_HIER.sh`, `linux/STOP_HIER.sh`: Einrichtung und Rückbau unter Ubuntu/Debian mit systemd.
- `tests/`: Pester-Tests (Windows) und ein Test der SSH-Konfiguration (Linux); sie laufen in der CI (`.github/workflows/toolkit.yml`).

## Windows 10 und 11

1. Im entpackten Ordner `toolkit/windows` die Datei `START_HIER.cmd` per Rechtsklick **als Administrator ausführen**.
2. Das private Netzwerk und `1` für zwei Stunden oder `2` für einen dauerhaften Zugang wählen.
3. IP-Adresse, Benutzername und Passwort stehen anschließend im Fenster. Auf dem zweiten Rechner den angezeigten `ssh`-Befehl ausführen und das angezeigte Passwort eingeben. Beim ersten Kontakt den SSH-Hostschlüssel vor Bestätigung unabhängig prüfen.
4. Zum vorzeitigen Beenden `STOP_HIER.cmd` ebenfalls als Administrator starten. Es entfernt das vom Paket markierte Konto, die eigene SSH-Konfigurationspassage und Firewallregel sowie die eigene Aufgabe. Das installierte OpenSSH-Paket bleibt erhalten.

Der temporäre Benutzer läuft nach zwei Stunden ab. Eine geplante SYSTEM-Aufgabe führt den Rückbau aus; nach einem Neustart wird der Zugang vorsorglich früher entfernt. Der Account erhält keine Administratorrechte. Windows-Hello-PIN und SSH-Passwort sind nicht dasselbe. Ein laufendes SSH-Terminal kann über den Ablauf hinaus offen bleiben; es bei Bedarf ausdrücklich schließen.

## Ubuntu und Debian

Im entpackten Ordner `toolkit/linux` ein Terminal öffnen:

```bash
sudo bash START_HIER.sh
```

Netz und Laufzeit auswählen und anschließend den angezeigten SSH-Befehl auf dem zweiten Rechner ausführen. Zum Beenden:

```bash
sudo bash STOP_HIER.sh
```

Der systemd-Timer führt den Rückbau nach zwei Stunden aus; bei Neustart erfolgt er früher. Home-Verzeichnisse und installierte Pakete werden nicht gelöscht. Offene Sitzungen können bestehen bleiben oder das Entfernen des Kontos verhindern. In diesem Fall die Sitzungen beenden und STOP erneut starten. Bereits vorhandene Firewallregeln werden unter Linux nicht verändert; eine Firewall kann den Zugang blockieren.

## Diagnose und Hinweise

Windows bietet im Ordner `windows/zusatz` die Dateien `SYSTEMINFO.cmd`, `WINDOWS_DIAGNOSE.cmd`, `NETZWERK_DIAGNOSE.cmd`, `SSH_REPARIEREN.cmd` und `SYSTEM_REPARIEREN.cmd`. Die Diagnose löst keinen Netzwerkreset aus; die Systemreparatur verlangt eine ausdrückliche Bestätigung.

Der SSH-Server nutzt seine bestehende Konfiguration und erhält eine markierte Kontoregel. Das Skript prüft diese mit `sshd -t` und `sshd -T` für ausgewählte Beispieladressen; diese Prüfung beweist nicht die Wirkung für alle bestehenden `Match`- und `Include`-Regeln. Andere unabhängig betriebene SSH-Server können eigene Regeln verwenden. Eine bereits offene Firewallregel wird durch eine neue engere Regel nicht eingeschränkt; das Starten eines zuvor gestoppten SSH-Dienstes kann bestehende Konten erreichbar machen. Dienstneustarts können laufende SSH-Verbindungen betreffen. Eine Firewall oder ein isoliertes Gastnetz kann den Zugang verhindern.

SSH eignet sich für verschlüsselte Terminalbefehle und mit SFTP/SCP auch für Dateien. Für einen einmaligen Dateiaustausch kann eine vorhandene Netzwerkfreigabe oder ein anderer vorhandener sicherer Übertragungsweg genügen.

## Teststand

Auf einem Windows-10-Rechner wurden Einrichtung, Passwortanmeldung, STOP und automatischer Ablauf laut Praxistest erfolgreich geprüft. Die Verbindung zwischen Windows und Ubuntu funktionierte in beiden Richtungen. Linux-START und -STOP wurden auf dem produktiven Ubuntu-Rechner nicht ausgeführt; Syntax und SSH-Konfigurationsauswertung wurden geprüft. Windows 11 und abweichende Firewall- oder SSH-Konfigurationen wurden nicht praktisch getestet.
