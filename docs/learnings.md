# Learnings

## 2026-02-08
- `make report` depends on direct execution (`./scripts/system_report.sh`), so the script mode bit is part of functional correctness, not just style.
- In this repo, `dotfiles/zshenv` already prepends `~/.local/bin`; doing it again in interactive config creates avoidable PATH churn.
- CUDA env setup is safer when handled via Zsh's tied arrays (`ld_library_path`/`LD_LIBRARY_PATH`) with `typeset -U` to prevent repeated entries.
- `questionary + rich` is already sufficient for a noticeably better setup UX when profile metadata is explicit and shown before prompting.
- Parsing profile key from display text is brittle; returning typed profile values directly from `questionary.Choice` is safer and simpler.
- Showing per-step and total runtime gives useful operator feedback during setup without adding heavy dependencies or framework complexity.
