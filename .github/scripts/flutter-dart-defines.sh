#!/usr/bin/env bash
set -euo pipefail

if [ -z "${PVZ2C_ENCRYPTION_KEY:-}" ]; then
  if [ "${GITHUB_EVENT_NAME:-}" = "pull_request" ]; then
    echo "Warning: PVZ2C_ENCRYPTION_KEY is missing. Using a dummy key for Pull Request build." >&2
    PVZ2C_ENCRYPTION_KEY="DUMMY_KEY_FOR_PR_BUILDS"
  else
    echo "PVZ2C_ENCRYPTION_KEY must be set for release builds." >&2
    exit 1
  fi
fi

printf '%s' "--dart-define=PVZ2C_ENCRYPTION_KEY=${PVZ2C_ENCRYPTION_KEY}"
