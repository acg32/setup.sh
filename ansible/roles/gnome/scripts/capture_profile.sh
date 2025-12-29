#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/files/terminal-profiles.dconf"

tmp_script="$(mktemp)"
trap 'rm -f "$tmp_script"' EXIT

cat > "$tmp_script" <<'PY'
import sys
text = sys.stdin.read().splitlines()
profiles = {}
current = None
for line in text:
    if line.startswith('[:') and line.endswith(']'):
        current = line.strip()[2:-1]
        profiles[current] = []
        continue
    if current is not None:
        profiles[current].append(line)

uuid = None
for uid, lines in profiles.items():
    for l in lines:
        if l.strip() == "visible-name='Aci-Custom'":
            uuid = uid
            break
    if uuid:
        break

if not uuid:
    names = []
    for uid, lines in profiles.items():
        for l in lines:
            if l.startswith("visible-name="):
                names.append(l.split("=", 1)[1].strip().strip("'"))
    names = ", ".join(sorted(set(names)))
    sys.exit(f"Aci-Custom not found. Available: {names}")

out = []
out.append('[/]')
out.append(f"default='{uuid}'")
out.append(f"list=['{uuid}']")
out.append('')
out.append(f'[:{uuid}]')
out.extend(profiles[uuid])
print('\n'.join(out))
PY

dconf dump /org/gnome/terminal/legacy/profiles:/ 2>/dev/null | python3 "$tmp_script" > "$OUT"
printf "Wrote %s\n" "$OUT"
