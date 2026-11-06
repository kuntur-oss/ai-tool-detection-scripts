# Mosyle (custom command / command attribute)

Script: `kuntur-ai-inventory-mosyle.sh` (macOS)

Full guide: https://kuntur.io/guides/mosyle-detect-ai-tools

## What it finds

On every home folder under `/Users` (skipping Shared, Guest and hidden folders) it checks for: AI apps (Claude, ChatGPT, Cursor, Windsurf, Ollama, LM Studio), coding CLIs (Claude Code, Codex CLI, Gemini CLI in Homebrew, npm global paths and `~/.local/bin`), local models under `~/.ollama` and `~/.lmstudio`, AI editor extensions in VS Code and Cursor, and MCP config files (counted, never opened). Runs on the `/bin/bash` 3.2 that ships with macOS.

## How to run it

1. Create a new macOS custom command in Mosyle and paste the script.
2. If your plan offers command attributes, add the same script as an attribute so the result is stored per device.
3. Assign to a pilot device group, then the fleet, on a daily (or less frequent) schedule.
4. Create a Smart Device Group on the attribute value, for example *contains* `Claude Code`.

## What it prints

Prints one line of tool names and counts, or `None`.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls.

## SHA-256

These match the hashes published in the guide:

```
25a2a7dc0ca0a384c0734afa4c7dcbd30073aea9c44804b658e516039dc26839  kuntur-ai-inventory-mosyle.sh
```
