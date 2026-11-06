# Kuntur: find-ai-api-keys.ps1
# Copied verbatim from the code blocks published at https://kuntur.io/guides/find-ai-api-keys-on-endpoints
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: Check a Windows machine
# Read-only, no network. Run as the user. Prints file, line and key TYPE only;
# a value is matched in memory and never written to the output.
$types = [ordered]@{
  'sk-ant-api03-' = 'Anthropic API key'; 'sk-ant-admin01-' = 'Anthropic Admin API key'
  'sk-ant-oat01-' = 'Anthropic OAuth token (Claude Code)'; 'sk-proj-' = 'OpenAI project key'
  'sk-svcacct-' = 'OpenAI service account key'; 'sk-admin-' = 'OpenAI admin key'
  'sk-or-v1-' = 'OpenRouter key'; 'AIza' = 'Google API key (Gemini or another Google API)'
  'gsk_' = 'Groq key'; 'hf_' = 'Hugging Face token'; 'xai-' = 'xAI key'
  'r8_' = 'Replicate token'; 'pplx-' = 'Perplexity key'
}
$prefixRe = '(?<![A-Za-z0-9])(' + (($types.Keys | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')[A-Za-z0-9_-]{16,}'
$names = '(OPENAI|ANTHROPIC|CLAUDE_CODE_OAUTH|GEMINI|GOOGLE|GOOGLE_GENERATIVE_AI|GROQ|MISTRAL|OPENROUTER|XAI|DEEPSEEK|HF|HUGGINGFACE|COHERE|TOGETHER|AZURE_OPENAI|PERPLEXITY|REPLICATE)_(API_)?(KEY|TOKEN)'
$varRe = '(?i)\b(' + $names + ')["'']?\s*[=:]\s*["'']?[^\s"''$%{]'

$h = $env:USERPROFILE
$files = @(
  "$h\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
  "$h\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
  "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt",
  "$h\.bashrc", "$h\.claude\settings.json", "$h\.claude.json", "$h\.cursor\mcp.json",
  "$h\.codeium\windsurf\mcp_config.json", "$h\.gemini\settings.json", "$h\.gemini\.env",
  "$h\.codex\config.toml", "$h\.codex\auth.json", "$h\.continue\config.yaml",
  "$h\.continue\config.json", "$h\.aider.conf.yml",
  "$env:APPDATA\Claude\claude_desktop_config.json",
  "$env:APPDATA\Code\User\settings.json", "$env:APPDATA\Code\User\mcp.json",
  "$env:APPDATA\Cursor\User\settings.json"
) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }

# .env, .env.local, .envrc ... in working copies (skips AppData, node_modules, .git)
$files += @(Get-ChildItem -LiteralPath $h -Force -File -Filter '.env*' -ErrorAction SilentlyContinue) +
  @(Get-ChildItem -LiteralPath $h -Force -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin 'AppData', 'node_modules', '.git' } |
    Get-ChildItem -Recurse -Depth 4 -Force -File -Filter '.env*' -ErrorAction SilentlyContinue) |
  Where-Object { $_.FullName -notmatch '[\\/](node_modules|\.git)[\\/]' } |
  ForEach-Object { $_.FullName }
$files = $files | Select-Object -Unique

foreach ($f in $files) {
  try { $lines = [IO.File]::ReadAllLines($f) } catch { continue }
  for ($i = 0; $i -lt $lines.Count; $i++) {
    foreach ($m in [regex]::Matches($lines[$i], $prefixRe)) {
      '{0}:{1}  {2}' -f $f, ($i + 1), $types[$m.Groups[1].Value]
    }
    foreach ($m in [regex]::Matches($lines[$i], $varRe)) {
      '{0}:{1}  {2} set to a literal value' -f $f, ($i + 1), $m.Groups[1].Value.ToUpper()
    }
  }
}

# User environment variables (HKCU\Environment, set with setx): names only
[Environment]::GetEnvironmentVariables('User').Keys |
  Where-Object { $_ -match ('^' + $names + '$') } |
  ForEach-Object { 'HKCU\Environment  {0} is set' -f $_ }
