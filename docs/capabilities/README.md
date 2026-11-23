# Capabilities: current behaviour

One file per capability (`checkout.md`, `user-accounts.md`), describing **what the system does today**. This is the place to look up current behaviour.

| | `docs/capabilities/<name>.md` | `docs/specs/NNN-slug/` |
|---|---|---|
| Answers | How does it behave **now**? | What did **one change** add or alter, and how was it built? |
| Lifetime | Living: kept current with every merged change | Historical once delivered: never edited again |
| Updated by | `/spec-verify` (before the PR), `/bugfix` when it restores or clarifies a rule, `/spec-extract` for existing code | `/spec-new`, `/spec-design`, `/spec-tasks` |

Rules:
- A change spec names the capabilities it touches (*Capabilities* line in `requirements.md`). `/spec-verify` folds its approved REQs into those files before opening the PR, so the PR merges code and current behaviour together.
- Rule IDs are stable per capability: `CHECKOUT-1`, `CHECKOUT-2`, and so on. Never renumber. A removed rule is ~~struck through~~ with the spec that removed it.
- Each rule links back to the change REQ that introduced it, and to its test(s).
- Old `design.md` files are not the current architecture. Lasting decisions belong in an ADR (`docs/adr/`) and are linked from here.
- If the code, a capability file, and a change spec disagree, don't pick one. Report the conflict and ask the human (hard rule 7).

Template: [`_template.md`](_template.md).

## Index

| Capability | File | Last changed by |
|---|---|---|
