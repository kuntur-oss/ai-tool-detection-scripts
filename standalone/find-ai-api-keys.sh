#!/bin/bash
# Kuntur: find-ai-api-keys.sh
# Copied verbatim from the code blocks published at https://kuntur.io/guides/find-ai-api-keys-on-endpoints
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: Check macOS and Linux
# Read-only, no network. Run as the user. Prints file, line and key TYPE only:
# values pass through the pipes below but are never written to the output.
prefixes='sk-ant-api03-|sk-ant-admin01-|sk-ant-oat01-|sk-proj-|sk-svcacct-|sk-admin-|sk-or-v1-|AIza|gsk_|hf_|xai-|r8_|pplx-'
vars='(OPENAI|ANTHROPIC|CLAUDE_CODE_OAUTH|GEMINI|GOOGLE|GOOGLE_GENERATIVE_AI|GROQ|MISTRAL|OPENROUTER|XAI|DEEPSEEK|HF|HUGGINGFACE|COHERE|TOGETHER|AZURE_OPENAI|PERPLEXITY|REPLICATE)_(API_)?(KEY|TOKEN)'

key_type() {
  case "$1" in
    sk-ant-api03-)   echo "Anthropic API key" ;;
    sk-ant-admin01-) echo "Anthropic Admin API key" ;;
    sk-ant-oat01-)   echo "Anthropic OAuth token (Claude Code)" ;;
    sk-proj-)        echo "OpenAI project key" ;;
    sk-svcacct-)     echo "OpenAI service account key" ;;
    sk-admin-)       echo "OpenAI admin key" ;;
    sk-or-v1-)       echo "OpenRouter key" ;;
    AIza)            echo "Google API key (Gemini or another Google API)" ;;
    gsk_)            echo "Groq key" ;;
    hf_)             echo "Hugging Face token" ;;
    xai-)            echo "xAI key" ;;
    r8_)             echo "Replicate token" ;;
    pplx-)           echo "Perplexity key" ;;
  esac
}

scan_file() {
  # 1. Values with a known provider prefix: keep only the line number and the prefix
  grep -noE "(^|[^A-Za-z0-9])($prefixes)[A-Za-z0-9_-]{16,}" "$1" 2>/dev/null |
    sed -nE "s/^([0-9]+):[^A-Za-z0-9]?($prefixes).*/\1 \2/p" |
    while read -r line prefix; do printf '%s:%s  %s\n' "$1" "$line" "$(key_type "$prefix")"; done
  # 2. Known variable names set to a literal (not ${VAR} or $VAR): keep only the name
  grep -noiE "${vars}[\"']?[[:space:]]*[=:][[:space:]]*[\"']?[^[:space:]\"'\$%{]" "$1" 2>/dev/null |
    sed -nE 's/^([0-9]+):([A-Za-z_]+).*/\1 \2/p' |
    while read -r line name; do printf '%s:%s  %s set to a literal value\n' "$1" "$line" "$name"; done
}

list_files() {
  for f in ~/.bashrc ~/.bash_profile ~/.profile ~/.zshrc ~/.zprofile ~/.zshenv \
           ~/.bash_history ~/.zsh_history ~/.config/fish/config.fish \
           ~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt \
           ~/.claude/settings.json ~/.claude.json ~/.cursor/mcp.json \
           ~/.codeium/windsurf/mcp_config.json ~/.gemini/settings.json ~/.gemini/.env \
           ~/.codex/config.toml ~/.codex/auth.json ~/.continue/config.yaml \
           ~/.continue/config.json ~/.aider.conf.yml ~/.config/goose/config.yaml \
           "$HOME/Library/Application Support/Claude/claude_desktop_config.json" \
           "$HOME/Library/Application Support/Code/User/settings.json" \
           "$HOME/Library/Application Support/Code/User/mcp.json" \
           ~/.config/Claude/claude_desktop_config.json \
           ~/.config/Code/User/settings.json ~/.config/Code/User/mcp.json; do
    if [ -f "$f" ]; then printf '%s\0' "$f"; fi
  done
  # .env, .env.local, .envrc ... in working copies (skips node_modules, .git, ~/Library)
  find "$HOME" -maxdepth 6 \( -name node_modules -o -name .git -o -path "$HOME/Library" \) -prune \
    -o -type f -name '.env*' -print0 2>/dev/null
}

list_files | sort -zu | while IFS= read -r -d '' f; do scan_file "$f"; done
