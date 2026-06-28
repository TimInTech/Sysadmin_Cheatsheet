# 03 Windows RE (Recovery Environment)

Die Windows Recovery Environment (WinRE) ist die blaue Reparaturkonsole, die erscheint, wenn Windows nicht mehr bootet, oder die du über einen Windows-Installations-USB-Stick ("Computerreparaturoptionen" -> "Problembehandlung" -> "Eingabeaufforderung") erreichst.

## 1. Boot-Probleme beheben (MBR / Legacy BIOS)
Wenn das System beim Start meldet "Operating System not found" oder "Bootmgr is missing", hilft das Tool `bootrec`.

```cmd
:: 1. Den Master Boot Record (MBR) neu schreiben
bootrec /fixmbr

:: 2. Einen neuen Bootsektor auf die Systempartition schreiben
bootrec /fixboot

:: 3. Nach installierten Windows-Versionen suchen und zur Boot-Datenbank (BCD) hinzufügen
bootrec /rebuildbcd
```

## 2. Boot-Probleme beheben (UEFI / GPT)
Bei modernen Systemen (UEFI) funktioniert `bootrec /fixboot` oft nicht ("Zugriff verweigert"). Hier muss die versteckte EFI-Partition repariert werden.

### Schritt 1: EFI-Partition finden und Laufwerksbuchstaben zuweisen
```cmd
:: Diskpart starten
diskpart

:: Laufwerke anzeigen
list disk

:: Laufwerk auswählen (meistens 0)
select disk 0

:: Volumen anzeigen
list volume
```
*Suche das Volumen, das als "FAT32" formatiert ist und meist ca. 100-300 MB groß ist. Das ist die EFI-Partition.*
```cmd
:: Angenommen, das FAT32 Volumen ist Volume 2
select volume 2

:: Einen freien Buchstaben zuweisen (z.B. V:)
assign letter=V

:: Diskpart beenden
exit
```

### Schritt 2: Boot-Dateien (BCD) neu schreiben
Jetzt, da die EFI-Partition als `V:` gemountet ist, können wir die Boot-Dateien reparieren.
Finde heraus, auf welchem Laufwerk Windows installiert ist (in der Konsole ist es nicht immer `C:`, überprüfe es mit `dir C:` oder `dir D:`). Angenommen, Windows liegt auf `C:`.

```cmd
:: Die Boot-Konfiguration (BCD) auf der EFI-Partition (V:) reparieren
bcdboot C:\Windows /s V: /f UEFI
```
*Danach den PC neu starten.*

## 3. Beschädigte Systemdateien offline reparieren (SFC & DISM)

Manchmal startet Windows, stürzt aber direkt mit einem Bluescreen ab. Dann müssen Systemdateien repariert werden.
Da wir in der WinRE sind, müssen wir den Offline-Pfad zu Windows angeben (angenommen, Windows liegt auf `D:`).

```cmd
:: System File Checker (SFC) offline ausführen
sfc /scannow /offbootdir=D:\ /offwindir=D:\Windows

:: DISM offline ausführen (Repariert das Windows-Image ohne Internet)
DISM /Image:D:\ /Cleanup-Image /RestoreHealth
```

## 4. Laufwerksbuchstaben identifizieren
Da in der WinRE die Buchstaben oft wild durcheinandergewürfelt sind (der USB-Stick ist C:, Windows ist D:, etc.), hilft folgender Befehl, um sich zurechtzufinden:
```cmd
:: Öffnet den Editor notepad.exe mit einer kleinen GUI
notepad.exe
```
*Tipp: Klicke in Notepad auf "Datei" -> "Öffnen". Jetzt hast du einen kleinen Mini-Explorer und kannst sehen, welcher Buchstabe zu welchem Laufwerk gehört!*
