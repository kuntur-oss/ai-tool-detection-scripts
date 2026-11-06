# Kuntur: detect-local-llms.ps1
# Copied verbatim from the code blocks published at https://kuntur.io/guides/detect-ollama-local-llms
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: Check a Windows machine manually
Get-Process -Name ollama*, 'LM Studio', lms, llama-server -ErrorAction SilentlyContinue |
  Select-Object Name, Id, Path

Get-NetTCPConnection -State Listen -LocalPort 11434, 1234, 8080 -ErrorAction SilentlyContinue |
  Select-Object LocalAddress, LocalPort,
    @{n='Process'; e={ (Get-Process -Id $_.OwningProcess).Name }}

[Environment]::GetEnvironmentVariable('OLLAMA_HOST', 'User')
[Environment]::GetEnvironmentVariable('OLLAMA_HOST', 'Machine')

# --- Guide section: Check a Windows machine manually
$dirs = @("$env:USERPROFILE\.ollama\models", "$env:USERPROFILE\.lmstudio\models")
if ($env:OLLAMA_MODELS) { $dirs += $env:OLLAMA_MODELS }
foreach ($d in $dirs | Where-Object { Test-Path $_ }) {
  $gb = (Get-ChildItem $d -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1GB
  '{0}  {1:N1} GB' -f $d, $gb
}

# --- Guide section: Check a Windows machine manually
Invoke-RestMethod http://127.0.0.1:11434/api/version
(Invoke-RestMethod http://127.0.0.1:11434/api/tags).models | Select-Object name, size, modified_at
