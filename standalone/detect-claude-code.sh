#!/bin/bash
# Kuntur: detect-claude-code.sh
# Copied verbatim from the code blocks published at https://kuntur.io/guides/detect-claude-code
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: How to check if Claude Code is installed
command -v claude
ls -d ~/.local/bin/claude ~/.claude/local/claude ~/.claude "$(npm root -g 2>/dev/null)/@anthropic-ai/claude-code" 2>/dev/null

# --- Guide section: Check macOS and Linux
# 1. Installed? Native installer, npm, Homebrew
ls -l ~/.local/bin/claude ~/.claude/local/claude 2>/dev/null
ls ~/.local/share/claude/versions 2>/dev/null
command -v claude && claude --version
npm ls -g --depth=0 2>/dev/null | grep claude-code
brew list --cask 2>/dev/null | grep -x claude-code

# 2. Running right now?
pgrep -fl claude

# 3. Used, and how recently?
ls -lt ~/.claude/projects 2>/dev/null | head -n 11

# --- Guide section: Settings that matter more than the install
# Run as the user (macOS/Linux; on Windows use the same keys with ConvertFrom-Json)
S=~/.claude/settings.json
jq -r '.permissions.defaultMode // empty' "$S"                     # "bypassPermissions" = no prompts
jq -r '.permissions.allow[]? | select(test("^(Bash|Bash\\(\\*\\)|Bash\\(:\\*\\)|PowerShell)$"))' "$S"
jq -r '.enableAllProjectMcpServers // empty' "$S"                  # true = every repo's .mcp.json auto-approved
jq -r '.env // {} | keys[]' "$S"                                   # look for ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL
jq -r '.env.ANTHROPIC_BASE_URL // empty' "$S"
jq -r 'to_entries[] | "\(.key)\t\(.value.source.repo // .value.source.url // .value.source.path)"' \
   ~/.claude/plugins/known_marketplaces.json 2>/dev/null           # plugin marketplaces added
jq -r '.bypassPermissionsModeAccepted // empty' ~/.claude.json      # user accepted bypass mode at least once
