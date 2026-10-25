# {{PROJECT_NAME}}

{{One or two sentences: what the product does and who uses it.}}

## Status

{{Prototype / active development / production.}} {{Significant limitations, or "none known".}}

## Quick start

### Prerequisites

{{PREREQUISITES}}

### Configuration and startup

```bash
cp .env.example .env        # then fill in local values
{{INSTALL_CMD}}
{{RUN_CMD}}
```

{{How to confirm it works, e.g. "open http://localhost:8080/actuator/health".}}

## Development

| Action | Command |
|---|---|
| Full gate (format, lint, types, tests, coverage) | `bash scripts/check.sh` |
| Apply formatters and autofixes | `bash scripts/check.sh --fix` |
| Run one test | `{{TEST_ONE_CMD}}` |
| Build | `{{BUILD_CMD}}` |

## Architecture

{{Main components, technologies, and responsibilities in a few sentences. Decisions: docs/adr/.}}

## Documentation

- [Business context](docs/BUSINESS.md)
- [Current behaviour, per capability](docs/capabilities/)
- [Change specs (requirements, design, tasks)](docs/specs/)
- [Project principles](docs/constitution.md)
- [Contribution guide](CONTRIBUTING.md)
- [AI agent instructions](CLAUDE.md) · [other agents](AGENTS.md)
- [How the workflow works](docs/WORKFLOW.md)

## License

{{License or usage terms; link to LICENSE if present.}}
