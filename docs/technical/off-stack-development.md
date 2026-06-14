# Off-Stack Development

ZASIS uses an unconventional development approach for an ABAP project: the majority of the development loop — writing code, linting, and running tests — happens entirely outside of a SAP system, on a developer's local machine or in CI.

This page explains why that approach was chosen, how it works technically, and what its limitations are.

---

## The Problem with Classic ABAP Development

Traditional ABAP development is tightly coupled to a running SAP system. Code lives in the system, tests run in the system, and CI typically means deploying to a system and hoping it compiles. This creates several friction points:

- Each developer needs access to a shared or personal SAP instance
- Code changes require upload (via abapGit or ADT) before they can be tested
- CI pipelines that require SAP access are slow, expensive, and hard to parallelize
- Pull request reviews cannot run tests automatically without SAP credentials in the pipeline

ZASIS takes a different path: as much of the development and testing loop as possible runs off-stack, treating the SAP system as the final integration environment rather than the primary development environment.

---

## The Toolchain

### ABAP Transpiler (`@abaplint/transpiler-cli`)

The [abaplint transpiler](https://github.com/abaplint/transpiler) converts ABAP source code into JavaScript (ESM). The output is a set of `.mjs` modules that can run in Node.js, including ABAP Unit test classes decorated with `FOR TESTING`.

Configuration: `abap_transpile.json` at the project root.

The transpiled output is written to `output/` (gitignored) and executed directly by Node.js. ABAP Unit test results are printed to stdout in the same format as running tests in SE80 or ADT.

### ABAP Runtime (`@abaplint/runtime`)

The transpiler output depends on an ABAP runtime library that provides Node.js implementations of built-in ABAP types, string operations, table operations, exception mechanics, and more. This is what makes transpiled ABAP behave semantically like real ABAP without an ABAP kernel.

### Static Analysis (`abaplint`)

[abaplint](https://github.com/abaplint/abaplint) performs static analysis on the ABAP source files without a SAP system. It enforces naming conventions, keyword casing, unused variable detection, abapdoc presence, and other rules defined in `abaplint.jsonc`.

abaplint runs as the first step of `npm test` and as a pre-merge gate in CI. It catches a large class of errors — typos, naming violations, unreachable code — before anything is uploaded to SAP.

### ICF Shim (`express-icf-shim`)

The ICF shim is a bridge that allows the transpiled `ZASIS_CL_HTTP_HANDLER_CORE` to handle real HTTP requests in Node.js. It works as follows:

```
HTTP request
  → Express (Node.js HTTP server)
    → express-icf-shim (adapts Express req/res to IF_HTTP_EXTENSION contract)
      → Transpiled ZASIS_CL_HTTP_HANDLER_CORE (routing, validation, interpreter)
        → In-memory SQLite (via @abaplint/database-sqlite)
          → HTTP response
```

The shim translates Express request/response objects into the interfaces that `ZASIS_CL_HTTP_HANDLER_CORE` expects (`ZASIS_IF_HTTP_REQUEST` / `ZASIS_IF_HTTP_RESPONSE`). Because the core handler was deliberately designed to depend only on those custom interfaces — not on SAP's `IF_HTTP_EXTENSION` or `IF_HTTP_SERVICE_EXTENSION` directly — it runs identically in Node.js and on a real SAP system.

The in-memory SQLite database is seeded with test fixture data at startup, replacing HANA for the duration of the test run.

This setup allows the full HTTP handler stack — routing, request validation, RuleSet loading, interpretation, and JSON serialization — to be tested locally and in CI without any SAP system.

---

## What Can and Cannot Be Tested Off-Stack

### Can be tested off-stack

| Concern | Mechanism |
|---|---|
| Interpreter logic (Match, Replace, offsets, Custom Logic, context) | ABAP Unit tests via transpiler |
| Exception message text consistency | ABAP Unit tests via transpiler |
| HTTP routing and method dispatch | ICF shim integration tests |
| Request validation (content type, empty string, missing RuleSet) | ICF shim integration tests |
| RuleSet loading from database | ICF shim integration tests (SQLite fixture) |
| JSON serialization of results | ICF shim integration tests |
| HTTP status codes | ICF shim integration tests |
| Static analysis and naming conventions | abaplint |

### Cannot be tested off-stack

| Concern | Reason |
|---|---|
| `AUTHORITY-CHECK` / real authorization | `AUTHORITY-CHECK` is a no-op in the transpiled runtime |
| Real HANA database behavior | SQLite semantics differ; CDS views cannot be evaluated |
| CDS view access control (DCL) | Requires a real ABAP kernel |
| RAP behavior (validations, actions, draft) | RAP framework is not available in the transpiler runtime |
| PCRE regex parameter | `@abaplint/runtime` does not currently implement the `pcre =` parameter |
| ICF node registration and activation | Requires SAP system administration |

These gaps are closed by the HTTP integration test suite (`npm run sap-test`, `npm run sap-auth-test`) and by running ABAP Unit tests on the real SAP system via ADT after syncing via abapGit.

---

## The Development Loop

A typical change follows this flow:

1. Edit ABAP source locally (`.clas.abap`, `.intf.abap`, etc.)
2. Run `npm test` — lint + transpile + unit tests, all off-stack (~2–5 seconds)
3. Run `npm run icf-test` for HTTP handler changes — full stack integration, off-stack (~400ms)
4. Commit and push — CI runs the same checks automatically
5. When ready: sync to SAP via abapGit (`adt_gitpull`) and run ABAP Unit tests on-stack (`adt_rununit`)

Steps 1–4 require no SAP connection. Step 5 is the final gate before merge.
