# Test Layer Comparison

This document compares the three test layers in the ZASIS project: what each covers, where they run, and what gaps remain.

---

## Summary Table

| | Unit Tests (ABAP) | ICF Shim Tests | HTTP Tests (SAP) |
|---|---|---|---|
| **Runs where** | Node.js (transpiled) + SAP system | Node.js (transpiled) | Against live SAP system |
| **Command** | `npm run unit` / SE38 | `npm run icf-test` | `npm run sap-test` |
| **Framework** | ABAP Unit (FOR TESTING) | `node:test` (Node built-in) | `node:test` (Node built-in) |
| **Needs SAP?** | No (transpiled) / Yes (on-system) | No | Yes |
| **Speed** | ~2s (transpiled) | ~400ms | ~5s+ (network) |
| **Test scenarios** | 34 methods + 2 msg tests | Shared scenarios (12 tests) | Same shared scenarios (12 tests) |
| **Scope** | Single class, mocked deps | Full HTTP handler stack | Full system incl. auth |

---

## Layer 1: Unit Tests (ABAP)

**Files:**
- `src/bo/zasis_cl_interpreter.clas.testclasses.abap` (34 test methods)
- `src/utils/zasis_cx_exc.clas.testclasses.abap` (message consistency)
- `src/bo/zasis_cx_ruleset_ui.clas.testclasses.abap` (message consistency)

**What they test:**

The interpreter class (`zasis_cl_interpreter`) in isolation with mocked dependencies:

| Mock | Replaces |
|------|----------|
| `ltcl_auth_checker_mock` | `zasis_if_auth_checker` |
| `ltcl_event_producer_mock` | `zasis_if_event_producer` |
| `ltcl_ev_producer_resolver_mock` | `zasis_if_ev_producer_resolver` |
| `ltcl_customlogic_mock` | `zasis_if_customlogic` |
| `ltcl_customlogic_resolver_mock` | `zasis_if_customlogic_resolver` |

**Scenarios covered:**

- MATCH type: successful extraction, no match
- REPLACE type: regex substitution, no-match behavior
- Invalid interpretation type raises exception
- Multiple items processed in sequence
- Offset handling (pre, post, combined, zeroing)
- Auth denial raises `zasis_cx_no_auth`
- Event producer: called on match, not called on no-match/empty, receives correct params
- Event producer: error doesn't break interpretation flow
- Event producer: context forwarded correctly
- Event producer: resolver receives correct class name
- Custom logic: positive case, not-found handling, context forwarding
- Custom logic: combined with event producer
- Custom logic: error doesn't break interpretation flow
- Empty string raises exception
- Context passthrough in output structure
- Mixed item types in single ruleset

**What they DON'T test:**

- HTTP layer (routing, request parsing, response serialization)
- Factory / database interaction (ruleset loading from DB)
- JSON serialization via `/ui2/cl_json`
- Real authorization (AUTHORITY-CHECK)
- Real database SELECTs

---

## Layer 2: ICF Shim Integration Tests

**Files:**
- `__test/integration/icf.test.mjs` (shared scenarios runner)
- `__test/integration/scenarios.mjs` (shared scenario definitions)
- `__test/integration/helpers/icf-server.mjs` (server setup + data seeding)
- `__test/integration/serve.mjs` (standalone server for manual curl)

**What they test:**

The full HTTP handler stack running as transpiled JavaScript with an in-memory SQLite database:

```
HTTP request → Express → ICF shim → zasis_cl_http_handler
  → zasis_lcl_http_handler (local class: routing + validation)
    → zasis_cl_ruleset_factory (DB read)
      → zasis_cl_interpreter (execution)
        → /ui2/cl_json (serialization)
          → HTTP response
```

**Scenarios covered:**

| Test | Verifies |
|------|----------|
| POST extracts MaterialNo | Happy path: routing + factory + interpreter + JSON response |
| POST no match for unknown tags | Interpreter returns "no match" for all items |
| POST context returned in output | Context array round-trips through the handler |
| POST empty string → 400 | Input validation in local handler class |
| POST unknown RuleSet → 400 | Factory raises exception → handler returns 400 |
| POST wrong Content-Type → 400 | Content-type validation |
| GET returns header + items | GET routing + factory + JSON serialization |
| GET unknown RuleSet → 400 | Factory exception handling on GET path |
| PUT → 405 | Unsupported method handling |

**What they DON'T test:**

- Authorization (AUTHORITY-CHECK is a no-op in transpiled runtime)
- Real HANA database behavior (uses SQLite — different collation, types)
- CDS views and access control (DCL)
- RAP managed BO operations (draft, validations, determinations)
- SAP system-level behavior (client handling, logon, sessions)

