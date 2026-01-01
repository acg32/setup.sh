#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

color() {
    code="$1"
    shift
    printf "\033[%sm%s\033[0m\n" "$code" "$*"
}

check_link() {
    src="$1"
    dest="$2"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        color "1;32" "✅  $dest → $src"
    else
        color "1;31" "❌  $dest (missing)"
    fi
}

color "1;36" "✨ Dotfiles link check ✨"

check_link "$ROOT/git/gitconfig" "$HOME/.gitconfig"
check_link "$ROOT/git/ignore" "$HOME/.config/git/ignore"
check_link "$ROOT/bin" "$HOME/.local/bin"
check_link "$ROOT/zsh/zshrc" "$HOME/.zshrc"
check_link "$ROOT/zshenv" "$HOME/.zshenv"
check_link "$ROOT/vim/vimrc" "$HOME/.vimrc"
check_link "$ROOT/vim/colors" "$HOME/.vim/colors"
check_link "$ROOT/shellcheckrc" "$HOME/.shellcheckrc"
check_link "$ROOT/inputrc" "$HOME/.inputrc"
check_link "$ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
check_link "$ROOT/nvim/init.lua" "$CONFIG_HOME/nvim/init.lua"
check_link "$ROOT/nvim/lua" "$CONFIG_HOME/nvim/lua"
check_link "$ROOT/starship/starship.toml" "$CONFIG_HOME/starship.toml"
check_link "$ROOT/aliases" "$CONFIG_HOME/aliases"
check_link "$ROOT/btop/btop.conf" "$CONFIG_HOME/btop/btop.conf"
check_link "$ROOT/bat/config" "$CONFIG_HOME/bat/config"
check_link "$ROOT/rg/rg.conf" "$CONFIG_HOME/rg/rg.conf"
check_link "$ROOT/fd/ignore" "$CONFIG_HOME/fd/ignore"
check_link "$ROOT/less/lesskey" "$CONFIG_HOME/less/lesskey"
check_link "$ROOT/less/lesskey" "$HOME/.lesskey"
