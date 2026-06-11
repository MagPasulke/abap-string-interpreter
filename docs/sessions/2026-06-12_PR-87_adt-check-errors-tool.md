# 2026-06-12 PR-87 adt-check-errors-tool

**Date:** 2026-06-12
**Title:** Add adt_checkerrors tool for syntax error detection

## Summary

Added a new `adt_checkerrors` OpenCode tool that runs ATC with the `SYNTAX_CHECK` variant on the SAP system to detect compilation errors after git pull. Initially attempted an `inactiveObjects()` approach but discovered objects stay active with old version when activation fails — pivoted to ATC which correctly surfaces all syntax errors. Also integrated as optional `checkErrors=true` flag on `adt_gitpull`. Live-tested by introducing a deliberate type reference error (`ZASIS_NONEXISTENT_TYPE`) which cascaded across 6 classes (23 findings), then verified clean state after revert (only pre-existing SLIN quality findings remain). Output uses raw priority labels (P1/P2/P3) without interpreting severity. Created `adt-checkerrors` skill, updated `adt-gitpull` skill with new parameter, and added syntax check documentation to AGENTS.md. All local tests pass (lint + typecheck + 53 unit tests). PR #87.
