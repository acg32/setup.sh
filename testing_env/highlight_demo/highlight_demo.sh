#!/usr/bin/env bash
# Small script to visually verify shell highlighting.

set -euo pipefail

APP_NAME="highlight-demo"
MAX_RETRIES=3

function log_info() {
  local message="$1"
  printf '[INFO] %s\n' "$message"
}

function main() {
  log_info "starting $APP_NAME"

  for i in $(seq 1 "$MAX_RETRIES"); do
    log_info "attempt $i"
  done

  if [[ -n "${HOME:-}" ]]; then
    log_info "home is $HOME"
  fi
}

main "$@"
