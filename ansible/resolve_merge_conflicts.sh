#!/bin/bash
set -e

# THIS MERGE STRATEGY IS NOT FOR PRODUCTION use

REPO_PATH=$1

# 1. get lit of all unmerged conflicts
CONF_FILES=$(git -C "$REPO_PATH" diff --name-only --diff-filter=U)

if [ -z "$CONF_FILES" ]; then
    echo "no conflicts...
fi

# 2. check one by file
echo "$CONF_FILES" | while read -r FILE; do
    # try checkout --ours. if file is missing, pcommand selže.
    if ! git -C "$REPO_PATH" checkout --ours "$FILE" 2>/dev/null; then
        # if the command does not exist in our version => delete as we do not want it in OURS version
        git -C "$REPO_PATH" rm "$FILE"
    fi
done

# 3. complete
git -C "$REPO_PATH" add .
git -C "$REPO_PATH" commit -m "Resolve conflicts keeping ours"