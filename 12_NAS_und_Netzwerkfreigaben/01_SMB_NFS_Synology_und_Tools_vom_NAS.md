# 01 NAS und Netzwerkfreigaben: SMB, NFS, Synology und Tools vom NAS

Ein NAS (Network Attached Storage) ist ein kleiner Server im Heimnetz, der Dateien für alle Geräte bereitstellt. Der Computer sieht einen Ordner des NAS wie ein eigenes Laufwerk. Zwei Verfahren sind üblich: **SMB** (auch "Windows-Freigabe", funktioniert überall) und **NFS** (schnell und einfach unter Linux).

> **Hinweis:** Die Befehle sind gegen die offizielle Dokumentation geprüft (man7.org, systemd, Microsoft Learn). Es stand kein NAS zur Verfügung. Was ein echtes NAS braucht, ist als *nicht getestet* gekennzeichnet. Ersetze `NAS` durch den Namen oder die IP deines NAS, `FREIGABE` durch den Freigabenamen und `BENUTZER` durch dein NAS-Konto.

> **Warnung:** Passwörter gehören nie in Befehle, die im Verlauf (History) landen, und nie in Skripte im Repository. Nutze eine Zugangsdatei mit Rechten `600` (Linux) oder die Abfrage (`*`) bei `net use` (Windows). Gib NAS-Freigaben nie direkt ins Internet frei (kein Port-Forwarding für SMB/NFS).

## 1. Windows: Freigabe verbinden (SMB)

Im Explorer: Adressleiste `\\NAS\FREIGABE` eingeben. Dauerhaft als Laufwerk:

```powershell
# Laufwerk Z: verbinden, fragt nach dem Passwort (* = Abfrage), bleibt nach Neustart erhalten
net use Z: \\NAS\FREIGABE /user:BENUTZER * /persistent:yes

# Verbundene Freigaben anzeigen
net use
Get-SmbMapping

# Verbindung trennen
net use Z: /delete
```

Falls der Name `NAS` nicht aufgelöst wird, die IP-Adresse des NAS verwenden: `\\IP-ADRESSE\FREIGABE`.

> **Hinweis:** Fehlermeldung "Sie können nicht verbunden werden, weil die Richtlinie ... unsichere Gastanmeldungen ... blockiert": Das NAS erlaubt Gastzugriff. Besser ein NAS-Konto mit Passwort anlegen, statt die Windows-Richtlinie zu lockern.

