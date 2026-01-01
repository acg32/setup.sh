# Language/toolchain helpers
if [[ -d "$HOME/.cargo" && -f "$HOME/.cargo/env" ]]; then
    safe_source "$HOME/.cargo/env"
fi

if [[ -d "/usr/local/cuda/bin" ]]; then
    path=("/usr/local/cuda/bin" $path)
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}"
fi

if [[ -d "/opt/dell/dcc" ]]; then
    path=("/opt/dell/dcc" $path)
fi

if [[ -d "$HOME/gems" ]]; then
    export GEM_HOME="$HOME/gems"
    path=("$HOME/gems/bin" $path)
fi

# Node (optional, lazy-loaded)
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    _nvm_load() {
        # shellcheck disable=SC1090
        safe_source "$NVM_DIR/nvm.sh"
        # shellcheck disable=SC1090
        safe_source "$NVM_DIR/bash_completion"
    }

    nvm() {
        unset -f nvm node npm npx
        _nvm_load
        nvm "$@"
    }

    node() {
        unset -f nvm node npm npx
        _nvm_load
        node "$@"
    }

    npm() {
        unset -f nvm node npm npx
        _nvm_load
        npm "$@"
    }

    npx() {
        unset -f nvm node npm npx
        _nvm_load
        npx "$@"
    }
fi
