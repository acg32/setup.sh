# Ansible (Ubuntu laptop + Debian/Ubuntu VM root layer)

Laptop playbooks target **Ubuntu 24+** only. The `vm` playbook also accepts
**Debian 12+**. User preferences and dotfiles live in `dotfiles/`.

## Run locally
```bash
ansible-playbook --ask-become-pass -e user=$USER -i inventory.ini playbook-base.yaml
```

`make ansible-*` auto-skips `--ask-become-pass` when passwordless sudo works
(`sudo -n true`). Force either mode with `ASK_BECOME=1` or `ASK_BECOME=0`.

## Roles
- `preflight`: asserts Ubuntu 24+ for laptop playbooks; for `setup_target=vm`
  allows Ubuntu 24+ or Debian 12+ (soft note on non-laptop chassis).
- `system-base`: base packages (curl, git, tmux, zsh, etc.).
- `dev-tools`: optional CLI tools (btop, ripgrep, fd, bat, eza, delta, jq, starship, neovim).
- `vscode`: Visual Studio Code install (enabled by default).
- `security`: UFW with sensible defaults (deny incoming, allow OpenSSH).
- `firmware`: fwupd for firmware updates.
- `updates`: unattended-upgrades (optional).
- `docker`: Docker Engine + Compose (Ubuntu or Debian apt repos).
- `battery`: power tuning (TLP + powertop), with Dell-specific settings.
- `gnome`: terminal profile defaults via dconf (optional).
- `summary`: prints a short role summary at the end.

## Playbooks
- `playbook-base.yaml`: core OS setup (includes VS Code, security, firmware).
- `playbook-ux.yaml`: optional UX defaults (dev-tools, gnome, battery).
- `playbook-workloads.yaml`: Docker only.
- `playbook-personal.yaml`: personal extras (wine, retroarch).
- `playbook-vm.yaml`: VM tooling on Ubuntu 24+ or Debian 12+ (base +
  CLI/dev-tools only; no vscode/Chrome/zram/UFW/Docker/Node/nvidia/gnome/
  battery/firmware).
- `playbook-local.yaml`: alias for base.

## Config
`config.yaml` provides role settings:
- `battery.enable_dell` enables Dell-specific charge thresholds.
- `battery.use_power_profiles_daemon` switches from TLP to GNOME power profiles.
- `nvidia.enable` toggles the NVIDIA role in base playbook.
- `nvidia.prime_profile` sets PRIME mode (intel|nvidia|on-demand).
- `obsidian.update_vault` optionally updates the vault repo.

Add or remove roles in `playbook-local.yaml` as needed.
