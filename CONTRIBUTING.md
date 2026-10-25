# Contributing

Short rules for people. AI agents follow the same process via [CLAUDE.md](CLAUDE.md) and [AGENTS.md](AGENTS.md).

1. **Read first:** [README.md](README.md), [business context](docs/BUSINESS.md), [project principles](docs/constitution.md), and the [capability](docs/capabilities/) you're changing.
2. **Size the change** (details in [CLAUDE.md → Workflow](CLAUDE.md)):
   - **Trivial** (typo, config value, no behaviour change): a short PR description is enough.
   - **Bug** (behaviour differs from a capability rule or spec): a failing test that reproduces it comes first. No new spec needed.
   - **Feature** (new or changed behaviour): a spec in `docs/specs/NNN-slug/` (requirements → design → tasks), each step approved before the next.
3. **Branch** from `main`: `feat/NNN-slug`, `fix/slug`, or `chore/slug`. One coherent change per PR. Commits follow [Conventional Commits](https://www.conventionalcommits.org/) with the spec tag: `feat(auth): add login rate limit [spec 003 T4]`.
4. **Check** with `bash scripts/check.sh` (the same gate CI runs). In the PR, report what passed, what failed, and what you didn't run, and why.
5. **Update what your change affects:** the capability file in `docs/capabilities/`, contracts, `.env.example`, README, and an ADR for hard-to-reverse decisions.
6. **PR description:** the problem, the resulting behaviour, the verification, open issues, and a link to the spec.
7. **Merge:** squash merge into `main`, done by a maintainer after review. AI agents never merge, and push only to branches they created.

## Done means

- The acceptance criteria are met, and each one has a passing test.
- `bash scripts/check.sh` is green; any exception is recorded in the PR.
- The capability file and other affected docs describe the new behaviour.
- The review is complete, and findings are fixed or answered.
