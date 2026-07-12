#!/usr/bin/env bash
set -euo pipefail

if [ -z "${PVZ2C_ENCRYPTION_KEY:-}" ]; then
  echo "PVZ2C_ENCRYPTION_KEY must be set for release builds." >&2
  exit 1
fi

printf '%s' "--dart-define=PVZ2C_ENCRYPTION_KEY=${PVZ2C_ENCRYPTION_KEY}"
