# 2026-05-24 PR-39 abaplint-naming-hygiene-rules

**Date:** 2026-05-24
**Title:** Add naming & hygiene abaplint rules

## Summary

Added the remaining abaplint rules from issue #29: `keyword_case` (upper keywords enforced), `method_parameter_names` (snake_case), `class_attribute_names` (snake_case with optional leading underscore, UPPER constants), `functional_writing` (prefer functional calls), and `exporting` (flag redundant EXPORTING keyword). Fixed 22 lint violations: uppercased keywords in `zasis_if_interpreter.intf.abap` and testclasses, corrected `_patH_elements` typo in the HTTP handler, and excluded RAP behavior/CDS-derived files from `keyword_case` since CamelCase entity names are framework-mandated. All 142 files pass lint with 0 issues, transpiled unit tests pass with 0 failures. PR #39 closes #29.
