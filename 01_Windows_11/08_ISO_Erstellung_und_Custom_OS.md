# 08 ISO Erstellung und Custom OS (Windows 11)

Befehle und Anleitungen für die Vorbereitung und Optimierung von Windows-Installationsmedien, insbesondere für angepasste Windows-Versionen wie AtlasOS oder ReviOS.

## 1. Systeminformationen für ISO-Vorbereitung abfragen

Vor der Erstellung eines bootfähigen Mediums (z.B. mit Rufus oder Ventoy) können folgende Parameter des Zielsystems ausgelesen werden, um die passenden Einstellungen zu wählen:

```powershell
# Partitionsstil der Systemfestplatte abfragen (MBR oder GPT)
(Get-Disk -Number (Get-Partition -DriveLetter $env:SystemDrive.Substring(0, 1)).DiskNumber).PartitionStyle

# Status von Secure Boot überprüfen
Confirm-SecureBootUEFI
```

## 2. Bootfähiges USB-Medium erstellen (Ventoy)

Ventoy ist ideal für Custom-OS, da es erlaubt, ISO-Dateien einfach auf den Stick zu kopieren und Konfigurationen (wie ReviOS) automatisch anzuwenden.

### 2.1 Empfohlene Struktur für Ventoy (ReviOS Konfiguration)
Um Windows-Anforderungen (TPM, Online-Zwang) bei der Installation zu umgehen:
1. Lade die Ventoy-Konfigurationsdateien (z.B. von ReviOS) herunter.
2. Kopiere sie ins Stammverzeichnis des Ventoy-Sticks.
3. Lege die Windows-ISO-Datei im Ordner `WinISO` ab.

```
F: (Dein USB-Laufwerk)
├── ventoy
│   ├── ventoy.json
│   └── revi
│       └── autounattend.xml
├── ReviSetup
│   └── setup.cmd
└── WinISO
    └── Windows11.iso
```

## 3. Direkte ISO-Installation (Inplace / Mount)

Falls kein USB-Stick zur Hand ist und Windows bereits läuft, kann eine ISO-Datei direkt gemountet und das Setup per CMD gestartet werden:

```cmd
:: ISO mounten und das Setup vom virtuellen Laufwerk (hier als Beispiel Laufwerk H:) aufrufen
H:\sources\setup.exe
```

## 4. AtlasOS / ReviOS Playbook Installation

Nach einer frischen Windows-Installation (idealerweise ohne Internet-Verbindung und ohne Updates) werden diese Custom-OS-Systeme über den AME Wizard installiert:

1. **AME Wizard** (Ameliorated) herunterladen.
2. Das passende **Playbook** (`.apbx`) für AtlasOS oder ReviOS herunterladen.
3. `AME Wizard.exe` starten und das Playbook per Drag & Drop hineinziehen.
4. Den Anweisungen folgen und das System optimieren lassen.

> [!TIP]
> **AtlasOS:** Fokus auf maximaler Leistung, Gaming, Latenzreduzierung. Entfernt sehr viel Bloatware.
> **ReviOS:** Bessere Balance zwischen Optimierung, Stabilität und Datenschutz. Geeignet für Office und Streaming.
