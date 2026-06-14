# Testing

ZASIS uses three complementary test layers. Each layer covers different concerns and runs in a different environment. Understanding which layer covers what is important for knowing where to add or update tests when making a change.

For the philosophy behind off-stack testing and the toolchain that enables it, see [Off-Stack Development](off-stack-development.md).

---

## Quick Reference

| | ABAP Unit Tests | ICF Shim Tests | HTTP Integration Tests |
|---|---|---|---|
| **Command** | `npm run unit` | `npm run icf-test` | `npm run sap-test` |
| **Runs where** | Node.js (transpiled) | Node.js (transpiled + Express) | Against live SAP system |
| **Needs SAP?** | No | No | Yes |
| **Speed** | ~2s | ~400ms | ~5s+ |
| **Scope** | Single class, mocked deps | Full HTTP stack, SQLite DB | Full system, real auth, HANA |

All three are run in CI: the first two automatically on every push and PR; the SAP integration tests manually via the `deploy-sap` workflow after merge to main.

---

## Layer 1: ABAP Unit Tests

**Command:** `npm run unit`

**What runs:** ABAP Unit test classes decorated with `FOR TESTING`, transpiled to JavaScript and executed in Node.js via the abaplint transpiler.

**Test files:**

| File | What it covers |
|---|---|
| `src/bo/zasis_cl_interpreter.clas.testclasses.abap` | Interpreter logic — 34 test methods |
| `src/utils/zasis_cx_exc.clas.testclasses.abap` | Exception message text consistency |
| `src/bo/zasis_cx_ruleset_ui.clas.testclasses.abap` | RAP exception message text consistency |

**What is tested:**

The interpreter class is tested in complete isolation. All external dependencies are replaced by local mock implementations injected via constructor:

| Mock | Replaces |
|---|---|
| `ltcl_auth_checker_mock` | `ZASIS_IF_AUTH_CHECKER` |
| `ltcl_event_producer_mock` | `ZASIS_IF_EVENT_PRODUCER` |
| `ltcl_ev_producer_resolver_mock` | `ZASIS_IF_EV_PRODUCER_RESOLVER` |
| `ltcl_customlogic_mock` | `ZASIS_IF_CUSTOMLOGIC` |
| `ltcl_customlogic_resolver_mock` | `ZASIS_IF_CUSTOMLOGIC_RESOLVER` |

Scenarios covered include: Match and Replace extraction, no-match behaviour, invalid rule type exception, multiple items in a RuleSet, offset trimming, authorization denial, event producer invocation (on match, not on no-match, correct parameters, error swallowing, context forwarding, resolver routing), custom logic (positive case, class not found, context forwarding, combined with event producer, error swallowing), empty input string exception, context passthrough, and mixed item types.

**What is NOT tested:** HTTP layer, factory and database interaction, JSON serialization, real authorization, real database queries.

---

## Layer 2: ICF Shim Integration Tests

**Command:** `npm run icf-test`

**What runs:** A Node.js Express server hosting the transpiled `ZASIS_CL_HTTP_HANDLER_CORE`, seeded with an in-memory SQLite database. Real HTTP requests are sent against this server using Node's built-in test runner.

**Test files:**

| File | Role |
|---|---|
| `__test/integration/icf.test.mjs` | Test runner — sends HTTP requests, asserts responses |
| `__test/integration/scenarios.mjs` | Shared test scenarios (reused by SAP tests) |
| `__test/integration/helpers/icf-server.mjs` | Starts the Express + shim server, seeds SQLite |
| `__test/integration/serve.mjs` | Standalone server entry point for `npm run icf-server` |

**Full stack under test:**

```
HTTP request
  → Express
    → ICF shim (express-icf-shim)
      → ZASIS_CL_HTTP_HANDLER_CORE (transpiled)
        → ZASIS_CL_RULESET_FACTORY (SQLite via @abaplint/database-sqlite)
          → ZASIS_CL_INTERPRETER (transpiled)
            → /UI2/CL_JSON (transpiled)
              → HTTP response
```

