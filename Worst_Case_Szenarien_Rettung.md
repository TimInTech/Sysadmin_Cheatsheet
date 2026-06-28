# Worst-Case-Szenarien & System-Rettung

Wenn nichts mehr geht, helfen oft nur noch harte Konsolen-Befehle, um ein totes System wieder zum Leben zu erwecken. Diese Sammlung enthält die wichtigsten Befehle für Notfälle (Linux & Windows).

---

## 1. Linux Notfall-Rettung

### 1.1 Dateisystem voll (Kein Login möglich, Dienste stürzen ab)
Wenn `/` (Root) zu 100% belegt ist, streiken viele Dienste. So findest du den Übeltäter:
```bash
# Zeigt die Festplattenbelegung an
df -h

# Finde die 10 größten Dateien/Verzeichnisse auf Root (Achtung: Kann dauern!)
sudo du -ah / | sort -rh | head -n 10

# Speicherfresser unter /var/log löschen (Logs älter als 7 Tage)
sudo find /var/log -type f -name "*.log" -mtime +7 -exec rm -f {} \;

# Journal-Logs rigoros auf 100MB begrenzen
sudo journalctl --vacuum-size=100M
```

### 1.2 System ist komplett eingefroren (Prozesse killen)
Wenn die grafische Oberfläche hängt, wechsle in ein TTY (Strg+Alt+F3) und melde dich an.
```bash
# Ressourcen-fressende Prozesse interaktiv finden
htop
# ODER top
top

# Einen Prozess gnadenlos beenden (ersetze PID durch die Prozess-ID)
sudo kill -9 <PID>

# Alle Prozesse eines bestimmten Programms abschießen (z.B. Firefox)
sudo pkill -9 firefox
```

### 1.3 Boot-Probleme (Grub reparieren via Live-USB)
Wenn Linux nicht mehr bootet (Grub zerschossen), boote einen Linux Live-USB-Stick und mounte das System (Chroot).
*Angenommen, `/dev/sda2` ist deine Linux-Partition.*
```bash
sudo mount /dev/sda2 /mnt
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
sudo chroot /mnt

# Grub neu installieren und aktualisieren (z.B. auf /dev/sda)
grub-install /dev/sda
update-grub
exit

sudo umount /mnt/sys /mnt/proc /mnt/dev /mnt
```

### 1.4 Netzwerk komplett tot (Kein DHCP)
Wenn der Netzwerk-Manager abgestürzt ist, musst du manuell eine IP vergeben, um per SSH zugreifen zu können.
```bash
# Schnittstellen anzeigen (z.B. eth0 oder enp3s0)
ip a

# Schnittstelle aktivieren
sudo ip link set eth0 up

# Manuell eine IP zuweisen
sudo ip addr add 192.168.1.100/24 dev eth0

# Standard-Gateway (Router) eintragen
sudo ip route add default via 192.168.1.1

# DNS-Server in resolv.conf eintragen
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
```

---

## 2. Windows Notfall-Rettung (CMD / PowerShell)

Diese Befehle müssen in der erweiterten Startumgebung (Computerreparaturoptionen -> Eingabeaufforderung) oder als Administrator in Windows ausgeführt werden.

### 2.1 Boot-Probleme beheben (MBR / BCD zerschossen)
Startet Windows nicht mehr, nutze einen Windows-Installations-USB-Stick, wähle "Computerreparaturoptionen" -> "Eingabeaufforderung".
```cmd
:: Master Boot Record reparieren
bootrec /fixmbr

:: Neuen Bootsektor schreiben
bootrec /fixboot

:: Boot-Konfigurationsdatenbank (BCD) neu aufbauen
bootrec /rebuildbcd
```

### 2.2 Zerstörte Systemdateien reparieren (Bluescreens, Hänger)
Wenn Windows zwar bootet, aber abstürzt oder Komponenten (wie das Startmenü) nicht mehr gehen:
```cmd
:: Schritt 1: Das Windows Image reparieren (braucht Internet!)
DISM /Online /Cleanup-Image /RestoreHealth

:: Schritt 2: Systemdateien auf Fehler prüfen und reparieren
sfc /scannow
```

### 2.3 Windows Updates hängen (Update-Dienst zurücksetzen)
Wenn Updates fehlschlagen oder bei 0% hängen, muss der Cache geleert werden:
```cmd
:: Update-Dienste stoppen
net stop wuauserv
net stop bits
net stop cryptsvc

:: SoftwareDistribution-Ordner umbenennen (Cache leeren)
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 catroot2.old

:: Dienste wieder starten
net start wuauserv
net start bits
net start cryptsvc
```

### 2.4 Explorer reagiert nicht mehr (Taskkill)
Wenn der Bildschirm schwarz ist, aber der Task-Manager (Strg+Shift+Esc) noch geht -> Datei -> Neuen Task ausführen -> `cmd.exe` (als Admin):
```cmd
:: Explorer brutal beenden
taskkill /F /IM explorer.exe

:: Explorer neu starten
start explorer.exe
```

> [!WARNING]
> Verwende Befehle wie `kill -9` (Linux) oder `taskkill /F` (Windows) nur im absoluten Notfall, da nicht gespeicherte Daten verloren gehen können!
