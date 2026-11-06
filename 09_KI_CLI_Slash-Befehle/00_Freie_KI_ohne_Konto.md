# 00 Freie KI ohne Konto und Anmeldung

KI-Chats, die sich ohne Registrierung nutzen lassen, um Befehle zu erklären, Fehlermeldungen zu deuten oder eine Gegenmeinung einzuholen. Stand: 2026-11-06.

> [!WARNING]
> Angebote ohne Konto ändern Bedingungen, Modelle und Tageslimits ohne Ankündigung. Die Tabelle trennt deshalb, was selbst geprüft wurde, was nur aus Berichten stammt und was unbestätigt ist.
>
> Keine Passwörter, Schlüssel, Tokens, privaten Daten oder interne Adressen eingeben. Befehle aus KI-Antworten **nie blind als Administrator** ausführen: erst erklären lassen, dann mit einem Testlauf (`--dry-run`, `-n`) prüfen, bei Datenträgern vorher ein Backup anlegen.

## 1. Im Browser, ohne Konto

| Dienst | Link | Konto nötig? | Hinweis | Prüfstand |
| --- | --- | --- | --- | --- |
| **Duck.ai** (DuckDuckGo) | <https://duck.ai> | Nein | Mehrere Modelle zur Auswahl, Anfragen laufen anonymisiert über DuckDuckGo, Chats bleiben lokal im Browser. Tageslimit, die Modellauswahl wechselt. | Erreichbar geprüft; „kein Konto“ laut [TechRadar](https://www.techradar.com/pro/what-is-duck-ai-everything-we-know-about-duckduckgos-privacy-focused-ai-chatbot) und [CyberInsider](https://cyberinsider.com/duckduckgo-makes-privacy-respecting-ai-chat-service-widely-available/) |
| **Microsoft Copilot** | <https://copilot.com> | Nein (Web) | Im Browser ohne Anmeldung nutzbar, mit Einschränkungen und Kapazitätsgrenzen. Die Windows-App verlangt ein Konto. | Laut [Microsoft Support](https://support.microsoft.com/topic/understanding-the-different-microsoft-copilot-experiences-cfff4791-694a-4d90-9c9c-1eb3fb28e842) |
| **ChatGPT** | <https://chatgpt.com> | Gastzugang möglich, nicht garantiert | Seit 2024 ohne Konto nutzbar, ohne Verlauf und mit strengeren Regeln. Verfügbarkeit und Limits sind aktuell nicht offiziell belegt. | Nur aus Berichten ([Trusted Reviews](https://www.trustedreviews.com/news/its-now-possible-to-use-chatgpt-without-an-account-4513416)) |
| **Arena** (früher LMArena) | <https://arena.ai> | Battle-Modus laut Berichten nein | Zwei anonyme Modelle antworten auf dieselbe Frage, man wählt die bessere. Gut zum Vergleichen. | Seite blockt Skriptabruf, im Browser prüfen. Quelle: [PrivacyTools](https://wiki.privacytools.io/wiki/LMArena) |
| **Perplexity** | <https://www.perplexity.ai> | Eingeschränkt | Websuche mit Quellenangaben, nützlich für aktuelle Fehlermeldungen. Umfang ohne Konto begrenzt. | Erreichbar geprüft, Konto-Regel unbestätigt |

## 2. Im Terminal, ohne Konto

**Pollinations** bietet eine Textschnittstelle ohne Schlüssel. Sie wurde am 2026-11-06 getestet und antwortete.

```bash
# Frage stellen (Anführungszeichen in der Frage vermeiden)
frage='Erkläre in zwei Sätzen, was der Befehl tar -xzf archiv.tar.gz macht.'
curl -s "https://text.pollinations.ai/$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$frage")"
```

```powershell
# Windows PowerShell (nicht getestet)
$frage = 'Erkläre in zwei Sätzen, was der Befehl Get-Service macht.'
Invoke-RestMethod ('https://text.pollinations.ai/' + [uri]::EscapeDataString($frage))
```

Der Dienst ist kostenlos und von Dritten betrieben. Verfügbarkeit, Modell und Datenschutz sind nicht zugesichert. Keine vertraulichen Inhalte senden.

## 3. Lokal auf dem eigenen Rechner

Lokale Modelle brauchen kein Konto, keine Internetverbindung (nach dem Download) und senden nichts nach außen. Sie benötigen aber Arbeitsspeicher; kleine Modelle laufen auf normalen PCs.

| Werkzeug | Zweck | Link |
| --- | --- | --- |
| **Ollama** | Modelle im Terminal starten, auch als lokale Schnittstelle | <https://ollama.com/download> |
| **LM Studio** | Grafische Oberfläche zum Laden und Befragen von Modellen | <https://lmstudio.ai> |

```bash
# Nach der Installation von Ollama: ein Modell laden und starten
# Modellnamen stehen unter https://ollama.com/library
ollama run MODELLNAME
```

Für Befehlserklärungen reichen kleine Modelle. Bei Rettungseinsätzen ohne Internet ist ein vorher geladenes Modell auf dem Stick oder NAS die einzige Option.

## 4. Nicht ohne Konto nutzbar oder unbestätigt

- **Claude** (<https://claude.ai>) verlangt eine Anmeldung.
- **DeepSeek, Mistral Le Chat, Phind:** Die Seiten blocken Skriptabrufe. Ob sie ohne Konto funktionieren, ist nicht geprüft.
- **HuggingChat, Qwen Chat, Z.ai, Kimi, Blackbox:** erreichbar, aber ob und wie lange ohne Konto nutzbar, ist nicht bestätigt. Einfach im Browser ausprobieren.

## 5. Gute Frage für Befehlsprüfungen

```text
Erkläre diesen Befehl Teil für Teil. Nenne, was er auf einem Ubuntu-System ändert oder löscht,
ob er Administratorrechte braucht und wie ich ihn gefahrlos testen kann.
Befehl: HIER_BEFEHL_EINFÜGEN
```

Antworten gegen die Handbuchseite prüfen: `man BEFEHL`, `BEFEHL --help` oder unter Windows `Get-Help BEFEHL`.
