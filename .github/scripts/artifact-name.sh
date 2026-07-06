#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: artifact-name.sh <suffix> <dev|release>" >&2
  exit 1
fi

SUFFIX="$1"
CHANNEL="$2"

RAW_VERSION=$(grep -E '^version:' pubspec.yaml | head -1 | sed -E 's/^version:[[:space:]]*//')
VERSION="${RAW_VERSION%%+*}"

if [ "$CHANNEL" = "release" ]; then
  echo "c_editor-${VERSION}-${SUFFIX}"
elif [ "$CHANNEL" = "dev" ]; then
  SHORT_SHA="${GITHUB_SHA::7}"
  echo "c_editor-${VERSION}+${SHORT_SHA}-${SUFFIX}"
else
  echo "Unknown channel: $CHANNEL (use dev or release)" >&2
  exit 1
fi
