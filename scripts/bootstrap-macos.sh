#!/bin/bash
# Bootstrap Homebrew and uv for the macOS setup path.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This bootstrap targets macOS only." >&2
    exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
    echo "Installing the Xcode Command Line Tools."
    echo "Complete the macOS prompt, then rerun 'make install'."
    xcode-select --install
    exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
    installer="$(mktemp "${TMPDIR:-/tmp}/homebrew-install.XXXXXX")"
    trap 'rm -f "$installer"' EXIT
    curl --fail --silent --show-error --location \
        --proto '=https' --tlsv1.2 \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
        --output "$installer"
    NONINTERACTIVE=1 /bin/bash "$installer"
fi

if command -v brew >/dev/null 2>&1; then
    brew_bin="$(command -v brew)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
    brew_bin=/opt/homebrew/bin/brew
elif [[ -x /usr/local/bin/brew ]]; then
    brew_bin=/usr/local/bin/brew
else
    echo "Homebrew installation completed, but brew was not found." >&2
    exit 1
fi

brew_prefix="$("$brew_bin" --prefix)"
export PATH="$brew_prefix/bin:$brew_prefix/sbin:$PATH"

if ! command -v uv >/dev/null 2>&1; then
    "$brew_bin" install uv
fi

brew --version
uv --version
