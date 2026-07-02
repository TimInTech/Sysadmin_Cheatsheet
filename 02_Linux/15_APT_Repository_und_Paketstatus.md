# 15 APT-Repository und Paketstatus (Linux)

Paketquellen, Keyrings und Reparaturdiagnose fuer apt/dpkg.

Quellen:

- Debian Reference: <https://www.debian.org/doc/manuals/debian-reference/>
- Ubuntu Server Docs: <https://ubuntu.com/server/docs/>

## 1. Paketstatus prüfen

```bash
apt list --upgradable 2>/dev/null
dpkg --audit
apt-mark showhold
```

## 2. Paketquellen anzeigen

```bash
grep -RhsE '^(deb|Types:|URIs:|Suites:|Components:|Signed-By:)' \
  /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources 2>/dev/null
```

## 3. Keyrings prüfen

```bash
find /etc/apt/keyrings /usr/share/keyrings -maxdepth 1 -type f 2>/dev/null | sort
```

## 4. Upgrade simulieren

```bash
sudo apt update
sudo apt -s full-upgrade
```

## 5. Paketverwaltung reparieren

> **Warnung:** Kann Paketkonfigurationen abschliessen und Abhaengigkeiten aendern.

```bash
sudo dpkg --configure -a
sudo apt --fix-broken install
dpkg --audit
```
