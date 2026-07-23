# Progress Log

## 2026-07-22
- Assessed missing live command-line highlighting on this macOS laptop.
- Confirmed root cause: `30-plugins.zsh` gates highlighting on Oh My Zsh, but OMZ is not installed and Brewfiles do not ship `zsh-syntax-highlighting` / `zsh-autosuggestions`.
- Added Homebrew formulas and direct, optional loading so the plugins work with or without Oh My Zsh.
- Added fzf-tab completion and zsh substring history search to the macOS profile and interactive config.
- Reworked bin installation to link only the four tracked Git helpers and migrated uv/Cursor-generated tools out of the repository.

## 2026-07-16
- Added Homebrew manifests matching the active base, UX, workloads, and personal setup profiles.
- Routed bootstrap, package targets, and dotfiles by operating system while preserving the Ubuntu Ansible path.
- Added Homebrew fzf shell integration and documented intentional macOS package differences.
- Added Starship to the macOS UX manifest so the linked prompt configuration is activated.
- Added Zsh prefix-history search bindings for the up and down arrow keys.
- Added a managed Ghostty configuration using AdwaitaMono Nerd Font and pragmatic macOS defaults.

## 2026-05-06
- Investigated `apt update` warnings from local apt sources.
- Identified duplicate Docker repository declarations in both `docker.list` and `docker.sources`.
- Updated the Docker role to remove the legacy `docker.list` file before managing the deb822 source.
- Updated the dev-tools role to replace the unpinned NodeSource source with an `amd64`-pinned entry for machines with `i386` enabled.

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
