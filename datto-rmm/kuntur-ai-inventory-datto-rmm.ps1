<#
  Kuntur AI inventory - Datto RMM component
  https://kuntur.io/guides/datto-rmm-detect-ai-tools

  What it does
    Looks in every user profile on the device for AI coding tools, AI desktop
    apps, local model runners, AI editor extensions and MCP server configs.
    Read-only. No network. Never prints file contents or secrets: only tool
    names, counts and the user names that have something installed.
    Same detection catalog as the Kuntur Intune and NinjaOne scripts.

  Output and exit code (Datto RMM components)
    - Prints ONE line to StdOut, visible in the job results.
    - Optional: set the component variable UdfNumber (1-300) to also copy the
      line into that user-defined field. Datto RMM UDFs hold 255 characters,
      so the UDF copy is shortened; StdOut keeps the full line. Writing a UDF
      means setting a REG_SZ value CustomN under HKLM\SOFTWARE\CentraStage,
      which the agent uploads and then removes. That is the only write, and it
      only happens when UdfNumber is set.
    - Always exits 0, so the job shows as successful whether or not AI tools
      were found. Filter on the UDF or the output, not the job status.

  Runs on Windows PowerShell 5.1 as LocalSystem (the Datto RMM default), which
  can read every profile under C:\Users.
  Kuntur, November 2026. MIT licence.
#>
param(
  # Folder that holds the user profiles.
  [string]$ProfileRoot = $(if ($env:SystemDrive) { Join-Path $env:SystemDrive 'Users' } else { 'C:\Users' }),
  # Where machine-wide installs live. Empty skips the machine-wide check.
  [string]$ProgramFilesRoot = $env:ProgramFiles,
  # UDF to copy the summary into (1-300). Datto RMM passes component
  # variables as environment variables; empty means print only.
  [string]$UdfNumber = $env:UdfNumber
)

$ErrorActionPreference = 'SilentlyContinue'
Set-StrictMode -Version 2.0

$MaxOutput = 4000   # StdOut is generous; the UDF copy is cut to 255 below.

function Join-Parts([string]$Base, [string[]]$Parts) {
  $p = $Base
  foreach ($part in $Parts) { $p = Join-Path $p $part }
  return $p
}

function Test-AnyPath([string]$Base, [object[]]$Candidates) {
  foreach ($c in $Candidates) {
    $full = Join-Parts $Base ([string[]]$c)
    if (Test-Path -Path $full) { return $true }
  }
  return $false
}

function Count-McpServers([string]$File, [string]$Key) {
  # Counts server entries under a JSON key. Reads names only, never values.
  try {
    $raw = Get-Content -LiteralPath $File -Raw -ErrorAction Stop
    $json = $raw | ConvertFrom-Json -ErrorAction Stop
  } catch { return 0 }
  $n = 0
  $node = $json.PSObject.Properties[$Key]
  if ($node -and $node.Value) { $n += @($node.Value.PSObject.Properties).Count }
  $projects = $json.PSObject.Properties['projects']   # ~/.claude.json keeps per-project servers
  if ($projects -and $projects.Value) {
    foreach ($proj in $projects.Value.PSObject.Properties) {
      $inner = $proj.Value.PSObject.Properties[$Key]
      if ($inner -and $inner.Value) { $n += @($inner.Value.PSObject.Properties).Count }
    }
  }
  return $n
}

# Tool definitions: each candidate is a list of path segments under the profile.
$Tools = [ordered]@{
  'Claude Code'    = @( @('.local','bin','claude.exe'), @('.claude'), @('AppData','Roaming','npm','node_modules','@anthropic-ai','claude-code') )
  'Codex CLI'      = @( @('.codex'), @('AppData','Roaming','npm','node_modules','@openai','codex') )
  'Gemini CLI'     = @( @('.gemini'), @('AppData','Roaming','npm','gemini.cmd'), @('AppData','Roaming','npm','node_modules','@google','gemini-cli') )
  'Cursor'         = @( @('AppData','Local','Programs','cursor'), @('.cursor') )
  'Windsurf'       = @( @('AppData','Local','Programs','Windsurf'), @('.windsurf'), @('.codeium','windsurf') )
  'Claude Desktop' = @( @('AppData','Local','AnthropicClaude'), @('AppData','Local','Programs','Claude'), @('AppData','Local','Packages','Claude_*'), @('AppData','Local','Packages','AnthropicPBC.Claude*'), @('AppData','Roaming','Claude') )
  'ChatGPT Desktop'= @( @('AppData','Local','Packages','OpenAI.ChatGPT-Desktop_*'), @('AppData','Local','Programs','ChatGPT') )
  'Ollama'         = @( @('AppData','Local','Programs','Ollama'), @('.ollama') )
  'LM Studio'      = @( @('AppData','Local','Programs','LM Studio'), @('AppData','Local','Programs','lm-studio'), @('.lmstudio') )
}

$ExtensionPatterns = @(
  'github.copilot-*', 'github.copilot-chat-*', 'anthropic.claude-code-*', 'continue.continue-*',
  'saoudrizwan.claude-dev-*', 'rooveterinaryinc.roo-cline-*', 'kilocode.kilo-code-*', 'codeium.codeium-*',
  'openai.chatgpt-*', 'google.geminicodeassist-*', 'amazonwebservices.amazon-q-vscode-*', 'tabnine.tabnine-vscode-*'
)

