# 2026-06-04 PR-72 sorted-table-unique-key-ruleset-cache

**Date:** 2026-06-04
**Title:** Replace BINARY SEARCH with sorted table unique key + VALUE OPTIONAL in ruleset cache

## Summary

Refactored `zasis_tt_rulesetrefs` from a default-key sorted table to a sorted table with explicit unique key on `RULESET_ID` (ACCESSMODE=S, KEYDEF=K, KEYKIND=U), following guidance from the blog post "Binary Search in ABAP — What is Dead May Never Die". The `TRY/CATCH cx_sy_itab_line_not_found` block in `zasis_cl_ruleset_factory` was replaced with the cleaner `VALUE zasis_ruleset_refs( table_expression OPTIONAL )` pattern, eliminating silent exception abuse. A transpiler limitation prevented inline component access on `VALUE OPTIONAL`, so the result is split into a `DATA(cached)` interim variable. The ttyp XML went through several correction cycles — the final correct abapGit serialization (confirmed by pushing from SAP and pulling back) uses KEYDEF=K/KEYKIND=U with a DD42V key component block. A pre-existing unit test failure caused by stale npm dependencies was resolved by running `npm install`. All local tests (lint + unit) pass; PR #72 covers this branch.
