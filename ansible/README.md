# Ansible (Ubuntu root layer)

This playbook is intentionally small and only handles **root/OS tasks** on Ubuntu 24+.
User preferences and dotfiles live in `dotfiles/`.

## Run locally
```bash
ansible-playbook --ask-become-pass -e user=$USER -i inventory.ini playbook-local.yaml
```

## Roles
- `system-base`: base packages (curl, git, tmux, zsh, etc.).
- `dev-tools`: optional CLI tools (btop, ripgrep, fd, bat, eza, delta, jq).
- `vscode`: Visual Studio Code install (enabled by default).
- `security`: UFW with sensible defaults (deny incoming, allow OpenSSH).
- `firmware`: fwupd for firmware updates.
- `docker`: Docker Engine + Compose with sane defaults.
- `battery`: power tuning (TLP + powertop), with Dell-specific settings.
- `gnome`: terminal profile defaults via dconf (optional).

## Playbooks
- `playbook-local.yaml`: core OS setup (includes VS Code).
- `playbook-personal.yaml`: personal extras (wine, retroarch).

## Config
`config.yaml` provides role settings:
- `battery.enable_dell` enables Dell-specific charge thresholds.
- `obsidian.update_vault` optionally updates the vault repo.

Add or remove roles in `playbook-local.yaml` as needed.
