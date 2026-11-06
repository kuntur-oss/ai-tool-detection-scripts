<#
.SYNOPSIS
  Read-only inventory of AI tools on a Windows endpoint, for NinjaOne.

.DESCRIPTION
  Checks every user profile for AI coding CLIs, AI desktop apps and IDEs,
  local model runners, AI editor extensions and MCP configuration files.
  It only tests whether files and folders exist and counts MCP servers.
  It never prints file contents, prompts, tokens or keys, and makes no
  network calls.

  Run it as System so it can see every profile. The summary is printed to
  the activity output and, when the NinjaOne agent module is present,
  written to a device custom field (Multi-line, Automations: Read/Write).

  Source: https://kuntur.io/guides/ninjaone-detect-ai-tools
  Kuntur, November 2026. MIT licence.
#>
param(
    # Folder that holds the user profiles.
    [string]$ProfileRoot = $(if ($env:SystemDrive) { Join-Path $env:SystemDrive 'Users' } else { 'C:\Users' }),
    # Internal name of the NinjaOne custom field. Leave empty to only print.
    [string]$CustomField = 'aiToolsInventory'
)

$ErrorActionPreference = 'SilentlyContinue'
$skip = @('Public', 'Default', 'Default User', 'All Users', 'defaultuser0', 'WDAGUtilityAccount')

function J { param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Parts) [IO.Path]::Combine([string[]]$Parts) }
function Has { param([string]$Path) return (Test-Path -LiteralPath $Path) }
function HasLike {
    param([string]$Parent, [string]$Filter)
    if (-not (Has $Parent)) { return $false }
    return [bool](Get-ChildItem -LiteralPath $Parent -Filter $Filter -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1)
}
function McpCount {
    # Counts servers in an MCP config without printing any of its values.
    param([string]$Path)
    if (-not (Has $Path)) { return -1 }
    try {
        $j = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        $n = 0
        foreach ($key in @('mcpServers', 'servers')) {
            $node = $j.$key
            if ($node) { $n += @($node.PSObject.Properties).Count }
        }
        return $n
    } catch { return 0 }
}

$aiExtensions = @(
    'github.copilot', 'github.copilot-chat', 'anthropic.claude-code', 'openai.chatgpt',
    'continue.continue', 'saoudrizwan.claude-dev', 'rooveterinaryinc.roo-cline',
    'codeium.codeium', 'tabnine.tabnine-vscode', 'amazonwebservices.amazon-q-vscode',
    'google.geminicodeassist', 'sourcegraph.cody-ai'
)

$lines = New-Object System.Collections.Generic.List[string]
$profilesSeen = 0
$toolCount = 0

$profiles = Get-ChildItem -LiteralPath $ProfileRoot -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object { $skip -notcontains $_.Name -and -not $_.Name.StartsWith('.') }

