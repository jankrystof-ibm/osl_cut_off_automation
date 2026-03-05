#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_DIR="$(dirname $(realpath "$0"))"

# Required/optional environment variables:
#   CLONE_OUT_HOST (required)
#   SSH_KEY_LOCATION (required)

: "${CLONE_OUT_HOST:?CLONE_OUT_HOST is not set}"
: "${SSH_KEY_LOCATION:?SSH_KEY_LOCATION is not set}"
: "${ANSIBLE_DIR_HOST:=$THIS_SCRIPT_DIR/ansible}"
: "${CONTAINER_IMAGE:=quay.io/rh-ee-jkrystof/osl_cut_off_automation:latest}"
: "${GIT_USER_NAME:=not set}"
: "${GIT_USER_EMAIL:=not@set}"

if [[ ! -d "$CLONE_OUT_HOST" ]]; then
  echo "Host directory CLONE_OUT_HOST does not exist: $CLONE_OUT_HOST"
  exit 1
fi

if [[ ! -d "$ANSIBLE_DIR_HOST" ]]; then
  echo "Host directory ANSIBLE_DIR_HOST does not exist: $ANSIBLE_DIR_HOST"
  exit 1
fi

if [[ ! -f "$SSH_KEY_LOCATION" ]]; then
  echo "SSH key not found: $SSH_KEY_LOCATION"
  exit 1
fi


TEMP_HOME=$(mktemp -d /tmp/ci_home.XXX)
chmod 700 "$TEMP_HOME"
echo Temporary HOME created in $TEMP_HOME

TMP_SSH_DIR="$TEMP_HOME/.ssh"
mkdir -p "$TMP_SSH_DIR"
chmod 700 "$TMP_SSH_DIR"

cp "$SSH_KEY_LOCATION" "$TMP_SSH_DIR/id_rsa"
chmod 600 "$TMP_SSH_DIR/id_rsa"

ssh-keyscan github.com > "$TMP_SSH_DIR/known_hosts"
ssh-keyscan gitlab.cee.redhat.com >> "$TMP_SSH_DIR/known_hosts"

chmod 644 "$TMP_SSH_DIR/known_hosts"

GIT_SSH_COMMAND="ssh -i $TMP_SSH_DIR/id_rsa -o UserKnownHostsFile=$TMP_SSH_DIR/known_hosts -o StrictHostKeyChecking=yes"

docker run --rm \
  --user $(id -u):$(id -g) \
  -e HOME="$TEMP_HOME" \
  -e ANSIBLE_REMOTE_TMP="$TEMP_HOME/.ansible/tmp" \
  -e GIT_SSH_COMMAND="$GIT_SSH_COMMAND" \
  -v /etc/passwd:/etc/passwd:ro \
  -v /etc/group:/etc/group:ro \
  -v "$TEMP_HOME:$TEMP_HOME" \
  -v "$CLONE_OUT_HOST:/tmp/osl_cut_off_automation/OUT" \
  -v "$ANSIBLE_DIR_HOST:/tmp/osl_cut_off_automation/ansible:ro" \
  $CONTAINER_IMAGE \
  bash -c '
    set -euo pipefail
    git config --global user.name "'"$GIT_USER_NAME"'"
    git config --global user.email "'$GIT_USER_EMAIL'"
    git config --global user.name
    git config --global user.email
    cd /tmp/osl_cut_off_automation/ansible
    ansible-playbook play__osl_cut_off.yml -e cloning_target_dir=/tmp/osl_cut_off_automation/OUT
  '
