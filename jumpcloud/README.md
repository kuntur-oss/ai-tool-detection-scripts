# JumpCloud (Commands)

Scripts: `kuntur-ai-inventory-jumpcloud.sh` (macOS and Linux), `kuntur-ai-inventory-jumpcloud.ps1` (Windows)

Full guide: https://kuntur.io/guides/jumpcloud-detect-ai-tools

## How to run it

1. JumpCloud Admin Portal > Device Management > Commands > new command.
2. Mac or Linux: Type **Mac** (or **Linux**), Run As **root**, paste the `.sh` script.
3. Windows: Type **Windows**, check **Windows PowerShell**, paste the `.ps1` script (runs as LocalSystem).
4. Bind to a device group, save, **Run Now**. Read the output in Commands > Results > View.

Both scripts always exit 0 so a device with AI tools is not shown as a failed command; the findings are in the output. On macOS, "Operation not permitted" means the JumpCloud agent needs Full Disk Access.

## What it prints

Mac/Linux: one line per finding, e.g. `[ana] CLI agent: Claude Code - ~/.local/bin/claude (review)`, and a summary. Tools listed in `ALLOW` (separated by `|`) show as `approved`.
Windows: one line per user with findings under a dated header.

Read-only, no network calls, never prints file contents or secrets.

## SHA-256

```
7afbcc505d7d23a29a9ae8c1ca2622778182653d5ec496f2883567947a548f06  kuntur-ai-inventory-jumpcloud.sh
863704abfe80b05588c7532d8404f3595706849f618340e6df0586a576bdc514  kuntur-ai-inventory-jumpcloud.ps1
```
