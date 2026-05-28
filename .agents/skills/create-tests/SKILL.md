---
name: create-tests
description: Detailed guidance on which test layer(s) to update and how to write tests for different kinds of changes in the ZASIS project.
---

# Create / Adapt Tests

This skill guides you on **where** and **how** to write tests for changes in ZASIS. The project has three test layers.

For architecture details of the ICF shim tests, see [`docs/icf-shim-integration-tests.md`](../../../docs/icf-shim-integration-tests.md).
For a full comparison of all layers, see [`docs/test-layer-comparison.md`](../../../docs/test-layer-comparison.md).

---

## Core Principle: ICF Shim and HTTP Tests Must Have Equal Coverage

**ICF shim tests and HTTP tests always cover the same scenarios.** The only exception is authorization (401/403), which can only be tested against real SAP.

To enforce this, the integration tests use a **shared test scenario file** that runs against both targets:

```
__test/integration/
├── scenarios.mjs          ← shared test scenarios (target-agnostic)
├── icf.test.mjs           ← runs scenarios against ICF shim (localhost:3040)
├── sap.test.mjs           ← runs scenarios against real SAP system
├── sap-auth.test.mjs      ← SAP-only: auth tests (401/403)
└── helpers/
    ├── icf-server.mjs     ← ICF shim server setup + seed data
    └── sap-client.mjs     ← SAP connection config loader
```

When adding a new integration test scenario, **always add it to the shared file**. It automatically runs in both environments. Only add to `sap-auth.test.mjs` if it tests authorization behavior.

---

## Decision Matrix: Which Layer(s) to Update

| What changed | Unit tests | Integration tests (shared) | SAP-only auth tests |
|---|:---:|:---:|:---:|
| Interpreter logic (match, replace, offset, custom logic) | **Yes** | **Yes** | — |
| New exception / error message | **Yes** | **Yes** (if surfaced via HTTP) | — |
| Event producer / custom logic interface behavior | **Yes** | — | — |
| HTTP handler routing (new endpoint, path change) | — | **Yes** | — |
| Request validation (content-type, body parsing) | — | **Yes** | — |
| Response JSON structure change | — | **Yes** | — |
| Factory logic (DB read, caching) | — | **Yes** | — |
| Authorization behavior | — | — | **Yes** |
| New RuleSet item type or field | **Yes** | **Yes** | — |

**Rule of thumb**: If it's observable via HTTP (except auth) → add to shared integration scenarios. If it tests internal class logic → unit tests. If it tests auth → SAP-only auth file.

---

## Layer 1: ABAP Unit Tests

### Location

```
src/bo/zasis_cl_interpreter.clas.testclasses.abap   ← interpreter tests (34 methods)
src/utils/zasis_cx_exc.clas.testclasses.abap        ← exception message consistency
src/bo/zasis_cx_ruleset_ui.clas.testclasses.abap    ← RAP exception message consistency
```

### Pattern

Tests use mock classes for all dependencies:

```abap
CLASS ltcl_test DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.
  PRIVATE SECTION.
    DATA cut            TYPE REF TO zasis_cl_interpreter.
    DATA auth_mock      TYPE REF TO ltcl_auth_checker_mock.
    DATA ev_resolver    TYPE REF TO ltcl_ev_producer_resolver_mock.
    DATA cl_resolver    TYPE REF TO ltcl_customlogic_resolver_mock.
    METHODS setup.
    METHODS test_my_scenario FOR TESTING.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.
  METHOD setup.
    auth_mock = NEW ltcl_auth_checker_mock( ).
    ev_resolver = NEW ltcl_ev_producer_resolver_mock( ).
    cl_resolver = NEW ltcl_customlogic_resolver_mock( ).
    cut = NEW zasis_cl_interpreter(
      auth_checker            = auth_mock
      event_producer_resolver = ev_resolver
      customlogic_resolver    = cl_resolver ).
  ENDMETHOD.

  METHOD test_my_scenario.
    " Arrange: build ruleset with items
    DATA(items) = VALUE zasis_tt_rulesetitm( (
      intpretationtarget  = 'MyField'
      interpretationrule  = '<TAG>([^<]*)'
      interpretation_type = '1'   " MATCH
      offset_pre          = 5
      offset_post         = 0
    ) ).
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetid = 'TEST' )
      items  = items ).

    " Act
    DATA(output) = cut->zasis_if_interpreter~execute(
      ruleset                  = ruleset
      string_to_be_interpreted = '<TAG>MyValue' ).

    " Assert
    cl_abap_unit_assert=>assert_equals(
      act = output-results[ 1 ]-interpretationresult
      exp = 'MyValue' ).
  ENDMETHOD.
ENDCLASS.
```

