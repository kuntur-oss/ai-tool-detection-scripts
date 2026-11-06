# PDQ Inventory (PowerShell scanner) / PDQ Deploy

Script: `kuntur-ai-inventory-pdq.ps1` (Windows)

Full guide: https://kuntur.io/guides/pdq-detect-ai-tools

## What it finds

For every user profile under `C:\Users` (skipping Public, Default and system profiles) it checks for: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Claude Desktop, ChatGPT Desktop, Ollama (and how many models), LM Studio, AI editor extensions in VS Code (GitHub Copilot, Claude Code, Continue, Cline, Roo Code, Kilo Code, Codeium, ChatGPT, Gemini Code Assist, Amazon Q, Tabnine) and MCP config files (it counts server entries without reading their commands, URLs or environment variables).

## How to run it

1. PDQ Inventory (Enterprise mode) > Scan Profiles > add a scanner of type **PowerShell**, named `Kuntur AI inventory`.
2. Choose **File**, select the script, leave Parameters empty, keep the default Row Limit of 100.
3. Run against a few test computers, then add to scheduled scans. Use credentials that are local admin on targets.
4. Build a report or a dynamic collection with `Tool` *is not* `(none)`.

For PDQ Deploy, run it with `-AsText` to get the one-line summary.

## What it prints

By default returns one row per finding with the columns `Tool`, `Count` (profiles), `Users` and `Detail`; a clean computer returns one row with `Tool` = `(none)`. With `-AsText` it prints the one-line summary used by the other Windows scripts.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls.

## SHA-256

These match the hashes published in the guide:

```
a295e18ddc4b6b6650614d35c7bc020231f1f2cfbb79335706e6416e6bb01705  kuntur-ai-inventory-pdq.ps1
```
