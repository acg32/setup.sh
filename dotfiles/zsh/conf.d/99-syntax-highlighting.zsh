# Keep syntax highlighting last: it wraps the ZLE widgets configured above.
brew_prefix="${HOMEBREW_PREFIX:-}"
if [[ -z "$brew_prefix" ]] && has brew; then
    brew_prefix="$(brew --prefix 2>/dev/null || true)"
fi

if [[ -n "$brew_prefix" && -z "${ZSH_HIGHLIGHT_VERSION:-}" ]]; then
    safe_source "$brew_prefix/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
