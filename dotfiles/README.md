# Dotfiles (portable user layer)

These files are meant to work on Ubuntu 24+, macOS, and SSH servers.
Nothing here requires root or a specific OS.

## Install
```bash
make install
```

## Minimal install (SSH-safe)
```bash
make minimal
```

## Notes
- User identity lives in `~/.gitconfig.local` (auto-seeded on first install).
- Optional tools (starship, oh-my-zsh, fzf, delta, ripgrep, fd, bat, eza, jq) are used when present.
- Existing dotfiles are backed up with a `.bak.<timestamp>` suffix before linking.
- Vim users get `~/.vimrc` + `~/.vim/colors` with a built-in colorscheme.
- Optional aliases live in `~/.config/aliases/`.
