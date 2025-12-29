# Context: Laptop Setup Architecture & Tooling Philosophy

## High-level intent

This machine is **not a homelab server**.

It is a **daily-driver Linux laptop** (Ubuntu) used for:
- one-off deep learning experiments (CUDA, kernels, custom builds)
- systems / low-level development
- temporary web services (local or LAN)
- general software development

Key constraints:
- The host OS must remain **boring, stable, and safe**
- Experiments must be **isolated, disposable, and low-risk**
- No always-on services, no uptime guarantees
- No fleet management mindset

Guiding principle:
> The host is sacred. Everything interesting lives in sandboxes.

---

## Architectural layers (intentional split)

### Layer 1 — System / root (Ansible, Ubuntu only)

Scope:
- OS packages
- system services
- Docker installation
- firewall defaults
- laptop-specific tuning (battery, power, thermals)
- GPU drivers
- users / sudo

Properties:
- root only
- OS-specific (Ubuntu)
- not portable to macOS
- not meant for SSH servers
- small and boring on purpose

Tooling:
- Ansible, but minimal (few roles, no over-engineering)

Explicitly NOT here:
- vim config
- shell aliases
- git config
- developer UX or preferences

---

### Layer 2 — User environment (portable dotfiles)

Scope:
- zsh configuration
- vim / neovim
- git config
- tmux
- CLI UX (fzf, ripgrep, fd, bat, etc.)
- prompt, theme, editor ergonomics

Properties:
- works on:
  - Ubuntu laptop
  - macOS work laptop
  - random SSH servers
- no root required
- must degrade gracefully (optional tools)
- safe to `scp` or `git clone`

Design rules:
- detect OS at runtime (`uname`)
- avoid OS-specific full file templates
- prefer small conditionals inside shared config
- never fail hard if a tool is missing

Tooling choice:
- **Plain git dotfiles repo + Makefile**
- NOT chezmoi (felt too magical / heavy for needs)

---

### Layer 3 — Workloads (isolated execution)

Scope:
- deep learning experiments
- CUDA / GPU work
- experimental builds
- web apps / APIs
- databases for local dev

Properties:
- isolated from host
- disposable
- reproducible
- no important data inside containers

Tooling:
- Docker (rootful, simple)
- optionally LXC / systemd-nspawn later for heavier isolation

Explicitly not using:
- Kubernetes
- Swarm
- long-running infra

---

## Dotfiles philosophy (important)

Goals:
- same repo works on Ubuntu, macOS, SSH servers
- supports both “full” and “minimal” installs

Expected structure:
```

dotfiles/
├── zsh/
├── vim/ or nvim/
├── tmux/
├── git/
├── bin/
├── Makefile
├── install.sh

````

Expected install modes:
- `make install` → full local setup
- `make minimal` → SSH-safe setup
- `make macos`
- `make linux`

No secrets management required in dotfiles.

---

## Ansible philosophy (important)

Ansible is:
- for **root**
- for **Ubuntu laptop only**

Good use:
- install packages
- enable services
- firewall setup
- Docker daemon config
- battery / power tuning

Bad use:
- user shell config
- editor config
- developer taste
- anything needing portability

Target state:
- small playbook
- few roles
- easy to reason about
- reinstall OS → run Ansible → done

Sensible defaults:
- keep a single optional `dev-tools` role for common CLI niceties
- keep it off by default in the playbook
- never let it mutate user dotfiles or preferences

---

## Laptop-specific requirements

- battery life optimization when unplugged
- performance when plugged
- NVIDIA GPU present but not always used
- power tuning must NOT leak into dotfiles

Likely tools:
- tlp
- powertop
- systemd services
- kernel parameters

These belong strictly to Ansible.

---

## SSH server experience goal

Desired flow:
```bash
scp -r dotfiles user@server:~
ssh user@server
cd dotfiles && make minimal
````

Result:

* good-looking vim
* sensible defaults
* fast shell
* no assumptions about fonts, sudo, or system packages

---

## Non-goals / explicitly rejected

* Treating laptop as a real homelab
* Always-on services
* Kubernetes
* Ansible managing user dotfiles
* Heavy abstraction layers
* One tool to manage everything

---

## Next implementation steps (for the agent)

1. Design dotfiles repo (plain git) with:

   * zsh
   * vim or neovim
   * portable defaults
   * Makefile with install targets

2. Design minimal Ansible structure:

   * Ubuntu only
   * root tasks only
   * laptop power tuning isolated

3. Define Docker usage conventions:

   * disposable containers
   * no important data inside
   * bind-mount code from host

4. Keep host OS boring and recoverable.

---

## Current state (notes)

- Ansible is root-only and minimal; `system-base` is the default role.
- VS Code is enabled by default; additional roles are split across playbooks.
- Personal/taste roles live in `ansible/playbook-personal.yaml` (wine, retroarch).
- NVIDIA role installs drivers only; CUDA/cuDNN are intentionally excluded.
- Battery role uses distro TLP + powertop; Dell tuning is gated by `battery.enable_dell`.
- GNOME terminal profiles are managed by the `gnome` role via `dconf`.
- Dotfiles are consolidated into a single tree with a simple `install.sh` and sensible defaults.
- Preflight checks enforce Ubuntu 24+; playbooks end with a role summary.

## Direction (guiding decisions)

- Keep the host stable: only root/OS tasks in Ansible.
- Keep developer UX portable: dotfiles are plain files + symlinks, no magic.
- Keep workloads isolated: heavy stacks (CUDA, experiments) are not part of Ansible.
- Keep taste optional: anything personal is opt-in and easy to remove.
