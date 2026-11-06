#!/bin/bash
# Local syntax checks (no CI). Uses shellcheck and pwsh when they are installed.
# Usage: bash check.sh
cd "$(dirname "$0")" || exit 1
fail=0

echo "== bash -n"
for f in ./*/*.sh; do bash -n "$f" || fail=1; done

if command -v shellcheck >/dev/null 2>&1; then
  echo "== shellcheck (severity warning and above)"
  shellcheck -S warning ./*/*.sh || fail=1
else
  echo "shellcheck not installed, skipped"
fi

if command -v pwsh >/dev/null 2>&1; then
  echo "== PowerShell parser"
  # shellcheck disable=SC2016
  pwsh -NoProfile -NonInteractive -Command '
    $bad = 0
    foreach ($f in Get-ChildItem -Path */*.ps1) {
      $t = $null; $e = $null
      [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$t, [ref]$e)
      if ($e.Count) { $bad++; "FAIL $($f.Name)"; $e | ForEach-Object { "  line $($_.Extent.StartLineNumber): $($_.Message)" } }
    }
    exit $bad' || fail=1
else
  echo "pwsh not installed, skipped"
fi

echo "== SHA-256 (compare with the hashes in each folder README)"
if command -v sha256sum >/dev/null 2>&1; then sha256sum ./*/kuntur-ai-inventory-*; else shasum -a 256 ./*/kuntur-ai-inventory-*; fi

[ "$fail" -eq 0 ] && echo "All checks passed." || echo "Some checks failed."
exit "$fail"
