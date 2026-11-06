#!/bin/bash
# Kuntur: detect-mcp-servers.sh
# Copied verbatim from the code blocks published at https://kuntur.io/guides/detect-mcp-servers
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: Detect MCP servers manually on macOS and Linux
for f in \
  "$HOME/Library/Application Support/Claude/claude_desktop_config.json" \
  "$HOME/.claude.json" \
  "$HOME/.cursor/mcp.json" \
  "$HOME/Library/Application Support/Code/User/mcp.json" \
  "$HOME/.config/Code/User/mcp.json" \
  "$HOME/.copilot/mcp-config.json" \
  "$HOME/.config/devin/mcp_config.json" \
  "$HOME/.codeium/windsurf/mcp_config.json"; do
  [ -f "$f" ] || continue
  echo "== $f"
  jq -r '[.mcpServers, .servers, (.projects // {} | .[].mcpServers)]
         | map(select(. != null) | to_entries[]) | .[]
         | "\(.key)\t\(.value.url // ([.value.command] + (.value.args // []) | join(" ")))"' "$f" \
    || echo "   (unparseable JSON)"
done

# --- Guide section: Detect MCP servers manually on macOS and Linux
find "$HOME" \( -name node_modules -o -name Library \) -prune -o \
  \( -name '.mcp.json' -o -path '*/.cursor/mcp.json' -o -path '*/.vscode/mcp.json' \) -print 2>/dev/null

# --- Guide section: Detect MCP servers manually on macOS and Linux
ps -axo pid=,ppid=,command= | grep -Ei 'mcp|modelcontextprotocol' | grep -v grep |
  while read -r pid ppid cmd; do
    printf '%s\tparent=%s\t%s\n' "$pid" "$(ps -o comm= -p "$ppid")" "$cmd"
  done
