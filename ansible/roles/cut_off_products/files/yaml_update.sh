#!/usr/bin/env bash
set -euo pipefail

# ✅ Parametry
FILE_LOCATION="${1:?Specify workflow file}"
SELECTOR="${2:?Specify yq selector}"
KEY="${3:?Specify key to append}"
VALUE="${4:?Specify value to append}"

CHANGED_MSG="Appending ${VALUE}"

# create map given by SELECTOR along with KEY, if not exist
yq eval -i "(${SELECTOR}) |= ((. // {}) + {\"${KEY}\": (.${KEY} // \"\")})" "$FILE_LOCATION"

# read current value
current_value=$(yq eval "${SELECTOR}.${KEY}" "$FILE_LOCATION")

# add
if [[ "$current_value" != *"${VALUE}"* ]]; then
    yq eval -i "(${SELECTOR}.${KEY}) |= (. + \" ${VALUE}\")" "$FILE_LOCATION"
    echo "$CHANGED_MSG"
fi
