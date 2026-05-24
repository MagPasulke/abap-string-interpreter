# 2026-05-24 PR-42 fix-potential-bugs

**Date:** 2026-05-24
**Title:** Fix potential bugs: RETURN in loop, overly broad CATCH

## Summary

Fixed potential bugs from issue #26: (1) replaced RETURN with CONTINUE in the precheck_update LOOP in `zbp_asis_i_ruleset.clas.locals_imp.abap` so all entities are validated, (2) narrowed `CATCH cx_root` to `CATCH zasis_cx_exc cx_sy_create_object_error` in `zasis_cl_ev_producer_resolver.clas.abap`, and (3) replaced overly broad `CATCH cx_root` with `CATCH cx_rap_query_filter_no_range cx_sy_move_cast_error` in `zasis_cl_get_domain_fix_values.clas.abap`, removing dead variables and returning empty result for expected failures while letting unexpected exceptions propagate. All lint checks pass (0 issues, 142 files) and all 39 transpiled unit tests pass. Version bumped to 0.2.3. PR #42 opened against main.
