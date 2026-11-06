# Standalone checks (plain PowerShell and bash)

Manual checks for one machine, copied from the code blocks in the Kuntur guides. Run them in a terminal as the user whose profile you want to check (they look at the current user's home folder, not every profile). The code is unchanged from the guides; each file only adds a comment header and a `# --- Guide section:` marker before each block.

| File | Finds | Guide |
|---|---|---|
| `find-ai-api-keys.sh` / `.ps1` | AI provider API keys and tokens (Anthropic, OpenAI, OpenRouter, Google, Groq, Hugging Face, xAI, Replicate, Perplexity) in shell profiles, shell history, AI tool configs and `.env*` files; on Windows also user environment variables | https://kuntur.io/guides/find-ai-api-keys-on-endpoints |
| `detect-mcp-servers.sh` / `.ps1` | MCP servers configured in Claude Desktop, Claude Code, Cursor, VS Code, Copilot CLI, Devin and Windsurf; project `.mcp.json` files; running MCP server processes | https://kuntur.io/guides/detect-mcp-servers |
| `detect-claude-code.sh` / `.ps1` | Whether Claude Code is installed (native, npm, Homebrew, WinGet), running, and recently used; on macOS/Linux also risky settings (bypass permissions, auto-approved project MCP servers, custom base URL, plugin marketplaces) | https://kuntur.io/guides/detect-claude-code |
| `detect-local-llms.sh` / `.ps1` | Ollama, LM Studio, llama.cpp server and vLLM: processes, listening ports and bind address, model folders and their size, installed models | https://kuntur.io/guides/detect-ollama-local-llms |

## How to run

```bash
bash standalone/find-ai-api-keys.sh
bash standalone/detect-mcp-servers.sh      # needs jq
bash standalone/detect-claude-code.sh      # settings checks need jq
bash standalone/detect-local-llms.sh       # last step needs jq
```

```powershell
powershell -ExecutionPolicy Bypass -File .\standalone\find-ai-api-keys.ps1
powershell -ExecutionPolicy Bypass -File .\standalone\detect-mcp-servers.ps1
powershell -ExecutionPolicy Bypass -File .\standalone\detect-claude-code.ps1
powershell -ExecutionPolicy Bypass -File .\standalone\detect-local-llms.ps1
```

You can also paste each block from the guide into a terminal one at a time; the result is the same.

## What they print

- **find-ai-api-keys**: file path, line number and key type only, for example `~/.zshrc:12  OpenAI project key` or `.env:3  ANTHROPIC_API_KEY set to a literal value`. Key values are matched in memory or inside the pipe and never written to the output.
- **detect-mcp-servers**: config file, server name and the server's target (its URL, or its command and arguments), plus `.mcp.json` file paths and the command lines of MCP-looking processes. It does not print the `env` block of a server config. Note that if someone put a token directly in a server's URL or arguments (instead of in `env`), that token will appear in the output. Treat the output as sensitive, or use the platform scripts in this repo, which only count servers.
- **detect-claude-code**: install paths, version, running process, the 10 most recent project folders, and on macOS/Linux the values of a few settings. For the `env` block it prints key names only, plus `ANTHROPIC_BASE_URL` if set.
- **detect-local-llms**: process names, listening ports and bind addresses, `OLLAMA_HOST`, model folder sizes and installed model names.

## Network

None of these scripts contact anything outside the machine. The local LLM check asks the Ollama API on `127.0.0.1:11434` (loopback only) for its version and model list. The guide also shows how to find exposed Ollama and LM Studio instances from the network with `nmap`; that is a network scan rather than an endpoint check, so it is not included here.

## Related

For an MCP config you already have open, the browser-based auditor at https://kuntur.io/tools/mcp-config-auditor checks it locally in the page.
