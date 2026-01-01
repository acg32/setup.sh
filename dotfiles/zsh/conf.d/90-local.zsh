# Aliases and per-machine overrides
if [[ -f "$HOME/.config/aliases/common.sh" ]]; then
    safe_source "$HOME/.config/aliases/common.sh"
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
    safe_source "$HOME/.zshrc.local"
fi
