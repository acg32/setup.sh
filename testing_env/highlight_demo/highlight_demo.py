#!/usr/bin/env python3
"""Small script to visually verify Python syntax highlighting."""

from dataclasses import dataclass
from typing import Any

API_URL = "https://example.com"
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 2.5


class ApiClient:
    def __init__(self, base_url: str, timeout: float = DEFAULT_TIMEOUT) -> None:
        self.base_url = base_url
        self.timeout = timeout

    def request(self, path: str) -> dict:
        # TODO: replace with real I/O
        return {"ok": True, "path": path}


@dataclass
class User:
    id: int
    name: str


def fetch_user(client: ApiClient, user_id: int) -> User:
    result = client.request(f"/users/{user_id}")
    return User(id=user_id, name=str(result["path"]))


async def main() -> None:
    client = ApiClient(API_URL)
    user = fetch_user(client, 42)
    print(user)


if __name__ == "__main__":
    import asyncio

    asyncio.run(main())