**What they uniquely cover (not in other layers):**

- HTTP routing correctness (path_info parsing)
- Request/response serialization end-to-end
- Factory ↔ Interpreter integration with real DB reads
- Content-Type and method validation
- JSON output structure from `/ui2/cl_json`
- HTTP status codes for each error category

---

## Layer 3: HTTP Integration Tests (Against SAP)

**Files:**
- `__test/integration/sap.test.mjs` (shared scenarios, same as ICF)
- `__test/integration/sap-auth.test.mjs` (auth-only, SAP-exclusive)
- `__test/integration/scenarios.mjs` (shared scenario definitions)
- `__test/http/http-client.env.json` (connection config, gitignored)

**Prerequisites:** Running SAP system with ZASIS deployed, valid credentials in env file.

**What they test:**

The real deployed SICF handler on the SAP system over HTTP:

```
HTTP request → SAP ICF → zasis_cl_http_handler
  → real AUTHORITY-CHECK
  → real DB SELECT (HANA)
  → real /ui2/cl_json
  → HTTP response
```

**Scenarios covered:**

| Test | Verifies |
|------|----------|
| GET MySample → 200 with header+items | Real DB read + serialization |
| GET unknown → 400 | Real exception handling |
| GET without auth → 401/403 | **Real authentication rejection** |
| POST extracts MaterialNo | Full real execution |
| POST no matching tag → no match | Real interpreter behavior |
| POST unknown RuleSet → 400 | Real factory exception |
| POST with context → 200 | Context round-trip on real system |
| POST empty context array → 200 | Edge case handling |
| POST empty string → 400 | Real validation |
| POST missing field → 400 | Real JSON deserialization handling |
| POST wrong Content-Type → 400 | Real content-type check |
| PUT → 405 | Real method routing |

**What they uniquely cover (not in other layers):**

- Real AUTHORITY-CHECK (auth object ZASIS_GRL)
- Real HANA database behavior
- Real SAP ICF infrastructure (session, client)
- Real `/ui2/cl_json` serialization (correct casing, quoting)
- Missing `string_to_be_interpreted` field handling (JSON deserialization edge case)
- Network-level concerns (timeouts, TLS, SAP logon)

---

## Coverage Gap Analysis

| Concern | Unit | ICF Shim | HTTP/SAP |
|---------|:----:|:--------:|:--------:|
| Interpreter logic (match/replace/offset) | ✅ | ✅ | ✅ |
| Auth denial (403) | ✅ (mock) | ❌ | ✅ |
| Event producer integration | ✅ (mock) | ❌ | ❌ |
| Custom logic integration | ✅ (mock) | ❌ | ❌ |
| HTTP routing | ❌ | ✅ | ✅ |
| Request validation | ❌ | ✅ | ✅ |
| JSON serialization | ❌ | ✅* | ✅ |
| DB read (factory) | ❌ | ✅ (SQLite) | ✅ (HANA) |
| Context in output | ✅ | ✅ | ✅ |
| Method not allowed (405) | ❌ | ✅ | ✅ |
| Status codes correct | ❌ | ✅ | ✅ |
| Real auth infra | ❌ | ❌ | ✅ |
| CDS / Access Control | ❌ | ❌ | ✅ (implicit) |
| RAP BO operations | ❌ | ❌ | ❌ (separate UI) |
| Exception message texts | ✅ | ❌ | ❌ |

*JSON serialization in ICF shim has known quirks (unquoted hex) that differ from real system behavior.

---

## When to Use Which

| Situation | Use |
|-----------|-----|
| Adding new interpreter logic (rules, offsets, types) | Unit tests |
| Adding new event producer / custom logic behavior | Unit tests (with mocks) |
| Changing HTTP routing or adding endpoints | ICF shim tests |
| Changing request/response JSON structure | ICF shim tests + HTTP tests |
| Changing validation logic | ICF shim tests |
| Verifying auth behavior | HTTP tests (on SAP) |
| Pre-merge confidence (no SAP needed) | `npm test` (lint + unit) + `npm run icf-test` |
| Final validation before release | HTTP tests on SAP + ABAP Unit on SAP |

---

## Running All Local Tests

```bash
# Full local validation (no SAP needed):
npm test              # lint + transpiled unit tests
npm run icf-test      # ICF shim integration tests (shared scenarios)

# Against SAP (requires running system + credentials):
npm run sap-test      # same shared scenarios against real SAP
npm run sap-auth-test # auth-only tests (SAP exclusive)
```
