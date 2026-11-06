# Kuntur: detect-claude-code.ps1
# Copied verbatim from the code blocks published at https://kuntur.io/guides/detect-claude-code
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: How to check if Claude Code is installed
Get-Command claude -ErrorAction SilentlyContinue | Select-Object Source
"$env:USERPROFILE\.local\bin\claude.exe", "$env:APPDATA\npm\node_modules\@anthropic-ai\claude-code", "$env:USERPROFILE\.claude" |
  Where-Object { Test-Path $_ }

# --- Guide section: Check a Windows laptop
# 1. Installed? Native installer, npm global package, WinGet
Test-Path "$env:USERPROFILE\.local\bin\claude.exe"
Get-Command claude -ErrorAction SilentlyContinue | Select-Object Source, Version | Format-Table -AutoSize
npm ls -g --depth=0 2>$null | Select-String 'claude-code'
winget list --id Anthropic.ClaudeCode 2>$null

# 2. Running right now?
Get-Process -Name claude -ErrorAction SilentlyContinue | Select-Object Name, Id, Path | Format-Table -AutoSize

# 3. Used, and how recently? (session transcripts are written per project)
$d = "$env:USERPROFILE\.claude\projects"
if (Test-Path $d) {
  Get-ChildItem $d -Directory | Sort-Object LastWriteTime -Descending |
    Select-Object -First 10 Name, LastWriteTime | Format-Table -AutoSize
}
