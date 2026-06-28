# 🛠️ Wichtige Befehle für die Systemwartung

Die Kommandozeile ist ein mächtiges Werkzeug unter Linux. Hier sind die wichtigsten grundlegenden Befehle für Updates, Festplattenverwaltung und Systembereinigung.

## 1. Updates und Upgrades

- **Paketlisten aktualisieren:**
  ```bash
  sudo apt update
  ```
  Aktualisiert die Paketlisten und stellt sicher, dass das System die neuesten Informationen über verfügbare Updates hat.

- **System aktualisieren:**
  ```bash
  sudo apt upgrade -y
  ```
  Installiert alle verfügbaren Updates für das System. Es wird empfohlen, diesen Befehl regelmäßig auszuführen.

- **Distribution aktualisieren (falls erforderlich):**
  ```bash
  sudo apt dist-upgrade -y
  ```
  Aktualisiert das System und nimmt notwendige Änderungen an Abhängigkeiten vor, die bei einem einfachen Upgrade nicht berücksichtigt werden.

- **Manuell installierte Programme aktualisieren:**
  ```bash
  sudo dpkg -i [Dateiname.deb]
  ```
  Wird verwendet, um lokal heruntergeladene `.deb`-Pakete zu installieren oder zu aktualisieren.

---

## 2. Festplattenverwaltung

- **Angeschlossene Laufwerke anzeigen:**
  ```bash
  lsblk
  ```
  Zeigt alle verfügbaren Laufwerke und Partitionen an. Sehr nützlich, um zu sehen, welche Geräte angeschlossen sind.

- **Festplatte überprüfen und reparieren:**
  ```bash
  sudo fsck /dev/sdX
  ```
  *(Ersetze `sdX` mit dem Laufwerksnamen)* Überprüft das Dateisystem auf Fehler und repariert sie. **Vorsicht:** Nicht auf eingehängten (mounted) Partitionen verwenden!

- **Plattenplatz überprüfen:**
  ```bash
  df -h
  ```
  Zeigt den verfügbaren und belegten Speicherplatz auf allen Laufwerken in einem gut lesbaren Format an.

---

## 3. System aufräumen (Wartungsbetrieb)

- **Nicht mehr benötigte Pakete entfernen:**
  ```bash
  sudo apt autoremove -y
  ```
  Entfernt Pakete, die nicht mehr benötigt werden, wie alte Kernel-Versionen oder Abhängigkeiten, die verwaist sind.

- **Cache bereinigen:**
  ```bash
  sudo apt autoclean
  ```
  Bereinigt den Paket-Cache und entfernt veraltete Pakete, die nicht mehr heruntergeladen werden können.

- **Alle Paket-Caches leeren:**
  ```bash
  sudo apt clean
  ```
  Entfernt alle heruntergeladenen Pakete aus dem Cache und schafft so viel zusätzlichen Speicherplatz.

- **Systemprotokolle aufräumen:**
  ```bash
  sudo journalctl --vacuum-time=2weeks
  ```
  Entfernt alte System-Logs und behält nur die Protokolle der letzten zwei Wochen.
