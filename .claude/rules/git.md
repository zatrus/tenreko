# Git rules

## Branches
- **Branch per spec:** `feat/NNN-slug`, `fix/short-slug`, `chore/short-slug`. Never commit directly to `main`.
- **The agent pushes only to branches it created** in this clone (`git switch -c` / `git checkout -b` / `git worktree add -b`). The guard hook records those names in `.git/claude-branches` and blocks pushes to any other branch, including `main` and branches made by the human or teammates.
  - To let the agent push to a branch it didn't create, the human runs: `echo <branch> >> .git/claude-branches`
  - If a branch with that name already exists (locally or as a remote-tracking branch), the agent doesn't take it over. Pick a new name.
- **The agent never merges into `main`.** No `gh pr merge`, no `git merge` while on `main`, no push to `main`. Only the human merges pull requests.

## Commits
- **One task = one commit** on the feature branch, gate green at every commit. These commits are checkpoints: they let you roll back a failed task, review task by task, and use `git bisect`.
- **Tiny tasks can share a commit:** tasks of ≤ ~20 changed lines that touch the same files may be committed together, tagged with all their IDs: `[spec 003 T2,T3]`.
- **Conventional Commits:** `type(scope): imperative summary [spec NNN TX]`
  - types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`
  - body: *why*, not what. Breaking change: `BREAKING CHANGE:` footer.
- Stage explicit paths (`git add path/…`), not `git add -A`. Check `git status` first so you don't commit stray files.
- Never skip hooks (`--no-verify`). If a hook fails, fix the cause.

## Pull requests and merging
- **Squash-merge into `main`:** one spec = one PR = one commit on `main`. The task commits stay visible in the PR history. (Enable "Allow squash merging" only, in the GitHub repo settings.)
- The agent may push its own branch and open the PR (`gh pr create`). Then it **stops**. The human reviews and merges.
- **PR title** = the squash commit message: `feat(<scope>): <spec title> [spec NNN]`.
- **PR body** = the squash commit body: link to the spec, the REQs covered, the gate summary, and the `/spec-verify` report.

## Never without an explicit human `GO`
`push --force` / `+refspec`, `reset --hard`, `clean -f`, rebasing branches that others use, deleting branches or tags, pushing tags, releases, publishing packages.
