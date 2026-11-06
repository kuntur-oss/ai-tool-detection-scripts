# Iru (formerly Kandji) Custom Script audit

Script: `kuntur-ai-inventory-kandji.sh` (macOS)

Full guide: https://kuntur.io/guides/kandji-detect-ai-tools

## What it finds

On every home folder under `/Users` (skipping Shared, Guest and hidden folders) it checks for: AI apps (Claude, ChatGPT, Cursor, Windsurf, Ollama, LM Studio), coding CLIs (Claude Code, Codex CLI, Gemini CLI in Homebrew, npm global paths and `~/.local/bin`), local models under `~/.ollama` and `~/.lmstudio`, AI editor extensions in VS Code and Cursor, and MCP config files (counted, never opened). Runs on the `/bin/bash` 3.2 that ships with macOS.

## How to run it

1. Edit the `ALLOW` line near the top with the tools you have approved, exactly as the script prints them, separated by `|` (for example `ALLOW="GitHub Copilot|Claude Desktop"`).
2. Iru Endpoint > Library > Add Library Item > Custom Script.
3. Assign it to a pilot Blueprint, set execution to **Run daily**, paste the script into **Audit Script**.
4. Leave the remediation script empty and do not offer it in Self Service. Save.

## What it prints

Prints one line per finding with user, tool and path, then a summary, for example:

```
[ana] CLI agent: Claude Code - ~/.local/bin/claude (review)
[ana] IDE extension: GitHub Copilot - ~/.vscode/extensions/github.copilot-1.250.0 (approved)
Summary: 5 AI tool(s) found, 4 not on the allowlist.
```

Exits `1` (Error) when a tool is not on the allowlist, `0` (Pass) otherwise.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls. The SHA-256 below is for the file as published, before you edit `ALLOW`.

## SHA-256

These match the hashes published in the guide:

```
6ca8f9c939f76e6a2029619b6430525389ab6fdf8163ed6d783a99a5e6cfdb4e  kuntur-ai-inventory-kandji.sh
```
