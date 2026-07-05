#!/usr/bin/env bash
set -euo pipefail

RAW_VERSION=$(grep -E '^version:' pubspec.yaml | head -1 | sed -E 's/^version:[[:space:]]*//')
VERSION="${RAW_VERSION%%+*}"
SHORT_SHA="${GITHUB_SHA::7}"

echo "version=$VERSION" >> "$GITHUB_OUTPUT"
echo "short_sha=$SHORT_SHA" >> "$GITHUB_OUTPUT"
