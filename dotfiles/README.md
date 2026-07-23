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
- Machine-wide Git identity and other private settings live in
  `~/.gitconfig.local` (auto-seeded on first install).
- Work repositories under `~/work/` can override those settings with
  `~/.gitconfig.work`:
  ```bash
  cp git/gitconfig.work.example ~/.gitconfig.work
  $EDITOR ~/.gitconfig.work
  ```
  Change `gitdir:~/work/` in `git/gitconfig` if work repositories live
  elsewhere. Git's `gitdir` match includes repositories in subdirectories.
- Optional tools (starship, oh-my-zsh, fzf, delta, ripgrep, fd, bat, eza, jq) are used when present.
- Starship links both `starship.toml` (laptop `aci`) and `starship.vm.toml`
  (gruvbox_dark + hostname). The `vm` setup profile seeds `STARSHIP_CONFIG` in
  `~/.zshenv.local` (must be set before prompt init; `~/.zshrc.local` loads too late).
- Existing dotfiles are backed up with a `.bak.<timestamp>` suffix before linking.
- Vim users get `~/.vimrc` + `~/.vim/colors` with a built-in colorscheme.
- Optional aliases live in `~/.config/aliases/`.
- Global ignore file is linked to `~/.config/git/ignore`.
- Readline defaults are linked to `~/.inputrc`.
- Tool defaults are linked under `~/.config/` for Ghostty, `rg`, `fd`, `bat`, and `less`.
- Ghostty uses the installed `AdwaitaMono Nerd Font` family.
- Optional per-machine overrides:
  - `~/.vimrc.local`
  - `~/.config/nvim/init.local.lua`
  - `~/.zshrc.local`
  - `~/.zshenv.local` (early; use for `STARSHIP_CONFIG` and PATH)
  - `~/.config/zsh/local/*.zsh` for machine-specific shell configuration and
    credentials (for example, `01-cohere.zsh`). This directory is deliberately
    outside the linked dotfiles tree and is never managed by Git.
