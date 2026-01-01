# Oh My Zsh (optional)
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME=""
    DISABLE_UNTRACKED_FILES_DIRTY="true"
    plugins=(aliases zsh-autosuggestions zsh-syntax-highlighting fzf fzf-tab)
    safe_source "$ZSH/oh-my-zsh.sh"
fi

# fzf integration (optional)
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

    if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        safe_source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi
    if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
        safe_source /usr/share/doc/fzf/examples/completion.zsh
    fi
fi
