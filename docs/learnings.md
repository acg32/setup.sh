# Learnings

## 2026-02-08
- `make report` depends on direct execution (`./scripts/system_report.sh`), so the script mode bit is part of functional correctness, not just style.
- In this repo, `dotfiles/zshenv` already prepends `~/.local/bin`; doing it again in interactive config creates avoidable PATH churn.
- CUDA env setup is safer when handled via Zsh's tied arrays (`ld_library_path`/`LD_LIBRARY_PATH`) with `typeset -U` to prevent repeated entries.
