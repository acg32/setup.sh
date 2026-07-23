#!/usr/bin/env -S uv run --with rich --with questionary
import argparse
import os
import platform
import shutil
import subprocess
from dataclasses import dataclass
from time import perf_counter
from typing import List, Sequence

import questionary
from prompt_toolkit.styles import Style
from rich.console import Console
from rich.panel import Panel
from rich.table import Table


@dataclass(frozen=True)
class ProfileSpec:
    key: str
    title: str
    description: str
    targets: Sequence[str]
    eta_minutes: int
    recommended: bool = False


PROFILE_SPECS = {
    "base": ProfileSpec(
        key="base",
        title="Base",
        description="Core system baseline and essential packages",
        targets=("ansible-base",),
        eta_minutes=8,
    ),
    "ux": ProfileSpec(
        key="ux",
        title="UX",
        description="Desktop UX, battery and dev comfort tools",
        targets=("ansible-ux",),
        eta_minutes=10,
    ),
    "workloads": ProfileSpec(
        key="workloads",
        title="Workloads",
        description="Containers and workload helpers",
        targets=("ansible-workloads",),
        eta_minutes=6,
    ),
    "personal": ProfileSpec(
        key="personal",
        title="Personal",
        description="Personal extras (wine/retroarch and similar)",
        targets=("ansible-personal",),
        eta_minutes=7,
    ),
    "vm": ProfileSpec(
        key="vm",
        title="VM",
        description="VM tooling on Ubuntu 24+ or Debian 12+ (no laptop UX)",
        targets=("ansible-vm",),
        eta_minutes=12,
    ),
    "full": ProfileSpec(
        key="full",
        title="Full",
        description="Base + UX + workloads",
        targets=("ansible-base", "ansible-ux", "ansible-workloads"),
        eta_minutes=20,
        recommended=True,
    ),
}

SUPPORTED_SYSTEMS = {"Darwin", "Linux"}

QUESTIONARY_STYLE = Style.from_dict(
    {
        "qmark": "fg:#ff9e3b bold",
        "question": "fg:#9ccfd8 bold",
        "answer": "fg:#a6da95 bold",
        "pointer": "fg:#f7768e bold",
        "highlighted": "fg:#f5a97f bold",
        "selected": "fg:#7dcfff bold",
        "instruction": "fg:#7aa2f7 italic",
        "text": "fg:#c0caf5",
        "disabled": "fg:#6b7089 italic",
    }
)


def run(cmd: List[str], cwd: str) -> float:
    started = perf_counter()
    subprocess.run(cmd, cwd=cwd, check=True)
    return perf_counter() - started


VM_STARSHIP_MARKER = "# setup.sh vm profile"
VM_STARSHIP_BLOCK = """# setup.sh vm profile
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.vm.toml"
"""

VM_ZSH_HANDOFF_MARKER = "# setup.sh vm profile: zsh handoff"
VM_ZSH_HANDOFF_BLOCK = """# setup.sh vm profile: zsh handoff
# Google OS Login keeps /bin/bash as the login shell; chsh cannot change it.
if [ -t 1 ] && [ -z "${ZSH_VERSION:-}" ] && [ -x /usr/bin/zsh ]; then
  export SHELL=/usr/bin/zsh
  exec /usr/bin/zsh -l
fi
"""


def _append_seed_block(path: str, marker: str, block: str) -> bool:
    """Append block to path if marker is absent. Returns True if written."""
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as handle:
            existing = handle.read()
        if marker in existing:
            return False
        with open(path, "a", encoding="utf-8") as handle:
            if existing and not existing.endswith("\n"):
                handle.write("\n")
            handle.write(block)
            if not block.endswith("\n"):
                handle.write("\n")
    else:
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(block)
    return True


