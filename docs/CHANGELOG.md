# Changelog

## Unreleased
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

## Commit styleguide

- Use a playful, fanciful tone and keep it short.
- Include emojis in the subject line.
- Format: "<emoji> <whimsical verb>: <what changed>".
- Keep the subject under 72 characters; add a body only if needed.
