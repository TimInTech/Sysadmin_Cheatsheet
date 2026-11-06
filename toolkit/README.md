# Portable Sysadmin Toolkit – Entwicklungsstand

**Noch nicht für den produktiven Einsatz freigegeben.** Der Windows-SSH-Start ist gesperrt. Die Linux-Variante ist ein Entwurf und muss unabhängig geprüft werden. Es gibt noch kein fertiges Downloadpaket oder Release.

Die fünf Windows-Diagnosewerkzeuge liegen unter `windows/`. Diagnose und Reparatur sind getrennt; `SYSTEM_REPARIEREN.cmd` verlangt eine ausdrückliche Bestätigung. Die CMD-Dateien benötigen die zugehörigen PowerShell-Dateien im selben Ordner. Der SSH-Starter benötigt ebenfalls die Dateien des vollständigen Ordners; eine einzelne CMD-Datei genügt nicht.

Der Linux-Entwurf unter `linux/` richtet einen zeitlich begrenzten Zugang ein. Ein Neustart beendet ihn vorzeitig. Er ändert keine bestehende Firewall; diese kann die Verbindung blockieren. Eine dauerhafte Einrichtung und automatische Firewallöffnung fehlen. Die isolierte Authentifizierung wirkt sich innerhalb der Sitzung auf die Anmeldung als andere lokale Benutzer und auf sudo-Passwortprüfungen aus.

Der Entwurf bricht bei nicht unterstützten Identitätsanbietern ab. Der geprüfte Ubuntu-GNOME-Host mit `sss` und zusätzlichen UserDB-Anbietern wird derzeit abgewiesen; die Kompatibilität mit typischen Ubuntu-Desktops ist daher nicht nachgewiesen. Die UID-Prüfung ist eine Momentaufnahme und kann eine gleichzeitige privilegierte Neuzuweisung nicht atomar ausschließen.

## Bisherige Prüfung und offene Punkte

- In einer isolierten Ubuntu-26.04-VM wurden Erstinstallation, richtige und falsche Passwörter, Verweigerung am bestehenden SSH-Dienst, STOP, Neustart und beschleunigter Ablauf geprüft. Ein weiterer Test prüfte den Ablauf bei blockierter Einrichtung und offener Sitzung. Das ist kein Test von einem zweiten physischen Rechner oder auf anderen Linux-Versionen.
- Auf einem GitHub-Actions-Windows-Server-Runner bestanden PSScriptAnalyzer und 18 Pester-Tests mit Windows PowerShell 5.1. Echte Windows-10- und Windows-11-Systeme wurden nicht getestet. Der Windows-SSH-Entwurf hat offene Fragen zur Prozesslebensdauer, Nebenläufigkeit und zum Installationszustand; er bleibt gesperrt.
- Ein dauerhafter Zugang, Firewallintegration, vollständige Integrationstests und ein Downloadpaket fehlen. CI ersetzt keine Tests auf echten Zielsystemen.

Die vorhandenen Anleitungen zu [Windows OpenSSH](../01_Windows_11/11_OpenSSH_Server_Ubuntu_Zugriff.md) und [Linux SSH](../02_Linux/04_SSH_und_Remote_Zugriff.md) beschreiben die manuelle Einrichtung und Diagnose.
