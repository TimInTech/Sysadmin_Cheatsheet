# SMART und Festplattendiagnose (Linux)

Bevor Datenrettungs-Tools wie `ddrescue` oder `testdisk` eingesetzt werden, sollte immer zuerst der physische Zustand des Datenträgers geprüft werden. Stirbt die Platte, kann jeder unnötige Lesezugriff tödlich für die Restdaten sein.

## 1. Laufwerke identifizieren (lsblk)

Zuerst herausfinden, welchen Bezeichner (z. B. `/dev/sdb`) die defekte Festplatte hat:
```bash
# Zeigt alle angeschlossenen Blockgeräte und deren Partitionen als Baumstruktur
lsblk
```

## 2. SMART-Werte auslesen (smartctl)

Für diesen Schritt muss das Paket `smartmontools` installiert sein (meistens im Live-System vorhanden).

### Kurztest: Ist die Festplatte grundsätzlich fehlerhaft?
```bash
sudo smartctl -H /dev/sdb
```
*(Wenn hier nicht "PASSED" steht, ist die Festplatte ein Fall für den sofortigen Image-Klon oder den professionellen Datenretter).*

### Detaillierte SMART-Informationen anzeigen
Listet alle Parameter auf (wie Reallocated Sector Count, Power On Hours, etc.):
```bash
sudo smartctl -a /dev/sdb
```
*Achtung bei folgenden Werten:*
- `ID 5: Reallocated_Sector_Ct` (Zahl der defekten, ausgelagerten Sektoren)
- `ID 197: Current_Pending_Sector` (Sektoren, die unlesbar waren)
- `ID 198: Offline_Uncorrectable` (Sektoren, die bei Offline-Scans nicht repariert werden konnten)
*Stehen diese Rohwerte (Raw_Value) auf allem > 0, ist Vorsicht geboten!*

### SMART-Selbsttest starten (Short oder Long)
```bash
# Kurzer Test (dauert ca. 2-5 Minuten)
sudo smartctl -t short /dev/sdb

# Ausführlicher Oberflächen-Scan (kann viele Stunden dauern)
sudo smartctl -t long /dev/sdb
```

Den Fortschritt und die Ergebnisse des Tests danach wieder abrufen mit:
```bash
sudo smartctl -l selftest /dev/sdb
```

## 3. Windows-Alternative (PowerShell)

Falls Sie unter Windows prüfen müssen und kein grafisches Tool wie CrystalDiskInfo zur Hand haben:
```powershell
# Gibt grundlegende SMART-Vorhersagen (PredictFailure) aus
Get-WmiObject -namespace root\wmi –class MSStorageDriver_FailurePredictStatus
```
*(PredictFailure=False bedeutet okay, True bedeutet baldiges Ableben).*
