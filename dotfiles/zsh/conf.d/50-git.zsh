# Git log sugar (interactive)
git() {
    if [ "${1:-}" = "log" ] && command -v git-fancy-log >/dev/null 2>&1; then
        shift
        git-fancy-log "$@"
        return
    fi
    command git "$@"
}

gcd() {
    local root
    root="$(command git rev-parse --show-toplevel 2>/dev/null)" || return 1
    cd "$root" || return 1
}
