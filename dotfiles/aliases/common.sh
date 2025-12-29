# Common aliases for all machines
alias setup="cd ~/code/setup.sh"

# Aliases with eza
alias l='eza -lah --color=always --icons --group-directories-first' # with headers
alias la='eza -al --color=always --icons --group-directories-first'  # all files and dirs
alias ll='eza -l --color=always --icons --group-directories-first'  # long format
alias lt='eza -aT --color=always --icons --group-directories-first' # tree listing

# Aliases with fzf: with preview
alias fzp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
