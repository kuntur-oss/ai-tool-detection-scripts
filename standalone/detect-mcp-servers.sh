#!/bin/bash
# Kuntur: detect-mcp-servers.sh
# Copied verbatim from the code blocks published at https://kuntur.io/guides/detect-mcp-servers
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: Detect MCP servers manually on macOS and Linux
# Values that look like secrets (tokens, keys, flag values, URL credentials and queries) print as ***.
M='def sn: test("token|key|secret|password|auth|bearer|apikey"; "i");
   def url: sub("://[^/@]*@"; "://") | sub("\\?.*"; "?***");
   def mask: reduce (.[] | tostring) as $s ({o: [], f: false};
     .o += [if .f or ($s | test("^(sk-|ghp_|gho_|github_pat_|xox[bp]-|AKIA|AIza|glpat-|hf_)[A-Za-z0-9_-]{8,}|^[A-Za-z0-9_-]{32,}$")) then "***"
            elif ($s | test("^[a-z][a-z0-9+.-]*://"; "i")) then ($s | url)
            elif ($s | test("^[-\\w.]+(=(?!=)|: )")) and ($s | sub("[=:].*"; "") | sn) then ($s | sub("^(?<k>[-\\w.]+(=|: )).*"; "\(.k)***"))
            else $s end]
     | .f = ($s | sn and test("^-[^=]*$|:$|^bearer$"; "i"))) | .o;'
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
  jq -r "$M"'[.mcpServers, .servers, (.projects // {} | .[].mcpServers)]
         | map(select(. != null) | to_entries[]) | .[]
         | "\(.key)\t\(if .value.url then (.value.url | url) else ([.value.command] + (.value.args // [] | mask) | join(" ")) end)"' "$f" \
    || echo "   (unparseable JSON)"
done

# --- Guide section: Detect MCP servers manually on macOS and Linux
find "$HOME" \( -name node_modules -o -name Library \) -prune -o \
  \( -name '.mcp.json' -o -path '*/.cursor/mcp.json' -o -path '*/.vscode/mcp.json' \) -print 2>/dev/null

# --- Guide section: Detect MCP servers manually on macOS and Linux
# Uses $M from the first snippet (run that first): secret-looking arguments print as ***.
ps -axo pid=,ppid=,command= | grep -Ei 'mcp|modelcontextprotocol' | grep -v grep |
  while read -r pid ppid cmd; do
    printf '%s\tparent=%s\t%s\n' "$pid" "$(ps -o comm= -p "$ppid")" \
      "$(printf '%s' "$cmd" | jq -Rr "$M"'split(" ") | mask | join(" ")')"
  done
