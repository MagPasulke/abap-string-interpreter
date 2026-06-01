# 2026-06-01 PR-69 docs-user-manual-automation

**Date:** 2026-06-01
**Title:** Add docs:user-manual automation workflow and seed initial user manual

## Summary

PR #69 introduces a GitHub Actions workflow (`.github/workflows/update-user-manual.yml`) that automatically creates a Copilot-assigned GitHub Issue whenever a PR labeled `docs:user-manual` is merged, instructing the Copilot coding agent to update `docs/user/manual.md`. The workflow also supports a retroactive `workflow_dispatch` path with a PR number input and a `force` flag to bypass the label check. Idempotency is enforced by checking for any open issue tagged `docs:user-manual-pending` matching the same PR number before creating a new one. As part of this PR the initial `docs/user/manual.md` was authored from scratch covering all nine user-facing areas (overview, core concepts, RuleSet configuration, ABAP API, HTTP API, custom logic, event producers, authorization, and troubleshooting). The README `### Usage` section was removed as duplicate content, replaced by a link to the manual at the top of Part 1. Both required GitHub labels (`docs:user-manual`, `docs:user-manual-pending`) were created in the repository via `gh label create`. No ABAP source changes were made; `npm test` was not run as this PR contains only documentation and CI automation.
