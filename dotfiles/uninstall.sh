#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

remove_link() {
    dest="$1"

    if [ -L "$dest" ]; then
        target="$(readlink "$dest")"
        case "$target" in
            "$ROOT"/*)
                rm -f "$dest"
                ;;
        esac
    fi
}

restore_backup() {
    dest="$1"
    latest="$(ls -1 "${dest}".bak.* 2>/dev/null | tail -n 1 || true)"
    if [ -n "$latest" ] && [ ! -e "$dest" ]; then
        mv "$latest" "$dest"
    fi
}

remove_link "$HOME/.gitconfig"
remove_link "$HOME/.config/git/ignore"
remove_link "$HOME/.local/bin"
remove_link "$HOME/.zshrc"
remove_link "$HOME/.vimrc"
remove_link "$HOME/.vim/colors"
remove_link "$HOME/.shellcheckrc"
remove_link "$HOME/.inputrc"
remove_link "$HOME/.tmux.conf"
remove_link "$CONFIG_HOME/nvim/init.lua"
remove_link "$CONFIG_HOME/nvim/lua"
remove_link "$CONFIG_HOME/starship.toml"
remove_link "$CONFIG_HOME/aliases"
remove_link "$CONFIG_HOME/btop/btop.conf"
remove_link "$CONFIG_HOME/bat/config"
remove_link "$CONFIG_HOME/rg/rg.conf"
remove_link "$CONFIG_HOME/fd/ignore"
remove_link "$CONFIG_HOME/less/lesskey"

restore_backup "$HOME/.gitconfig"
restore_backup "$HOME/.zshrc"
restore_backup "$HOME/.vimrc"
restore_backup "$HOME/.tmux.conf"
restore_backup "$CONFIG_HOME/nvim/init.vim"
restore_backup "$CONFIG_HOME/starship.toml"
restore_backup "$HOME/.shellcheckrc"
restore_backup "$HOME/.inputrc"

printf "Dotfiles removed; backups restored when available.\n"
