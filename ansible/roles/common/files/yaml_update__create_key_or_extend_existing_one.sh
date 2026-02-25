#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# This script appends a value to a specific key in a YAML file using yq.
#
# Parameters:
#   1) FILE_LOCATION - Path to the YAML file (e.g., workflow file)
#   2) SELECTOR      - yq selector pointing to the target node
#   3) KEY           - Key under the selected node to append the value to
#   4) VALUE         - Value to append
#
# Behavior:
# - Ensures that the path defined by SELECTOR exists, creating maps as needed.
# - Reads the current value of the given key.
# - If the VALUE is not already present in the key, it appends it.
# - If the VALUE is already present, no change is made.
#
# Idempotency:
# - The script is idempotent: running it multiple times with the same parameters
#   will not create duplicate entries.
#
# Ansible Integration:
# - When a value is appended, the script prints a message to stdout.
#   This allows Ansible to detect that a modification occurred and mark the
#   task as "changed".

FILE_LOCATION="${1:?Specify workflow file}"
SELECTOR="${2:?Specify yq selector}"
KEY="${3:?Specify key to append}"
VALUE="${4:?Specify value to append}"

CHANGED_MSG="Appending ${VALUE}"

# create map given by SELECTOR along with KEY, if not exist
yq eval -i "(${SELECTOR}) |= ((. // {}) + {\"${KEY}\": (.${KEY} // \"\")})" "$FILE_LOCATION"

# read current value
current_value=$(yq eval "${SELECTOR}.${KEY}" "$FILE_LOCATION")

# add teh value
if [[ "$current_value" != *"${VALUE}"* ]]; then
    yq eval -i "(${SELECTOR}.${KEY}) |= (. + \" ${VALUE}\")" "$FILE_LOCATION"
    echo "$CHANGED_MSG"
fi
