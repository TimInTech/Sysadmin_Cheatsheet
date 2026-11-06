# ChatGPT – Promptvorlagen mit Merknamen

Sammlung technischer Promptvorlagen für Linux, Windows, Netzwerk, Homelab, Git, Programmierung und IT-Sicherheit.

> [!NOTE]
> Die Namen wie `/linuxfehler` sind frei gewählte Merknamen und keine eingebauten ChatGPT-Befehle. Prompttext aus dem Codeblock kopieren, Angaben ergänzen und Logs oder Dateien anhängen. Verfügbare Werkzeuge hängen von App und Tarif ab.

> [!WARNING]
> In Prompts keine Passwörter, Tokens, privaten Schlüssel oder interne Adressen einfügen. Logs und Konfigurationen vorher schwärzen.

## Universelles Promptgerüst

```text
Aufgabe: Was soll konkret getan werden?
Kontext: Welche Daten, Dateien, Zielgruppe und Ziele sind wichtig?
Grenzen: Was darf nicht verändert oder angenommen werden?
Ausgabe: Wie lang und in welchem Format soll die Antwort sein?
Prüfung: Welche Fakten müssen belegt und welche Unsicherheiten genannt werden?
```

## Computer & Windows (12 Vorlagen)

### `/winfehler` — Windows-Fehler analysieren

```text
Analysiere diesen Windows-Fehlercode und nenne zuerst sichere Diagnoseprüfungen.
```

### `/treibercheck` — Treiberbedarf klären

```text
Prüfe anhand dieses Geräte-Manager-Screenshots, welcher Treiber fehlt.
```

### `/startproblem` — Bootfehler einordnen

```text
Hilf mir, einen Windows-Startfehler einzugrenzen, ohne Daten zu löschen.
```

### `/speichercheck` — Datenträger verstehen

```text
Erkläre mir diese Windows-Datenträgerverwaltung und identifiziere die Systempartition.
```

### `/updatecheck` — Updates beurteilen

```text
Erkläre, was dieses Windows-Update ändert und ob bekannte Probleme bestehen.
```

### `/leistungcheck` — Performance analysieren

```text
Analysiere diese Task-Manager-Werte auf mögliche Flaschenhälse.
```

### `/backupplan` — Backup planen

```text
Entwirf einen Windows-Backupplan mit Wiederherstellungstest.
```

### `/netzfehler` — Verbindung testen

```text
Führe mich durch sichere Netzwerktests bei fehlendem Internetzugang.
```

### `/autostart` — Startprogramme bewerten

```text
Hilf mir, unnötige Autostart-Einträge anhand der Liste zu erkennen.
```

### `/cmdverstehen` — Befehl erklären

```text
Erkläre genau, was dieser PowerShell-Befehl macht, bevor ich ihn ausführe.
```

### `/installation` — Setup vorbereiten

```text
Erstelle eine Checkliste für eine saubere Windows-Installation mit Datensicherung.
```

### `/fehlerprotokoll` — Logs interpretieren

```text
Werte diese Ereignisanzeige-Meldung aus und priorisiere wahrscheinliche Ursachen.
```

## Linux & Terminal (12 Vorlagen)

### `/linuxdiagnose` — Systematisch prüfen

```text
Analysiere diese Terminalausgabe und fordere nur fehlende Diagnosedaten an.
```

### `/befehlcheck` — Befehl vorab prüfen

```text
Erkläre Risiken, Nebenwirkungen und Rückweg dieses Shell-Befehls.
```

### `/journalcheck` — System-Logs lesen

```text
Werte diese journalctl-Ausgabe aus und markiere den ersten relevanten Fehler.
```

### `/servicecheck` — Dienst untersuchen

```text
Hilf mir, den Status eines systemd-Dienstes anhand dieser Ausgabe zu prüfen.
```

### `/rechtecheck` — Berechtigungen verstehen

```text
Erkläre diese chmod- und chown-Werte an meinem Dateibeispiel.
```

### `/sshcheck` — SSH-Probleme

```text
Analysiere diese SSH-Fehlermeldung und nenne sichere Prüfungen.
```