**Scenarios covered:**

| Scenario | What is verified |
|---|---|
| POST — successful extraction | Happy path end-to-end, result JSON structure |
| POST — no match for unknown tags | Interpreter no-match behaviour |
| POST — context returned in output | Context round-trip through the full stack |
| POST — empty string | Returns HTTP 400 with error envelope |
| POST — unknown RuleSet | Returns HTTP 400, factory exception handling |
| POST — wrong Content-Type | Returns HTTP 400, validation logic |
| GET — returns header and items | GET routing and RuleSet serialization |
| GET — unknown RuleSet | Returns HTTP 400 on GET path |
| PUT | Returns HTTP 405, unsupported method handling |

**Error response format:** All errors return a structured JSON envelope:

```json
{
  "ERROR": {
    "CODE": "ZASIS_MSGS/015",
    "MESSAGE": "String to interpret must not be empty",
    "STATUS": "400"
  }
}
```

**Known limitations in the shim environment:**

- `AUTHORITY-CHECK` is a no-op — authorization cannot be tested here
- `/UI2/CL_JSON` serializes integer-valued strings without quotes in some edge cases (unquoted hex values)
- The static RuleSet cache persists across test cases within a single server lifecycle; tests that depend on cache isolation must account for this
- ABAP class names in transpiled output follow a JS naming convention (`ZasisClRulesetFactory`) — this is relevant only when debugging transpiler output

**Running a local server for manual testing:**

```bash
npm run icf-server
# Server starts on http://localhost:3040
```

---

## Layer 3: HTTP Integration Tests (SAP)

**Command:** `npm run sap-test` / `npm run sap-auth-test`

**What runs:** The same shared scenarios from `scenarios.mjs` are executed against a real running SAP system. A separate auth test file covers 401/403 cases that cannot be replicated in the ICF shim.

**Prerequisites:**

- A SAP system with ZASIS installed and the HTTP service or SICF node active
- Credentials in `__test/http/http-client.env.json` (gitignored — never committed)

**What only this layer covers:**

- Real `AUTHORITY-CHECK` execution and 403 responses
- Real HANA database — actual SELECT against `ZASIS_RULESETHD` / `ZASIS_RULESETITM`
- CDS view access control (DCL)
- TLS and network handling
- Exact `/UI2/CL_JSON` behaviour on a real ABAP kernel (no shim quirks)

---

## Coverage Summary

| Concern | Unit | ICF Shim | HTTP/SAP |
|---|:---:|:---:|:---:|
| Interpreter logic (Match/Replace/offsets) | ✅ | ✅ | ✅ |
| Auth denial (403) | ✅ mock | — | ✅ |
| Event producer integration | ✅ mock | — | — |
| Custom logic integration | ✅ mock | — | — |
| HTTP routing | — | ✅ | ✅ |
| Request validation | — | ✅ | ✅ |
| JSON serialization | — | ✅* | ✅ |
| DB read (factory) | — | ✅ SQLite | ✅ HANA |
| Context round-trip | ✅ | ✅ | ✅ |
| Method not allowed (405) | — | ✅ | ✅ |
| HTTP status codes | — | ✅ | ✅ |
| Real auth infrastructure | — | — | ✅ |
| CDS / Access Control | — | — | ✅ implicit |
| Exception message texts | ✅ | — | — |

*JSON serialization in ICF shim has known quirks with unquoted hex values.

---

## When to Add or Update Tests

| Change type | Update |
|---|---|
| New or modified interpreter logic | ABAP Unit tests |
| New event producer or custom logic behaviour | ABAP Unit tests (via mocks) |
| New HTTP route or method | ICF shim tests |
| Changed request or response JSON structure | ICF shim tests + HTTP/SAP tests |
| Changed validation logic | ICF shim tests |
| New authorization rule | HTTP/SAP auth tests |
| Pre-merge confidence check (no SAP) | `npm test` + `npm run icf-test` |
| Final validation before release | HTTP/SAP tests + ABAP Unit on SAP via ADT |
