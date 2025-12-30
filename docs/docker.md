# Docker Conventions

This laptop uses Docker for disposable workloads only.

## Principles
- Keep the host clean; do not install DBs or long-running stacks on the host.
- Use bind mounts for source code.
- Treat containers as disposable; no important data inside.

## Example
```bash
docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  python:3.12-slim \
  bash
```

## Commit styleguide

- Use a playful, fanciful tone and keep it short.
- Include emojis in the subject line.
- Format: "<emoji> <whimsical verb>: <what changed>".
- Keep the subject under 72 characters; add a body only if needed.
