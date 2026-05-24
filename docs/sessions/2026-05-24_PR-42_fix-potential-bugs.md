# 2026-05-24 PR-42 fix-potential-bugs

**Date:** 2026-05-24
**Title:** Fix potential bugs: RETURN in loop, overly broad CATCH

## Summary

Fixed two potential bugs from issue #26: replaced RETURN with CONTINUE in the precheck_update LOOP in `zbp_asis_i_ruleset.clas.locals_imp.abap` so that all entities in the loop are validated (not just the first failing one), and narrowed `CATCH cx_root` to `CATCH zasis_cx_exc cx_sy_create_object_error` in `zasis_cl_ev_producer_resolver.clas.abap` to avoid silently swallowing system exceptions. All lint checks pass (0 issues, 142 files) and all 39 transpiled unit tests pass. Version bumped to 0.2.3. PR #42 opened against main.
