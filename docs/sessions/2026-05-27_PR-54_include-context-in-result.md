# 2026-05-27 PR-54 include-context-in-result

**Date:** 2026-05-27
**Title:** Include interpretation context in interpreter result

## Summary

Implemented issue #15 — the interpreter now returns a wrapper structure `zasis_interpret_output` containing both the interpretation results table (`results`) and the context that was active during interpretation (`context`). This required changing the `zasis_if_interpreter~execute()` return type from `zasis_tt_interpretationresult` to `zasis_interpret_output`, updating the interpreter class to populate `output-context`, adapting the HTTP handler and RAP behavior implementation (`zbp_asis_i_ruleset`), and updating all 32 existing unit tests plus 2 new tests (`test_ctx_returned_in_output`, `test_empty_ctx_returned`). All 34 interpreter tests and 7 exception tests pass; abaplint reports 0 issues across 143 files. Version bumped from 0.3.2 to 0.4.0 (minor — new capability). PR #54.
