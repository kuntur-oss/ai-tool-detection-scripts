# Addigy (Custom Fact)

Script: `kuntur-ai-inventory-addigy.sh` (macOS)

Full guide: https://kuntur.io/guides/addigy-detect-ai-tools

## What it finds

On every home folder under `/Users` (skipping Shared, Guest and hidden folders) it checks for: AI apps (Claude, ChatGPT, Cursor, Windsurf, Ollama, LM Studio), coding CLIs (Claude Code, Codex CLI, Gemini CLI in Homebrew, npm global paths and `~/.local/bin`), local models under `~/.ollama` and `~/.lmstudio`, AI editor extensions in VS Code and Cursor, and MCP config files (counted, never opened). Runs on the `/bin/bash` 3.2 that ships with macOS.

## How to run it

1. Catalog > Custom Facts > New.
2. Name it (for example `AI tools`), return type **String**, language **Bash**, keep the default hashbang, paste the script.
3. Add the fact to a pilot policy, then to your fleet policies.
4. Show it as a column in Devices and filter on it, or alert when the value is not `None`.

## What it prints

Prints one line such as `ChatGPT desktop; Claude Code; Cursor; MCP configs (1)`, or `None`.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls.

## SHA-256

These match the hashes published in the guide:

```
f6e422ebe69dea0c583343c1c7d25e32c96dfdae7bcf1f15435a69df1735778e  kuntur-ai-inventory-addigy.sh
```
