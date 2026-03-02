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

echo print 1
ls -la $ANSIBLE_DIR_HOST
echo print 2
docker run --rm -v $ANSIBLE_DIR_HOST:/tmp/x $CONTAINER_IMAGE ls -la /tmp/x
echo "ANSIBLE_DIR_HOST=$ANSIBLE_DIR_HOST"

#if [[ ! -d "$CLONE_OUT_HOST" ]]; then
#  echo "Host directory CLONE_OUT_HOST does not exist: $CLONE_OUT_HOST"
#  exit 1
#fi
#
#if [[ ! -d "$ANSIBLE_DIR_HOST" ]]; then
#  echo "Host directory ANSIBLE_DIR_HOST does not exist: $ANSIBLE_DIR_HOST"
#  exit 1
#fi
#echo qwert
#ls -la $ANSIBLE_DIR_HOST
#
#if [[ ! -f "$SSH_KEY_LOCATION" ]]; then
#  echo "SSH key not found: $SSH_KEY_LOCATION"
#  exit 1
#fi
#
#
## prepare configuration for git
#TMP_SSH_DIR=$(mktemp -d)
#chmod 700 "$TMP_SSH_DIR"
#
## copy ssh private key
#cp "$SSH_KEY_LOCATION" "$TMP_SSH_DIR/id_rsa"
#chmod 600 "$TMP_SSH_DIR/id_rsa"
#
#ssh-keyscan github.com >> "$TMP_SSH_DIR/known_hosts" 2>/dev/null
#GIT_SSH_COMMAND="ssh -i $TMP_SSH_DIR/id_rsa -o UserKnownHostsFile=$TMP_SSH_DIR/known_hosts -o StrictHostKeyChecking=yes"
#
#export ANSIBLE_DIR_HOST=$ANSIBLE_DIR_HOST
#echo xxx1
#echo "${ANSIBLE_DIR_HOST}:/tmp/osl_cut_off_automation/ansible:ro"
#ls -la ${ANSIBLE_DIR_HOST}
#docker run --rm \
#  -e GIT_SSH_COMMAND="$GIT_SSH_COMMAND" \
#  -v "${TMP_SSH_DIR}:${TMP_SSH_DIR}:ro" \
#  -v "${CLONE_OUT_HOST}:/tmp/osl_cut_off_automation/OUT" \
#  -v "${ANSIBLE_DIR_HOST}:/tmp/osl_cut_off_automation/ansible:ro" \
#  $CONTAINER_IMAGE \
#  ls -la /tmp/osl_cut_off_automation/ansible
##  bash -c '
##    set -euo pipefail
##
##    echo "Preparing SSH environment..."
##    # Setup git identities
##    git config --global user.name "pepa zdepa"
##    git config --global user.email "pepa@z.depa"
##
##    echo "Mounted clone directory:"
##    cd /tmp/osl_cut_off_automation/ansible
##    echo ...OUT
##    ls -la /tmp/osl_cut_off_automation/OUT
##
##    echo ..ansible
##    ls -la /tmp/osl_cut_off_automation/ansible
##
##
##    ansible-playbook play__osl_cut_off.yml -e cloning_target_dir=/tmp/osl_cut_off_automation/OUT
##  '