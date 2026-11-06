# 01 Remotezugriff über SSH hinaus: RDP, VNC, Tailscale, WireGuard und Wake-on-LAN

SSH reicht für die Kommandozeile. Wer den **Bildschirm** eines anderen Rechners sehen will, braucht RDP oder VNC. Wer von **unterwegs** zugreifen will, braucht ein VPN wie Tailscale oder WireGuard. Und wer den Rechner erst **einschalten** muss, nutzt Wake-on-LAN. Das einfache SSH-Setup steht im [SSH-Toolkit](../toolkit/README.md).

> **Hinweis:** Die Befehle sind gegen die Hilfe von FreeRDP 3.32.1 und ethtool sowie die offizielle Dokumentation von Microsoft, Tailscale, WireGuard und xrdp geprüft. Es standen keine zweiten Rechner, kein Windows und kein Router bereit. Alles, was ein Gegenüber braucht, ist als *nicht getestet* gekennzeichnet. Ersetze `HOST` durch Name oder Adresse des Zielrechners und `BENUTZER` durch das Konto dort.

> **Warnung:** Öffne **nie** RDP (Port 3389) oder VNC (Port 5900) direkt im Router zum Internet. Solche Ports werden ständig gescannt und angegriffen. Nutze dafür ein VPN (Abschnitte 4 und 5) oder einen SSH-Tunnel (Abschnitt 3).

## Welche Lösung passt?

| Ziel | Lösung |
| --- | --- |
| Windows-PC im Heimnetz bedienen | RDP (Abschnitt 1) |
| Ubuntu-Desktop bedienen | xrdp oder GNOME-Remotedesktop (Abschnitt 2) |
| Von unterwegs, möglichst einfach | Tailscale (Abschnitt 4) |
| Eigenes VPN, volle Kontrolle | WireGuard (Abschnitt 5) |
| Rechner aus dem Ruhezustand wecken | Wake-on-LAN (Abschnitt 6) |

## 1. Windows: Remotedesktop (RDP)

Der RDP-Server ist nur in **Windows 10/11 Pro, Enterprise und Education** enthalten, nicht in Home. Als Client (Verbinden) funktioniert jede Edition.

### Einschalten am Zielrechner

Einfach: **Einstellungen -> System -> Remotedesktop** einschalten. Per PowerShell (als Administrator):

```powershell
# Remotedesktop erlauben
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0

# Firewallregel für Remotedesktop aktivieren
Enable-NetFirewallRule -DisplayGroup "Remotedesktop"
```

