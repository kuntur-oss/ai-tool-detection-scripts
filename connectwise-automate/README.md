# ConnectWise Automate

Script: `kuntur-ai-inventory-connectwise-automate.ps1` (Windows)

Full guide: https://kuntur.io/guides/connectwise-automate-detect-ai-tools

## What it finds

For every user profile under `C:\Users` (skipping Public, Default and system profiles) it checks for: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Claude Desktop, ChatGPT Desktop, Ollama (and how many models), LM Studio, AI editor extensions in VS Code (GitHub Copilot, Claude Code, Continue, Cline, Roo Code, Kilo Code, Codeium, ChatGPT, Gemini Code Assist, Amazon Q, Tabnine) and MCP config files (it counts server entries without reading their commands, URLs or environment variables).

## How to run it

1. Script editor > new script `Kuntur AI inventory`, target **Computer**.
2. Add an **Execute Script** step: PowerShell with execution policy bypass, paste the script. The output lands in `%shellresult%`.
3. Add a script log step that writes `%shellresult%`. Optionally save it to an Extra Data Field and branch on `contains none found`.
4. Run it on one computer, then schedule it on a group (daily or weekly). Keep the default Local System context.

## What it prints

Prints one line, for example `AI tools: Claude Code(2), Cursor(1), Ollama(1; 3 models), AI extensions(4 in 2), MCP configs(2; 5 servers) | users: alice,bob`. A clean device prints `AI tools: none found in N profiles`. The numbers in brackets are how many profiles have the tool. Always starts with `AI tools:` and always exits `0`.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls.

## SHA-256

These match the hashes published in the guide:

```
f7d790a480d3db47caa1f7c67c517734e58bd76ea3d27747e6fd2221ff5d602d  kuntur-ai-inventory-connectwise-automate.ps1
```
