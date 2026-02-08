# Progress Log

## 2026-02-08
- Fixed `make report` by restoring execute permissions on `scripts/system_report.sh`.
- Removed redundant `~/.local/bin` insertion from `dotfiles/zsh/conf.d/00-core.zsh` to avoid PATH duplication.
- Made CUDA library path handling idempotent in `dotfiles/zsh/conf.d/80-toolchain.zsh` using Zsh unique array semantics for `LD_LIBRARY_PATH`.
- Verified with a fresh report run that `make report` executes correctly.
- Upgraded `scripts/setup.py` into a clearer guided wizard while staying Python-native (`questionary + rich`).
- Added profile metadata (description, targets, ETA, recommended flag) and rendered a pre-selection profile guide table.
- Improved execution UX with numbered plan output, selected-profile summary, ETA hint, per-step runtime, and total runtime in final success panel.
- Kept CLI compatibility for existing automation flags (`--profile`, `--dotfiles`, `--yes`, `--dry-run`).
- Added custom `questionary` color styling to make interactive selection/confirmation prompts more expressive.
- Styled prompt UI elements (qmark, question, pointer, highlighted item, selected marker, answer, instruction, disabled text).
