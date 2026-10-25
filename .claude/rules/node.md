---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.mjs"
  - "**/*.cjs"
  - "package.json"
  - "tsconfig*.json"
---

# Node / TypeScript rules

## Toolchain
- **TypeScript, strict.** `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes` stay on. New files are `.ts`, never `.js`.
- ESM only (`"type": "module"`). Node version pinned in `.nvmrc` and `engines`.
- Package manager: **npm** with a committed `package-lock.json`. Install with `npm ci` in CI. Add deps with `npm install <pkg>`; never hand-edit the lockfile.
- Gate: `npm run check` = `format:check` + `lint` + `typecheck` + `test` (Vitest with coverage).
- Formatting is Prettier's job and runs on save via a hook. Don't argue style in review.

## Code
- **No `any`.** Use `unknown` and narrow it. No non-null `!` assertions except in tests. No `@ts-ignore`; `@ts-expect-error` only with a reason.
- **Validate external data with a schema** (e.g. `zod`) at the boundary and derive the type from the schema (`z.infer`). Don't cast `JSON.parse` results.
- Prefer `type` aliases plus discriminated unions for domain states. Use exhaustive `switch` with a `never` check.
- Errors: throw `Error` subclasses with `cause`. For expected failures in the domain, return a result union (`{ ok: true, value } | { ok: false, error }`).
- `async`/`await` only. No floating promises (the lint rule is on). Use `Promise.all` for independent work.
- Named exports only; no default exports. One module = one responsibility. No barrel files that create import cycles.
- Use `node:` prefixed built-ins (`node:fs/promises`). Read config once in a `config.ts` validated by the schema; never access `process.env` elsewhere.
- Use `const` by default, `readonly` on properties and arrays where possible, and no `class` when a function plus closure is enough.

## Tests (Vitest)
- Co-locate tests as `*.test.ts` next to the source, or in `test/` for integration.
- Use `vi.useFakeTimers()` and injected clocks; never sleep.
- Property-based: `fast-check` (`fc.assert(fc.property(...))`) via `@fast-check/vitest` `test.prop`. Add with `npm install -D fast-check @fast-check/vitest` when the first edge-case REQ needs it.
- Concurrency: `Promise.all` of N calls against the real DB adapter (Testcontainers), then assert the invariant. Node is single-threaded, but every `await` between a read and a write is a race window.
- HTTP adapters: test with the framework's in-process injector (e.g. `app.inject`, `supertest`), not a real port.