Die Optionen von `net use` zeigt `net use /?` direkt in der Eingabeaufforderung. Für PowerShell siehe [Get-SmbMapping](https://learn.microsoft.com/de-de/powershell/module/smbshare/get-smbmapping).

## 2. Linux: SMB-Freigabe verbinden

```bash
# Werkzeuge installieren
sudo apt update
sudo apt install cifs-utils smbclient

# Freigaben des NAS auflisten
smbclient -L //NAS -U BENUTZER

# Einhängepunkt anlegen und einmalig verbinden
sudo mkdir -p /mnt/nas
sudo mount -t cifs //NAS/FREIGABE /mnt/nas -o username=BENUTZER,uid=$(id -u),gid=$(id -g),vers=3.0
```

Das Passwort wird abgefragt. `uid` und `gid` sorgen dafür, dass dein Benutzer die Dateien besitzt. Mit `vers=3.0` erzwingst du SMB 3. Ältere NAS brauchen `vers=2.1`. Die Optionen stehen in der [mount.cifs-Hilfe](https://man7.org/linux/man-pages/man8/mount.cifs.8.html).

### Dauerhaft einbinden (fstab)

Zugangsdatei anlegen (nur du darfst sie lesen):

```bash
sudo install -m 600 /dev/null /root/.nas-zugang
sudo nano /root/.nas-zugang
```

Inhalt der Datei (zwei Zeilen, Werte ersetzen):

```text
username=BENUTZER
password=PASSWORT
```

Eintrag in `/etc/fstab` (eine Zeile). `nofail` und `x-systemd.automount` verhindern, dass der Rechner beim Start hängt, wenn das NAS aus ist:

```text
//NAS/FREIGABE  /mnt/nas  cifs  credentials=/root/.nas-zugang,uid=1000,gid=1000,file_mode=0664,dir_mode=0775,vers=3.0,_netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=60  0  0
```

`uid=1000` ist meist der erste Benutzer. Mit `id -u` prüfen. Danach testen, **bevor** du neu startest:

```bash
sudo cp /etc/fstab /etc/fstab.bak
sudo systemctl daemon-reload
sudo mount -a
ls /mnt/nas
```

Rollback bei Fehlern: `sudo cp /etc/fstab.bak /etc/fstab && sudo systemctl daemon-reload`.

> **Warnung:** Ein falscher `fstab`-Eintrag kann den Start verzögern. `nofail` ist deshalb Pflicht bei Netzlaufwerken. Die Optionen stehen in [systemd.mount](https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html) und [fstab(5)](https://man7.org/linux/man-pages/man5/fstab.5.html). Das Einbinden mit echtem NAS ist *nicht getestet*.

Wieder lösen:

```bash
sudo umount /mnt/nas
```

## 3. Linux: NFS-Freigabe verbinden

NFS braucht kein Passwort, sondern erlaubt bestimmte Rechner anhand der Adresse. Das ist im Heimnetz bequem, aber nur sicher, wenn nur Geräte deines Netzes drin sind.

```bash
sudo apt install nfs-common

# Welche Freigaben bietet das NAS?
showmount -e NAS

# Einmalig einbinden
sudo mkdir -p /mnt/nfs
sudo mount -t nfs -o nfsvers=4.1 NAS:/volume1/FREIGABE /mnt/nfs
```

Der Pfad nach dem Doppelpunkt ist der Exportpfad auf dem NAS, bei Synology meist `/volume1/FREIGABE`. Dauerhaft in `/etc/fstab`:

```text
NAS:/volume1/FREIGABE  /mnt/nfs  nfs  nfsvers=4.1,_netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=60  0  0
```

Zum Prüfen wieder `sudo mount -a`. Der Unterschied `hard`/`soft` ist in der [nfs(5)-Hilfe](https://man7.org/linux/man-pages/man5/nfs.5.html) erklärt: `hard` (Standard) wartet bei NAS-Ausfall, `soft` bricht ab und kann Daten verlieren. Für Backups `hard` lassen. Nicht getestet.

## 4. Windows: NFS (nur Pro/Enterprise)

Windows 10/11 Pro und Enterprise können NFS als optionales Feature. Home-Editionen nicht. Nutze dort lieber SMB.

```powershell
# Als Administrator, Neustart danach
Enable-WindowsOptionalFeature -Online -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -NoRestart
```

Danach `mount \\NAS\volume1\FREIGABE Z:` (Pfad mit Backslash). Nicht getestet.

## 5. Synology einrichten

Am NAS in der Weboberfläche (DSM, nicht getestet, Menünamen können je nach DSM-Version abweichen):

1. **Systemsteuerung -> Gemeinsamer Ordner**: Ordner anlegen, z. B. `tools`.
2. **Systemsteuerung -> Benutzer und Gruppe**: eigenen Benutzer für die Freigabe anlegen (nicht `admin` benutzen) und Rechte auf *Lesen/Schreiben* setzen.
3. **Systemsteuerung -> Dateidienste -> SMB**: SMB aktivieren. Als Mindestversion SMB 2 oder 3 wählen. **SMB 1 aus lassen.**
4. Für NFS: **Dateidienste -> NFS** aktivieren, dann am Ordner **Bearbeiten -> NFS-Berechtigungen -> Erstellen**. Als Client die IP des Computers eintragen, nicht `*`.
5. Zwei-Faktor-Anmeldung und automatische Updates für das NAS einschalten.

Offizielle Anleitung: [Synology Knowledge Center](https://kb.synology.com/de-de).

## 6. Portable Tools vom NAS

Ein Ordner `tools` auf dem NAS dient als gemeinsame Werkzeugkiste: Installer, das [SSH-Toolkit](../toolkit/README.md), ISO-Dateien und Skripte stehen dann an jedem Rechner im Heimnetz bereit.

Aufbau-Vorschlag:

```text
tools/
├── toolkit/          # SSH-Toolkit aus diesem Repository
├── installer/        # Programme (Firefox, 7-Zip, ...)
├── iso/              # Windows-, Ubuntu-ISOs, Rettungsstick-Abbilder
└── skripte/          # eigene Hilfsskripte
```

Toolkit auf das NAS legen (Linux/Windows, über die verbundene Freigabe):

```bash
cp -r toolkit /mnt/nas/tools/
```

```powershell
Copy-Item -Recurse .\toolkit Z:\tools\
```

Auf einem frisch installierten Rechner das Toolkit direkt von der Freigabe starten:

```powershell
# Windows: Laufwerk verbinden und Ordner öffnen
net use Z: \\NAS\tools /user:BENUTZER *
explorer Z:\toolkit
```

> **Warnung:** Führe Skripte vom NAS nur aus, wenn du dem Ordner vertraust. Wer Schreibrechte auf `tools` hat, kann dort Schadcode ablegen. Gib die Freigabe deshalb für normale Benutzer **nur lesend** frei. Schreibrechte nur dein Admin-Konto.

Wer Dateien prüfen will, vergleicht Prüfsummen:

```powershell
Get-FileHash .\setup.exe -Algorithm SHA256
```

```bash
sha256sum setup.exe
```

Weitere Hinweise: [Download-Links](../04_Rettungsmedien_und_Live_Systeme/04_Download_Links.md).

## 7. Fehlersuche

| Problem | Prüfen |
| --- | --- |
| NAS nicht erreichbar | `ping NAS`, IP-Adresse statt Name, gleiches Netz/WLAN |
| "Zugriff verweigert" | Benutzer hat Rechte am Ordner? Passwort richtig? |
| Linux: `mount error(13)` | Falsche Zugangsdaten oder falsche `vers=`-Option |
| Linux: `mount error(112)` oder Zeitüberschreitung | `vers=3.0`/`2.1` anpassen, Firewall des NAS prüfen |
| NFS: `access denied` | Client-IP in den NFS-Berechtigungen des NAS eingetragen? |
| Rechner startet langsam | In `fstab` fehlt `nofail` bzw. `x-systemd.automount` |

```bash
# Linux: Freigaben und Ports des NAS prüfen (445 = SMB, 2049 = NFS)
nc -zv NAS 445
nc -zv NAS 2049
```

Weitere Netzwerkdiagnose: [Netzwerk und Dienste](../02_Linux/03_Netzwerk_und_Dienste.md), [DNS-Diagnose](../02_Linux/23_DNS_Diagnose.md), [Netzwerk und Reset (Windows)](../01_Windows_11/04_Netzwerk_und_Reset.md).

## Quellen

- [mount.cifs (man7.org)](https://man7.org/linux/man-pages/man8/mount.cifs.8.html)
- [nfs(5) (man7.org)](https://man7.org/linux/man-pages/man5/nfs.5.html)
- [systemd.mount](https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html)
- [Get-SmbMapping (Microsoft Learn)](https://learn.microsoft.com/de-de/powershell/module/smbshare/get-smbmapping)
- [Synology Knowledge Center](https://kb.synology.com/de-de)
