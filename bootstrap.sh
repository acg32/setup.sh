#!/bin/bash
# Bootstrapping script for local machine: git + uv + ansible
set -euo pipefail

function setup_uv() {
    sudo apt-get update
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
        git ca-certificates

    if ! command -v uv >/dev/null 2>&1; then
        curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
        sh /tmp/uv-install.sh
    fi

    # Final setup for the user
    set +x
    echo "**************************"
    echo "--------------------"
    echo "To finalize install:"
    echo "--------------------"
    echo "exec $SHELL"
    echo "uv --version"
    echo "--------------------"
    echo "Install Python:"
    echo "--------------------"
    echo "uv python install 3.12"
    echo "uv venv --python 3.12 .venv"
    echo "python --version && which python"
    echo "**************************"
}

function setup_ansible() {
    # Bins will be at ~/.local/bin
    if ! command -v ansible >/dev/null 2>&1; then
        uv tool install ansible
    fi
    command -v ansible && ansible --version
}

# If shellcheck blocks on this, you need to add -x arg to it
source utils/colors.sh
source utils/display.sh
announce_fn setup_uv

announce_fn setup_ansible
