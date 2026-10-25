---
paths:
  - "**/*.py"
  - "pyproject.toml"
  - "uv.lock"
---

# Python rules

## Toolchain
- **uv** manages Python, venv, and deps. Python version pinned in `.python-version` and `requires-python`. Commit `uv.lock`.
  - Add a dep with `uv add <pkg>` (dev: `uv add --dev <pkg>`). Never `pip install` into the project or hand-edit `uv.lock`.
  - Run anything with `uv run …`.
- **src layout:** `src/<package>/…`, tests in `tests/`.
- Gate: `ruff format --check` + `ruff check` + `mypy --strict` + `pytest` with coverage (configured in `pyproject.toml`).

## Code
- **Type hints everywhere**, mypy strict passes. No bare `Any` in public signatures. No `# type: ignore` without an error code and reason: `# type: ignore[import-untyped]  # lib has no stubs`.
- Modern syntax: `list[int]`, `X | None`, `match` for state dispatch, `from __future__ import annotations` not needed on 3.12+.
- **Data:** `@dataclass(frozen=True, slots=True)` for domain values; **pydantic** models only at I/O boundaries (API, config, files).
- Config via `pydantic-settings` (or one `config.py`) read once; no `os.environ` scattered in code.
- **Errors:** define a small exception hierarchy per package (`class OrderError(Exception)`). Raise with context (`raise X(...) from err`). Never bare `except:` or `except Exception: pass`.
- `pathlib.Path`, not `os.path`. `logging` (structured, `logger = logging.getLogger(__name__)`), never `print` in library code.
- No mutable default arguments. No module-level side effects on import (no I/O, no network).
- Public functions get a one-line docstring saying what, plus `Raises:` if they raise domain errors.
- Async only when the I/O needs it. Don't mix sync blocking calls into async code.

## Tests (pytest)
- `tests/unit/…` and `tests/integration/…`, mirroring the package. Files `test_*.py`, functions `test_<behaviour>`.
- Use fixtures over setup methods, `pytest.mark.parametrize` for tables of cases, `tmp_path` for files, and `freezegun` or an injected clock for time.
- `pytest.raises(SpecificError, match=...)`. Never assert on a broad `Exception`.