foreach ($p in $profiles) {
    $profilesSeen++
    $u = $p.FullName
    $roam = J $u 'AppData' 'Roaming'
    $local = J $u 'AppData' 'Local'
    $progs = J $local 'Programs'
    $pkgs = J $local 'Packages'
    $npm = J $roam 'npm' 'node_modules'
    $found = New-Object System.Collections.Generic.List[string]

    # AI coding CLIs
    $how = @()
    if (Has (J $u '.local' 'bin' 'claude.exe')) { $how += 'native' }
    if (Has (J $npm '@anthropic-ai' 'claude-code')) { $how += 'npm' }
    if ($how.Count -gt 0) { $found.Add("Claude Code ($($how -join '+'))") }
    elseif (Has (J $u '.claude')) { $found.Add('Claude Code (data folder only)') }
    if (Has (J $npm '@openai' 'codex')) { $found.Add('Codex CLI (npm)') }
    elseif (Has (J $u '.codex')) { $found.Add('Codex CLI (data folder only)') }
    if ((Has (J $npm '@google' 'gemini-cli')) -or (Has (J $roam 'npm' 'gemini.cmd'))) { $found.Add('Gemini CLI (npm)') }

    # AI IDEs and desktop apps
    if (Has (J $progs 'cursor')) { $found.Add('Cursor') }
    if (Has (J $progs 'Windsurf')) { $found.Add('Windsurf') }
    if ((Has (J $local 'AnthropicClaude')) -or (Has (J $progs 'Claude')) -or (HasLike $pkgs 'Claude_*') -or (HasLike $pkgs 'AnthropicPBC.Claude*')) { $found.Add('Claude desktop') }
    if ((Has (J $progs 'ChatGPT')) -or (HasLike $pkgs 'OpenAI.ChatGPT-Desktop_*')) { $found.Add('ChatGPT desktop') }

    # Local model runners
    $models = @()
    $manifests = J $u '.ollama' 'models' 'manifests' 'registry.ollama.ai' 'library'
    if (Has $manifests) {
        foreach ($m in Get-ChildItem -LiteralPath $manifests -Directory -Force) {
            foreach ($t in Get-ChildItem -LiteralPath $m.FullName -File -Force) { $models += "$($m.Name):$($t.Name)" }
        }
    }
    if ((Has (J $progs 'Ollama')) -or $models.Count -gt 0) {
        if ($models.Count -gt 0) { $found.Add("Ollama (models: $(($models | Select-Object -First 8) -join ', '))") }
        else { $found.Add('Ollama') }
    }
    if ((Has (J $progs 'LM Studio')) -or (Has (J $progs 'lm-studio')) -or (Has (J $u '.lmstudio'))) { $found.Add('LM Studio') }

    # AI extensions in VS Code (and VS Code-based editors that share the layout)
    $ext = @()
    foreach ($dir in @((J $u '.vscode' 'extensions'), (J $u '.cursor' 'extensions'), (J $u '.windsurf' 'extensions'))) {
        if (-not (Has $dir)) { continue }
        foreach ($e in Get-ChildItem -LiteralPath $dir -Directory -Force) {
            foreach ($id in $aiExtensions) {
                if ($e.Name.ToLower().StartsWith("$id-")) { $ext += $id }
            }
        }
    }
    $ext = $ext | Sort-Object -Unique
    if ($ext.Count -gt 0) { $found.Add("AI extensions: $($ext -join ', ')") }

    # MCP configuration files (server count only)
    $mcp = @()
    $configs = [ordered]@{
        'Claude desktop' = (J $roam 'Claude' 'claude_desktop_config.json')
        'Claude Code'    = (J $u '.claude.json')
        'Cursor'         = (J $u '.cursor' 'mcp.json')
        'VS Code'        = (J $roam 'Code' 'User' 'mcp.json')
        'Windsurf'       = (J $u '.codeium' 'windsurf' 'mcp_config.json')
    }
    foreach ($k in $configs.Keys) {
        $n = McpCount $configs[$k]
        if ($n -gt 0) { $mcp += "$k $n" }
    }
    if ($mcp.Count -gt 0) { $found.Add("MCP servers: $($mcp -join ', ')") }

    if ($found.Count -gt 0) {
        $toolCount += $found.Count
        $lines.Add("$($p.Name): $($found -join '; ')")
    }
}

$header = "Kuntur AI inventory $(Get-Date -Format 'yyyy-MM-dd HH:mm') | profiles: $profilesSeen | findings: $toolCount"
if ($lines.Count -eq 0) { $lines.Add('No AI tools found in user profiles.') }
$summary = (@($header) + $lines) -join "`n"
if ($summary.Length -gt 9500) { $summary = $summary.Substring(0, 9500) + "`n(truncated)" }

Write-Output $summary

if ($CustomField) {
    try {
        if (Get-Command Set-NinjaProperty -ErrorAction SilentlyContinue) {
            Set-NinjaProperty -Name $CustomField -Value $summary
        } elseif (Get-Command Ninja-Property-Set -ErrorAction SilentlyContinue) {
            Ninja-Property-Set $CustomField $summary
        } else {
            Write-Output "(NinjaOne module not found: custom field '$CustomField' not updated)"
        }
    } catch {
        Write-Output "(Could not write custom field '$CustomField': $($_.Exception.Message))"
    }
}
exit 0
