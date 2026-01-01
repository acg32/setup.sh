# Completion (fast + cached)
autoload -Uz compinit
zmodload -i zsh/complist

compdump_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
if [[ ! -d "$compdump_dir" ]]; then
    mkdir -p "$compdump_dir"
fi

compdump="${ZSH_COMPDUMP:-$compdump_dir/zcompdump}"
compinit -d "$compdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$compdump_dir"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

if [[ -n "${LS_COLORS:-}" ]]; then
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi
