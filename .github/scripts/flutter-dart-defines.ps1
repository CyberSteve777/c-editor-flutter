$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrEmpty($env:PVZ2C_ENCRYPTION_KEY)) {
    Write-Error 'PVZ2C_ENCRYPTION_KEY must be set for release builds.'
    exit 1
}

Write-Output "--dart-define=PVZ2C_ENCRYPTION_KEY=$($env:PVZ2C_ENCRYPTION_KEY)"
