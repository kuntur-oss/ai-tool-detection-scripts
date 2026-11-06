# Omnissa Workspace ONE UEM (sensor)

Script: `kuntur-ai-inventory-workspace-one.ps1` (Windows)

Full guide: https://kuntur.io/guides/workspace-one-detect-ai-tools

## What it finds

For every user profile under `C:\Users` (skipping Public, Default and system profiles) it checks for: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Claude Desktop, ChatGPT Desktop, Ollama (and how many models), LM Studio, AI editor extensions in VS Code (GitHub Copilot, Claude Code, Continue, Cline, Roo Code, Kilo Code, Codeium, ChatGPT, Gemini Code Assist, Amazon Q, Tabnine) and MCP config files (it counts server entries without reading their commands, URLs or environment variables).

## How to run it

1. Workspace ONE UEM console > Resources > Sensors > Add > Windows.
2. Name it `kuntur_ai_inventory` (lowercase letters, digits, underscores).
3. Language **PowerShell**, Execution Context **System**, 64-bit architecture, Response Data Type **String**. Upload the script.
4. Save & Assign to a smart group; a periodic trigger (plus login) is enough.
5. Read the value on the device's Sensors tab, or in Omnissa Intelligence under Device Sensors.

## What it prints

Prints one line, for example `AI tools: Claude Code(2), Cursor(1), Ollama(1; 3 models), AI extensions(4 in 2), MCP configs(2; 5 servers) | users: alice,bob`. A clean device prints `AI tools: none found in N profiles`. The numbers in brackets are how many profiles have the tool. Writes exactly one line with `Write-Output` and always exits `0`.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls.

## SHA-256

These match the hashes published in the guide:

```
17ba561df122bba24f00243dd69b1974c863d62fd049be538e12018f52d3a4f6  kuntur-ai-inventory-workspace-one.ps1
```
