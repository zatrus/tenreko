"""Example module showing the conventions. Delete it with its test once real code exists."""

from __future__ import annotations


class GreetingError(ValueError):
    """Raised when a greeting cannot be produced."""


def greet(name: str) -> str:
    """Return a greeting for ``name``.

    Raises:
        GreetingError: if ``name`` is blank.
    """
    trimmed = name.strip()
    if not trimmed:
        raise GreetingError("name must not be blank")
    return f"Hello, {trimmed}!"
