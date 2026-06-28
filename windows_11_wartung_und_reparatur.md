# Windows 11: Umfangreiche Befehlssammlung (Update, Reparatur & Wartung)

> [!IMPORTANT]
> Viele dieser Befehle müssen in einer **Eingabeaufforderung (CMD)** oder **PowerShell** mit **Administratorrechten** (Rechtsklick -> Als Administrator ausführen) ausgeführt werden.

## 1. Skripte erlauben (Execution Policy)
Windows blockiert standardmäßig die Ausführung vieler Skripte, was häufig zu Fehlern führt. Um Skripte reibungslos auszuführen, kann die Execution Policy (Ausführungsrichtlinie) angepasst werden.

- **Nur für die aktuelle Sitzung erlauben (Sicherste Methode):**
  ```powershell
  Set-ExecutionPolicy Bypass -Scope Process -Force
  ```
- **Für den aktuellen Benutzer dauerhaft erlauben:**
  ```powershell
  Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
  ```
- **Systemweit für alle Benutzer erlauben:**
  ```powershell
  Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
  ```

## 2. Programme und Apps updaten (Winget)
Mit dem vorinstallierten Windows Package Manager (Winget) können alle installierten Programme mit einem einzigen Befehl aktualisiert werden.

- **Alle verfügbaren Updates auf einmal installieren:**
  ```powershell
  winget upgrade --all --include-unknown
  ```
- **Updates komplett ohne Benutzerinteraktion (Silent) installieren:**
  ```powershell
  winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
  ```

## 3. System reparieren (DISM & SFC)
Wenn Windows Probleme macht, abstürzt oder Updates fehlschlagen, helfen diese beiden Tools. **Wichtig: Immer zuerst DISM, danach SFC ausführen.**

- **Komponentenspeicher prüfen und reparieren (DISM):**
  ```cmd
  DISM /Online /Cleanup-Image /ScanHealth
  DISM /Online /Cleanup-Image /CheckHealth
  DISM /Online /Cleanup-Image /RestoreHealth
  ```
- **Systemdateien auf Fehler prüfen und reparieren (SFC):**
  ```cmd
  sfc /scannow
  ```

## 4. Windows Updates (System)
Windows Updates können auch direkt über die Kommandozeile erzwungen und gesteuert werden.

- **Mit dem integrierten USOClient (CMD):**
  - Nach Updates suchen: `usoclient StartScan`
  - Updates herunterladen: `usoclient StartDownload`
  - Updates installieren: `usoclient StartInstall`
  - Alles in einem (Suchen, Laden, Installieren): `usoclient StartInteractiveScan`
  - Neustart erzwingen (falls erforderlich): `usoclient RestartDevice`

- **Mit PowerShell (Modul "PSWindowsUpdate"):**
  ```powershell
  # Modul installieren (einmalig erforderlich)
  Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
  
  # Alle Windows-Updates installieren und falls nötig automatisch neustarten
  Install-WindowsUpdate -AcceptAll -AutoReboot
  ```

## 5. Treiber Updates
Treiber-Updates können über Windows Update erzwungen oder per Tool verwaltet werden.

- **Treiber-Updates über Windows Update abrufen (PowerShell):**
  ```powershell
  # Benötigt das PSWindowsUpdate Modul (siehe Punkt 4)
  Get-WindowsUpdate -AcceptAll -Install -MicrosoftUpdate
  ```
- **Treiber aus einem Ordner stapelweise installieren (CMD/PowerShell):**
  Wenn du Treiber-Dateien (.inf) heruntergeladen hast:
  ```cmd
  pnputil /add-driver "C:\Pfad\Zu\Deinen\Treibern\*.inf" /subdirs /install
  ```
- **Alte oder fehlerhafte Treiber bereinigen:**
  Löst Probleme mit korrupten Treibern, indem ungenutzte Pakete entfernt werden:
  ```cmd
  # Zeigt alle Treiber an
  pnputil /enum-drivers
  # Bestimmten Treiber löschen (oemXX.inf ersetzen)
  pnputil /delete-driver oemXX.inf /uninstall /force
  ```

## 6. Systemwartung und Bereinigung
Routine-Befehle, um das System sauber und schnell zu halten.

- **Festplatte auf Dateisystemfehler prüfen (CHKDSK):**
  ```cmd
  chkdsk C: /f /r
  ```
  *(Erfordert in der Regel einen Neustart des Systems)*

- **Erweiterte Datenträgerbereinigung starten:**
  ```cmd
  # Öffnet das Tool mit allen versteckten Optionen (Häkchen setzen)
  cleanmgr /sageset:1
  # Führt die Bereinigung dann automatisch aus
  cleanmgr /sagerun:1
  ```

## 7. Windows 11 Update-Fehler umgehen (TPM / CPU nicht unterstützt)
Wenn ein Update (oft bei ca. 6-8%) hängen bleibt oder abbricht, liegt das bei älterer Hardware häufig daran, dass CPU oder TPM 2.0 nicht offiziell unterstützt werden. Mit den folgenden Schritten lässt sich diese Sperre bei Upgrades umgehen.

- **TPM- und CPU-Check per Registry deaktivieren (Microsofts offizieller Bypass):**
  Dieser Befehl setzt einen Registry-Wert, der Windows anweist, das Upgrade auch auf Systemen mit inkompatibler CPU oder fehlendem TPM 2.0 zuzulassen.
  ```cmd
  reg add "HKLM\SYSTEM\Setup\MoSetup" /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f
  ```

- **Update-Cache komplett zurücksetzen (Wenn das Update feststeckt):**
  Hängt das Update bei 6% komplett fest, ist der lokale Download-Cache beschädigt. Diese Befehle stoppen die Update-Dienste, benennen die fehlerhaften Ordner um (als Backup) und starten die Dienste neu. Am besten Zeile für Zeile in CMD (als Admin) einfügen.
  ```cmd
  net stop wuauserv
  net stop cryptSvc
  net stop bits
  net stop msiserver
  ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
  ren C:\Windows\System32\catroot2 catroot2.old
  net start wuauserv
  net start cryptSvc
  net start bits
  net start msiserver
  ```
  *(Tipp: Nach Ausführung dieser Befehle den PC einmal neustarten und das Update erneut versuchen.)*

- **Bypass für In-Place Upgrades per Setup-Parameter:**
  Startest du ein großes Funktions-Update manuell über eine Windows 11 ISO, kannst du die `setup.exe` über CMD mit folgendem Parameter aufrufen. Dadurch überspringt das Setup die Hardware-Checks für Endanwender.
  ```cmd
  setup.exe /product server
  ```