# MCP config files and the JSON key that lists servers.
$McpConfigs = @(
  @{ Parts = @('AppData','Roaming','Claude','claude_desktop_config.json'); Key = 'mcpServers' },
  @{ Parts = @('.claude.json');                                           Key = 'mcpServers' },
  @{ Parts = @('.cursor','mcp.json');                                     Key = 'mcpServers' },
  @{ Parts = @('.codeium','windsurf','mcp_config.json');                  Key = 'mcpServers' },
  @{ Parts = @('.gemini','settings.json');                                Key = 'mcpServers' },
  @{ Parts = @('.lmstudio','mcp.json');                                   Key = 'mcpServers' },
  @{ Parts = @('AppData','Roaming','Code','User','mcp.json');             Key = 'servers' }
)

$SkipProfiles = @('Public','Default','Default User','All Users','WDAGUtilityAccount','defaultuser0','DefaultAppPool')

$toolUsers   = [ordered]@{}   # tool name -> list of users
$ollamaModels = 0
$extCount = 0; $extUsers = @()
$mcpFiles = 0; $mcpServers = 0; $mcpUsers = @()
$usersWithAI = @()

$profiles = @(Get-ChildItem -LiteralPath $ProfileRoot -Directory -Force | Where-Object {
  ($SkipProfiles -notcontains $_.Name) -and ($_.Name -notlike '.*') -and ($_.Name -notlike 'defaultuser*')
})

foreach ($prof in $profiles) {
  $home_ = $prof.FullName
  $user = $prof.Name
  $hit = $false

  foreach ($name in $Tools.Keys) {
    if (Test-AnyPath $home_ $Tools[$name]) {
      if (-not $toolUsers.Contains($name)) { $toolUsers[$name] = @() }
      $toolUsers[$name] += $user
      $hit = $true
    }
  }

  $manifests = Join-Parts $home_ @('.ollama','models','manifests')
  if (Test-Path -LiteralPath $manifests) {
    $ollamaModels += @(Get-ChildItem -LiteralPath $manifests -Recurse -File -Force).Count
  }

  $extDir = Join-Parts $home_ @('.vscode','extensions')
  if (Test-Path -LiteralPath $extDir) {
    $extFound = @(Get-ChildItem -LiteralPath $extDir -Directory -Force | Where-Object {
      $n = $_.Name.ToLowerInvariant(); $m = $false
      foreach ($pat in $ExtensionPatterns) { if ($n -like $pat) { $m = $true; break } }
      $m
    })
    if ($extFound.Count -gt 0) { $extCount += $extFound.Count; $extUsers += $user; $hit = $true }
  }

  $userMcp = $false
  foreach ($cfg in $McpConfigs) {
    $f = Join-Parts $home_ ([string[]]$cfg.Parts)
    if (Test-Path -LiteralPath $f -PathType Leaf) {
      $servers = Count-McpServers $f $cfg.Key
      if ($servers -gt 0) { $mcpFiles++; $mcpServers += $servers; $userMcp = $true }
    }
  }
  if ($userMcp) { $mcpUsers += $user; $hit = $true }

  if ($hit) { $usersWithAI += $user }
}

# Machine-wide installs (all users).
$machineWide = @()
if ($ProgramFilesRoot) {
  foreach ($p in @(
      @{ Name = 'Cursor'; Path = (Join-Path $ProgramFilesRoot 'cursor') },
      @{ Name = 'Ollama'; Path = (Join-Path $ProgramFilesRoot 'Ollama') })) {
    if (Test-Path -LiteralPath $p.Path) { $machineWide += $p.Name }
  }
}

$parts = @()
foreach ($name in $toolUsers.Keys) {
  $n = @($toolUsers[$name] | Select-Object -Unique).Count
  if ($name -eq 'Ollama' -and $ollamaModels -gt 0) { $parts += ('{0}({1}; {2} models)' -f $name, $n, $ollamaModels) }
  else { $parts += ('{0}({1})' -f $name, $n) }
}
foreach ($m in ($machineWide | Select-Object -Unique)) {
  if (-not $toolUsers.Contains($m)) { $parts += ('{0}(machine)' -f $m) }
}
if ($extCount -gt 0) { $parts += ('AI extensions({0} in {1})' -f $extCount, @($extUsers | Select-Object -Unique).Count) }
if ($mcpFiles -gt 0) { $parts += ('MCP configs({0}; {1} servers)' -f $mcpFiles, $mcpServers) }

$found = $parts.Count -gt 0
if ($found) {
  $line = 'AI tools: ' + ($parts -join ', ')
  $userList = @($usersWithAI | Select-Object -Unique)
  if ($userList.Count -gt 0) { $line += ' | users: ' + ($userList -join ',') }
} else {
  $line = 'AI tools: none found in ' + $profiles.Count + ' profiles'
}
if ($line.Length -gt $MaxOutput) { $line = $line.Substring(0, $MaxOutput - 3) + '...' }

Write-Output $line

$udf = 0
if ($UdfNumber -and [int]::TryParse($UdfNumber.Trim(), [ref]$udf) -and $udf -ge 1 -and $udf -le 300) {
  $udfValue = $line
  if ($udfValue.Length -gt 255) { $udfValue = $udfValue.Substring(0, 252) + '...' }
  try {
    New-ItemProperty -Path 'HKLM:\SOFTWARE\CentraStage' -Name ('Custom' + $udf) -PropertyType String -Value $udfValue -Force -ErrorAction Stop | Out-Null
    Write-Output ('(copied to UDF ' + $udf + ')')
  } catch {
    Write-Output ('(could not write UDF ' + $udf + ')')
  }
} elseif ($UdfNumber) {
  Write-Output '(UdfNumber must be a number from 1 to 300; no UDF written)'
}
exit 0
