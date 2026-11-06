# Datto RMM (component)

Script: `kuntur-ai-inventory-datto-rmm.ps1` (Windows)

Full guide: https://kuntur.io/guides/datto-rmm-detect-ai-tools

## What it finds

For every user profile under `C:\Users` (skipping Public, Default and system profiles) it checks for: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Claude Desktop, ChatGPT Desktop, Ollama (and how many models), LM Studio, AI editor extensions in VS Code (GitHub Copilot, Claude Code, Continue, Cline, Roo Code, Kilo Code, Codeium, ChatGPT, Gemini Code Assist, Amazon Q, Tabnine) and MCP config files (it counts server entries without reading their commands, URLs or environment variables).

## How to run it

1. Component Library > new component in the **Scripts** category, type **PowerShell**, paste the script.
2. Optional: add a component variable `UdfNumber` (1-300) to also write the line to that user-defined field.
3. Run it as a quick job, or a scheduled job (daily/weekly) as LocalSystem.
4. Read StdOut in each job result, or filter devices on the UDF.

## What it prints

Prints one line, for example `AI tools: Claude Code(2), Cursor(1), Ollama(1; 3 models), AI extensions(4 in 2), MCP configs(2; 5 servers) | users: alice,bob`. A clean device prints `AI tools: none found in N profiles`. The numbers in brackets are how many profiles have the tool. Always exits `0`.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls. The only write it can make is the optional UDF (`HKLM\SOFTWARE\CentraStage\CustomN`, which the Datto agent uploads and removes), and only when `UdfNumber` is set. The UDF copy is trimmed to 255 characters.

## SHA-256

These match the hashes published in the guide:

```
c499b05c4a865fd89aa58707b3406d74b247c07b083fcd81127557b09d7a95e9  kuntur-ai-inventory-datto-rmm.ps1
```
