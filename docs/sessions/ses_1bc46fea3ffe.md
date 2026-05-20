# ses_1bc46fea3ffe

**Date:** 2026-05-20
**Title:** Refactor Custom Logic to Instance-based Resolver (fixes #13)

## Summary

Changed `zasis_if_customlogic` from static to instance method. Created `zasis_if_customlogic_resolver` + `zasis_cl_customlogic_resolver` with DI in interpreter. New shared `zasis_cl_class_validator` utility replacing inline RTTI checks across resolver, event producer resolver, and RAP validations. Added `custom_logic_not_exist`/`custom_logic_no_intf` constants to `zasis_cx_ruleset_ui`. Messages 011-014 in ZASIS_MSGS. Message consistency unit tests using `MESSAGE INTO` (no T100 SELECT). Added no-amend/no-force-push rule to AGENTS.md. 25 transpile tests green. PR #19 merged.
