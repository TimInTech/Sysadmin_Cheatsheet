# 13 tcpdump und nmap (Linux)

Paketanalyse mit `tcpdump` und Netzwerkscans mit `nmap` gehoeren zu den wichtigsten Diagnosewerkzeugen fuer Admins. tcpdump zeigt rohen Netzwerkverkehr, nmap kartiert offene Ports und Dienste.

> **Warnung:** Netzwerkscans koennen von Sicherheitssystemen (IDS/IPS) als Angriff gewertet werden. Scans nur auf eigenen oder autorisierten Systemen durchfuehren. `nmap` kann Dienste zum Absturz bringen, wenn aggressive Scan-Methoden eingesetzt werden.

Voraussetzung:

```bash
sudo apt install tcpdump nmap
```

Quellen:

- tcpdump Manual: <https://www.tcpdump.org/manpages/tcpdump.1.html>
- nmap Reference Guide: <https://nmap.org/book/man.html>

## 1. tcpdump – Paketmitschnitt und Analyse

> **Hinweis:** tcpdump benoetigt root-Rechte. Bei grossem Datenverkehr koennen Dateien schnell wachsen – Mitschnitte daher immer mit Filtern und `-c` (Paketzaehler) begrenzen.

### 1.1 Interfaces anzeigen und Live-Mitschnitt

```bash
# Verfuegbare Netzwerkschnittstellen anzeigen
sudo tcpdump --list-interfaces

# Live-Mitschnitt auf eth0 (alle Pakete, bricht mit Strg+C ab)
sudo tcpdump -i eth0

# Nur die ersten 50 Pakete aufzeichnen
sudo tcpdump -i eth0 -c 50
```

### 1.2 Nach Host filtern

```bash
# Nur Verkehr von/zu einer bestimmten IP
sudo tcpdump -i eth0 host 192.168.1.100

# Nur von dieser Quelle
sudo tcpdump -i eth0 src host 10.0.0.5

# Nur zu diesem Ziel
sudo tcpdump -i eth0 dst host 8.8.8.8
```

### 1.3 Nach Port und Protokoll filtern

```bash
# Nur SSH (Port 22)
sudo tcpdump -i eth0 port 22

# Nur HTTP und HTTPS
sudo tcpdump -i eth0 port 80 or port 443

# Nur ICMP (Pings)
sudo tcpdump -i eth0 icmp

# Nur TCP oder UDP
sudo tcpdump -i eth0 tcp
sudo tcpdump -i eth0 udp
```

### 1.4 Kombinierte Filter (BPF-Ausdruecke)

```bash
# HTTP von einer bestimmten Quelle
sudo tcpdump -i eth0 src host 10.0.0.5 and port 80

# DNS-Anfragen (Port 53) an einen bestimmten DNS-Server
sudo tcpdump -i eth0 host 8.8.8.8 and port 53

# Alles ausser SSH und DHCP
sudo tcpdump -i eth0 not port 22 and not port 67 and not port 68

# Bestimmtes Subnetz (CIDR-Notation)
sudo tcpdump -i eth0 net 192.168.1.0/24
```

### 1.5 Mitschnitt in Datei speichern und auslesen

```bash
# Mitschnitt in Datei schreiben (-w)
sudo tcpdump -i eth0 -w /tmp/capture.pcap -c 1000

# Gespeicherten Mitschnitt lesen (-r)
sudo tcpdump -r /tmp/capture.pcap

# Mit Filter aus gespeicherter Datei lesen
sudo tcpdump -r /tmp/capture.pcap port 443

# Menschlich lesbare Ausgabe mit Zeitstempeln (-tttt)
sudo tcpdump -r /tmp/capture.pcap -tttt
```

### 1.6 Ausgabe-Detailgrad steuern

```bash
# -q: Weniger Details (quiet)
sudo tcpdump -i eth0 -q

# -v: Mehr Details (TTL, ID, Gesamtlaenge)
sudo tcpdump -i eth0 -v

# -vv: Noch mehr Details
sudo tcpdump -i eth0 -vv

# -X: Hex und ASCII Ausgabe (Payload sichtbar)
sudo tcpdump -i eth0 -X -c 10

# -A: Nur ASCII (z.B. HTTP-Header lesen)
sudo tcpdump -i eth0 -A port 80
```

### 1.7 Typische Diagnose-Szenarien

```bash
# Lauscht ein Dienst? (SYN-Pakete auf Port 443 beobachten)
sudo tcpdump -i eth0 tcp port 443 and tcp[tcpflags] & tcp-syn != 0

# ARP-Tabelle beobachten (wer fragt wen?)
sudo tcpdump -i eth0 arp

# DHCP-Lease beobachten
sudo tcpdump -i eth0 port 67 or port 68 -v

# TCP-Verbindungsaufbau verfolgen (SYN, SYN-ACK, ACK)
sudo tcpdump -i eth0 host 10.0.0.1 and tcp port 443 -v
```

## 2. nmap – Portscans und Diensterkennung

> **Warnung:** Ein `nmap`-Scan erzeugt Netzverkehr und wird auf fremden Systemen als Einbruchsversuch gewertet. Nur auf eigener Infrastruktur oder mit schriftlicher Erlaubnis einsetzen. Die `-A`-Flagge ist besonders aggressiv.

