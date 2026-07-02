# 12 TLS-Zertifikate und OpenSSL (Linux)

OpenSSL hilft bei Zertifikatsdiagnose, CSR-Erstellung und Chain-Pruefung. Private Keys sind Secrets und gehoeren nicht in Tickets, Chatverlaeufe, Repositories oder Shell-Ausgaben.

Quellen:

- OpenSSL x509 Manual: <https://docs.openssl.org/3.2/man1/openssl-x509/>
- OpenSSL verify Manual: <https://docs.openssl.org/3.0/man1/openssl-verify/>

## 1. Zertifikat anzeigen

```bash
# Laufzeit, Subject, Issuer und SANs anzeigen
openssl x509 -in server.crt -noout -subject -issuer -dates -ext subjectAltName

# Vollstaendige Textansicht fuer Diagnose
openssl x509 -in server.crt -noout -text
```

Pruefpunkte:

- Passt der Common Name oder Subject Alternative Name zum Dienstnamen?
- Ist die Laufzeit noch gueltig?
- Ist die ausstellende CA erwartet?

## 2. Zertifikatskette pruefen

```bash
# Serverzertifikat gegen CA-Bundle pruefen
openssl verify -CAfile ca-chain.pem server.crt

# Mit Intermediate-Zertifikaten pruefen
openssl verify -CAfile root-ca.pem -untrusted intermediate.pem server.crt
```

Verifikation:

- Erwartet ist `server.crt: OK`.
- Bei Fehlern erst Chain, Datum, Hostname und CA-Vertrauen pruefen, bevor Zertifikate ersetzt werden.

## 3. Remote-Zertifikat auslesen

```bash
# Zertifikat eines TLS-Dienstes anzeigen
openssl s_client -connect example.com:443 -servername example.com </dev/null

# Nur Zertifikatsdaten extrahieren
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

## 4. CSR mit separatem Private Key erzeugen

> **Warnung:** Private Keys sind Secrets. Dateirechte restriktiv setzen, Key-Backups verschluesseln und niemals Private-Key-Inhalte in Markdown, Logs oder Tickets kopieren.

```bash
# Private Key erzeugen
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -out server.key
chmod 600 server.key

# CSR erzeugen
openssl req -new -key server.key -out server.csr -subj "/CN=example.com"

# CSR pruefen
openssl req -in server.csr -noout -subject -text
```

Backup:

```bash
# Key verschluesselt in ein gesichertes Backup aufnehmen, Zielpfad anpassen
tar --mode=600 -czf server-key-backup.tgz server.key server.csr
```

## 4.1 ACME / Certbot (Let's Encrypt)

```bash
# Alle verwalteten Zertifikate anzeigen
certbot certificates 2>/dev/null || true

# Automatische Verlängerung prüfen (Timer)
systemctl list-timers | grep -i certbot || true

# Trockenlauf der Verlängerung
certbot renew --dry-run
```

## 5. Config Test, Reload und Rollback

> **Warnung:** Ein falsches Zertifikat oder eine fehlerhafte Konfiguration kann Webserver, Mailserver oder interne APIs sofort stoeren. Vor dem Austausch Konfiguration sichern und testen.

### 5.1 Nginx

```bash
# Vollständige Konfiguration sichern
sudo mkdir -p /root/webserver-config-backups
sudo tar czf /root/webserver-config-backups/nginx-$(date +%Y%m%d-%H%M%S).tar.gz /etc/nginx

# Konfiguration testen
sudo nginx -t

# Reload ohne laufende Verbindungen hart zu beenden
sudo systemctl reload nginx
```

Verifikation:

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

Rollback:

```bash
sudo tar xzf /root/webserver-config-backups/nginx-latest.tar.gz -C /
sudo nginx -t
sudo systemctl reload nginx
```

### 5.2 Caddy

```bash
sudo mkdir -p /root/webserver-config-backups
sudo tar czf /root/webserver-config-backups/caddy-$(date +%Y%m%d-%H%M%S).tar.gz /etc/caddy

# Caddyfile validieren
caddy validate --config /etc/caddy/Caddyfile 2>/dev/null || sudo caddy validate --config /etc/caddy/Caddyfile

sudo systemctl reload caddy
```
