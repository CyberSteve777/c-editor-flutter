#!/usr/bin/env bash
# Builds the C-Editor web app together with the RSB export Web Worker.
#
# The worker (web/rsb_worker.dart) runs the CPU-heavy sen pack/unpack pipeline
# off the UI thread so exporting on the web does not freeze the tab. Flutter has
# no pre-build hook, so it must be compiled explicitly before `flutter build web`.
#
# Builds the JavaScript (dart2js) web target on purpose — no `--wasm`.
#
# Usage:
#   ./tool/build_web.sh                    # release JS build
#   ./tool/build_web.sh --base-href /app/  # forward extra args to flutter build web
set -euo pipefail

# Minimum required Flutter (see pubspec.yaml). Warn only when below the floor.
MIN_FLUTTER="3.35.3"
CURRENT_FLUTTER="$(flutter --version 2>/dev/null | head -n1 | awk '{print $2}')"
if [[ -n "${CURRENT_FLUTTER}" ]]; then
  LOWEST="$(printf '%s\n%s\n' "${MIN_FLUTTER}" "${CURRENT_FLUTTER}" | sort -V | head -n1)"
  if [[ "${LOWEST}" != "${MIN_FLUTTER}" ]]; then
    echo "Warning: need Flutter >= ${MIN_FLUTTER} (found ${CURRENT_FLUTTER}). See .fvmrc / README.md." >&2
  fi
fi

echo "Compiling RSB export worker (web/rsb_worker.dart -> web/rsb_worker.dart.js)..."
dart compile js web/rsb_worker.dart -o web/rsb_worker.dart.js -O2

echo "Building Flutter web app (JS target)..."
flutter build web --no-wasm-dry-run "$@"
