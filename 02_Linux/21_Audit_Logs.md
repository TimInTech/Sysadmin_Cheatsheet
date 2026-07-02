# 21 Audit Logs (Linux)

Auth-, sudo-, auditd- und Login-Logs fuer Sicherheitspruefungen.

Quellen:

- auditd Documentation: <https://linux.die.net/man/8/auditd>
- last(1) Manual: <https://man7.org/linux/man-pages/man1/last.1.html>

## 1. Auth-Logs

```bash
sudo journalctl -b --no-pager | grep -Ei 'sudo|su:|sshd|authentication|failed password|accepted password|accepted publickey' | tail -n 160
```

## 2. auditd

```bash
systemctl status auditd --no-pager 2>/dev/null || true
sudo ausearch -m USER_LOGIN,USER_AUTH,USER_ACCT 2>/dev/null | tail -n 120 || true
```

## 3. Login-Verlauf

```bash
last -a | head -n 40
lastb -a 2>/dev/null | head -n 40 || true
```
