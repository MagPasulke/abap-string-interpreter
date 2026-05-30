# 2026-05-30 PR-65 gitpull-branch-support

**Date:** 2026-05-30
**Title:** Enhance adt_gitpull to support pulling from different branches

## Summary

Implemented issue #63 by adding an optional `branch` parameter to the `adtGitPull` core function, OpenCode tool wrapper, and skill documentation. When provided, the branch is passed directly to the SAP API in full ref format (`refs/heads/<name>`); when omitted, it auto-detects from the currently checked-out git branch via `git rev-parse --abbrev-ref HEAD`. Discovered during testing that `gitPullRepo` alone does not switch the SAP-side branch — added `switchRepoBranch` call before pull to fix this. Also added `typescript` as devDependency with a `typecheck` npm script (included in `npm test`), removed unused `jest` dependency (290 packages), updated AGENTS.md to use unified `npm test` command everywhere, and added chat-mode-only usage notes to both adt_* skill docs. Verified end-to-end: feature branch synced to SAP, dummy constants appeared, cleanup confirmed, 51/51 ABAP Unit tests pass. PR #65 against `main`.
