# SSH-Schnellzugriff und Diagnose

> **Wichtig:** Bestehende SSH-Sonderkonfigurationen oder weitere SSH-Server können die Netzbegrenzung beeinflussen. Vor dem Einsatz vorhandene SSH-Dienste und Firewallregeln prüfen.

Mit diesem Paket lässt sich ein eigener Standardbenutzer für SSH im ausgewählten privaten IPv4-Netz anlegen. Ein zufälliges Passwort wird nur vor Ort angezeigt; bitte sicher an die Person am zweiten Rechner weitergeben. Der Zugriff ist für berechtigt administrierte Rechner gedacht. Keine Portfreigabe am Router einrichten.

## Download

Auf der [GitHub-Repositoryseite](https://github.com/TimInTech/Sysadmin_Cheatsheet) **Code → Download ZIP** wählen und das Archiv entpacken. Die CMD-Dateien benötigen die zugehörigen PowerShell-Dateien im selben Ordner; eine einzelne CMD-Datei reicht nicht.

Optional in PowerShell nur herunterladen:

```powershell
Invoke-WebRequest 'https://github.com/TimInTech/Sysadmin_Cheatsheet/archive/refs/heads/main.zip' -OutFile "$env:USERPROFILE\Downloads\Sysadmin_Cheatsheet.zip"
```

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

Windows bietet im gleichen Ordner `SYSTEMINFO.cmd`, `WINDOWS_DIAGNOSE.cmd`, `NETZWERK_DIAGNOSE.cmd`, `SSH_REPARIEREN.cmd` und `SYSTEM_REPARIEREN.cmd`. Die Diagnose löst keinen Netzwerkreset aus; die Systemreparatur verlangt eine ausdrückliche Bestätigung.

Der SSH-Server nutzt seine bestehende Konfiguration und erhält eine markierte Kontoregel. Das Skript prüft diese mit `sshd -t` und `sshd -T` für ausgewählte Beispieladressen; diese Prüfung beweist nicht die Wirkung für alle bestehenden `Match`- und `Include`-Regeln. Andere unabhängig betriebene SSH-Server können eigene Regeln verwenden. Eine bereits offene Firewallregel wird durch eine neue engere Regel nicht eingeschränkt; das Starten eines zuvor gestoppten SSH-Dienstes kann bestehende Konten erreichbar machen. Dienstneustarts können laufende SSH-Verbindungen betreffen. Eine Firewall oder ein isoliertes Gastnetz kann den Zugang verhindern.

SSH eignet sich für verschlüsselte Terminalbefehle und mit SFTP/SCP auch für Dateien. Für einen einmaligen Dateiaustausch kann eine vorhandene Netzwerkfreigabe oder ein anderer vorhandener sicherer Übertragungsweg genügen.

## Teststand

Auf einem Windows-10-Rechner wurden Einrichtung, Passwortanmeldung, STOP und automatischer Ablauf laut Praxistest erfolgreich geprüft. Die Verbindung zwischen Windows und Ubuntu funktionierte in beiden Richtungen. Linux-START und -STOP wurden auf dem produktiven Ubuntu-Rechner nicht ausgeführt; Syntax und SSH-Konfigurationsauswertung wurden geprüft. Windows 11 und abweichende Firewall- oder SSH-Konfigurationen wurden nicht praktisch getestet.
