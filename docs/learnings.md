# Learnings

## 2026-07-23
- Duplicated typed characters ("ls" -> "llsls") after enabling
  zsh-syntax-highlighting = a terminfo mismatch, not a highlighting bug.
  Highlighting redraws the line each keystroke; if `$TERM` has no terminfo
  entry, ZLE miscomputes the cursor and duplicates input. Ghostty sets
  `TERM=xterm-ghostty`, which minimal servers lack. Fall back to
  `xterm-256color` when `infocmp "$TERM"` fails (guarded by `has infocmp`).
- Ghostty's standard Forward Delete sequence is `^[[3~`; Zsh leaves it
  unbound by default, so bind it explicitly to `delete-char`.
- Starship's Kubernetes module is disabled by default; enable it explicitly and add `$kubernetes` to the prompt format to show the active context.
- Because `~/.config/zsh/conf.d` is a symlink into the repository, machine-local Zsh snippets need a sibling directory such as `~/.config/zsh/local/`, not another file under `conf.d`.
- `zsh-history-substring-search` also defines `_zsh_highlight`; use `ZSH_HIGHLIGHT_VERSION` to detect the syntax-highlighting plugin rather than testing that function name.
- `zsh-syntax-highlighting` must be sourced after every other ZLE-using configuration, including prompt frameworks and local overrides; loading it earlier can leave its library present without live highlighting.
- Calling `brew --prefix <formula>` from an interactive shell can trigger Homebrew API refreshes and fail in restricted networks. Resolve the Homebrew root once, then use its stable `opt/<formula>` symlinks to source installed plugins without network access.

- Google OS Login users are not in `/etc/passwd`, so `chsh` fails. Login
  shell stays `/bin/bash`. Fix: seed `~/.bashrc` with an interactive
  `exec /usr/bin/zsh -l` handoff (vm profile via setup.py).
- Cloud VMs: skip zram, host UFW, Docker, and Node/npm unless needed; keep
  CLI tooling (rg/fd/bat/starship/nvim). GCP VPC/IAP already firewalls.
- This onboarding VM is Debian 13, not Ubuntu. Laptop playbooks stay
  Ubuntu-only; `setup_target=vm` preflight must accept Debian 12+ or the
  profile is unusable on GCP Debian images. Docker apt URIs must use
  `linux/debian` (not ubuntu) when `ansible_distribution` is Debian.
- `--ask-become-pass` is for the *sudo* password, not SSH. GCP/IAP VMs often
  have NOPASSWD sudo; prompting then is useless. Detect with `sudo -n true`
  and skip the flag (override via `ASK_BECOME`).
- Ubuntu Ansible never installed Starship; linking `starship.toml` alone left
  `40-prompt.zsh` as a silent no-op. Install the binary in `dev-tools` (same
  lesson as macOS Brewfile.ux).
- VM vs laptop prompt cue: keep one layout, switch via `STARSHIP_CONFIG` + a
  second toml (`palette` + `$hostname` with `ssh_only = false`). Seed
  `~/.zshenv.local` (sourced from `zshenv` before prompt init) — not
  `~/.zshrc.local`, which loads in `90-local.zsh` after Starship init.
  Ansible stays out of user taste.
- `playbook-vm.yaml` should set nested `nvidia.enable: false` under `vars`
  (dotted key literals do not override `config.yaml` maps).
- Preflight chassis warnings are laptop bias; for `setup_target=vm` treat
  non-laptop chassis as expected, not scary.

## 2026-07-22
- Live typing colors in zsh come from `zsh-syntax-highlighting` (not Starship, not Ghostty theme). Ghost history suggestions are `zsh-autosuggestions`.
- The original repo wiring exposed both only as Oh My Zsh plugins behind `[[ -d ~/.oh-my-zsh ]]`; direct optional loading now makes the Homebrew setup independent of OMZ.
- On macOS, prefer Homebrew formulas + direct `source` (no OMZ required): `zsh-syntax-highlighting`, `zsh-autosuggestions`. Caveat: syntax highlighting must be sourced near the end of interactive init.
- OMZ stock does not include `zsh-syntax-highlighting`, `zsh-autosuggestions`, or `fzf-tab`; those need `custom/plugins/` clones even when OMZ is present. Declaring them in `plugins=(...)` alone is not enough.
- Ubuntu Ansible (`system-base` / `dev-tools`) also does not install these plugins — same silent gap on Linux unless added manually.
- `fzf-tab` must load after `compinit`; substring history search must bind the arrow keys after the repo's default prefix-history widgets.
- Never symlink an entire dotfiles `bin` directory to `~/.local/bin`: installers such as uv and Cursor write there and pollute the repository. Link an explicit allowlist of repository-owned helpers instead.

## 2026-07-16
- Profile-scoped Brewfiles preserve the existing setup vocabulary without making Ubuntu-specific Ansible roles conditional and harder to reason about.
- Package parity should follow intent rather than names: macOS already provides certificates, OpenSSH, zsh, and compiler tooling, while zram, NVIDIA PRIME, TLP, UFW, and fwupd have no direct package-equivalent.
- Adding Homebrew's standard prefixes to the root Makefile PATH lets a freshly bootstrapped `uv` run in the same `make install` invocation.
- Homebrew's fzf formula exposes shell integration under its formula prefix, not Debian's `/usr/share/doc/fzf/examples` path.
- Homebrew renamed the Docker cask to `docker-desktop`; its general Wine casks are deprecated and scheduled for removal, so Wine is not a durable macOS package mapping.
- Linking Starship's configuration is insufficient on a fresh machine; the UX package profile must also install the `starship` executable or prompt initialization is skipped.
- Zsh does not read `.inputrc`; matching readline's prefix-history arrows requires explicit ZLE widgets and `bindkey` mappings.
- Ghostty supports the XDG path `~/.config/ghostty/config.ghostty` on macOS, which fits the existing portable dotfile layout and backup/link lifecycle.

## 2026-05-06
- Docker's deb822 source (`docker.sources`) and legacy one-line source (`docker.list`) describe the same apt targets, so leaving both creates duplicate target warnings for Packages, Translations, DEP-11, icons, and CNF metadata.
- This laptop has `i386` enabled as a foreign architecture, so third-party repositories that only publish `amd64` packages should be explicitly architecture-pinned to avoid apt acquisition notices.
- `apt-get indextargets` is useful without sudo for confirming which source file owns each apt target and for surfacing duplicate source warnings.

## 2026-02-08
- `make report` depends on direct execution (`./scripts/system_report.sh`), so the script mode bit is part of functional correctness, not just style.
- In this repo, `dotfiles/zshenv` already prepends `~/.local/bin`; doing it again in interactive config creates avoidable PATH churn.
- CUDA env setup is safer when handled via Zsh's tied arrays (`ld_library_path`/`LD_LIBRARY_PATH`) with `typeset -U` to prevent repeated entries.
- `questionary + rich` is already sufficient for a noticeably better setup UX when profile metadata is explicit and shown before prompting.
- Parsing profile key from display text is brittle; returning typed profile values directly from `questionary.Choice` is safer and simpler.
- Showing per-step and total runtime gives useful operator feedback during setup without adding heavy dependencies or framework complexity.
- `questionary` theming can be centralized with `prompt_toolkit` `Style.from_dict(...)`, then reused across `select` and `confirm` for a coherent visual identity.
- CLI dry-runs do not exercise interactive prompt styling; they still provide a safe behavior regression check for the non-interactive path.
