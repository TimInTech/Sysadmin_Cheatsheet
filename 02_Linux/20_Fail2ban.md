# 20 Fail2ban (Linux)

Fail2ban-Status, Jails, Logs und manuelles Ban/Unban.

Quellen:

- Fail2ban Wiki: <https://github.com/fail2ban/fail2ban/wiki>

## 1. Status

```bash
fail2ban-client version 2>/dev/null || true
systemctl status fail2ban --no-pager 2>/dev/null || true
```

## 2. Jails anzeigen

```bash
sudo fail2ban-client status 2>/dev/null || true
```

## 3. Logs prüfen

```bash
journalctl -u fail2ban -b --no-pager 2>/dev/null | tail -n 160
sudo tail -n 160 /var/log/fail2ban.log 2>/dev/null || true
```

## 4. Manuell bannen / entbannen

```bash
# IP bannen
sudo fail2ban-client set JAILNAME ban IP

# IP entbannen
sudo fail2ban-client set JAILNAME unban IP
```