Der Name der Firewall-Gruppe ist sprachabhängig: "Remote Desktop" auf englischem Windows. Mit `Get-NetFirewallRule | Select-Object DisplayGroup -Unique` den genauen Namen prüfen. Die Netzwerkebenen-Authentifizierung (NLA) bleibt eingeschaltet. Die Windows-Schritte stehen in der [Microsoft-Dokumentation](https://learn.microsoft.com/de-de/windows-server/remote/remote-desktop-services/clients/remote-desktop-allow-access). Nicht getestet.

Rückgängig: `fDenyTSConnections` auf `1` setzen und `Disable-NetFirewallRule -DisplayGroup "Remotedesktop"`.

> **Warnung:** Das verbindende Konto braucht ein **Passwort**. Konten ohne Passwort können sich per RDP nicht anmelden. Verwende ein starkes Passwort oder eine PIN-lose Anmeldung nur im vertrauten Netz.

### Verbinden

Windows: `mstsc` eingeben oder die App "Remotedesktopverbindung" starten, `HOST` eintragen.

Linux (FreeRDP):

```bash
sudo apt install freerdp3-x11
xfreerdp3 /v:HOST /u:BENUTZER /size:1920x1080 /cert:tofu
```

Das Passwort wird abgefragt. `/cert:tofu` merkt sich das Zertifikat beim ersten Mal und warnt, wenn es sich ändert. Zum Dateien teilen: `/drive:tauschen,/home/BENUTZER/Tausch`. Welcher Paketname bei deiner Version passt (`freerdp3-x11` oder `freerdp2-x11`), zeigt `apt search freerdp`. Bequem mit Oberfläche geht es mit **Remmina** (`sudo apt install remmina`).

## 2. Linux: Desktop von außen bedienen

### Variante A: xrdp (RDP für Linux)

Damit verbindet sich Windows-`mstsc` direkt mit einem Ubuntu-Rechner.

```bash
sudo apt update
sudo apt install xrdp
sudo systemctl enable --now xrdp
systemctl status xrdp --no-pager

# Firewall (nur nötig, wenn ufw aktiv ist; besser nur für dein Heimnetz freigeben)
sudo ufw allow from NETZ/24 to any port 3389 proto tcp
```

`NETZ/24` ist dein Heimnetz in Kurzschreibweise (Adresse und Maske mit `ip -br a` ermitteln). Bei Ubuntu mit GNOME braucht xrdp oft einen Eintrag für Zertifikate und meldet nach der Anmeldung einen schwarzen Bildschirm, wenn derselbe Benutzer schon am Rechner angemeldet ist. Dann zuerst am Rechner abmelden. Das Verhalten hängt von der Ubuntu-Version ab. Nicht getestet.

### Variante B: GNOME-Remotedesktop (eingebaut)

Neuere Ubuntu-Versionen mit GNOME bringen eine Freigabe mit: **Einstellungen -> System -> Remote-Desktop** (bzw. *Freigabe -> Remotedesktop*). Dort Benutzername und Passwort festlegen. Vorteil: Funktioniert mit Wayland. Verbinden mit einem RDP-Client wie oben. Menünamen unterscheiden sich je nach Version, nicht getestet.

### Variante C: VNC

VNC sendet standardmäßig **unverschlüsselt**. Nur über SSH-Tunnel oder VPN verwenden.

```bash
# Auf dem Zielrechner (X11-Sitzung): aktuellen Desktop über Port 5900 anbieten, nur lokal
sudo apt install x11vnc
x11vnc -display :0 -localhost -usepw -forever
```

Beim ersten Start legt `-usepw` ein Passwort an. Von deinem Rechner per SSH-Tunnel verbinden (siehe Abschnitt 3):

```bash
ssh -L 5900:localhost:5900 BENUTZER@HOST
# in einem zweiten Fenster:
remmina -c vnc://localhost:5900
```

`x11vnc` zeigt unter Wayland nichts oder nur einen schwarzen Bildschirm. Dann Variante A oder B verwenden. Nicht getestet.

## 3. SSH-Tunnel für RDP und VNC

Ein Tunnel packt den Verkehr in die SSH-Verbindung. Das Beispiel leitet den lokalen Port 3390 an den RDP-Port des Zielrechners weiter:

```bash
ssh -L 3390:localhost:3389 BENUTZER@HOST
xfreerdp3 /v:localhost:3390 /u:BENUTZER
```

SSH auf Windows einrichten: [OpenSSH-Server unter Windows](../01_Windows_11/11_OpenSSH_Server_Ubuntu_Zugriff.md). Port-Forwarding im Detail: [SSH und Remote-Zugriff](../02_Linux/04_SSH_und_Remote_Zugriff.md).

## 4. Tailscale: das einfachste VPN

Tailscale verbindet deine Geräte zu einem privaten Netz, ohne Portfreigabe im Router. Jedes Gerät bekommt eine feste Adresse und einen Namen. Du brauchst ein Konto bei einem Anmeldedienst (Google, Microsoft, GitHub u. a.). Der Dienst ist für Privatpersonen im kostenlosen Tarif nutzbar, die aktuellen Grenzen stehen auf der [Tailscale-Webseite](https://tailscale.com/pricing).

> **Hinweis:** Die Anmeldung läuft im Browser. Gib dein Passwort nur dort ein, nie in ein Terminal oder in dieses Repository.

```bash
# Linux: Installation laut offizieller Anleitung
# https://tailscale.com/kb/1031/install-linux
# (Das Skript vorher ansehen: curl -fsSL https://tailscale.com/install.sh | less)
curl -fsSL https://tailscale.com/install.sh | sh

# Anmelden (öffnet einen Link zur Anmeldung)
sudo tailscale up

# Status und Adresse dieses Geräts
tailscale status
tailscale ip -4

# Erreichbarkeit eines anderen Geräts testen
tailscale ping GERÄTENAME
```

Windows: Installer von [tailscale.com/download](https://tailscale.com/download) und anmelden. Danach erreichst du jedes Gerät über seinen Namen oder die Tailscale-Adresse, z. B. `xfreerdp3 /v:GERÄTENAME /u:BENUTZER` oder `ssh BENUTZER@GERÄTENAME`.

Ausschalten und Rückgängig:

```bash
sudo tailscale down
```

Optionen findest du in der [CLI-Referenz](https://tailscale.com/kb/1080/cli). Nicht getestet (kein zweites Gerät).

## 5. WireGuard: eigenes VPN

WireGuard ist ein schlankes, schnelles VPN. Du brauchst einen Server mit **erreichbarer Adresse** (öffentliche IP oder DynDNS-Name) und eine Portweiterleitung im Router für den UDP-Port. Für Einsteiger ist Tailscale einfacher.

```bash
sudo apt install wireguard-tools

# Schlüsselpaar erzeugen (privaten Schlüssel nie weitergeben)
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

Beispiel für `/etc/wireguard/wg0.conf` auf dem **Server** (Tunnelnetz `10.200.200.0/24` ist frei wählbar, Werte in Großbuchstaben ersetzen):

```ini
[Interface]
Address = 10.200.200.1/24
ListenPort = 51820
PrivateKey = PRIVATER_SCHLUESSEL_DES_SERVERS

[Peer]
# Laptop
PublicKey = OEFFENTLICHER_SCHLUESSEL_DES_LAPTOPS
AllowedIPs = 10.200.200.2/32
```

Auf dem **Laptop** (Client):

```ini
[Interface]
Address = 10.200.200.2/24
PrivateKey = PRIVATER_SCHLUESSEL_DES_LAPTOPS

[Peer]
PublicKey = OEFFENTLICHER_SCHLUESSEL_DES_SERVERS
Endpoint = SERVER-ADRESSE:51820
AllowedIPs = 10.200.200.0/24
PersistentKeepalive = 25
```

Starten, prüfen, stoppen:

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
sudo wg-quick up wg0
sudo wg show
sudo wg-quick down wg0

# Beim Start automatisch
sudo systemctl enable --now wg-quick@wg0
```

`AllowedIPs = 10.200.200.0/24` leitet nur den Tunnelverkehr. `0.0.0.0/0` würde allen Internetverkehr über den Server schicken, braucht aber zusätzlich Weiterleitung und Firewall-Regeln auf dem Server. Quellen: [WireGuard Quickstart](https://www.wireguard.com/quickstart/) und [Ubuntu Server: WireGuard](https://documentation.ubuntu.com/server/how-to/wireguard-vpn/). Nicht getestet.

> **Warnung:** Prüfe die Firewall vor `wg-quick up` auf SSH-Zugang, besonders bei entfernten Servern. Eine falsche `AllowedIPs`-Zeile kann dich aussperren.

## 6. Wake-on-LAN (Rechner aus der Ferne einschalten)

Wake-on-LAN (WoL) schaltet einen ausgeschalteten oder schlafenden Rechner per Netzwerkpaket ein. Es funktioniert in der Regel nur mit **Netzwerkkabel** und im selben Netz. Du brauchst die MAC-Adresse der Netzwerkkarte des Zielrechners.

### Zielrechner vorbereiten

1. Im **BIOS/UEFI** die Option "Wake on LAN" bzw. "Power On By PCI-E" einschalten (Name je nach Hersteller).
2. **Windows:** Geräte-Manager -> Netzwerkadapter -> Eigenschaften -> Erweitert: "Wake on Magic Packet" aktivieren. Reiter *Energieverwaltung*: "Gerät kann den Computer aus dem Ruhezustand aktivieren". Zusätzlich **Schnellstart** abschalten (Systemsteuerung -> Energieoptionen -> Auswirkungen des Netzschalters), sonst wacht der Rechner nach dem Herunterfahren oft nicht auf.

```powershell
# Karten und MAC-Adresse anzeigen
Get-NetAdapter | Select-Object Name, MacAddress, Status

# Magic Packet erlauben (Name des Adapters ersetzen)
Set-NetAdapterPowerManagement -Name "Ethernet" -WakeOnMagicPacket Enabled
```

Der Befehl ist in der [Dokumentation](https://learn.microsoft.com/de-de/powershell/module/netadapter/set-netadapterpowermanagement) beschrieben. Nicht getestet.

**Linux:**

```bash
# Netzwerkkarte und MAC-Adresse
ip -br link

# Aktueller Stand (Wake-on: g bedeutet eingeschaltet)
sudo ethtool NETZWERKKARTE | grep -i wake

# Einschalten (gilt bis zum nächsten Neustart)
sudo ethtool -s NETZWERKKARTE wol g
```

`ethtool -s … wol g` ist in der ethtool-Hilfe dokumentiert. Die Einstellung geht beim Neustart verloren. Dauerhaft geht es mit NetworkManager:

```bash
sudo nmcli connection modify "VERBINDUNGSNAME" 802-3-ethernet.wake-on-lan magic
sudo nmcli connection up "VERBINDUNGSNAME"
```

`nmcli connection show` zeigt den Namen. Nicht getestet.

### Das Weckpaket senden

Von einem anderen Rechner **im selben Netz**:

```bash
sudo apt install wakeonlan
wakeonlan AA:BB:CC:DD:EE:FF
```

Alternative: `sudo etherwake -i NETZWERKKARTE AA:BB:CC:DD:EE:FF`. `AA:BB:CC:DD:EE:FF` durch die MAC-Adresse des Zielrechners ersetzen. Aufwecken von unterwegs geht nur über ein weiteres, immer laufendes Gerät im Heimnetz (z. B. ein Raspberry Pi oder das NAS), das du per Tailscale oder SSH erreichst und das dann `wakeonlan` ausführt.

### Fehlersuche

| Problem | Prüfen |
| --- | --- |
| Rechner wacht nicht auf | BIOS-Option, Kabel statt WLAN, Schnellstart aus, WoL-Einstellung der Karte |
| Geht nur aus dem Ruhezustand, nicht aus "Aus" | Netzteil/Board-Standby, BIOS-Option "ErP/EuP" abschalten |
| Linux: Einstellung verschwindet | nmcli-Eintrag setzen (siehe oben) |
| Von unterwegs geht nichts | Weckpaket muss im Heimnetz gesendet werden |

## 7. Absichern

- Nutze für RDP und VNC nur das lokale Netz, einen SSH-Tunnel oder ein VPN.
- Aktiviere für Tailscale-Konten die Zwei-Faktor-Anmeldung.
- Trenne die Verbindung und schalte Remote-Funktionen aus, wenn du sie nicht brauchst.
- Hinweise zu Firewall und Netzwerk: [Netzwerk und Dienste](../02_Linux/03_Netzwerk_und_Dienste.md), [nftables Firewall](../02_Linux/11_Nftables_Firewall.md).

## Quellen

- [Remotedesktop erlauben (Microsoft Learn)](https://learn.microsoft.com/de-de/windows-server/remote/remote-desktop-services/clients/remote-desktop-allow-access)
- [Set-NetAdapterPowerManagement (Microsoft Learn)](https://learn.microsoft.com/de-de/powershell/module/netadapter/set-netadapterpowermanagement)
- [xrdp](https://www.xrdp.org/)
- [Tailscale: Linux installieren](https://tailscale.com/kb/1031/install-linux) und [CLI](https://tailscale.com/kb/1080/cli)
- [WireGuard Quickstart](https://www.wireguard.com/quickstart/)
- [Wake-on-LAN (ArchWiki)](https://wiki.archlinux.org/title/Wake-on-LAN)
