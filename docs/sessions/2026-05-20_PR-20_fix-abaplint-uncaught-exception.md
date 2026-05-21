# ses_1bca6f1a3ffe

**Date:** 2026-05-20
**Title:** Fix abaplint uncaught exception errors (fixes #16, v0.1.1)

## Summary

Added `RAISING zasis_cx_exc` to `zasis_if_event_producer~on_item_interpreted`. Narrowed `CATCH cx_root` → `CATCH zasis_cx_exc` in `call_event_producer`. Replaced `cx_sy_zerodivide` mock raise with `zasis_cx_exc`. Wrapped all bare `execute()` calls in test classes with `TRY/CATCH zasis_cx_exc zasis_cx_no_auth`. Wrapped `set_total_number_of_records`/`set_data` calls in `zasis_cl_get_domain_fix_values` with `TRY/CATCH cx_rap_query_response_set_twic`. Added `uncaught_exception` and `local_variable_names` (no Hungarian prefix) abaplint rules; renamed catch vars to comply. Version bump 0.1.0→0.1.1. All 25 unit tests + 6 HTTP tests green. PR #20 merged.
