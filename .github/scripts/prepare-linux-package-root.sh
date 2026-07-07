#!/usr/bin/env bash
set -euo pipefail

BUNDLE="build/linux/x64/release/bundle"
PKG_ROOT=".linux-pkg-root"
DESKTOP_ID="team.international2c.c_editor"
ICON_NAME="$DESKTOP_ID"

if [ ! -d "$BUNDLE" ]; then
  echo "Linux bundle not found at $BUNDLE (run flutter build linux --release first)." >&2
  exit 1
fi

rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/opt/c-editor"
mkdir -p "$PKG_ROOT/usr/bin"
mkdir -p "$PKG_ROOT/usr/share/applications"
mkdir -p "$PKG_ROOT/DEBIAN"

cp -a "$BUNDLE"/. "$PKG_ROOT/opt/c-editor/"
ln -sf /opt/c-editor/C-Editor "$PKG_ROOT/usr/bin/c-editor"

install -Dm644 linux/packaging/c_editor.desktop \
  "$PKG_ROOT/usr/share/applications/${DESKTOP_ID}.desktop"

for size in 48 128 256; do
  icon_dir="$PKG_ROOT/usr/share/icons/hicolor/${size}x${size}/apps"
  mkdir -p "$icon_dir"
  install -Dm644 assets/meta/icon.png "$icon_dir/${ICON_NAME}.png"
done

install -Dm755 linux/packaging/postinstall.sh "$PKG_ROOT/DEBIAN/postinst"

echo "Prepared $PKG_ROOT"
