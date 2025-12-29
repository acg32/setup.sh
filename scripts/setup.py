#!/usr/bin/env -S uv run --with rich --with questionary
import argparse
import os
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
    args = parser.parse_args()

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    console = Console()

    console.print(Panel.fit("Laptop Setup Runner", style="bold cyan"))

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

    if not questionary.confirm("Proceed?", default=True).ask():
        console.print("Aborted.", style="yellow")
        return

    for target in PROFILES[profile]:
        run(["make", target], cwd=root)

    if use_dotfiles:
        run(["make", "dotfiles"], cwd=root)

    console.print("Done.", style="bold green")


if __name__ == "__main__":
    main()
