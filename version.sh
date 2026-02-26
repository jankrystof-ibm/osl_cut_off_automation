#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <CHANGELOG.md>"
  exit 1
fi

CHANGELOG_FILE="$1"

if [[ ! -f "$CHANGELOG_FILE" ]]; then
  echo "File not found: $CHANGELOG_FILE"
  exit 1
fi

# Extract first occurrence of: ## [X.Y.Z]
grep -E '^## \[[0-9]+\.[0-9]+\.[0-9]+' "$CHANGELOG_FILE" \
  | head -n1 \
  | sed -E 's/^## \[([0-9]+\.[0-9]+\.[0-9]+)\].*/\1/'