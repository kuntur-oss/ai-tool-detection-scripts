#!/bin/bash
# Kuntur AI inventory: JumpCloud Command for Mac and Linux.
# https://kuntur.io/guides/jumpcloud-detect-ai-tools
#
# Read-only. Makes no network calls, changes nothing and never prints the
# contents of any file. It only checks whether known paths exist.
# Set "Run As" to root in the JumpCloud Command so it can walk every home
# folder (/Users on macOS, /home on Linux).
#
# Always exits 0 so JumpCloud shows the run as successful; read the result
# in Device Management > Commands > Results > View.
# Lines marked (review) are tools that are not on the allowlist.
#
# Allowlist: tool names exactly as printed below, separated by "|".
# Example: ALLOW="GitHub Copilot|Claude Desktop"
ALLOW="${ALLOW-}"

# Only change these to test the script on a fake directory tree.
if [ "$(uname -s)" = "Darwin" ]; then
  USERS_ROOT="${USERS_ROOT:-/Users}"
  BIN_DIRS="${BIN_DIRS:-/usr/local/bin /opt/homebrew/bin}"
  NPM_DIRS="${NPM_DIRS:-/usr/local/lib/node_modules /opt/homebrew/lib/node_modules}"
else
  USERS_ROOT="${USERS_ROOT:-/home}"
  BIN_DIRS="${BIN_DIRS:-/usr/local/bin /usr/bin /snap/bin}"
  NPM_DIRS="${NPM_DIRS:-/usr/local/lib/node_modules /usr/lib/node_modules}"
fi
APPS_DIR="${APPS_DIR:-/Applications}"

HT="~" # shown instead of the full home path
FOUND=0
REVIEW=0
SEEN="
"

is_allowed() {
  local name="$1" item
  local IFS='|'
  for item in $ALLOW; do
    [ "$item" = "$name" ] && return 0
  done
  return 1
}

# report SCOPE KIND NAME WHERE
report() {
  local scope="$1" kind="$2" name="$3" where="$4" status key
  key="$scope|$name"
  case "$SEEN" in
    *"
$key
"*) return 0 ;;
  esac
  SEEN="$SEEN$key
"
  FOUND=$((FOUND + 1))
  if is_allowed "$name"; then
    status="approved"
  else
    status="review"
    REVIEW=$((REVIEW + 1))
  fi
  printf '[%s] %s: %s - %s (%s)\n' "$scope" "$kind" "$name" "$where" "$status"
}

# First existing match of a glob pattern, or nothing.
first_match() {
  local p
  for p in "$@"; do
    [ -e "$p" ] && { printf '%s' "$p"; return 0; }
  done
  return 1
}

check_app() { # SCOPE DIR APPNAME DISPLAYNAME
  [ -d "$2/$3.app" ] && report "$1" "AI app" "$4" "$2/$3.app"
}

check_apps() { # SCOPE DIR
  check_app "$1" "$2" "Claude" "Claude Desktop"
  check_app "$1" "$2" "ChatGPT" "ChatGPT Desktop"
  check_app "$1" "$2" "ChatGPT Atlas" "ChatGPT Atlas"
  check_app "$1" "$2" "Codex" "Codex Desktop"
  check_app "$1" "$2" "Gemini" "Gemini Desktop"
  check_app "$1" "$2" "Cursor" "Cursor"
  check_app "$1" "$2" "Windsurf" "Windsurf"
  check_app "$1" "$2" "Ollama" "Ollama"
  check_app "$1" "$2" "LM Studio" "LM Studio"
}

check_npm() { # SCOPE NODE_MODULES_DIR SHOWN_PREFIX
  [ -d "$2/@anthropic-ai/claude-code" ] && report "$1" "CLI agent" "Claude Code" "$3/@anthropic-ai/claude-code (npm)"
  [ -d "$2/@openai/codex" ] && report "$1" "CLI agent" "Codex CLI" "$3/@openai/codex (npm)"
  [ -d "$2/@google/gemini-cli" ] && report "$1" "CLI agent" "Gemini CLI" "$3/@google/gemini-cli (npm)"
  return 0
}

check_ext() { # SCOPE EXT_DIR SHOWN_DIR ID DISPLAYNAME
  local hit
  hit=$(first_match "$2/$4"-[0-9]*) && report "$1" "IDE extension" "$5" "$3/${hit##*/}"
  return 0
}

check_extensions() { # SCOPE EXT_DIR SHOWN_DIR
  [ -d "$2" ] || return 0
  check_ext "$1" "$2" "$3" "github.copilot" "GitHub Copilot"
  check_ext "$1" "$2" "$3" "github.copilot-chat" "GitHub Copilot Chat"
  check_ext "$1" "$2" "$3" "anthropic.claude-code" "Claude Code for VS Code"
  check_ext "$1" "$2" "$3" "openai.chatgpt" "Codex for VS Code"
  check_ext "$1" "$2" "$3" "saoudrizwan.claude-dev" "Cline"
  check_ext "$1" "$2" "$3" "rooveterinaryinc.roo-cline" "Roo Code"
  check_ext "$1" "$2" "$3" "kilocode.kilo-code" "Kilo Code"
  check_ext "$1" "$2" "$3" "continue.continue" "Continue"
  check_ext "$1" "$2" "$3" "codeium.codeium" "Windsurf Plugin (Codeium)"
  check_ext "$1" "$2" "$3" "google.geminicodeassist" "Gemini Code Assist"
  check_ext "$1" "$2" "$3" "amazonwebservices.amazon-q-vscode" "Amazon Q"
  check_ext "$1" "$2" "$3" "tabnine.tabnine-vscode" "Tabnine"
}

