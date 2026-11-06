# Kuntur: detect-mcp-servers.ps1
# Copied verbatim from the code blocks published at https://kuntur.io/guides/detect-mcp-servers
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: Detect MCP servers manually on Windows
$paths = @(
  "$env:APPDATA\Claude\claude_desktop_config.json",
  "$env:USERPROFILE\.claude.json",
  "$env:USERPROFILE\.cursor\mcp.json",
  "$env:APPDATA\Code\User\mcp.json",
  "$env:USERPROFILE\.copilot\mcp-config.json",
  "$env:APPDATA\devin\mcp_config.json",
  "$env:USERPROFILE\.codeium\windsurf\mcp_config.json"
)
$found = foreach ($p in $paths) {
  if (-not (Test-Path $p)) { continue }
  try { $j = Get-Content $p -Raw | ConvertFrom-Json } catch { Write-Warning "Unparseable: $p"; continue }
  $sets = @($j.mcpServers, $j.servers)
  if ($j.projects) { $j.projects.PSObject.Properties | ForEach-Object { $sets += $_.Value.mcpServers } }
  foreach ($s in $sets) {
    if (-not $s) { continue }
    $s.PSObject.Properties | ForEach-Object {
      $v = $_.Value
      $target = if ($v.url) { $v.url } else { (@($v.command) + @($v.args)) -join ' ' }
      [pscustomobject]@{ File = $p; Server = $_.Name; Target = $target }
    }
  }
}
$found | Format-Table -AutoSize -Wrap

# --- Guide section: Detect MCP servers manually on Windows
$skip = 'AppData','node_modules','.git','.cache','.npm','.nuget','.vscode-server','scoop','go'
@(Get-Item "$env:USERPROFILE\.mcp.json", "$env:USERPROFILE\mcp.json" -Force -ErrorAction SilentlyContinue) +
@(Get-ChildItem $env:USERPROFILE -Directory -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -notin $skip } |
  Get-ChildItem -Recurse -Force -File -Filter '*mcp.json' -Depth 6 -ErrorAction SilentlyContinue) |
  Where-Object { $_ -and $_.Name -in '.mcp.json','mcp.json' -and $_.FullName -notmatch '\\node_modules\\' } |
  Select-Object FullName, LastWriteTime

# --- Guide section: Detect MCP servers manually on Windows
$procs = Get-CimInstance Win32_Process
$byId = @{}; $procs | ForEach-Object { $byId[$_.ProcessId] = $_ }
$procs | Where-Object { $_.Name -match '^(node|npx|uvx|uv|python|docker)(\.exe)?$' } |
  ForEach-Object {
    $parent = $byId[$_.ParentProcessId]
    [pscustomobject]@{ PID = $_.ProcessId; Parent = $parent.Name; CommandLine = $_.CommandLine }
  } | Where-Object { $_.Parent -match 'Claude|Cursor|Code|Windsurf|Devin' } | Format-List
