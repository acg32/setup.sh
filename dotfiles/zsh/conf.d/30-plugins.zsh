# Oh My Zsh (optional)
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME=""
    DISABLE_UNTRACKED_FILES_DIRTY="true"
    plugins=(aliases zsh-autosuggestions zsh-syntax-highlighting fzf fzf-tab)
    safe_source "$ZSH/oh-my-zsh.sh"
fi

# fzf integration (optional)
brew_prefix="${HOMEBREW_PREFIX:-}"
if [[ -z "$brew_prefix" ]] && has brew; then
    brew_prefix="$(brew --prefix 2>/dev/null || true)"
fi

if has fzf; then
    if has rg; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
            cd)
                fzf "$@" --preview 'if command -v tree >/dev/null 2>&1; then tree -C {} | head -200; else ls -la {}; fi'
                ;;
            vim|nvim)
                fzf "$@" --preview 'if command -v bat >/dev/null 2>&1; then bat --style=numbers --color=always --line-range :500 {}; elif command -v batcat >/dev/null 2>&1; then batcat --style=numbers --color=always --line-range :500 {}; else sed -n "1,200p" {}; fi'
                ;;
            *)
                fzf "$@"
                ;;
        esac
    }

    fzf_prefix="${brew_prefix:+$brew_prefix/opt/fzf}"

    if [[ -n "$fzf_prefix" && -f "$fzf_prefix/shell/key-bindings.zsh" ]]; then
        safe_source "$fzf_prefix/shell/key-bindings.zsh"
    elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        safe_source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi
    if [[ -n "$fzf_prefix" && -f "$fzf_prefix/shell/completion.zsh" ]]; then
        safe_source "$fzf_prefix/shell/completion.zsh"
    elif [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
        safe_source /usr/share/doc/fzf/examples/completion.zsh
    fi
fi

# Completion and history plugins (also work without Oh My Zsh)
if [[ -n "$brew_prefix" ]]; then
    fzf_tab_prefix="$brew_prefix/opt/fzf-tab"
    history_substring_prefix="$brew_prefix/opt/zsh-history-substring-search"
    safe_source "$fzf_tab_prefix/share/fzf-tab/fzf-tab.zsh"
    safe_source "$history_substring_prefix/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
    if typeset -f history-substring-search-up >/dev/null 2>&1; then
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
    fi
fi

# Homebrew autosuggestions (also work without Oh My Zsh)
if [[ -n "$brew_prefix" ]]; then
    zsh_autosuggestions_prefix="$brew_prefix/opt/zsh-autosuggestions"
    if ! typeset -f _zsh_autosuggest_start >/dev/null 2>&1; then
        safe_source "$zsh_autosuggestions_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi
fi
