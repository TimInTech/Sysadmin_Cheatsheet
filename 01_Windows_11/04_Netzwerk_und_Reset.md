# 04 Netzwerk und Reset (Windows 11)

Befehle für die Diagnose und Reparatur der Netzwerk-Infrastruktur unter Windows 11. Diese Befehle helfen oft bei undefinierbaren Verbindungsproblemen, WLAN-Abbrüchen oder IP-Konflikten.

## 1. Komplettes Netzwerk-Reset (Der "Heilige Gral")

Führe diese Befehle als Administrator (CMD) aus, wenn das Netzwerk streikt. Sie setzen den Netzwerk-Stack komplett zurück. Nach Ausführung ist ein Neustart zwingend erforderlich!

```cmd
:: 1. Winsock-Katalog zurücksetzen (repariert kaputte Sockets und LSPs)
netsh winsock reset

:: 2. TCP/IP-Stack zurücksetzen (stellt Standardkonfiguration her)
netsh int ip reset

:: 3. DNS-Cache leeren (behebt Probleme bei Namensauflösung)
ipconfig /flushdns

:: 4. Aktuelle IP-Adresse(n) freigeben
ipconfig /release

:: 5. Neue IP-Adresse(n) vom DHCP-Server anfordern
ipconfig /renew
```

## 2. WLAN / Wi-Fi Diagnose

```cmd
:: Alle gespeicherten WLAN-Profile anzeigen
netsh wlan show profiles

:: Details zu einem gespeicherten WLAN-Profil anzeigen
netsh wlan show profile name="WLAN-Name"

:: Detaillierten HTML-Report über die WLAN-Historie generieren (hilft bei Abbrüchen)
netsh wlan show wlanreport
```

Klartext-Passwörter nicht in Befehlen dokumentieren oder unnötig ausgeben.

## 3. Firewall zurücksetzen

Falls ein Programm durch falsche Firewall-Regeln blockiert wird:

> **Warnung:** `netsh advfirewall reset` entfernt angepasste Firewall-Regeln. Vorher Regeln exportieren oder dokumentieren, besonders auf Remote-Systemen.

```cmd
:: Backup der aktuellen Firewall-Regeln
netsh advfirewall export "%USERPROFILE%\Desktop\firewall-backup.wfw"

:: Windows Defender Firewall komplett auf Standardeinstellungen zurücksetzen
netsh advfirewall reset

:: Verifikation
netsh advfirewall show allprofiles

:: Rollback
netsh advfirewall import "%USERPROFILE%\Desktop\firewall-backup.wfw"
```
