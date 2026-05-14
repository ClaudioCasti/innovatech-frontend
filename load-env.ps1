<#
Load variables from .env into the current PowerShell session.
Usage: .\load-env.ps1
#>

$envFile = Join-Path -Path (Get-Location) -ChildPath ".env"
if (-Not (Test-Path $envFile)) {
    Write-Host ".env file not found at $envFile"
    exit 1
}

Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    $parts = $line -split '=', 2
    if ($parts.Count -eq 2) {
        $key = $parts[0].Trim()
        $value = $parts[1].Trim()
        # Remove surrounding quotes if present
        if ($value.StartsWith('"') -and $value.EndsWith('"')) {
            $value = $value.Substring(1, $value.Length - 2)
        } elseif ($value.StartsWith("'") -and $value.EndsWith("'")) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        Set-Item -Path Env:\$key -Value $value
        Write-Host "Loaded $key"
    }
}

Write-Host ".env loaded into session environment." -ForegroundColor Green
