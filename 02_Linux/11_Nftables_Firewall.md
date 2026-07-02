# 11 nftables Firewall (Linux)

`nftables` ist der moderne Netfilter-Nachfolger fuer Paketfilter, NAT und einfache Host-Firewalls. Auf Remote-Systemen ist ein geplanter Rueckweg Pflicht, bevor Regeln geladen werden.

Quellen:

- nftables Projektseite: <https://www.netfilter.org/projects/nftables/index.html>
- nftables Wiki Quick Reference: <https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes>

## 1. Aktuelle Regeln sichern

```bash
# Aktuelles Ruleset anzeigen
sudo nft list ruleset

# Backup vor Aenderungen erstellen
sudo nft list ruleset | sudo tee /root/nftables-backup.rules >/dev/null

# Dienststatus pruefen
systemctl status nftables
```

## 2. Remote-Sicherheitsnetz setzen

> **Warnung:** Firewall-Regeln koennen SSH, Monitoring oder VPN sofort aussperren. Auf Remote-Systemen immer eine zweite Sitzung offen halten und einen automatischen Rollback planen.

```bash
# Automatischen Rollback in 2 Minuten planen
sudo systemd-run --on-active=2m --unit nft-rollback \
  /usr/sbin/nft -f /root/nftables-backup.rules

# Geplanten Rollback kontrollieren
systemctl status nft-rollback.timer
```

Wenn die neue Firewall funktioniert, Rollback abbrechen:

```bash
sudo systemctl stop nft-rollback.timer nft-rollback.service
```

## 3. Minimales Host-Ruleset

`/etc/nftables.conf`:

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    iif lo accept
    ct state established,related accept
    ct state invalid drop

    tcp dport 22 accept
    ip protocol icmp accept
    ip6 nexthdr icmpv6 accept
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}
```

## 4. Regeln testen und laden

```bash
# Syntax pruefen, ohne Regeln zu laden
sudo nft -c -f /etc/nftables.conf

# Regeln laden
sudo nft -f /etc/nftables.conf

# Persistenz aktivieren
sudo systemctl enable nftables
```

Verifikation:

```bash
sudo nft list ruleset
ss -tulpn
ssh -o BatchMode=yes user@example-host true
```

Rollback:

```bash
sudo nft -f /root/nftables-backup.rules
sudo nft list ruleset
```

## 5. Gezielte Portfreigabe

```bash
# HTTPS temporaer fuer eingehende Verbindungen erlauben
sudo nft add rule inet filter input tcp dport 443 accept

# Regeln anzeigen und Handles finden
sudo nft -a list chain inet filter input

# Regel per Handle entfernen
sudo nft delete rule inet filter input handle 23
```

> **Warnung:** Handles sind laufzeitabhaengig. Vor `delete rule ... handle` immer direkt vorher `nft -a list ...` ausfuehren und die richtige Chain pruefen.
