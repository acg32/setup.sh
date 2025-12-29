# Ansible (Ubuntu root layer)

This playbook is intentionally small and only handles **root/OS tasks** on Ubuntu 24+.
User preferences and dotfiles live in `dotfiles/`.

## Run locally
```bash
ansible-playbook --ask-become-pass -e user=$USER -i inventory.ini playbook-base.yaml
```

## Roles
- `preflight`: asserts Ubuntu 24+ and warns on non-laptop chassis.
- `system-base`: base packages (curl, git, tmux, zsh, etc.).
- `dev-tools`: optional CLI tools (btop, ripgrep, fd, bat, eza, delta, jq).
- `vscode`: Visual Studio Code install (enabled by default).
- `security`: UFW with sensible defaults (deny incoming, allow OpenSSH).
- `firmware`: fwupd for firmware updates.
- `updates`: unattended-upgrades (optional).
- `docker`: Docker Engine + Compose with sane defaults.
- `battery`: power tuning (TLP + powertop), with Dell-specific settings.
- `gnome`: terminal profile defaults via dconf (optional).
- `summary`: prints a short role summary at the end.

## Playbooks
- `playbook-base.yaml`: core OS setup (includes VS Code, security, firmware).
- `playbook-ux.yaml`: optional UX defaults (dev-tools, gnome, battery).
- `playbook-workloads.yaml`: Docker only.
- `playbook-personal.yaml`: personal extras (wine, retroarch).
- `playbook-local.yaml`: alias for base.

## Config
`config.yaml` provides role settings:
- `battery.enable_dell` enables Dell-specific charge thresholds.
- `battery.use_power_profiles_daemon` switches from TLP to GNOME power profiles.
- `obsidian.update_vault` optionally updates the vault repo.

Add or remove roles in `playbook-local.yaml` as needed.
