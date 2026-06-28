# 03 Rechte und Besitz korrigieren

Oft kommt es bei der Datenrettung (oder wenn Festplatten aus alten PCs in neue eingebaut werden) zu Problemen mit Dateiberechtigungen. Der Zugriff wird verweigert. So zwingst du das System, dir die Rechte zu geben.

## 1. NTFS-Rechte unter Linux zurücksetzen

Wenn Windows nicht sauber heruntergefahren wurde (Fast Boot / Ruhezustand), sperrt Windows die NTFS-Partition (Dirty Bit). Linux mounted sie dann nur im "Read-Only" (Lesezugriff) Modus.

### ntfsfix
Dieser Befehl entfernt das Dirty-Bit der NTFS-Partition und ermöglicht wieder Schreibzugriff.

```bash
# Installation der NTFS-Tools (falls nicht vorhanden)
sudo apt install ntfs-3g

# Die betroffene Partition reparieren (z.B. sdb1)
sudo ntfsfix /dev/sdb1

# Danach kann die Partition wieder normal rw (read/write) gemountet werden
sudo mount -t ntfs-3g /dev/sdb1 /mnt
```

## 2. Alte Profile unter Windows erzwingen (takeown / icacls)

Wenn du eine alte Windows-Festplatte an einen neuen PC hängst, kannst du oft nicht auf `C:\Users\AlterName` zugreifen ("Sie verfügen momentan nicht über die Berechtigung..."). Die GUI braucht dafür extrem lange. Über die CMD (als Administrator) geht das in Sekunden.

### Schritt 1: Besitz übernehmen (takeown)
Zuerst muss der neue Administrator (du) der Besitzer (Owner) des Ordners und aller Unterordner werden.

```cmd
:: Besitz des gesamten Ordners und aller Inhalte an die Gruppe der Administratoren übertragen
takeown /F "D:\Users\AlterName" /R /A /D J
```
*(Parameter-Erklärung: `/F` = Ziel, `/R` = Rekursiv, `/A` = Administratoren-Gruppe, `/D J` = Beantwortet Prompt bei fehlenden Rechten mit 'Ja')*

### Schritt 2: Rechte neu vergeben (icacls)
Nachdem du der Besitzer bist, musst du dir Lese- und Schreibrechte erteilen.

```cmd
:: Dem Administrator Vollzugriff (F = Full) auf den Ordner geben
icacls "D:\Users\AlterName" /grant Administratoren:(OI)(CI)F /T

:: Falls die Berechtigungen völlig kaputt sind, Vererbung zurücksetzen:
icacls "D:\Users\AlterName" /reset /T /C /Q
```
