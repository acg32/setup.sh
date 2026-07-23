# Optional profiling (enable with ZSH_PROFILE=1)
if [[ -n "${ZSH_PROFILE:-}" ]]; then
    zmodload zsh/zprof
fi

# Small helpers for optional tooling
has() { command -v "$1" >/dev/null 2>&1; }
safe_source() { local file="$1"; [[ -r "$file" ]] && source "$file"; }

# Fall back to a widely available terminfo when the terminal's own entry is
# missing (common over SSH: e.g. Ghostty's xterm-ghostty on a minimal server).
# A missing entry breaks ZLE redraws, so zsh-syntax-highlighting duplicates
# typed characters ("ls" -> "llsls").
if has infocmp && [[ "$TERM" != dumb && "$TERM" != linux ]] \
    && ! infocmp "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

# PATH and editor defaults
typeset -U path PATH
export PATH

if has nvim; then
    export EDITOR="nvim"
elif has vim; then
    export EDITOR="vim"
fi

# Less defaults when lesskey is present
if [[ -f "$HOME/.config/less/lesskey" || -f "$HOME/.lesskey" ]]; then
    export LESS="-RFX"
fi