### How to Add a Test

1. Open `src/bo/zasis_cl_interpreter.clas.testclasses.abap`
2. Add a new `METHOD test_xxx FOR TESTING.` declaration in the test class definition
3. Implement the method following the Arrange/Act/Assert pattern above
4. Run `npm test` to verify it passes in transpile mode

### When Mocks Need Updating

If you add a new method to an interface (e.g., `zasis_if_auth_checker`), you must also add the method implementation to the corresponding mock class in the test file, even if it's empty.

---

## Layer 2 & 3: Integration Tests (Shared Scenarios)

### Architecture

Integration tests use a **shared scenario approach**:

1. **`scenarios.mjs`** defines all test scenarios as functions that accept a `request` helper
2. **`icf.test.mjs`** provides a `request` helper pointing at `localhost:3040` (ICF shim)
3. **`sap.test.mjs`** provides a `request` helper pointing at the real SAP system
4. **`sap-auth.test.mjs`** contains auth-only tests (cannot run against ICF shim)

This guarantees both environments run identical assertions.

### Shared Scenarios Pattern (`scenarios.mjs`)

```javascript
/**
 * Shared integration test scenarios.
 * Each function receives a `request(method, path, options)` helper
 * and uses the test framework's assertion API.
 */

export function postExecutionTests(describe, it, assert, request, ruleSetId) {
  describe('POST /ruleSetExecution', () => {
    it(`${ruleSetId} extracts MaterialNo from barcode`, async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>' },
      });
      assert.equal(status, 200);
      const results = body.RESULTS || body.results;
      const mat = results.find(r => (r.TARGETFIELD || r.targetfield) === 'MaterialNo');
      assert.ok(mat, 'Expected MaterialNo result');
      assert.equal(mat.INTERPRETATIONRESULT || mat.interpretationresult, 'MyMaterialNumber');
    });

    it(`${ruleSetId} returns no match for unrecognized tags`, async () => { /* ... */ });
    it('Empty string returns 400', async () => { /* ... */ });
    it('Unknown RuleSet returns 400', async () => { /* ... */ });
    it('Wrong Content-Type returns 400', async () => { /* ... */ });
    // ... all shared scenarios
  });
}

export function getTests(describe, it, assert, request, ruleSetId) {
  describe('GET /ruleSet', () => {
    it(`${ruleSetId} returns 200 with header and items`, async () => { /* ... */ });
    it('Unknown RuleSet returns 400', async () => { /* ... */ });
  });
}

export function methodTests(describe, it, assert, request, ruleSetId) {
  describe('Unsupported methods', () => {
    it('PUT returns 405', async () => { /* ... */ });
  });
}
```

### ICF Test Runner (`icf.test.mjs`)

```javascript
import { describe, it, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { startServer } from './helpers/icf-server.mjs';
import { postExecutionTests, getTests, methodTests } from './scenarios.mjs';

let server;
before(async () => { server = await startServer(true); });
after(async () => { server.close(); });

async function request(method, path, opts) {
  // ... fetch against localhost:3040, handle hex quoting quirk
}

const RULESET = 'TestRS';  // seeded in ICF shim DB

postExecutionTests(describe, it, assert, request, RULESET);
getTests(describe, it, assert, request, RULESET);
methodTests(describe, it, assert, request, RULESET);
```

### SAP Test Runner (`sap.test.mjs`)

```javascript
import { describe, it } from 'node:test';  // or Jest — adapt as needed
import assert from 'node:assert/strict';
import { postExecutionTests, getTests, methodTests } from './scenarios.mjs';

const env = loadSapEnv();  // reads http-client.env.json

async function request(method, path, opts) {
  // ... fetch against SAP baseUrl with auth headers
}

const RULESET = 'MySample';  // must exist on SAP system

postExecutionTests(describe, it, assert, request, RULESET);
getTests(describe, it, assert, request, RULESET);
methodTests(describe, it, assert, request, RULESET);
```

