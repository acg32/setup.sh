# macOS packages

The macOS setup mirrors the intent of the Ubuntu profiles with Homebrew. It
does not run the Ubuntu-only Ansible roles.

## Profiles

- `base`: curl, fzf, git, GnuPG, htop, tmux, tree, and Visual Studio Code.
- `ux`: Neovim, Node.js 24, bat, btop, eza, fd, git-delta, jq, ripgrep,
  Starship, zsh autosuggestions, zsh syntax highlighting, and Fira Code.
- `workloads`: Docker Desktop.
- `personal`: RetroArch.
- `full`: base, UX, and workloads.

Run the guided installer from the repository root:

```bash
make install
```

The corresponding noninteractive package targets are `make brew-base`,
`make brew-ux`, `make brew-workloads`, and `make brew-personal`.

## Intentional differences

macOS already provides certificates, OpenSSH, zsh, and the Xcode Command Line
Tools, so those are not duplicated in the Brewfiles. The installer skips
GNOME configuration and Linux-only zram, NVIDIA, battery, firewall, and
firmware tooling because they have no direct package-equivalent on macOS.

Docker uses Docker Desktop rather than a systemd-managed daemon. Wine is
intentionally omitted: Homebrew's general Wine casks are deprecated and
scheduled to be disabled, while the remaining macOS options are
application-specific or commercial.
