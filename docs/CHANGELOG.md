# Changelog

## Unreleased
- Enabled the active Kubernetes context and namespace in the shared Starship prompt.
- Added an untracked per-machine Zsh configuration directory for credentials and local shell integrations.
- Fixed macOS Zsh plugin loading when Homebrew cannot reach its package API.
- Fixed Zsh syntax highlighting hook order after prompt and local configuration.
- Fixed a Zsh plugin function-name collision that prevented syntax highlighting from loading.
- Added an optional directory-scoped Git identity and config for repositories under `~/work/`.
- Changed dotfiles bin installation to link only repository-owned helpers and preserve externally installed tools in `~/.local/bin`.
- Added Homebrew fzf-tab completion and substring-based history search.
- Added Homebrew zsh autosuggestions and live syntax highlighting to the macOS UX profile.
- Added profile-matched Homebrew setup and platform-aware install routing for macOS.
- Split Ansible playbooks by intent (base, UX, workloads, personal).
- Consolidated dotfiles and added QoL defaults (rg/fd/bat/less/inputrc).
- GNOME terminal profile captured and applied via Ansible.
- Added root Makefile and dotfiles verify/uninstall helpers.
- Added preflight checks and playbook summaries for safer runs.
- Added interactive setup CLI and Makefile target.
- Added editorconfig and local override hooks.
- Cleaned VS Code repo setup and pinned repo architectures to avoid apt i386 warnings.
- Removed legacy TLP PPA on Noble and normalized Google Chrome repo arch to avoid apt warnings.
- Added systemd zram generator setup (default 24G, lz4).
- Switched Docker to socket-activated on-demand daemon.
- Set NVIDIA PRIME to on-demand by default via nvidia role.
- Enabled NVIDIA role in base playbook (opt-out via nvidia.enable).

## Commit styleguide

- Use a playful, fanciful tone and keep it short.
- Include emojis in the subject line.
- Format: "<emoji> <whimsical verb>: <what changed>".
- Keep the subject under 72 characters; add a body only if needed.
