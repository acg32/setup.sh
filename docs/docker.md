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