def ensure_git_pagers(console: Console) -> None:
    if shutil.which("git") is None:
        return
    expected = "delta"
    keys = ["core.pager", "pager.log", "pager.diff", "pager.show"]
    updated = False
    for key in keys:
        result = subprocess.run(
            ["git", "config", "--global", "--get", key],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0 or result.stdout.strip() != expected:
            subprocess.run(["git", "config", "--global", key, expected], check=True)
            updated = True
    if updated:
        console.print("[bold green]✓ Fixed Git pager config[/bold green]")


def ensure_vm_starship_config(console: Console) -> None:
    # STARSHIP_CONFIG must be set before starship init (40-prompt.zsh), so seed
    # ~/.zshenv.local (sourced from zshenv) rather than ~/.zshrc.local (90-local).
    local_env = os.path.expanduser("~/.zshenv.local")
    if _append_seed_block(local_env, VM_STARSHIP_MARKER, VM_STARSHIP_BLOCK):
        console.print(
            "[bold green]✓ Seeded VM Starship config in ~/.zshenv.local[/bold green]"
        )
    else:
        console.print(
            "[dim]VM Starship config already present in ~/.zshenv.local[/dim]"
        )


def ensure_vm_zsh_handoff(console: Console) -> None:
    # OS Login / NSS users are not in /etc/passwd, so chsh cannot set zsh.
    # Hand off from interactive bash (SSH default) into zsh instead.
    bashrc = os.path.expanduser("~/.bashrc")
    if _append_seed_block(bashrc, VM_ZSH_HANDOFF_MARKER, VM_ZSH_HANDOFF_BLOCK):
        console.print(
            "[bold green]✓ Seeded bash→zsh handoff in ~/.bashrc[/bold green]"
        )
    else:
        console.print("[dim]bash→zsh handoff already present in ~/.bashrc[/dim]")


def render_profile_guide(console: Console) -> None:
    table = Table(title="Available profiles", show_header=True, header_style="bold cyan")
    table.add_column("Profile", style="bold")
    table.add_column("What it does")
    table.add_column("Targets")
    table.add_column("ETA")
    for spec in PROFILE_SPECS.values():
        name = spec.title
        if spec.recommended:
            name = f"{name} (recommended)"
        table.add_row(
            name,
            spec.description,
            ", ".join(spec.targets),
            f"~{spec.eta_minutes}m",
        )
    console.print(table)


def platform_targets(targets: Sequence[str], system_name: str) -> Sequence[str]:
    if system_name == "Darwin":
        return tuple(target.replace("ansible-", "brew-", 1) for target in targets)
    return targets


def select_profile() -> str:
    return questionary.select(
        "Choose a setup profile:",
        choices=[
            questionary.Choice(
                title="full      Base + UX + workloads (recommended)",
                value="full",
            ),
            questionary.Choice(
                title="vm        VM tooling (Ubuntu 24+ / Debian 12+, no laptop UX)",
                value="vm",
            ),
            questionary.Choice(
                title="base      Core system baseline and packages",
                value="base",
            ),
            questionary.Choice(
                title="ux        Desktop UX, battery, dev comfort",
                value="ux",
            ),
            questionary.Choice(
                title="workloads Containers and workload helpers",
                value="workloads",
            ),
            questionary.Choice(
                title="personal  Personal extras",
                value="personal",
            ),
        ],
        qmark="▶",
        pointer="❯",
        style=QUESTIONARY_STYLE,
        instruction="(Use ↑/↓ to move, Enter to choose)",
    ).ask()


def main() -> None:
    parser = argparse.ArgumentParser(description="Run setup for this laptop.")
    parser.add_argument(
        "--profile",
        choices=PROFILE_SPECS.keys(),
        help="Run a specific profile without prompting.",
    )
    parser.add_argument(
        "--dotfiles",
        action=argparse.BooleanOptionalAction,
        default=None,
        help="Enable or disable dotfiles install.",
    )
    parser.add_argument(
        "--yes",
        action="store_true",
        help="Run without confirmation prompts.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show planned commands without running them.",
    )
    args = parser.parse_args()

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    console = Console()
    system_name = platform.system()

    if system_name not in SUPPORTED_SYSTEMS:
        console.print(
            f"Unsupported operating system: {system_name or 'unknown'}",
            style="bold red",
        )
        raise SystemExit(1)

    console.print(
        Panel.fit(
            "[bold cyan]Laptop Setup Wizard[/bold cyan]\n"
            "[dim]Guided bootstrap for this machine[/dim]",
            border_style="cyan",
        )
    )

    if args.profile:
        profile = args.profile
    else:
        render_profile_guide(console)
        profile = select_profile()

    if profile == "vm" and system_name != "Linux":
        console.print(
            "The vm profile targets Ubuntu 24+ or Debian 12+ only.",
            style="bold red",
        )
        raise SystemExit(1)

    selected = PROFILE_SPECS[profile]
    selected_targets = platform_targets(selected.targets, system_name)
    package_manager = "Homebrew" if system_name == "Darwin" else "Ansible"

    if args.dotfiles is None:
        use_dotfiles = questionary.confirm(
            "Apply dotfiles after package setup? (recommended)",
            default=True,
            qmark="◆",
            style=QUESTIONARY_STYLE,
            instruction="(Y/n)",
        ).ask()
    else:
        use_dotfiles = args.dotfiles

    table = Table(title="Execution plan", show_header=True, header_style="bold magenta")
    table.add_column("#", style="bold")
    table.add_column("Step")
    table.add_column("Command")
    step_num = 1
    for target in selected_targets:
        table.add_row(str(step_num), package_manager, f"make {target}")
        step_num += 1
    if use_dotfiles:
        table.add_row(str(step_num), "Dotfiles", "make dotfiles")
    console.print(table)
    eta = selected.eta_minutes + (2 if use_dotfiles else 0)
    console.print(
        f"[dim]Selected profile:[/dim] [bold]{selected.title}[/bold] "
        f"[dim]- {selected.description}[/dim]"
    )
    if system_name == "Darwin":
        console.print(
            "[dim]macOS: GNOME and Linux-only system tuning are intentionally skipped.[/dim]"
        )
    if profile == "vm":
        console.print(
            "[dim]VM: skips vscode, Chrome, zram, UFW, Docker, Node/npm, nvidia, "
            "GNOME, battery, and firmware; seeds Starship VM theme.[/dim]"
        )
    console.print(f"[dim]Estimated total time:[/dim] ~{eta}m")
    console.rule("[bold cyan]Execution")

    if not args.yes:
        if not questionary.confirm(
            "Proceed?",
            default=True,
            qmark="◆",
            style=QUESTIONARY_STYLE,
            instruction="(Y/n)",
        ).ask():
            console.print("Aborted.", style="yellow")
            return
    if args.dry_run:
        console.print("Dry run complete.", style="yellow")
        return

    total_started = perf_counter()
    try:
        for target in selected_targets:
            console.print(f"[bold yellow]→ Running:[/bold yellow] make {target}")
            elapsed = run(["make", target], cwd=root)
            console.print(
                f"[bold green]✓ Done:[/bold green] make {target} "
                f"[dim]({elapsed:.1f}s)[/dim]"
            )

        if use_dotfiles:
            console.print("[bold yellow]→ Running:[/bold yellow] make dotfiles")
            elapsed = run(["make", "dotfiles"], cwd=root)
            console.print(
                "[bold green]✓ Done:[/bold green] make dotfiles "
                f"[dim]({elapsed:.1f}s)[/dim]"
            )
            ensure_git_pagers(console)
            if profile == "vm":
                ensure_vm_starship_config(console)
                ensure_vm_zsh_handoff(console)
    except subprocess.CalledProcessError as exc:
        console.print(
            Panel.fit(
                f"Step failed: {exc.cmd}\nExit code: {exc.returncode}",
                title="Setup failed",
                style="bold red",
            )
        )
        raise SystemExit(1)

    total_elapsed = perf_counter() - total_started
    console.print(
        Panel.fit(
            f"All set. Enjoy your fresh setup!\n[dim]Total time: {total_elapsed:.1f}s[/dim]",
            style="bold green",
        )
    )


if __name__ == "__main__":
    main()
