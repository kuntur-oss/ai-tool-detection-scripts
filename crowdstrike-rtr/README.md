# CrowdStrike Falcon Real Time Response

Script: `kuntur-ai-inventory-crowdstrike-rtr.ps1` (Windows)

Full guide: https://kuntur.io/guides/crowdstrike-rtr-detect-ai-tools

## What it finds

For every user profile under `C:\Users` (skipping Public, Default and system profiles) it checks for: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Claude Desktop, ChatGPT Desktop, Ollama (and how many models), LM Studio, AI editor extensions in VS Code (GitHub Copilot, Claude Code, Continue, Cline, Roo Code, Kilo Code, Codeium, ChatGPT, Gemini Code Assist, Amazon Q, Tabnine) and MCP config files (it counts server entries without reading their commands, URLs or environment variables).

## How to run it

Needs the RTR Administrator role and RTR enabled in the hosts' response policy.

**One host:** upload the script to Response scripts and files as `kuntur-ai-inventory` (platform Windows), open an RTR session and run:

```
runscript -CloudFile="kuntur-ai-inventory"
```

**A host group (PSFalcon):**

```powershell
Send-FalconScript -Path .\kuntur-ai-inventory-crowdstrike-rtr.ps1 -Platform windows -PermissionType group -Name kuntur-ai-inventory

Invoke-FalconRtr -Command runscript -Argument '-CloudFile="kuntur-ai-inventory"' -GroupId <host_group_id> -QueueOffline $true |
  Export-Csv .\kuntur-ai-inventory.csv -NoTypeInformation
```

**Read the results:**

```powershell
Import-Csv .\kuntur-ai-inventory.csv | Where-Object stdout |
  ForEach-Object { $_.stdout | ConvertFrom-Json } |
  Select-Object host, found, profiles, mcp_servers, summary |
  Sort-Object found -Descending | Format-Table -AutoSize
```

## What it prints

Prints one line of compact JSON (`host`, `found`, `profiles`, `summary`, `tools`, `machine_wide`, `ollama_models`, `ai_extensions`, `mcp_config_files`, `mcp_servers`) so results from many hosts are easy to parse. `summary` holds the same one-line text the other Windows scripts print. Always exits `0`. Nothing is written to disk.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls.

## SHA-256

These match the hashes published in the guide:

```
59bd7583bb2a4c033626663b08328d40ffb4cce26cc3d74b62eec5bb5290b634  kuntur-ai-inventory-crowdstrike-rtr.ps1
```
