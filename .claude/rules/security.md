# Security rules

- **Secrets:** never in code, tests, fixtures, logs, specs, or commit messages. Read them from env/secret store; document keys in `.env.example` with fake values. `.env*` files are blocked by a hook.
- **Input:** validate at every trust boundary (HTTP, CLI, files, queues) with an explicit schema. Reject by default.
- **Injection:** parameterised queries only; never build SQL/shell/HTML/paths by string concatenation with user input. Escape output for its context.
- **AuthZ:** check on every request at the server side, deny by default, test the "other user's resource" case.
- **Logging:** structured, no tokens, passwords, or personal data. Log IDs, not payloads.
- **Dependencies:** pin via lockfile; add only maintained, licence-compatible packages; run the stack's audit (`npm audit`, `pip-audit`, OWASP dependency-check) in CI.
- **Errors to clients** expose no stack traces or internals.
- Before merging anything touching auth, crypto, file upload, deserialisation, or external input, run `/security-review`.
