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
- `utils/`: shell helpers used by scripts.

## Quick start
### 1) Install uv + Ansible and apply OS changes
```bash
./bootstrap.sh
make ansible-base
```

Optional:
- `make ansible-ux` (dev-tools, gnome, battery)
- `make ansible-workloads` (docker)
- `make ansible-personal` (wine, retroarch)

### 2) Install dotfiles
```bash
make dotfiles
```

### 3) Test in VM (optional)
```bash
cd testing_env
vagrant up
ansible-playbook -i hosts ../ansible/playbook-local.yaml --ask-become-pass -e user=$USER
vagrant halt
```

### 4) Personal extras (optional)
```bash
make ansible-personal
```

## Make targets
- `make bootstrap`: install uv + Ansible (one-time setup).
- `make ansible-base`: core OS setup (Ubuntu 24+).
- `make ansible-ux`: optional UX defaults.
- `make ansible-workloads`: Docker only.
- `make ansible-personal`: personal extras.
- `make dotfiles`: link dotfiles.
- `make verify`: check dotfile symlinks.

## Docker conventions
- Use containers for experiments; keep the host clean.
- Bind-mount code from the host.
- Treat containers as disposable; no important data inside.

## Docs
See `docs/README.md` for the full docs index.