### SAP-Only Auth Tests (`sap-auth.test.mjs`)

```javascript
describe('Authorization', () => {
  it('GET without auth returns 401 or 403', async () => {
    const { status } = await requestWithoutAuth('GET', '/ruleSet/MySample');
    assert.ok([401, 403].includes(status));
  });
});
```

### How to Add a New Integration Test

1. **Add the scenario to `scenarios.mjs`** — this is the single source of truth
2. If new seed data is needed, add it to `helpers/icf-server.mjs` in `seedTestData()`
3. Ensure the corresponding RuleSet/data exists on the SAP system too
4. Run `npm run icf-test` to verify locally
5. Note in PR that `npm run sap-test` should be run on SAP to confirm parity

### Key Rule

> **Never add an integration test to only one runner.** If a scenario is added to `icf.test.mjs` but not to `sap.test.mjs` (or vice versa), the parity invariant is violated. The shared `scenarios.mjs` file prevents this by design.

---

## How to Add Seed Data (ICF Shim)

In `__test/integration/helpers/icf-server.mjs`, inside `seedTestData()`:

```javascript
const header = new abap.types.Structure({
  client: new abap.types.Character(3, {qualifiedName: "MANDT"}),
  rulesetuuid: new abap.types.Hex({length: 16}),
  rulesetid: new abap.types.Character(30),
  // ... all table fields
});
header.get().client.set("000");
header.get().rulesetuuid.set("AABBCCDD11223344");
header.get().rulesetid.set("MyNewRS");
await abap.statements.insertDatabase("zasis_rulesethd", {values: header});
```

**Type mapping (ABAP -> JS runtime):**

| ABAP Type | JS Constructor |
|-----------|---------------|
| `TYPE c(n)` | `abap.types.Character(n)` |
| `TYPE n(n)` | `abap.types.Numc({length: n})` |
| `TYPE i` | `abap.types.Integer` |
| `TYPE p LENGTH l DECIMALS d` | `abap.types.Packed({length: l, decimals: d})` |
| `TYPE x LENGTH n` | `abap.types.Hex({length: n})` |
| `TYPE xstring` | `abap.types.XString()` |
| `TYPE string` | `abap.types.String()` |

---

## Debugging Integration Tests

```bash
# Run a single ICF test by name pattern
node --test --test-name-pattern="extracts MaterialNo" __test/integration/icf.test.mjs

# Start server standalone for manual curl testing
npm run icf-server

# Then in another terminal:
curl -X POST http://localhost:3040/zasis/ruleSetExecution/TestRS \
  -H "Content-Type: application/json" \
  -d '{"string_to_be_interpreted":"<A7X>Hello"}'
```

### Known Quirks (ICF Shim Only)

- `/ui2/cl_json` emits unquoted hex — the `request()` helper patches with regex
- Field names may be UPPER or lower — always check both: `body.RESULTS || body.results`
- AUTHORITY-CHECK is a no-op — cannot test 403 scenarios here
- `node:test` is used instead of Jest because Jest can't resolve `%23`-encoded filenames

---

## Checklist: Before Committing

1. `npm run lint` passes
2. `npm run unit` passes (transpiled ABAP unit tests)
3. `npm run icf-test` passes (integration tests against ICF shim)
4. Note in PR that `npm run sap-test` must be verified on SAP (same scenarios)

---

## Adding a Brand New Test Class (ABAP Unit)

If testing a new class that doesn't have a testclasses file yet:

1. Create `src/<package>/<classname>.clas.testclasses.abap`
2. Follow the pattern: mock dependencies, instantiate CUT, write test methods
3. Ensure the class is NOT in `exclude_filter` in `abap_transpile.json` (or tests won't transpile)
4. Run `npm test` to confirm transpile + execution works

---

## Adding ICF Shim Tests for a New Table

If the handler reads from a new transparent table:

1. Check `output/init.mjs` for the CREATE TABLE DDL (generated by transpiler)
2. Copy the DDL into `__test/integration/helpers/icf-server.mjs` after `db.connect()`
3. Add seed data using `abap.statements.insertDatabase("new_table", {values: ...})`
4. The transpiler must be re-run first if the table is new (`npm run unit` does this)
