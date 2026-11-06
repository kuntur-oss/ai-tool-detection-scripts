# Jamf Pro (extension attribute)

Script: `kuntur-ai-inventory-jamf.sh` (macOS)

Full guide: https://kuntur.io/guides/jamf-detect-ai-tools

## What it finds

On every home folder under `/Users` (skipping Shared, Guest and hidden folders) it checks for: AI apps (Claude, ChatGPT, Cursor, Windsurf, Ollama, LM Studio), coding CLIs (Claude Code, Codex CLI, Gemini CLI in Homebrew, npm global paths and `~/.local/bin`), local models under `~/.ollama` and `~/.lmstudio`, AI editor extensions in VS Code and Cursor, and MCP config files (counted, never opened). Runs on the `/bin/bash` 3.2 that ships with macOS.

## How to run it

1. Jamf Pro > Settings > Computer management > Extension attributes > New.
2. Name it `AI tools (Kuntur)`, Data type **String**, Input type **Script**, paste the script, save.
3. Values appear at each Mac's next inventory (`sudo jamf recon` to force one on a test Mac).
4. Build Smart Groups with `AI tools (Kuntur)` *is not* `None`, or *like* `Claude Code`, etc.

Test locally first: `sudo bash kuntur-ai-inventory-jamf.sh`.

## What it prints

Prints one line such as `<result>Claude Code; Cursor; MCP configs (2); Ollama (2 models)</result>`, or `<result>None</result>`.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls.

## SHA-256

These match the hashes published in the guide:

```
faa1bd063cc1e84c5dce7b6bd337234fb9fc13cdcfa627f1c305ab4c96108510  kuntur-ai-inventory-jamf.sh
```
