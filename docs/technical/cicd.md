# CI/CD

ZASIS uses GitHub Actions for continuous integration, automated deployment to SAP, release management, and documentation maintenance. All workflows are defined in `.github/workflows/`.

---

## CI Workflow (`ci.yml`)

**Trigger:** Every push to `main` and every pull request.

**What it does:**

1. Checks out the repository and sets up Node.js
2. Installs dependencies via `npm ci`
3. Runs `npm test` — abaplint static analysis + TypeScript type-checking + transpiled ABAP Unit tests
4. Runs `npm run icf-test` — ICF shim integration tests (full HTTP handler stack in Node.js)

**Purpose:** This is the primary quality gate. A PR cannot be considered ready for merge unless all four checks pass. The CI run is deliberately kept fast (5-minute timeout) to preserve developer feedback loops.

The CI workflow intentionally does not connect to a SAP system. Off-stack testing covers everything that can be verified without one. SAP-specific validation (real auth, HANA, CDS) is handled separately via the deploy workflow and on-system ABAP Unit tests.

---

## SAP Deployment Workflow (`deploy-sap.yml`)

**Trigger:** Manual (`workflow_dispatch`) — can only be triggered from `main`.

**What it does:**

1. **Verify CI** — checks the GitHub Actions API to confirm that the exact commit SHA on `main` has a completed, successful `ci.yml` push run. If no such run exists, or if it did not succeed, the workflow fails immediately. This prevents deploying code that was never CI-validated.

2. **Sync to SAP** — calls `scripts/adt-gitpull-ci.ts` using ADT API credentials stored as repository secrets (`SAP_ADT_URL`, `SAP_ADT_USER`, `SAP_ADT_PASSWORD`). This triggers an abapGit pull on the target SAP system, synchronising the `main` branch.

**Why manual?** SAP system access is treated as a controlled environment. Automatic deployment on every merge would risk introducing breaking changes to a shared system before they have been manually verified. The deploy step is a deliberate gate that a developer runs when they are ready to validate on-stack.

**After deployment:** Run ABAP Unit tests on the SAP system to confirm all tests pass. This can be done via the `adt_rununit` OpenCode tool or directly in ADT.

---

## Release Workflow (`release-please.yml`)

**Trigger:** Every push to `main`.

**What it does:** Uses [Release Please](https://github.com/googleapis/release-please) to automate version management and changelog generation. It reads the conventional commit history and determines the next version:

| Commit prefix | Version bump |
|---|---|
| `fix:` | Patch (0.0.x) |
| `feat:` | Minor (0.x.0) |
| `feat!:` or `BREAKING CHANGE:` | Major (x.0.0) |

When unreleased commits accumulate, Release Please opens a Release PR that updates:
- `package.json` — the `"version"` field
- `src/zasis_if_version.intf.abap` — the `version` constant used at ABAP runtime
- `CHANGELOG.md` — with an entry for each commit since the last release

Merging the Release PR triggers a GitHub Release with the corresponding tag.

**Do not manually bump versions.** Release Please manages both version files. Manual edits will conflict with its next automated update.

---

## User Manual Update Workflow (`update-user-manual.yml`)

**Trigger:** When a merged PR carries the `docs:user-manual` label, or manually via `workflow_dispatch` with a PR number.

**What it does:** Creates a GitHub Issue assigned to a Copilot SWE agent with instructions to update `docs/user/manual.md` based on the changes in the merged PR. The issue includes:
- The PR title and number
- The list of changed files
- A structured prompt for the agent describing what to update and how

An idempotency guard (keyed on the label `docs:user-manual-pending`) prevents duplicate issues from being created for the same PR. After creating the issue, a second step assigns it to the `copilot-swe-agent[bot]` using the `COPILOT_PAT` secret.

**Why this workflow?** The user manual documents behaviour from the end-user perspective. Rather than requiring developers to update it manually as part of every PR, this workflow decouples documentation updates from feature work. The label-based trigger means only PRs that change user-facing behaviour produce a docs issue.

**Retroactive backfill:** If the label was added after a PR was merged, the workflow can be triggered manually with the PR number and optionally the `force` flag to bypass the label check.

---

## Technical Docs Update Workflow (`update-technical-docs.yml`)

**Trigger:** When a merged PR carries the `docs:technical` label, or manually via `workflow_dispatch` with a PR number.

**What it does:** Creates a GitHub Issue assigned to a Copilot SWE agent with instructions to update the relevant files under `docs/technical/` based on the changes in the merged PR. The issue includes:
- The PR title and number
- The list of changed files
- A structured prompt for the agent describing which doc files to update (architecture, testing, CI/CD, installation, authorization, off-stack development) and how

An idempotency guard (keyed on the label `docs:technical-pending`) prevents duplicate issues from being created for the same PR. After creating the issue, a second step assigns it to the `copilot-swe-agent[bot]` using the `COPILOT_PAT` secret.

**Why this workflow?** Technical documentation covers contributor and integrator concerns: package architecture, test infrastructure, CI/CD pipelines, and installation procedures. Keeping it in sync with code changes is important but easily overlooked during PR review. This workflow automates the tracking of that obligation via a label-based trigger — if a PR changes something architecturally significant, the author labels it `docs:technical` and an issue is automatically created for the agent to update the relevant doc files.

**Label semantics:**
- `docs:technical` — applied to a PR to signal that technical documentation needs updating. Triggers issue creation on merge.
- `docs:technical-pending` — applied automatically to the generated issue. Used as the idempotency key to prevent duplicate issues for the same PR.

**Retroactive backfill:** If the label was added after a PR was merged, the workflow can be triggered manually with the PR number. The optional `force` flag bypasses the label check entirely, which is intended only for exceptional cases.