### `/speicherlinux` — Speichernutzung prüfen

```text
Erkläre die Ausgabe von df -h und du -sh und erkenne Engpässe.
```

### `/netzlinux` — Linux-Netzwerk prüfen

```text
Interpretiere ip addr und ip route ohne Konfigurationsänderungen.
```

### `/paketcheck` — Paketkonflikt prüfen

```text
Analysiere die Fehlermeldung von apt und schlage reversible Schritte vor.
```

### `/shellscript` — Skript entwerfen

```text
Schreibe ein Bash-Skript, das täglich Logdateien nach Größe sortiert.
```

### `/croncheck` — Zeitplan verstehen

```text
Erkläre, wann dieser Cron-Ausdruck ausgeführt wird.
```

### `/rollback` — Rückweg planen

```text
Erstelle vor einer Konfigurationsänderung einen klaren Backup- und Rollbackplan.
```

## Programmieren & Code (12 Vorlagen)

### `/codeerklaeren` — Code verstehen

```text
Erkläre die Funktion dieses Python-Skripts abschnittsweise.
```

### `/codefehler` — Bug suchen

```text
Finde den wahrscheinlichen Fehler in diesem Code anhand des Tracebacks.
```

### `/codeaudit` — Qualität prüfen

```text
Prüfe diesen Code auf Wartbarkeit, Fehlerbehandlung und Sicherheit.
```

### `/refactoring` — Code vereinfachen

```text
Refaktoriere diese Funktion ohne ihr Verhalten zu ändern.
```

### `/testfaelle` — Tests entwerfen

```text
Erstelle pytest-Tests für diese Eingabevalidierung, inklusive Grenzfällen.
```

### `/typen` — Typisierung ergänzen

```text
Ergänze präzise Python-Typannotationen für diese Funktionen.
```

### `/regex` — Regulären Ausdruck erstellen

```text
Entwickle einen Regex für deutsche Postleitzahlen und nenne Grenzen.
```

### `/apiantwort` — API verstehen

```text
Erkläre dieses JSON-API-Ergebnis und die wichtigsten Felder.
```

### `/algorithmus` — Vorgehen planen

```text
Entwirf einen effizienten Algorithmus zum Entfernen doppelter Datensätze.
```

### `/codekommentar` — Kommentare verbessern

```text
Ergänze nur dort Kommentare, wo die Absicht des Codes nicht offensichtlich ist.
```

### `/performance` — Performance bewerten

```text
Untersuche diesen Code auf unnötige Schleifen und Datenbankabfragen.
```

### `/codeportierung` — Sprache wechseln

```text
Übertrage diese JavaScript-Funktion nach Python und bewahre ihr Verhalten.
```

## Git & GitHub (12 Vorlagen)

### `/gitstatus` — Repository einordnen

```text
Erkläre diese Ausgabe von git status und welche Änderungen uncommitted sind.
```

### `/gitdiff` — Änderungen verstehen

```text
Fasse diesen git diff nach Dateien und möglichem Risiko zusammen.
```

### `/committext` — Commit-Nachricht

```text
Schlage eine präzise Conventional-Commit-Nachricht für diese Änderungen vor.
```

### `/prreview` — Pull Request prüfen

```text
Reviewe diesen Pull Request auf Bugs, Tests und Seiteneffekte.
```

### `/issueform` — Issue schreiben

```text
Erstelle aus der Fehlermeldung ein reproduzierbares GitHub-Issue.
```

### `/branchplan` — Branchstrategie

```text
Plane kleine, nachvollziehbare Branches für diese neue Funktion.
```

### `/mergecheck` — Merge-Konflikt erklären

```text
Erkläre diesen Git-Merge-Konflikt und schlage die inhaltlich korrekte Lösung vor.
```

### `/readme` — README verbessern

```text
Erstelle eine klare README mit Installation, Nutzung und Grenzen dieses Projekts.
```

### `/release` — Release Notes

```text
Formuliere Release Notes aus diesen Commit-Nachrichten.
```

### `/actionscheck` — CI-Fehler analysieren

```text
Finde anhand dieses GitHub-Actions-Logs den fehlschlagenden Schritt.
```

