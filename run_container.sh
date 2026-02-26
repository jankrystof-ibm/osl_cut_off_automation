#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_DIR="$(dirname $(realpath "$0"))"

# Required/optional environment variables:
#   CLONE_OUT_HOST (required)
#   CLONE_OUT_CONTAINER (optional)
#   SSH_KEY_LOCATION (required)

: "${CLONE_OUT_HOST:?CLONE_OUT_HOST is not set}"
: "${SSH_KEY_LOCATION:?SSH_KEY_LOCATION is not set}"
: "${ANSIBLE_DIR_HOST:=$THIS_SCRIPT_DIR/ansible}"


ls $ANSIBLE_DIR_HOST

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

docker run --rm \
  -v "${CLONE_OUT_HOST}:/tmp/osl_cut_off/OUT" \
  -v "${ANSIBLE_DIR_HOST}:/tmp/osl_cut_off/ansible:ro" \
  -v "${SSH_KEY_LOCATION}:/tmp/osl_cut_off/ci_ssh_key:ro" \
  able/automation_osl_cutoff:latest \
  bash -c '
    set -euo pipefail

    echo "Preparing SSH environment..."

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    # Copy key into proper location
    cp /tmp/osl_cut_off/ci_ssh_key ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
	
	# Add GitHub to known_hosts
	ssh-keyscan github.com >> ~/.ssh/known_hosts
	chmod 644 ~/.ssh/known_hosts

    # Start ssh-agent
    eval "$(ssh-agent -s)"

    # Add key
    ssh-add ~/.ssh/id_ed25519

    echo "Loaded SSH identities:"
    ssh-add -l

    echo "Mounted clone directory:"
    cd /tmp/osl_cut_off/ansible
    ansible-playbook play__osl_cut_off.yml -e cloning_target_dir=/tmp/osl_cut_off/OUT


	#git -C /tmp/osl_cut_off/OUT clone git@github.com:kubesmarts/osl-images
  '
  