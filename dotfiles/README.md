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

## Verify or uninstall
```bash
make verify
make uninstall
```

## Notes
- User identity lives in `~/.gitconfig.local` (auto-seeded on first install).
- Optional tools (starship, oh-my-zsh, fzf, delta, ripgrep, fd, bat, eza, jq) are used when present.
- Existing dotfiles are backed up with a `.bak.<timestamp>` suffix before linking.
- Vim users get `~/.vimrc` + `~/.vim/colors` with a built-in colorscheme.
- Optional aliases live in `~/.config/aliases/`.
- Global ignore file is linked to `~/.config/git/ignore`.
- Readline defaults are linked to `~/.inputrc`.
- Tool defaults are linked under `~/.config/` for `rg`, `fd`, `bat`, and `less`.
- Optional per-machine overrides:
  - `~/.vimrc.local`
  - `~/.config/nvim/init.local.vim`
  - `~/.zshrc.local`
