import pytest

from app.greeting import GreetingError, greet


def test_greet_returns_greeting_for_name() -> None:
    result = greet("Ada")

    assert result == "Hello, Ada!"


@pytest.mark.parametrize("blank", ["", "   ", "\t"])
def test_greet_rejects_blank_name(blank: str) -> None:
    with pytest.raises(GreetingError, match="blank"):
        greet(blank)
