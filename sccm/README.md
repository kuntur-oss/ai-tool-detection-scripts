# Microsoft Configuration Manager (SCCM / MECM)

Script: `kuntur-ai-inventory-sccm.ps1` (Windows)

Full guide: https://kuntur.io/guides/sccm-detect-ai-tools

## What it finds

For every user profile under `C:\Users` (skipping Public, Default and system profiles) it checks for: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Claude Desktop, ChatGPT Desktop, Ollama (and how many models), LM Studio, AI editor extensions in VS Code (GitHub Copilot, Claude Code, Continue, Cline, Roo Code, Kilo Code, Codeium, ChatGPT, Gemini Code Assist, Amazon Q, Tabnine) and MCP config files (it counts server entries without reading their commands, URLs or environment variables).

## How to run it

**Option 1, Run Scripts (one-time audit):** Software Library > Scripts > Create Script, language PowerShell, import the file (no parameters). A second admin approves it. Then Device Collections > Run Script. Read results in Monitoring > Script Status.

**Option 2, configuration item (recurring):** create a Windows configuration item with a Script setting of data type String, paste the script as the discovery script, run as Local System. Compliance rule: value begins with `AI tools: none` (or contains `none found`). Add it to a baseline and deploy daily.

## What it prints

Prints one line, for example `AI tools: Claude Code(2), Cursor(1), Ollama(1; 3 models), AI extensions(4 in 2), MCP configs(2; 5 servers) | users: alice,bob`. A clean device prints `AI tools: none found in N profiles`. The numbers in brackets are how many profiles have the tool. Always exits `0`; the finding is in the output line, not the exit code. Run Scripts keeps 4 KB of output.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls.

## SHA-256

These match the hashes published in the guide:

```
dd6668ff8381330a2cbcb71e27a2169740238158179b716f316699fb4b367d57  kuntur-ai-inventory-sccm.ps1
```
