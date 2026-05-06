# Learnings

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
