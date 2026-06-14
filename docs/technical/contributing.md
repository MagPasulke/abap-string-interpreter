# Contributing

This page describes the development workflow for contributing to ZASIS — branch strategy, PR process, commit conventions, and the rules that govern code quality.

---

## Workflow Overview

Every change — whether a feature, bug fix, refactor, or documentation update — follows the same process:

1. Create a feature branch from `main`
2. Implement the change
3. Write or update tests (see [Testing](testing.md))
4. Run `npm test` and `npm run icf-test` — all must pass before committing
5. Commit and push
6. Repeat steps 2–5 for each logical unit of work
7. Mark the PR ready for review once complete

**Never commit directly to `main`.** All changes go through a branch and a pull request.

---

## Branch Naming

Use a `type/short-description` format, mirroring the conventional commit type:

| Change type | Branch prefix | Example |
|---|---|---|
| New feature | `feat/` | `feat/add-json-export` |
| Bug fix | `fix/` | `fix/replace-no-match` |
| Documentation | `docs/` | `docs/restructure-readme` |
| Refactor | `refactor/` | `refactor/extract-core-handler` |
| CI / build | `ci/` or `build/` | `ci/add-deploy-workflow` |

---

## Pull Requests

- Open a **draft PR** immediately after pushing the first commit, to make work visible
- PRs are merged into `main` — never into other feature branches
- **Squash merge** is preferred — it collapses branch commits into a single commit on `main`
- Delete the feature branch (local and remote) after merge
- The agent never merges autonomously — the user always merges or explicitly instructs a merge
- Before merging, the user must sync to the SAP system and confirm ABAP Unit tests pass on-stack

PR descriptions should note: _"⚠️ Please sync to SAP system via abapGit and run ABAP Unit tests before merging."_

---

## Commit Conventions

All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): short imperative description

Optional body with more context.

Optional footer — e.g. BREAKING CHANGE: description
```

**Allowed types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Version impact:** Release Please reads conventional commits to determine the next version automatically:

| Commit | Version bump |
|---|---|
| `fix:` | Patch |
| `feat:` | Minor |
| `feat!:` / `BREAKING CHANGE:` footer | Major |

**Never amend commits.** If a fix is needed after a commit, create a new commit. The commit history should trace what happened, including corrections.

**Never force-push.** History must remain linear and traceable.

---

## Code Quality Rules

These rules are enforced and non-negotiable:

- **`npm test` must pass before every commit.** This includes abaplint static analysis, TypeScript type-checking, and all transpiled ABAP Unit tests.
- **`npm run icf-test` must pass** when HTTP handler or RuleSet factory logic is modified.
- **Do not disable or bypass linter rules.** If abaplint reports a finding, fix the root cause in the ABAP source. Suppression comments and configuration overrides to silence findings are forbidden.
- **Do not modify `abaplint.jsonc` or `abap_transpile.json`** unless explicitly instructed. These files define the project's quality baseline and transpilation configuration.
- **Write tests for every change** — see [Testing](testing.md) for which layer and how.

---

## SAP System Sync

After local tests pass and a PR is ready, changes are synced to the SAP system via abapGit using the `deploy-sap` GitHub Actions workflow (manual trigger) or via the `adt_gitpull` OpenCode tool. ABAP Unit tests are then run on-stack via ADT or the `adt_rununit` tool.

This on-stack validation step is required before merging. It catches compilation errors and runtime behaviours that cannot be replicated off-stack — see [Off-Stack Development](off-stack-development.md) for the full list of gaps.
