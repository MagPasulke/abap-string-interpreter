# 2026-05-30 PR-65 gitpull-branch-support

**Date:** 2026-05-30
**Title:** Enhance adt_gitpull to support pulling from different branches

## Summary

Implemented issue #63 by adding an optional `branch` parameter to the `adtGitPull` core function, OpenCode tool wrapper, and skill documentation. When provided, the branch is passed directly to the SAP API in full ref format (`refs/heads/<name>`); when omitted, it auto-detects from the currently checked-out git branch via `git rev-parse --abbrev-ref HEAD`. The branch is always passed explicitly to `client.gitPullRepo()` (no reliance on SAP-side defaults). The CI script required no changes since `actions/checkout` checks out `main` and auto-detect resolves correctly. All lint and transpiled unit tests pass (0 issues, 44 test methods green). PR #65 created against `main`.