### 2.1 Einfacher Portscan

```bash
# Standard-Scan der 1000 haeufigsten Ports
nmap 192.168.1.100

# Bestimmte Ports scannen
nmap -p 22,80,443 192.168.1.100

# Portbereich scannen
nmap -p 1-1024 192.168.1.100

# Alle 65535 Ports (zeitaufwendig)
nmap -p- 192.168.1.100
```

### 2.2 Diensterkennung und OS-Detection

```bash
# Dienstversionen ermitteln (-sV)
nmap -sV 192.168.1.100

# OS erkennen (oft nur mit Administratorrechten)
sudo nmap -O 192.168.1.100

# Beides kombiniert (-A = aggressive scan)
sudo nmap -A 192.168.1.100
```

Ausgabe von `-A` enthaelt:

- Offene Ports mit Dienst und Version
- OS-Guess (z.B. "Linux 5.x")
- Traceroute zum Ziel
- Skript-Ergebnisse

### 2.3 Ping-Sweep (Host-Discovery)

```bash
# Alle aktiven Hosts im Subnetz finden
nmap -sn 192.168.1.0/24

# ARP-Scan im lokalen Netz (schneller als ICMP)
sudo nmap -PR -sn 192.168.1.0/24

# Kein Ping, alle Ziele scannen (auch solche, die auf Ping nicht antworten)
nmap -Pn 192.168.1.100
```

### 2.4 Scan-Typen

```bash
# TCP-SYN-Scan (Standard, schnell, unauffaellig)
sudo nmap -sS 192.168.1.100

# TCP-Connect-Scan (keine root-Rechte noetig)
nmap -sT 192.168.1.100

# UDP-Scan (langsam, aber wichtig fuer DNS/DHCP/SNMP)
sudo nmap -sU -p 53,67,68,161 192.168.1.100
```

> **Hinweis:** Ein SYN-Scan (`-sS`) ist diskreter, da keine vollstaendige TCP-Verbindung aufgebaut wird. Ein UDP-Scan (`-sU`) dauert aufgrund fehlender Bestaetigung deutlich laenger.

### 2.5 Ausgabeformate

```bash
# Normal (Mensch lesbar, Dateiendung .nmap)
nmap -oN scan.txt 192.168.1.100

# Grepbar (einfach mit Scripten auswertbar)
nmap -oG scan.gnmap 192.168.1.100

# XML (fuer weitere Verarbeitung z.B. in Tools)
nmap -oX scan.xml 192.168.1.100

# Alle Formate auf einmal
nmap -oA scan 192.168.1.100
```

### 2.6 NSE-Skripte (nmap Scripting Engine)

```bash
# Verfuegbare Skript-Kategorien auflisten
ls /usr/share/nmap/scripts/

# HTTP-Header eines Webservers abrufen
nmap --script http-headers -p 80,443 192.168.1.100

# SSL/TLS-Einstellungen pruefen
nmap --script ssl-enum-ciphers -p 443 192.168.1.100

# Schwachstellen-Scan (Vorsicht!)
nmap --script vuln -p 80,443 192.168.1.100
```

## 3. Kombinierte Diagnose-Workflows

### 3.1 Dienst antwortet nicht – Schritt fuer Schritt

```bash
# 1. Eigenen Netzwerkstack pruefen
ip a
ping -c 3 192.168.1.100

# 2. ARP: Ist das Ziel im lokalen Netz sichtbar?
sudo tcpdump -i eth0 arp and host 192.168.1.100 -c 5

# 3. Porttest: Kommt ein SYN-ACK zurueck?
sudo tcpdump -i eth0 host 192.168.1.100 and tcp port 443 -c 5

# 4. Scan vom eigenen Rechner aus
nmap -Pn -p 443 192.168.1.100
```

### 3.2 Offene Ports im lokalen Netz dokumentieren

```bash
# Alle aktiven Hosts finden
sudo nmap -PR -sn 192.168.1.0/24 -oG /tmp/hosts.gnmap

# Offene Ports auf allen gefundenen Hosts
sudo nmap -sS -p 22,80,443,8080,3306,5432 \
  -oN /tmp/open-ports.txt \
  192.168.1.0/24

# Ausgabe kategoriesieren
grep "open" /tmp/open-ports.txt
```

### 3.3 Unbekannter Traffic untersuchen

```bash
# Wer spricht mit wem? (10 Sekunden mitschneiden)
sudo timeout 10 tcpdump -i eth0 -n -c 1000 \
  | awk '{print $3, $5}' \
  | sed 's/\.[0-9]*$//' \
  | sort | uniq -c | sort -rn | head -20

# Verbindungsversuche auf ungewoehnlichen Ports
sudo tcpdump -i eth0 tcp and not port 22 and not port 80 and not port 443 -c 100
```

## 4. Sicherheitsnetz und Bereinigung

```bash
# tcpdump-Prozesse beenden (falls Mitschnitt laeuft)
sudo pkill -SIGINT tcpdump

# Groessere Mitschnitte komprimieren
gzip /tmp/capture.pcap

# Scan-Ergebnisse mit Timestamp sichern
cp scan.txt scan-$(date +%F_%H%M).txt
```
