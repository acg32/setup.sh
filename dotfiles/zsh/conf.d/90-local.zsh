# Aliases and per-machine overrides
if [[ -f "$HOME/.config/aliases/common.sh" ]]; then
    safe_source "$HOME/.config/aliases/common.sh"
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
    safe_source "$HOME/.zshrc.local"
fi

# Per-machine configuration and credentials live outside this repository.
local_conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local"
for file in "$local_conf_dir"/*.zsh(N); do
    safe_source "$file"
done
