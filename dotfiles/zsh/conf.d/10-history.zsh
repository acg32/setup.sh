# History settings
hist_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
if [[ ! -d "$hist_dir" ]]; then
    mkdir -p "$hist_dir"
fi

HISTFILE="$hist_dir/history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt hist_expire_dups_first
setopt hist_find_no_dups
