#!/usr/bin/env bash
set -euo pipefail

BUNDLE="build/linux/x64/release/bundle"
PKG_ROOT=".linux-pkg-root"

if [ ! -d "$BUNDLE" ]; then
  echo "Linux bundle not found at $BUNDLE (run flutter build linux --release first)." >&2
  exit 1
fi

rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/opt/c-editor"
mkdir -p "$PKG_ROOT/usr/bin"
mkdir -p "$PKG_ROOT/usr/share/applications"
mkdir -p "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps"

cp -a "$BUNDLE"/. "$PKG_ROOT/opt/c-editor/"
ln -sf /opt/c-editor/C-Editor "$PKG_ROOT/usr/bin/c-editor"
install -Dm644 linux/packaging/c_editor.desktop \
  "$PKG_ROOT/usr/share/applications/c-editor.desktop"
install -Dm644 assets/meta/icon.png \
  "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps/c_editor.png"

echo "Prepared $PKG_ROOT"
