#!/usr/bin/env -S uv run --with rich --with questionary
import argparse
import os
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
    "full": ProfileSpec(
        key="full",
        title="Full",
        description="Base + UX + workloads",
        targets=("ansible-base", "ansible-ux", "ansible-workloads"),
        eta_minutes=20,
        recommended=True,
    ),
}

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


def select_profile() -> str:
    return questionary.select(
        "Choose a setup profile:",
        choices=[
            questionary.Choice(
                title="full      Base + UX + workloads (recommended)",
                value="full",
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

    selected = PROFILE_SPECS[profile]

    if args.dotfiles is None:
        use_dotfiles = questionary.confirm(
            "Apply dotfiles after Ansible? (recommended)",
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
    for target in selected.targets:
        table.add_row(str(step_num), "Ansible", f"make {target}")
        step_num += 1
    if use_dotfiles:
        table.add_row(str(step_num), "Dotfiles", "make dotfiles")
    console.print(table)
    eta = selected.eta_minutes + (2 if use_dotfiles else 0)
    console.print(
        f"[dim]Selected profile:[/dim] [bold]{selected.title}[/bold] "
        f"[dim]- {selected.description}[/dim]"
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
        for target in selected.targets:
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
