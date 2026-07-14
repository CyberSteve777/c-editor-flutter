$ErrorActionPreference = 'Stop'

$key = $env:PVZ2C_ENCRYPTION_KEY
if ([string]::IsNullOrEmpty($key)) {
    if ($env:GITHUB_EVENT_NAME -eq 'pull_request') {
        Write-Host "Warning: PVZ2C_ENCRYPTION_KEY is missing. Using a dummy key for Pull Request build." -ForegroundColor Yellow
        $key = "DUMMY_KEY_FOR_PR_BUILDS"
    } else {
        Write-Error 'PVZ2C_ENCRYPTION_KEY must be set for release builds.'
        exit 1
    }
}

Write-Output "--dart-define=PVZ2C_ENCRYPTION_KEY=$key"
