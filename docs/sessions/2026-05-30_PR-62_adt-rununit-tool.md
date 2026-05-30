# 2026-05-30 PR-62 adt-rununit-tool

**Date:** 2026-05-30
**Title:** Add adt_rununit OpenCode tool for remote ABAP unit test execution

## Summary

Added a new OpenCode tool `adt_rununit` that triggers ABAP Unit tests on a remote SAP system via `abap-adt-api`. Follows the established core/wrapper split pattern from `adt_gitpull`: `scripts/adt_rununit_core.ts` contains reusable logic and `.opencode/tools/adt_rununit.ts` provides the OpenCode tool wrapper. Supports targeting specific classes (`CLAS`) or packages (`DEVC`), defaulting to the `SAP_ROOT_PACKAGE` env var when no target is specified. Returns a formatted text summary with pass/fail counts, execution time, and detailed failure information including assertion messages and stack locations. Tool errors (connection, auth) throw while test failures return successfully with the summary. All existing tests pass (44 ABAP unit tests, 0 issues from abaplint). PR #62.
