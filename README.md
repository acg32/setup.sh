# Setup (Laptop)

Pragmatic setup for a daily-driver Ubuntu 24+ laptop.
The host stays stable; experiments live in sandboxes.

## Architecture
1. **System / root (Ansible)**: OS packages, services, drivers, power tuning.
2. **User environment (dotfiles)**: portable config (zsh, git, tmux, nvim).
3. **Workloads (Docker)**: disposable containers for experiments.

## Project layout
- `ansible/`: root-only playbooks and roles (Ubuntu).
- `dotfiles/`: portable user config + install script.
- `testing_env/`: Vagrant VM to validate Ansible.
- `extras/`: optional, OS-specific extras.
- `utils/`: shell helpers used by scripts.

## Quick start
### 1) Install uv + Ansible and apply OS changes
```bash
./bootstrap.sh
ansible-playbook --ask-become-pass -e user=$USER -i ansible/inventory.ini ansible/playbook-local.yaml
```

Optional: enable `dev-tools` or `vscode` roles in `ansible/playbook-local.yaml`.

### 2) Install dotfiles
```bash
cd dotfiles
make install
```

### 3) Test in VM (optional)
```bash
cd testing_env
vagrant up
ansible-playbook -i hosts ../ansible/playbook-local.yaml --ask-become-pass -e user=$USER
vagrant halt
```

## Docker conventions
- Use containers for experiments; keep the host clean.
- Bind-mount code from the host.
- Treat containers as disposable; no important data inside.
