#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="${HOME}/flutter"

if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter config --enable-web
flutter precache --web
flutter pub get
DART_DEFINES="$(bash .github/scripts/flutter-dart-defines.sh)"
# -O0: wasm-opt fails on dart_eval/SplayTreeSet at default -O2 (dart2wasm bug).
# --no-tree-shake-icons: plugins use runtime IconData(codePoint).
flutter build web --release --wasm -O0 --no-tree-shake-icons ${DART_DEFINES}
