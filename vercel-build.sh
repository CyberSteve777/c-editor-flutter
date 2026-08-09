#!/usr/bin/env bash
set -euo pipefail

# Minimum Flutter version (first stable with Dart 3.12). Keep in sync with
# pubspec.yaml (`flutter: ">=…"`), .fvmrc, and the GitHub workflows.
FLUTTER_VERSION="3.44.0"
FLUTTER_DIR="${HOME}/flutter"

if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  git clone https://github.com/flutter/flutter.git -b "${FLUTTER_VERSION}" --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter config --enable-web
flutter precache --web
flutter pub get
DART_DEFINES="$(bash .github/scripts/flutter-dart-defines.sh)"

# Compile the RSB export Web Worker (flutter build web does not compile it) so
# heavy pack/unpack runs off the UI thread. Must run after `flutter pub get`.
dart compile js web/rsb_worker.dart -o web/rsb_worker.dart.js -O2

# JS (dart2js) target on purpose — no `--wasm`, to compare non-wasm performance.
# --no-tree-shake-icons: plugins use runtime IconData(codePoint).
flutter build web --release --no-tree-shake-icons --no-wasm-dry-run ${DART_DEFINES}
