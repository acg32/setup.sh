# Language/toolchain helpers
if [[ -d "$HOME/.cargo" && -f "$HOME/.cargo/env" ]]; then
    safe_source "$HOME/.cargo/env"
fi

if [[ -d "/usr/local/cuda/bin" ]]; then
    path=("/usr/local/cuda/bin" $path)
fi

if [[ -d "/usr/local/cuda/lib64" ]]; then
    # Tie colon-delimited env var to array, then enforce uniqueness.
    typeset -TUx LD_LIBRARY_PATH ld_library_path :
    typeset -U ld_library_path
    ld_library_path=("/usr/local/cuda/lib64" $ld_library_path)
    export LD_LIBRARY_PATH
fi

if [[ -d "/opt/dell/dcc" ]]; then
    path=("/opt/dell/dcc" $path)
fi

if [[ -d "$HOME/gems" ]]; then
    export GEM_HOME="$HOME/gems"
    path=("$HOME/gems/bin" $path)
fi
