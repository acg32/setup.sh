# Progress Log

## 2026-11-18
- Added a Tailscale-served share on the cloud dev VM: one root, one folder per project, auto-generated index page.
  `scripts/share` (installed as `~/bin/share` on the VM) manages projects, live apps (own HTTPS port) and the index;
  `publish <project> <file|dir>...` (`dotfiles/zsh/conf.d/65-share.zsh`) rsyncs from the laptop and prints the URLs.
  Per-machine `SHARE_VM` (ssh alias) lives in `~/.config/zsh/local/share.zsh`, outside the repo.
- Registered the trainjob dashboard (:8765 -> https :8443) and the PR tracker (:8790 -> https :10000) as live apps.
- Fixed stale `/home/...` paths and the linux-amd64 binary in the opencode MCP config copied from the Linux VM.
- Not verified: behaviour after a VM reboot (relies on `tailscale serve --bg` persistence and the tmux sessions).

## 2026-07-23
- Added a Zsh terminfo guard: fall back to `xterm-256color` when the current
  `$TERM` has no terminfo entry, fixing duplicated input under Ghostty (whose
  `xterm-ghostty` entry is absent on the VM) once highlighting was enabled.
- Bound Ghostty's standard Forward Delete sequence (`^[[3~`) to Zsh's
  `delete-char` widget.
- Enabled Starship's Kubernetes module for both local and VM shells.
- Fixed Homebrew Zsh plugin loading to use local `opt/<formula>` paths rather than formula-specific `brew --prefix` lookups, which can fail when Homebrew cannot refresh its API.
- Moved syntax highlighting to the final Zsh config file so its ZLE hooks are registered after Starship and local overrides.
- Corrected the syntax-highlighting guard: history-substring-search defines an unrelated `_zsh_highlight` function.
- Added `~/.config/zsh/local/` for machine-specific Zsh snippets and credentials outside the dotfiles repository.

- Seeded bash→zsh handoff for Google OS Login (login shell stays bash; `chsh`
  cannot change NSS users).
- Allowed Debian 12+ (and Ubuntu 24+) on the `vm` profile; Docker repo URI
  follows `ansible_distribution`. Pinned local inventory to `/usr/bin/python3`.
- Made Ansible become prompting conditional: skip `--ask-become-pass` when
  `sudo -n` succeeds (typical GCP/cloud VMs); override with `ASK_BECOME=0|1`.
- Added Ubuntu VM setup path: `playbook-vm.yaml`, Makefile `ansible-vm`, and
  setup profile `vm` (system-base + CLI/dev-tools; skips vscode, Chrome, zram,
  UFW, Docker, and Node/npm).
- Added `starship.vm.toml` (gruvbox_dark palette + always-on hostname) and seed
  `STARSHIP_CONFIG` into `~/.zshenv.local` for the vm profile (zshenv loads
  before `40-prompt.zsh`; `~/.zshrc.local` would be too late).
- Installed Starship via GitHub release in Ansible `dev-tools` so Ubuntu prompt
  init stops silently no-oping when only the config was linked.
- Softened preflight non-laptop chassis messaging when `setup_target=vm`.

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
