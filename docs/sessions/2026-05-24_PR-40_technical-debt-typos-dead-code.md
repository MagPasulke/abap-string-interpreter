# 2026-05-24 PR-40 technical-debt-typos-dead-code

**Date:** 2026-05-24
**Title:** Technical Debt: Typos, dead code, inconsistent casing

## Summary

Addressed all items from issue #31 across four files: fixed typo `Authorizaton` → `Authorization` in `zasis_cl_http_handler` (srv layer), fixed typo `unkown` → `unknown` in message class `zasis_msgs` (msg 007), fixed inconsistent constant name casing `duplicate_ruleSetId` → `duplicate_rulesetid` and `no_AUTH` → `no_auth` in `zasis_cx_ruleset_ui`, and removed the dead `sy-subrc` check after a SELECT INTO TABLE statement in `zasis_cl_get_domain_fix_values` adding `##SUBRC_OK` pragma (abaplint preferred pragma over pseudo comment `#EC CI_SUBRC`). All lint checks and 38 transpiled unit tests pass. PR #40.
