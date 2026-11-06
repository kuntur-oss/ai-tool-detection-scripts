# NinjaOne

Script: `kuntur-ai-inventory-ninjaone.ps1` (Windows)

Full guide: https://kuntur.io/guides/ninjaone-detect-ai-tools

## What it finds

For every folder under `C:\Users` (skipping Public and Default) it looks for AI coding CLIs (Claude Code, Codex CLI, Gemini CLI), AI IDEs and desktop apps (Cursor, Windsurf, Claude desktop, ChatGPT desktop), local models (Ollama with model names, LM Studio), editor extensions (GitHub Copilot, Claude Code, Cline, Roo Code, Continue, Codeium, Tabnine, Amazon Q, Gemini Code Assist, Cody) and MCP servers per client (count only).

## How to run it

1. Administration > Devices > Device Custom Fields: add a **Multi-line** field labelled `AI tools inventory` (internal name `aiToolsInventory`, or pass another with `-CustomField`). Give Automations read/write.
2. Add the script to the Automation Library (PowerShell, Windows PowerShell 5.1+).
3. Administration > Policies > your Windows policy > Scheduled Automations > Add automation, run as **System**, daily.

## What it prints

Prints a header plus one line per user with findings, and writes the same text to the device custom field, for example:

```
Kuntur AI inventory 2026-11-02 09:14 | profiles: 3 | findings: 7
alice: Claude Code (native); Cursor; Ollama (models: llama3:8b, qwen2.5-coder:7b); AI extensions: github.copilot; MCP servers: Claude desktop 1, Cursor 2
```

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls. The only write it makes is to the NinjaOne custom field, through `Ninja-Property-Set`. Ollama model names are printed; nothing else from file contents is.

## SHA-256

These match the hashes published in the guide:

```
3bc43ff6c8b2b32a1423d00fb3960f09adf73317ce451e92ffc4a315b6c0da96  kuntur-ai-inventory-ninjaone.ps1
```
