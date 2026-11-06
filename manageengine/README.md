# ManageEngine Endpoint Central (Windows and macOS)

Scripts: `kuntur-ai-inventory-manageengine-mac.sh`, `kuntur-ai-inventory-manageengine.ps1` (Windows and macOS)

Full guide: https://kuntur.io/guides/manageengine-endpoint-central-detect-ai-tools

## What it finds

`kuntur-ai-inventory-manageengine.ps1` (Windows) runs the same checks as the other Windows scripts. `kuntur-ai-inventory-manageengine-mac.sh` (macOS) checks AI desktop apps, coding agents, local models, AI extensions in VS Code, Cursor and Windsurf, and MCP config files (counted, never opened).

## How to run it

1. Add both scripts to the Script Repository.
2. Windows: Configurations > Add Configurations > Windows Configuration > Custom Script > Computer Configuration. Choose Repository, the PowerShell script, run as **System**, Frequency **Once**, enable logging.
3. Mac: same path under Mac Configuration, choose the bash script, Frequency **Once**, logging on. Edit the `ALLOW` line first with the tools you have approved, separated by `|`.
4. Target a pilot group, leave retries off, deploy. Read the **Remarks** column in Execution Status.

## What it prints

Windows: one line such as `AI tools: Claude Code(2), Cursor(1), MCP configs(1; 3 servers) | users: ana,bob`, always exits `0`. macOS: one line per tool with user and path; exits `1` (shown as Failed) when a tool is not on the allowlist. That is a finding, not an error.

It only checks whether paths exist, counts entries and, for MCP configs, parses JSON to count servers. It never prints file contents, API keys, tokens or MCP server commands. No network calls. The SHA-256 values below are for the files as published, before you edit them.

## SHA-256

These match the hashes published in the guide:

```
267b1f59e6100c9a27abc634019ca7f204617ab13de720858ce9176ed3e839fa  kuntur-ai-inventory-manageengine-mac.sh
8d8422c8cfbc352a698d27e6a7c4abfae80838879e83d76f3f34e96b4b1f75a5  kuntur-ai-inventory-manageengine.ps1
```