### `/repoaudit` — Repository überblicken

```text
Analysiere die Ordnerstruktur und nenne die wichtigsten Einstiegspunkte.
```

### `/gitvorsicht` — Git sicher nutzen

```text
Schlage sichere Git-Schritte vor, ohne Force-Push oder History-Rewrite.
```

## Netzwerk & WLAN (12 Vorlagen)

### `/netzplan` — Netzwerk darstellen

```text
Zeichne eine verständliche Übersicht aus Router, Switch, VLANs und Clients.
```

### `/iperklaeren` — IP-Adressen verstehen

```text
Erkläre diese IP-Konfiguration einschließlich Gateway und Subnetz.
```

### `/dnscheck` — DNS-Probleme prüfen

```text
Hilf mir, DNS-Fehler von allgemeinen Verbindungsfehlern zu unterscheiden.
```

### `/vlanplan` — VLANs planen

```text
Erstelle einen VLAN-Portplan aus meiner Switch-Belegung, zunächst ohne Änderungen.
```

### `/wlanreichweite` — WLAN-Abdeckung

```text
Erkläre die Einflussfaktoren auf 2,4- und 5-GHz-Reichweite im Haus.
```

### `/meshverstehen` — Mesh erklären

```text
Erkläre den Unterschied zwischen WLAN-Repeater, Mesh und kabelgebundenem Access Point.
```

### `/routercheck` — Router vergleichen

```text
Vergleiche diese Router nach Firmware-Support und Netzwerkschnittstellen.
```

### `/firewalllesen` — Regeln prüfen

```text
Erkläre diese Firewall-Regeln und welche Verbindungen sie erlauben.
```

### `/packetlesen` — Paketmitschnitt auswerten

```text
Interpretiere diese eigene PCAP-Zusammenfassung auf auffällige Verbindungsfehler.
```

### `/netzdiagramm` — Topologie dokumentieren

```text
Erstelle aus diesen Geräten ein Mermaid-Netzwerkdiagramm.
```

### `/latency` — Latenz analysieren

```text
Werte Ping- und Traceroute-Ergebnisse auf mögliche Engpässe aus.
```

### `/netzcheckliste` — Netzwerkfehler eingrenzen

```text
Gib mir eine sichere Prüfreihenfolge für sporadische WLAN-Abbrüche.
```

## Homelab & Server (12 Vorlagen)

### `/proxmoxstatus` — Proxmox bewerten

```text
Erkläre diese Proxmox-Statuswerte und markiere mögliche Engpässe.
```

### `/vmplanung` — VM-Ressourcen planen

```text
Schlage vCPU-, RAM- und Speicherwerte für einen kleinen Linux-Server vor.
```

### `/backupserver` — Server-Backup prüfen

```text
Prüfe diese Backupübersicht auf Lücken und fehlende Wiederherstellungstests.
```

### `/containerwahl` — VM oder Container

```text
Vergleiche LXC, Docker und VM für einen lokalen Dienst.
```

### `/storagecheck` — Storage erklären

```text
Erkläre local, local-lvm und ZFS in meinem Setup mit Auswirkungen auf Backups.
```

### `/monitoringplan` — Überwachung planen

```text
Entwirf sinnvolle Statuschecks und Warnschwellen für mein Homelab.
```

### `/hacheck` — Home Assistant verstehen

```text
Erkläre diese Home-Assistant-Automation und ihre Auslöser.
```

### `/haautomatik` — Automation entwerfen

```text
Entwirf eine Automation für eine Benachrichtigung bei ungewöhnlichem Stromverbrauch.
```

### `/serverlog` — Serverfehler auswerten

```text
Analysiere diesen Serverlog und trenne Symptome von Ursachen.
```

### `/dienstmigration` — Umzug planen

```text
Erstelle einen risikoarmen Migrationsplan für einen Docker-Dienst.
```

### `/zugriffsschutz` — Zugriff absichern

```text
Prüfe diese Homelab-Zugriffsarchitektur auf unnötig offene Dienste.
```

### `/notfallplan` — Wiederanlauf planen

