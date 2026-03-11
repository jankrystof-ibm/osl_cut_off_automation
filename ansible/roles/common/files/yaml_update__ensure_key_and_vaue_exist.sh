#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# This script updates a specific key in a YAML file using yq.
#
# Parameters:
#   1) FILE_LOCATION - Path to the YAML file (e.g., workflow file)
#   2) SELECTOR      - yq selector pointing to the target node
#   3) KEY           - Key to be modified under the selected node
#   4) VALUE         - Desired value for the key
#
# Behavior:
# - The script reads the current value of the given key.
# - If the current value differs from the desired VALUE,
#   it updates the YAML file in place.
# - If the value is already correct, no change is made.
#
# Idempotency:
# - The script is idempotent: running it multiple times with the same
#   parameters will not cause additional modifications once the desired
#   state is reached.
#
# Ansible Integration:
# - When a change occurs, the script prints a message to stdout.
#   This allows Ansible to detect that a modification was performed
#   and mark the task as "changed".

FILE_LOCATION="${1:?Specify workflow file}"
# when selector is not needed, pass '-'
SELECTOR="${2:?Specify yq selector}"
KEY="${3:?Specify key to setup}"
VALUE="${4:?Specify value for the key}"


if [ "$SELECTOR" == "-" ]; then
  KEY="$KEY" VALUE="$VALUE" yq -i '.[strenv(KEY)] = env(VALUE)' "$FILE_LOCATION"
  CHANGED_MSG="Appending ${VALUE}"
  echo "$CHANGED_MSG"
  exit 0
fi
CURRENT_VALUE=$(yq eval "(${SELECTOR}).${KEY} // \"\"" "$FILE_LOCATION")

if [ "$CURRENT_VALUE" != "$VALUE" ]; then
  yq -py eval -i "(${SELECTOR}).${KEY} = \"${VALUE}\"" "$FILE_LOCATION"
  CHANGED_MSG="Appending ${VALUE}"
  echo "$CHANGED_MSG"
fi
