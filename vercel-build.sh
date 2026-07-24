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
# Stay on WASM. Default -O2 runs wasm-opt, which currently fails validation on
# SplayTreeSet codegen pulled in via dart_eval (Flutter/Dart stable bug).
# Plugin IconData is created at runtime, so icon tree-shaking must stay off.
flutter build web --release --wasm -O0 --no-tree-shake-icons ${DART_DEFINES}
