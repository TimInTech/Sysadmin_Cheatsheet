# 22 Secret Hygiene (Linux)

Shell-History, Git-Grep, .env-Dateien und Berechtigungspruefung auf versehentlich preisgegebene Secrets.

> **Hinweis:** Vor Weitergabe von Systemen, Repositories oder Screenshots immer auf versehentlich ausgelagerte Secrets prüfen.

Quellen:

- GitHub Secret Scanning: <https://docs.github.com/en/code-security/secret-scanning>

## 1. Shell-History prüfen

```bash
grep -Ei 'token|api[_-]?key|secret|password|passwd|bearer|authorization' \
  ~/.bash_history ~/.zsh_history 2>/dev/null | tail -n 80
```

## 2. Git-Grep auf Secrets

```bash
git status --short
git grep -n -Ei 'token|api[_-]?key|secret|password|passwd|bearer|authorization' \
  -- . ':!*.md' ':!.gitignore' 2>/dev/null || true
```

## 3. .env-Dateien finden

```bash
find . -type f \( -name '.env' -o -name '*.env' -o -name 'secrets.*' \) -print
```

## 4. Berechtigungen prüfen

```bash
# Dateien mit offenen Berechtigungen finden (world-readable)
find . -type f \( -name '*.key' -o -name '*.pem' -o -name '.env*' \) -perm /o+r 2>/dev/null
```
