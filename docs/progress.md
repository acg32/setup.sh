# Progress Log

## 2026-02-08
- Fixed `make report` by restoring execute permissions on `scripts/system_report.sh`.
- Removed redundant `~/.local/bin` insertion from `dotfiles/zsh/conf.d/00-core.zsh` to avoid PATH duplication.
- Made CUDA library path handling idempotent in `dotfiles/zsh/conf.d/80-toolchain.zsh` using Zsh unique array semantics for `LD_LIBRARY_PATH`.
- Verified with a fresh report run that `make report` executes correctly.
