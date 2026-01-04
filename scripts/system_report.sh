#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: system_report.sh [-o OUTPUT_FILE]

Creates a plain text report with system, tooling, and repo context.
Review the output before sharing; it can include sensitive details.
USAGE
}

out_file=""
while getopts ":o:h" opt; do
  case "$opt" in
    o) out_file="$OPTARG" ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      usage >&2
      exit 1
      ;;
    :)
      echo "Missing value for -$OPTARG" >&2
      usage >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

timestamp="$(date +%Y%m%d-%H%M%S)"
REPORT_TIMEOUT="${REPORT_TIMEOUT:-5}"
if [[ -z "$out_file" ]]; then
  out_file="system-report-${timestamp}.txt"
fi

mkdir -p "$(dirname "$out_file")"

have() {
  command -v "$1" >/dev/null 2>&1
}

section() {
  echo ""
  echo "## $1"
}

run_cmd() {
  local title="$1"
  shift
  echo ""
  echo "-- $title"
  if [[ $# -eq 0 ]]; then
    echo "SKIP: no command provided"
    return 0
  fi
  local cmd="$*"
  if have timeout; then
    if ! timeout "${REPORT_TIMEOUT}s" bash -c "$cmd" 2>&1; then
      echo "ERROR: command failed or timed out: $cmd"
    fi
    return 0
  fi
  if ! eval "$cmd" 2>&1; then
    echo "ERROR: command failed: $*"
  fi
}

{
  echo "System Report"
  echo "Generated: $(date -Is)"
  echo "User: $(id -un) (uid=$(id -u))"
  echo "Host: $(hostname)"
  echo "Shell: ${SHELL:-unknown}"
  echo "TERM: ${TERM:-unknown}"
  echo "COLORTERM: ${COLORTERM:-unknown}"
  echo "TMUX: ${TMUX:-}"

  section "OS and Kernel"
  run_cmd "uname" "uname -a"
  run_cmd "os-release" "cat /etc/os-release"
  run_cmd "lsb_release" "lsb_release -a"
  run_cmd "uptime" "uptime"
  run_cmd "timedatectl" "timedatectl"
  run_cmd "locale" "locale"

  section "Hardware"
  have lscpu && run_cmd "lscpu" "lscpu"
  run_cmd "meminfo (free)" "free -h"
  have lsblk && run_cmd "lsblk" "lsblk -a"
  have lsblk && run_cmd "lsblk filesystems" "lsblk -f"
  have swapon && run_cmd "swapon" "swapon --show"
  have lspci && run_cmd "lspci" "lspci -nnk"
  have lsusb && run_cmd "lsusb" "lsusb"
  have dmidecode && run_cmd "dmidecode" "sudo -n dmidecode || true"

  section "Storage and Filesystems"
  run_cmd "df" "df -hT"
  run_cmd "mount" "mount"
  run_cmd "fstab" "cat /etc/fstab"

  section "Network"
  have ip && run_cmd "ip addr" "ip addr"
  have ip && run_cmd "ip route" "ip route"
  run_cmd "resolv.conf" "cat /etc/resolv.conf"
  run_cmd "hosts" "cat /etc/hosts"
  have ss && run_cmd "ss" "ss -tulpen"

  section "Systemd"
  have systemctl && run_cmd "systemctl failed" "systemctl --failed"
  have systemctl && run_cmd "systemctl running services" "systemctl list-units --type=service --state=running"
  have systemctl && run_cmd "systemctl timers" "systemctl list-timers --all"

  section "Tooling"
  have git && run_cmd "git" "git --version"
  have tmux && run_cmd "tmux" "tmux -V"
  have zsh && run_cmd "zsh" "zsh --version"
  have bash && run_cmd "bash" "bash --version"
  have nvim && run_cmd "nvim" "nvim --version"
  have python && run_cmd "python" "python --version"
  have python3 && run_cmd "python3" "python3 --version"
  have node && run_cmd "node" "node --version"
  have npm && run_cmd "npm" "npm --version"
  have rg && run_cmd "rg" "rg --version"
  have fd && run_cmd "fd" "fd --version"
  have bat && run_cmd "bat" "bat --version"
  have docker && run_cmd "docker" "docker --version"
  have docker && run_cmd "docker info" "docker info"
  have nvidia-smi && run_cmd "nvidia-smi" "nvidia-smi"

  section "Package Managers"
  have dpkg-query && run_cmd "dpkg (count)" "dpkg-query -f '.\n' -W 2>/dev/null | wc -l"
  run_cmd "apt sources" "ls -1 /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null"
  have snap && run_cmd "snap list" "snap list"
  have flatpak && run_cmd "flatpak list" "flatpak list"

  section "Environment (redacted)"
  run_cmd "env" "env | sort | sed -E 's/(TOKEN|KEY|SECRET|PASS|PASSWORD|AWS_|GCP_|AZURE_)=.*/\\1=[REDACTED]/'"
  run_cmd "path" "printf '%s\n' \"${PATH:-}\" | tr ':' '\n'"

  section "User and Sessions"
  run_cmd "id" "id"
  run_cmd "groups" "groups"
  have who && run_cmd "who" "who"
  have last && run_cmd "last" "last -n 20"

  section "Repo Context"
  if have git; then
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "$repo_root" ]]; then
      run_cmd "repo root" "printf '%s\n' \"$repo_root\""
      run_cmd "git status" "git -C \"$repo_root\" status --short"
      run_cmd "git branch" "git -C \"$repo_root\" branch --show-current"
      run_cmd "git log (last 5)" "git -C \"$repo_root\" log -n 5 --oneline"
    else
      echo ""
      echo "-- git repo"
      echo "SKIP: not in a git repo"
    fi
  fi
} >"$out_file"

echo "Report written to: $out_file"
