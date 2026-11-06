#!/bin/bash
# Kuntur AI inventory: Addigy Custom Fact (return type: String) (macOS).
# https://kuntur.io/guides/addigy-detect-ai-tools
#
# Lists AI apps, coding CLIs, local models, AI editor extensions and MCP
# configuration files found on this Mac, for every user home folder.
# Read-only: it only checks whether paths exist and counts entries.
# It never reads file contents, prints secrets or uses the network.
#
# Output: one line, "Item; Item; ...", or "None". Use it as a Custom Fact with
# return type String; Addigy collects standard output as the fact value.
# Compatible with the macOS default /bin/bash 3.2.

USERS_ROOT="${USERS_ROOT:-/Users}"
APPS_DIR="${APPS_DIR:-/Applications}"
SYSTEM_BIN_DIRS="${SYSTEM_BIN_DIRS:-/opt/homebrew/bin /usr/local/bin}"

found=""

add() {
  case "|$found|" in
    *"|$1|"*) ;;
    *) if [ -z "$found" ]; then found="$1"; else found="$found|$1"; fi ;;
  esac
}

# Real user home folders only.
homes() {
  for h in "$USERS_ROOT"/*; do
    [ -d "$h" ] || continue
    case "$(basename "$h")" in
      Shared|Guest|.*) continue ;;
    esac
    printf '%s\n' "$h"
  done
}

# 1. Apps installed system-wide or per user.
check_app() { # $1 label, $2 bundle name
  if [ -d "$APPS_DIR/$2" ]; then add "$1"; return; fi
  while IFS= read -r h; do
    if [ -d "$h/Applications/$2" ]; then add "$1"; return; fi
  done <<EOF
$(homes)
EOF
}
check_app "Claude desktop" "Claude.app"
check_app "ChatGPT desktop" "ChatGPT.app"
check_app "Cursor" "Cursor.app"
check_app "Windsurf" "Windsurf.app"
check_app "Ollama" "Ollama.app"
check_app "LM Studio" "LM Studio.app"

# 2. CLIs installed in shared locations (Homebrew, npm global).
for d in $SYSTEM_BIN_DIRS; do
  [ -e "$d/claude" ] && add "Claude Code"
  [ -e "$d/codex" ] && add "Codex CLI"
  [ -e "$d/gemini" ] && add "Gemini CLI"
  [ -e "$d/ollama" ] && add "Ollama"
done

# 3. Per-user installs, data folders and configuration.
models=0
mcp=0
while IFS= read -r h; do
  [ -n "$h" ] || continue
  if [ -e "$h/.local/bin/claude" ] || [ -e "$h/.claude/local/claude" ] || [ -d "$h/.claude" ]; then
    add "Claude Code"
  fi
  { [ -e "$h/.local/bin/codex" ] || [ -d "$h/.codex" ]; } && add "Codex CLI"
  { [ -e "$h/.local/bin/gemini" ] || [ -d "$h/.gemini" ]; } && add "Gemini CLI"
  { [ -d "$h/.lmstudio" ] || [ -d "$h/.cache/lm-studio" ]; } && add "LM Studio"

  # Ollama models: one manifest file per model tag.
  lib="$h/.ollama/models/manifests"
  if [ -d "$lib" ]; then
    add "Ollama"
    n=$(find "$lib" -type f 2>/dev/null | wc -l | tr -d ' ')
    models=$((models + n))
  fi

  # AI extensions in VS Code and Cursor (folder names start with the extension ID).
  for ext in "$h/.vscode/extensions" "$h/.cursor/extensions"; do
    [ -d "$ext" ] || continue
    for e in "$ext"/*; do
      [ -d "$e" ] || continue
      case "$(basename "$e" | tr '[:upper:]' '[:lower:]')" in
        github.copilot*) add "GitHub Copilot extension" ;;
        anthropic.claude-code*) add "Claude Code extension" ;;
        openai.chatgpt*) add "Codex extension" ;;
        continue.continue*) add "Continue extension" ;;
        saoudrizwan.claude-dev*) add "Cline extension" ;;
        rooveterinaryinc.roo-cline*) add "Roo Code extension" ;;
        codeium.*) add "Windsurf/Codeium extension" ;;
        google.geminicodeassist*) add "Gemini Code Assist extension" ;;
        amazonwebservices.amazon-q-vscode*) add "Amazon Q extension" ;;
        tabnine.tabnine-vscode*) add "Tabnine extension" ;;
      esac
    done
  done

  # MCP configuration files (counted, never read).
  for f in \
    "$h/Library/Application Support/Claude/claude_desktop_config.json" \
    "$h/.cursor/mcp.json" \
    "$h/.claude.json" \
    "$h/Library/Application Support/Code/User/mcp.json" \
    "$h/.codeium/windsurf/mcp_config.json"; do
    [ -f "$f" ] && mcp=$((mcp + 1))
  done
done <<EOF
$(homes)
EOF

if [ "$models" -gt 0 ]; then
  mword=models; [ "$models" -eq 1 ] && mword=model
  found=$(printf '%s' "$found" | tr '|' '\n' | sed "s/^Ollama\$/Ollama ($models $mword)/" | tr '\n' '|')
  found=${found%|}
fi
[ "$mcp" -gt 0 ] && add "MCP configs ($mcp)"

if [ -z "$found" ]; then
  echo "None"
else
  printf '%s' "$found" | tr '|' '\n' | sort | paste -sd ';' - | sed 's/;/; /g'
fi
