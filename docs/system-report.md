# System Report Script

This repo includes a system report script to capture a snapshot of the machine
for debugging setup issues or proposing improvements.

Script: `scripts/system_report.sh`

## Why this is useful

- Single, consistent dump of OS, hardware, services, tooling, and repo state.
- Quick way to spot drift (failed services, missing tools, driver issues).
- Safe default: read-only commands and redaction of common secrets.

## How it works

The script runs a curated set of system commands and writes the output to a
timestamped report file. It attempts to use a short timeout per command so a
single slow probe does not stall the report.

It collects:
- OS/kernel and locale
- hardware and storage
- network state and listeners
- systemd health (if available)
- common tooling versions
- package manager state
- redacted environment snapshot
- git repo context (if run inside a repo)

## Usage

```bash
make report
```

Or run directly:

```bash
bash scripts/system_report.sh
```

Write to a custom file:

```bash
bash scripts/system_report.sh -o /path/to/report.txt
```

Adjust per-command timeout (seconds):

```bash
REPORT_TIMEOUT=10 bash scripts/system_report.sh
```

## Notes

- Some commands require elevated access (e.g., `dmidecode`, systemd status).
  If run without privileges, those sections will be skipped or show errors.
- The output can include sensitive data. Review before sharing.
