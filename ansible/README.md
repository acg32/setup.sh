# Ansible (Ubuntu root layer)

This playbook is intentionally small and only handles **root/OS tasks** on Ubuntu 24+.
User preferences and dotfiles live in `dotfiles/`.

## Run locally
```bash
ansible-playbook --ask-become-pass -e user=$USER -i inventory.ini playbook-local.yaml
```

## Roles
- `system-base`: base packages (curl, git, tmux, zsh, etc.).
- `dev-tools`: optional CLI tools (ripgrep, fd, bat, eza, delta, jq).
- `vscode`: optional Visual Studio Code install.

Add or remove roles in `playbook-local.yaml` as needed.
