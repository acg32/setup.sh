# ✨ Setup (Laptop) ✨

Pragmatic setup for Ubuntu 24+ and macOS development machines — clean, fast,
and calm.

---

## 🌟 One-command install (recommended)
```bash
make install
```
This bootstraps the platform package manager and launches the interactive
setup. Ubuntu uses Ansible; macOS uses profile-scoped Homebrew Brewfiles and
skips Linux-only system tuning. On a fresh macOS install, complete the Xcode
Command Line Tools prompt and rerun `make install`.

---

## 🎛️ Common commands
- `make install`: platform-aware bootstrap + interactive setup.
- `make setup`: run the interactive profile picker.
- `make dotfiles`: link dotfiles only.
- `make verify`: check dotfile symlinks.

---

## 📚 Docs
See `docs/README.md` for architecture, playbooks, and conventions.
