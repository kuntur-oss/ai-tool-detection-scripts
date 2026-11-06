# Microsoft Intune (Remediations)

Script: `kuntur-ai-inventory-intune.ps1` (Windows)

Full guide: https://kuntur.io/guides/intune-detect-ai-tools

## What it finds

For every user profile under `C:\Users` (skipping Public, Default and system profiles) it checks for: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Claude Desktop, ChatGPT Desktop, Ollama (and how many models), LM Studio, AI editor extensions in VS Code (GitHub Copilot, Claude Code, Continue, Cline, Roo Code, Kilo Code, Codeium, ChatGPT, Gemini Code Assist, Amazon Q, Tabnine) and MCP config files (it counts server entries without reading their commands, URLs or environment variables).

## How to run it

1. Intune admin center > Devices > Scripts and remediations > Remediations > Create.
2. Upload `kuntur-ai-inventory-intune.ps1` as the **detection** script. Leave the remediation script empty.
3. Run this script using the logged-on credentials: **No** (runs as SYSTEM, sees every profile). Run script in 64-bit PowerShell: **Yes**.
4. Assign to a device group with a daily (or once) schedule.
5. Read results under Device status, adding the *Pre-remediation detection output* column.

Remediations needs Windows Enterprise/Education E3/E5/A3/A5 (or equivalent) licensing. Without it, any tool that runs PowerShell as SYSTEM can run the same script.

## What it prints

Prints one line, for example `AI tools: Claude Code(2), Cursor(1), Ollama(1; 3 models), AI extensions(4 in 2), MCP configs(2; 5 servers) | users: alice,bob`. A clean device prints `AI tools: none found in N profiles`. The numbers in brackets are how many profiles have the tool. Exit code follows Intune detection semantics: `1` = AI tools found (shows as *With issues*), `0` = nothing found.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls. Optional: set `[bool]$WriteJson = $true` in the param block to also write a short summary to `C:\ProgramData\KunturInventory\ai-inventory.json`. Off by default.

## SHA-256

These match the hashes published in the guide:

```
aa0739ab0aee972a838a26c50601689374fbf909dbb9ab83a77fe28136455849  kuntur-ai-inventory-intune.ps1
```
