# 2026-06-11 PR-85 copy-ruleset-factory-action

**Date:** 2026-06-11
**Title:** Add copyRuleSet factory action

## Summary

Implemented a RAP factory action `copyRuleSet` on the RuleSet BO (closes #84) that deep-copies an existing ruleset including all items into a new draft instance. Created abstract entity `ZASIS_A_COPYRULESET` with parameters `new_ruleset_id`, `copy_event_producer`, and `copy_custom_logic`. The handler reads source header + items via EML, conditionally clears EventProducer/CustomLogic fields based on boolean flags, and creates the new instance with CREATE BY association for child items. Added UI annotations for the action button on both list report and object page, and exposed the action in the projection BDEF. During SAP activation, fixed several issues: removed `lock: none` (incompatible with factory action on ABAP Platform 2022 SP01), corrected derived type DATA declaration, fixed table expression syntax (KEY keyword, entity secondary key), and added field-level `@EndUserText.label` annotations to override default "Truth Value" labels. All local tests pass (`npm test` — lint + typecheck + 52 unit tests, `npm run icf-test` — 19 integration tests) and SAP ABAP Unit tests pass (61/61).
