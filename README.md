# AI tool detection scripts

Free, read-only scripts that find AI tools on company endpoints: AI coding agents and CLIs (Claude Code, Codex CLI, Gemini CLI), AI IDEs and desktop apps (Cursor, Windsurf, Claude, ChatGPT), local LLM runners and models (Ollama, LM Studio), AI editor extensions (GitHub Copilot, Cline, Continue, Roo Code and others), MCP server configs, and AI API keys left in config files.

Most of these tools install into the user's profile without admin rights, so they rarely show up in an MDM or RMM software inventory. These scripts look in the paths where they actually live and report one compact result per device, in the format each management tool expects.

Each script is published with a step-by-step guide on kuntur.io. The files here are byte-for-byte the same as the ones linked from the guides, and the SHA-256 in each folder's README matches the hash in the guide.

## Platforms

| Folder | Platform | OS | Guide |
|---|---|---|---|
| [`intune/`](intune/) | Microsoft Intune Remediations | Windows | [guide](https://kuntur.io/guides/intune-detect-ai-tools) |
| [`sccm/`](sccm/) | Configuration Manager (SCCM / MECM) | Windows | [guide](https://kuntur.io/guides/sccm-detect-ai-tools) |
| [`crowdstrike-rtr/`](crowdstrike-rtr/) | CrowdStrike Falcon Real Time Response | Windows | [guide](https://kuntur.io/guides/crowdstrike-rtr-detect-ai-tools) |
| [`workspace-one/`](workspace-one/) | Omnissa Workspace ONE UEM | Windows | [guide](https://kuntur.io/guides/workspace-one-detect-ai-tools) |
| [`pdq/`](pdq/) | PDQ Inventory / PDQ Deploy | Windows | [guide](https://kuntur.io/guides/pdq-detect-ai-tools) |
| [`ninjaone/`](ninjaone/) | NinjaOne | Windows | [guide](https://kuntur.io/guides/ninjaone-detect-ai-tools) |
| [`datto-rmm/`](datto-rmm/) | Datto RMM | Windows | [guide](https://kuntur.io/guides/datto-rmm-detect-ai-tools) |
| [`connectwise-automate/`](connectwise-automate/) | ConnectWise Automate | Windows | [guide](https://kuntur.io/guides/connectwise-automate-detect-ai-tools) |
| [`manageengine/`](manageengine/) | ManageEngine Endpoint Central | Windows, macOS | [guide](https://kuntur.io/guides/manageengine-endpoint-central-detect-ai-tools) |
| [`jamf/`](jamf/) | Jamf Pro | macOS | [guide](https://kuntur.io/guides/jamf-detect-ai-tools) |
| [`kandji/`](kandji/) | Iru (formerly Kandji) | macOS | [guide](https://kuntur.io/guides/kandji-detect-ai-tools) |
| [`mosyle/`](mosyle/) | Mosyle | macOS | [guide](https://kuntur.io/guides/mosyle-detect-ai-tools) |
| [`addigy/`](addigy/) | Addigy | macOS | [guide](https://kuntur.io/guides/addigy-detect-ai-tools) |
| [`standalone/`](standalone/) | Plain PowerShell and bash, one machine | Windows, macOS, Linux | see folder |

`standalone/` has manual checks for AI API keys, MCP servers, Claude Code and local LLMs. For a single MCP config file there is also a browser-based auditor at https://kuntur.io/tools/mcp-config-auditor that runs entirely in the page.

## Privacy and safety

- **Read-only.** The platform scripts check whether known paths exist and count entries. They do not install, change or delete anything on the endpoint. The only writes are where the platform stores the result, and only where noted: the NinjaOne custom field, an optional Datto RMM UDF, and an optional JSON summary in the Intune script (off by default).
- **No network.** No script sends data anywhere. The one exception to "no network at all" is `standalone/detect-local-llms`, which asks the Ollama API on `127.0.0.1` (loopback) for its version and model list.
- **No secret values in output.** The platform scripts never print file contents; MCP configs are counted without reading their commands, URLs or environment variables. The API key check prints file, line and key type, never the key. The standalone MCP check prints server commands and URLs with secret-looking arguments and URL credentials and queries masked; read the note in [`standalone/README.md`](standalone/README.md) before sharing its output.
- **Read before you run.** They are plain text and short. Check the SHA-256 against the guide before uploading a script to your console.

## Limits

These are point-in-time checks against a fixed list of paths. They do not see browser-only use of ChatGPT, Claude or Gemini, tools inside WSL distros, containers or VMs, renamed binaries or custom install locations, or tools released after the list was written. Each guide has a "What it does not see" section with details.

## Checks

`bash check.sh` runs `bash -n`, `shellcheck` and the PowerShell parser on every script (each one only if installed) and prints the SHA-256 of the platform scripts. There is no CI.

## Contributing

Issues and pull requests are welcome, especially new tool paths and fixes for a specific platform. Please keep scripts read-only, offline and free of secret output.

## License

MIT. See [LICENSE](LICENSE).

---

Want this continuously across your fleet, with approvals and history? Kuntur does it with a read-only agent: https://kuntur.io/?utm_source=github&utm_medium=readme
