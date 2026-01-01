#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-full}"
OS_NAME="$(uname -s)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

link_file() {
    src="$1"
    dest="$2"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv "$dest" "${dest}.bak.$(date +%Y%m%d%H%M%S)"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
}

seed_gitconfig_local() {
    if [ ! -f "$HOME/.gitconfig.local" ] && [ -f "$ROOT/git/gitconfig.local.example" ]; then
        cp "$ROOT/git/gitconfig.local.example" "$HOME/.gitconfig.local"
    fi
}

install_common() {
    link_file "$ROOT/git/gitconfig" "$HOME/.gitconfig"
    link_file "$ROOT/git/ignore" "$HOME/.config/git/ignore"
    link_file "$ROOT/zsh/zshrc" "$HOME/.zshrc"
    link_file "$ROOT/zshenv" "$HOME/.zshenv"
    link_file "$ROOT/vim/vimrc" "$HOME/.vimrc"
    link_file "$ROOT/vim/colors" "$HOME/.vim/colors"
    link_file "$ROOT/shellcheckrc" "$HOME/.shellcheckrc"
    link_file "$ROOT/inputrc" "$HOME/.inputrc"
    link_file "$ROOT/editorconfig" "$HOME/.editorconfig"
    seed_gitconfig_local
}

install_full() {
    link_file "$ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
    link_file "$ROOT/nvim/init.lua" "$CONFIG_HOME/nvim/init.lua"
    link_file "$ROOT/nvim/lua" "$CONFIG_HOME/nvim/lua"
    link_file "$ROOT/starship/starship.toml" "$CONFIG_HOME/starship.toml"
    link_file "$ROOT/aliases" "$CONFIG_HOME/aliases"
    link_file "$ROOT/btop/btop.conf" "$CONFIG_HOME/btop/btop.conf"
    link_file "$ROOT/bat/config" "$CONFIG_HOME/bat/config"
    link_file "$ROOT/rg/rg.conf" "$CONFIG_HOME/rg/rg.conf"
    link_file "$ROOT/fd/ignore" "$CONFIG_HOME/fd/ignore"
    link_file "$ROOT/less/lesskey" "$CONFIG_HOME/less/lesskey"
}

case "$MODE" in
    minimal)
        install_common
        ;;
    linux)
        install_common
        install_full
        ;;
    macos)
        install_common
        install_full
        ;;
    full)
        install_common
        install_full
        ;;
    *)
        echo "Unknown mode: $MODE" >&2
        echo "Usage: $0 [full|minimal|linux|macos]" >&2
        exit 1
        ;;
esac

printf "Dotfiles installed (%s on %s)\n" "$MODE" "$OS_NAME"
