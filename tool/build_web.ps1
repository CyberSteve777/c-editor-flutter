# Builds the C-Editor web app together with the RSB export Web Worker.
#
# The worker (web/rsb_worker.dart) runs the CPU-heavy sen pack/unpack pipeline
# off the UI thread so exporting on the web does not freeze the tab. Flutter has
# no pre-build hook, so it must be compiled explicitly before `flutter build web`.
#
# Builds the JavaScript (dart2js) web target on purpose — no `--wasm`.
#
# Usage:
#   ./tool/build_web.ps1                 # release JS build
#   ./tool/build_web.ps1 --base-href /app/   # forward extra args to flutter build web
$ErrorActionPreference = "Stop"

# Minimum required Flutter (see pubspec.yaml). Warn only when below the floor.
$minFlutter = [version]"3.35.3"
$flutterVersionLine = (& flutter --version 2>$null | Select-Object -First 1)
if ($flutterVersionLine -match 'Flutter\s+(\d+\.\d+\.\d+)') {
  $currentFlutter = [version]$Matches[1]
  if ($currentFlutter -lt $minFlutter) {
    Write-Warning "Need Flutter >= $minFlutter (found $currentFlutter). See .fvmrc / README.md."
  }
}

Write-Host "Compiling RSB export worker (web/rsb_worker.dart -> web/rsb_worker.dart.js)..."
& dart compile js web/rsb_worker.dart -o web/rsb_worker.dart.js -O2
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Building Flutter web app (JS target)..."
& flutter build web --no-wasm-dry-run @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