```text
Erstelle eine Notfall-Checkliste für einen ausgefallenen Home-Server.
```

## IT-Sicherheit & Datenschutz (12 Vorlagen)

### `/phishingcheck` — Verdächtige Mail prüfen

```text
Prüfe diese E-Mail auf Phishing-Indikatoren ohne Links aufzurufen.
```

### `/urlcheck` — Webadresse bewerten

```text
Prüfe diese URL anhand öffentlich nachvollziehbarer Indikatoren.
```

### `/passwortschutz` — Passwortkonzept

```text
Entwirf eine sichere Passwortmanager- und MFA-Strategie für Privatkonten.
```

### `/rechteaudit` — Berechtigungen prüfen

```text
Hilf mir, unnötig weitreichende Dateiberechtigungen zu erkennen.
```

### `/updateprioritaet` — Patches priorisieren

```text
Ordne diese Sicherheitsupdates nach Risiko und Exponierung.
```

### `/logauffaellig` — Log-Anomalien erkennen

```text
Erkläre verdächtige Login-Versuche in meinen eigenen Serverlogs.
```

### `/datenminimierung` — Daten schützen

```text
Welche personenbezogenen Angaben sollte ich vor dem Teilen dieses Screenshots schwärzen?
```

### `/backupschutz` — Ransomware-Vorsorge

```text
Erstelle eine 3-2-1-Backupstrategie mit Offline-Kopie.
```

### `/securitybericht` — Befund dokumentieren

```text
Formuliere aus diesem autorisierten Test einen sachlichen Sicherheitsbericht.
```

### `/websicherheit` — Web-App prüfen

```text
Entwirf eine defensive Sicherheits-Checkliste für meine eigene Web-App.
```

### `/leakreaktion` — Datenleck reagieren

```text
Welche Schritte sollte ich unternehmen, wenn meine E-Mail in einem Datenleck auftaucht?
```

### `/berechtigungsrahmen` — Testgrenzen festlegen

```text
Erstelle klare Scope- und Freigaberegeln für einen Sicherheitscheck im eigenen Netz.
```

## KI, Prompts & Agenten (12 Vorlagen)

### `/promptbesser` — Prompt verbessern

```text
Überarbeite diesen Prompt: klares Ziel, Input, Grenzen und Ausgabeformat.
```

### `/rollenprompt` — Rolle definieren

```text
Schreibe einen Systemprompt für einen vorsichtigen Linux-Diagnoseassistenten.
```

### `/promptkritik` — Prompt prüfen

```text
Zeige Mehrdeutigkeiten und fehlende Anforderungen in meinem Prompt.
```

### `/promptkette` — Aufgaben aufteilen

```text
Teile dieses große Projekt in überprüfbare kleine KI-Arbeitsschritte.
```

### `/agentrolle` — Agenten abgrenzen

```text
Definiere Aufgaben und Verbote für einen lesenden Homelab-Monitoring-Agenten.
```

### `/toolwahl` — Werkzeuge wählen

```text
Welche Tools benötigt ein Dokumenten-Agent tatsächlich, und welche nicht?
```

### `/modellwahl` — Modell passend wählen

```text
Vergleiche benötigte Fähigkeiten, Kosten und Kontextbedarf für diese KI-Aufgabe.
```

### `/ausgabejson` — Strukturierte Ausgabe

```text
Erstelle eine JSON-Ausgabe mit status, risiko und begruendung für jedes Prüfergebnis.
```

### `/qualitaetscheck` — Antwort kontrollieren

```text
Prüfe diese KI-Antwort auf unbelegte Behauptungen und fehlende Quellen.
```

### `/kontextkompakt` — Kontext zusammenfassen

```text
Erstelle eine knappe Übergabe mit Ziel, aktuellem Stand und nächsten Schritten.
```

### `/agententest` — Agent testen

```text
Entwirf zehn sichere Testfälle für meinen Recherche-Agenten.
```

### `/promptvorlage` — Wiederverwendbarer Prompt

```text
Baue aus dieser Einzelanweisung eine Vorlage mit eindeutig beschriebenen Eingaben.
```