check_mcp() { # SCOPE HOME FILE_RELATIVE_TO_HOME LABEL
  [ -f "$2/$3" ] && report "$1" "MCP config" "$4" "$HT/$3"
  return 0
}

check_user() { # USERNAME HOME
  local u="$1" h="$2" hit
  if hit=$(first_match "$h/.local/bin/claude" "$h/.claude/local/claude" "$h/.local/share/claude/versions"); then
    report "$u" "CLI agent" "Claude Code" "$HT${hit#"$h"}"
  elif [ -d "$h/.claude" ]; then
    report "$u" "CLI agent" "Claude Code" "$HT/.claude (data folder)"
  fi
  [ -d "$h/.codex" ] && report "$u" "CLI agent" "Codex CLI" "$HT/.codex"
  [ -d "$h/.gemini" ] && report "$u" "CLI agent" "Gemini CLI" "$HT/.gemini"

  check_npm "$u" "$h/.npm-global/lib/node_modules" "$HT/.npm-global/lib/node_modules"
  local nvm
  for nvm in "$h"/.nvm/versions/node/*/lib/node_modules; do
    [ -d "$nvm" ] && check_npm "$u" "$nvm" "$HT${nvm#"$h"}"
  done

  check_apps "$u" "$h/Applications"

  if [ -d "$h/.ollama/models" ]; then
    report "$u" "Local model" "Ollama models" "$HT/.ollama/models"
  elif [ -d "$h/.ollama" ]; then
    report "$u" "Local model" "Ollama" "$HT/.ollama"
  fi
  if hit=$(first_match "$h/.lmstudio" "$h/.cache/lm-studio"); then
    report "$u" "Local model" "LM Studio" "$HT${hit#"$h"}"
  fi

  check_extensions "$u" "$h/.vscode/extensions" "$HT/.vscode/extensions"
  check_extensions "$u" "$h/.cursor/extensions" "$HT/.cursor/extensions"
  check_extensions "$u" "$h/.windsurf/extensions" "$HT/.windsurf/extensions"

  check_mcp "$u" "$h" "Library/Application Support/Claude/claude_desktop_config.json" "Claude Desktop MCP servers"
  check_mcp "$u" "$h" ".claude.json" "Claude Code MCP servers"
  check_mcp "$u" "$h" ".cursor/mcp.json" "Cursor MCP servers"
  check_mcp "$u" "$h" "Library/Application Support/Code/User/mcp.json" "VS Code MCP servers"
  check_mcp "$u" "$h" ".codeium/windsurf/mcp_config.json" "Windsurf MCP servers"
  check_mcp "$u" "$h" ".config/Code/User/mcp.json" "VS Code MCP servers"
  check_mcp "$u" "$h" ".config/Claude/claude_desktop_config.json" "Claude Desktop MCP servers"
  if hit=$(first_match "$h"/Applications/Cursor*.AppImage "$h"/.local/share/cursor-ai "$h/.config/Cursor"); then
    report "$u" "AI app" "Cursor" "$HT${hit#"$h"}"
  fi
  [ -d "$h/.config/Windsurf" ] && report "$u" "AI app" "Windsurf" "$HT/.config/Windsurf"
  return 0
}

printf 'Kuntur AI inventory (read-only) on %s, %s\n' "$(hostname 2>/dev/null)" "$(date -u '+%Y-%m-%d %H:%M UTC')"

# Machine-wide installs.
check_apps "machine" "$APPS_DIR"
for d in $BIN_DIRS; do
  [ -e "$d/claude" ] && report "machine" "CLI agent" "Claude Code" "$d/claude"
  [ -e "$d/codex" ] && report "machine" "CLI agent" "Codex CLI" "$d/codex"
  [ -e "$d/gemini" ] && report "machine" "CLI agent" "Gemini CLI" "$d/gemini"
  [ -e "$d/ollama" ] && report "machine" "Local model" "Ollama" "$d/ollama"
done
for d in $NPM_DIRS; do
  check_npm "machine" "$d" "$d"
done

# Linux system-wide app installs.
for d in /opt/cursor /opt/Cursor /usr/share/cursor; do
  [ -d "$d" ] && report "machine" "AI app" "Cursor" "$d"
done
for d in /usr/share/windsurf /opt/windsurf; do
  [ -d "$d" ] && report "machine" "AI app" "Windsurf" "$d"
done

# Every real user home (skips Shared, Guest and hidden folders).
for home in "$USERS_ROOT"/*/; do
  home="${home%/}"
  user="${home##*/}"
  case "$user" in
    Shared|Guest|lost+found|.*) continue ;;
  esac
  [ -d "$home" ] || continue
  check_user "$user" "$home"
done

if [ "$FOUND" -eq 0 ]; then
  echo "Summary: no AI tools found."
  exit 0
fi
printf 'Summary: %d AI tool(s) found, %d not on the allowlist.\n' "$FOUND" "$REVIEW"
exit 0
