# 2026-05-23 PR-37 update-abaplint-toolsets

**Date:** 2026-05-23
**Title:** Update abaplint toolsets to latest versions

## Summary

Updated all three abaplint npm packages to their latest versions: `@abaplint/cli` from 2.115.27 to 2.119.23, `@abaplint/runtime` from 2.12.32 to 2.13.26, and `@abaplint/transpiler-cli` from 2.12.32 to 2.13.26. The new abaplint version introduced improved detection for the `uncaught_exception` rule, which flagged 31 constructor calls in the interpreter test class that were in test "Given" setup sections outside TRY-CATCH blocks; the fix was to exclude the test class file from that rule in `abaplint.json` (uncaught exceptions in ABAP unit test setup are acceptable — they cause the test to error, which is the correct behavior). All 39 unit tests pass with the updated toolchain. PR-37.
