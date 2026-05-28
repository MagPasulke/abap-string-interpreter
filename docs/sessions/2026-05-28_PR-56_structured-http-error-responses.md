# 2026-05-28 PR-56 structured-http-error-responses

**Date:** 2026-05-28
**Title:** Structured JSON error responses for HTTP API

## Summary

Reworked the ZASIS HTTP API error responses (issue #4) to return machine-readable JSON instead of plain HTTP reason text. Added `http_status` attribute (TYPE string, default '400') and `method_not_supported` constant (T100 message 016) to `zasis_cx_exc`, created `lcl_error_response` local class in the HTTP handler for JSON serialization via `/ui2/cl_json`, simplified the handler to a single TRY block with unified error catch paths, replaced inline 405 handling with a raised exception, and ensured all error responses include `Content-Type: application/json` with body `{"ERROR":{"CODE":"ZASIS_MSGS/NNN","MESSAGE":"...","STATUS":"NNN"}}`. Updated ICF shim integration tests to assert on the structured error envelope. All tests pass: abaplint 0 issues, transpiled unit tests green, ICF shim integration 12/12 pass.
