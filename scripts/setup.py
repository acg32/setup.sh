#!/usr/bin/env -S uv run --with rich --with questionary
import argparse
import os
import shutil
import subprocess
from typing import List

import questionary
from rich.console import Console
from rich.panel import Panel
from rich.table import Table


PROFILES = {
    "base": ["ansible-base"],
    "ux": ["ansible-ux"],
    "workloads": ["ansible-workloads"],
    "personal": ["ansible-personal"],
    "full": ["ansible-base", "ansible-ux", "ansible-workloads"],
}


def run(cmd: List[str], cwd: str) -> None:
    subprocess.run(cmd, cwd=cwd, check=True)


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


def select_profile() -> str:
    return questionary.select(
        "Choose a setup profile",
        choices=[
            "base (core OS)",
            "ux (dev tools, gnome, battery)",
            "workloads (docker)",
            "personal (wine, retroarch)",
            "full (base + ux + workloads)",
        ],
        qmark="▶",
        pointer="❯",
    ).ask()


def main() -> None:
    parser = argparse.ArgumentParser(description="Run setup for this laptop.")
    parser.add_argument(
        "--profile",
        choices=PROFILES.keys(),
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

    console.print(Panel.fit("Laptop Setup Runner", style="bold cyan"))
    console.print("[bold magenta]Choose a profile and let the magic happen.[/bold magenta]")

    if args.profile:
        profile = args.profile
    else:
        selection = select_profile()
        profile = selection.split(" ", 1)[0]

    if args.dotfiles is None:
        use_dotfiles = questionary.confirm(
            "Apply dotfiles after Ansible?",
            default=True,
        ).ask()
    else:
        use_dotfiles = args.dotfiles

    table = Table(title="Planned actions", show_header=True, header_style="bold magenta")
    table.add_column("Step")
    table.add_column("Command")
    for target in PROFILES[profile]:
        table.add_row("Ansible", f"make {target}")
    if use_dotfiles:
        table.add_row("Dotfiles", "make dotfiles")
    console.print(table)
    console.rule("[bold cyan]Execution")

    if not args.yes:
        if not questionary.confirm("Proceed?", default=True).ask():
            console.print("Aborted.", style="yellow")
            return
    if args.dry_run:
        console.print("Dry run complete.", style="yellow")
        return

    try:
        for target in PROFILES[profile]:
            console.print(f"[bold yellow]→ Running:[/bold yellow] make {target}")
            run(["make", target], cwd=root)
            console.print(f"[bold green]✓ Done:[/bold green] make {target}")

        if use_dotfiles:
            console.print("[bold yellow]→ Running:[/bold yellow] make dotfiles")
            run(["make", "dotfiles"], cwd=root)
            console.print("[bold green]✓ Done:[/bold green] make dotfiles")
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

    console.print(Panel.fit("All set. Enjoy your fresh setup!", style="bold green"))


if __name__ == "__main__":
    main()
