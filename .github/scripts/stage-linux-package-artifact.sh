#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "Usage: stage-linux-package-artifact.sh <dev|release> <linux-deb|linux-rpm> <source-path>" >&2
  exit 1
fi

CHANNEL="$1"
KIND="$2"
SOURCE_PATH="$3"

if [ ! -f "$SOURCE_PATH" ]; then
  echo "Artifact not found: $SOURCE_PATH" >&2
  exit 1
fi

BASE_NAME="$(bash .github/scripts/artifact-name.sh "$KIND" "$CHANNEL")"
mkdir -p dist

case "$KIND" in
  linux-deb)
    DEST="dist/${BASE_NAME}.deb"
    ;;
  linux-rpm)
    DEST="dist/${BASE_NAME}.rpm"
    ;;
  *)
    echo "Unknown kind: $KIND" >&2
    exit 1
    ;;
esac

cp "$SOURCE_PATH" "$DEST"

{
  echo "path=$DEST"
  echo "name=$BASE_NAME"
} >>"${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"

echo "Staged $SOURCE_PATH -> $DEST"
