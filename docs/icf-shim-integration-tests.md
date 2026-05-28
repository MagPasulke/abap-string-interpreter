# ICF Shim Integration Tests — Architecture & How It Works

## Overview

The ICF (Internet Communication Framework) shim integration tests allow us to test the ABAP HTTP handler (`zasis_cl_http_handler`) **without a running SAP system**. They work by:

1. **Transpiling** all ABAP source code to JavaScript (ESM modules)
2. Running the transpiled code in **Node.js** with an in-memory SQLite database
3. Using the **express-icf-shim** library to bridge Express.js HTTP requests into the ABAP `IF_HTTP_EXTENSION~HANDLE_REQUEST` interface
4. Sending real HTTP requests to the Express server and asserting on responses

This gives us true end-to-end integration testing of the HTTP handler's routing, request parsing, validation, interpretation logic, and JSON serialization — all locally, in milliseconds.

---

## The Technology Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Runner (node:test)                    │
│  handler.test.mjs — sends HTTP requests via fetch()          │
└───────────────────────────────┬──────────────────────────────┘
                                │ HTTP on localhost:3040
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    Express.js Server                          │
│  start.mjs — routes all /zasis/* to the ICF shim             │
└───────────────────────────────┬──────────────────────────────┘
                                │ app.all("/zasis/*", ...)
                                ▼
┌─────────────────────────────────────────────────────────────┐
│              express-icf-shim (cl_express_icf_shim)           │
│  Converts Express req/res ↔ IF_HTTP_SERVER interface         │
│  Creates IF_HTTP_REQUEST / IF_HTTP_RESPONSE objects           │
│  Maps headers, body, method, path_info, query_string         │
└───────────────────────────────┬──────────────────────────────┘
                                │ calls li_handler->handle_request(server)
                                ▼
┌─────────────────────────────────────────────────────────────┐
│          zasis_cl_http_handler (transpiled ABAP)              │
│  The actual ABAP handler running as JavaScript                │
│  Routes GET → handle_get(), POST → handle_post()             │
│  Uses zasis_cl_ruleset_factory, zasis_cl_interpreter         │
└───────────────────────────────┬──────────────────────────────┘
                                │ SELECT FROM zasis_rulesethd / zasis_rulesetitm
                                ▼
┌─────────────────────────────────────────────────────────────┐
│              In-Memory SQLite Database                        │
│  @abaplint/database-sqlite (SQLiteDatabaseClient)            │
│  Registered as abap.context.databaseConnections["DEFAULT"]   │
│  Tables: zasis_rulesethd, zasis_rulesetitm                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Components

### 1. ABAP Transpiler (`@abaplint/transpiler-cli`)

The transpiler converts ABAP source files into ES modules (`.mjs` files) in the `output/` directory.

**Configuration**: `abap_transpile.json`
```json
{
  "input_folder": "src",
  "output_folder": "output",
  "libs": [
    { "url": "https://github.com/open-abap/open-abap-core" },
    { "url": "https://github.com/open-abap/express-icf-shim" }
  ],
  "write_unit_tests": true,
  "options": { "unknownTypes": "compileError" }
}
```

- **`input_folder`**: reads all `.clas.abap`, `.intf.abap`, etc. from `src/`
- **`libs`**: external ABAP libraries fetched from GitHub and transpiled together:
  - `open-abap-core`: provides standard SAP classes (`/ui2/cl_json`, `cl_http_entity`, `cl_http_utility`, etc.)
  - `express-icf-shim`: provides `cl_express_icf_shim` — the bridge class
- **`output_folder`**: all transpiled `.mjs` files land in `output/`

**Running the transpiler**: `npx @abaplint/transpiler-cli` (or via `npm run unit` which transpiles then runs tests)

The transpiler also generates `output/init.mjs` which:
- Creates the global `abap` runtime object
- Defines CREATE TABLE statements for all transparent tables (as arrays: `sqlite[]`, `hdb[]`, `pg[]`, `snowflake[]`)
- Defines INSERT statements for seed data (t100 messages, tadir entries, reposrc class source)
- Registers all transpiled classes/interfaces in the ABAP runtime's class registry

**Important**: `initializeABAP()` does NOT set up the database itself. It only prepares the ABAP runtime (type system, class registry, etc.). Database initialization must be done separately.

---

### 2. The ABAP Runtime (`@abaplint/runtime`)

This npm package provides the JavaScript runtime that makes transpiled ABAP code work:

- **`globalThis.abap`** — the global ABAP runtime object (created in `init.mjs`)
- **`abap.types.*`** — ABAP type constructors:
  - `Character(length, options)` — ABAP `TYPE c`
  - `Numc({length})` — ABAP `TYPE n` (numeric text)
  - `Integer` — ABAP `TYPE i`
  - `Packed({length, decimals})` — ABAP `TYPE p`
  - `Hex({length})` — ABAP `TYPE x` (raw/hex bytes)
  - `XString` — ABAP `TYPE xstring`
  - `String` — ABAP `TYPE string`
  - `Structure({...fields})` — ABAP structure
  - `Table` / `TableFactory` — ABAP internal tables
- **`abap.statements.*`** — ABAP statement implementations:
  - `insertDatabase(tableName, {values: structure})` — INSERT INTO transparent table
  - `selectDatabase(...)` — SELECT from transparent table
  - `updateDatabase(...)`, `deleteDatabase(...)`, etc.
- **`abap.context`** — runtime context:
  - `abap.context.databaseConnections["DEFAULT"]` — the default DB connection (must be set!)
  - `abap.context.databaseConnections["CONNECTION_NAME"]` — named secondary connections

---

### 3. The SQLite Database (`@abaplint/database-sqlite`)

Provides `SQLiteDatabaseClient` — an in-memory SQLite implementation of the runtime's `DatabaseClient` interface.

```javascript
import dbPkg from '@abaplint/database-sqlite';
const {SQLiteDatabaseClient} = dbPkg;

const db = new SQLiteDatabaseClient();
await db.connect();  // creates in-memory SQLite instance

// Create tables (DDL copied from output/init.mjs)
await db.execute(`CREATE TABLE 'zasis_rulesethd' (...);`);

// Register as the DEFAULT database connection
abap.context.databaseConnections["DEFAULT"] = db;
```

The `DatabaseClient` interface methods:
- `connect()` / `disconnect()`
- `execute(sql)` — run raw SQL (DDL, DML)
- `insert({table, columns, values})` — used internally by `abap.statements.insertDatabase`
- `select({select})` — used internally by `abap.statements.selectDatabase`
- `update(...)`, `delete(...)`, `beginTransaction()`, `commit()`, `rollback()`

**Why manual setup?** The transpiler generates the CREATE TABLE DDL in `init.mjs` but doesn't execute it — it's up to the consuming test harness to:
1. Create a `SQLiteDatabaseClient` instance
2. Execute the DDL statements
3. Register it on `abap.context.databaseConnections["DEFAULT"]`

---

### 4. The Express-ICF-Shim (`cl_express_icf_shim`)

This is an ABAP class (from the `express-icf-shim` library) that bridges Express.js and ABAP's ICF:

```javascript
// JavaScript side — Express route handler
app.all("/zasis/*", async function (req, res) {
  await cl_express_icf_shim.run({
    req,        // Express Request object
    res,        // Express Response object
    class: "ZASIS_CL_HTTP_HANDLER",  // ABAP class implementing IF_HTTP_EXTENSION
    base: new abap.types.String().set("/zasis")  // URL prefix to strip for ~path_info
  });
});
```

What `cl_express_icf_shim.run()` does internally (in transpiled ABAP):

1. **Creates an ABAP HTTP server** (`lcl_server` implementing `IF_HTTP_SERVER`)
2. **Populates the request object** from Express's `req`:
   - `req.body` → `IF_HTTP_REQUEST->SET_DATA()` (as xstring)
   - `req.method` → `~request_method` header field
   - `req.headers` → all header fields
   - `req.url` → `~request_uri`
   - `req.path` minus `base` → `~path_info` (this is how our handler knows the route!)
3. **Instantiates the ABAP handler** via `CREATE OBJECT li_handler TYPE (class_name)`
4. **Calls** `li_handler->handle_request(server)` — this is the real ABAP handler executing
5. **Maps the response** back to Express:
   - Status code, headers, body → `res.status(...).send(Buffer)`

The `base` parameter is critical: if the Express route is `/zasis/ruleSetExecution/TestRS`, and `base` is `/zasis`, then `~path_info` becomes `/ruleSetExecution/TestRS` — exactly what the ABAP handler expects.

---

### 5. The ABAP HTTP Handler (`zasis_cl_http_handler`)

This is the actual ABAP class being tested. It implements `IF_HTTP_EXTENSION~HANDLE_REQUEST`:

```abap
METHOD if_http_extension~handle_request.
  CASE server->request->get_method( ).
    WHEN 'GET'.   " handle_get() → returns RuleSet as JSON
    WHEN 'POST'.  " handle_post() → executes RuleSet interpretation
    WHEN OTHERS.  " returns 405
  ENDCASE.
ENDMETHOD.
```

The handler delegates to `zasis_lcl_http_handler` (local class in `*.locals_imp.abap`) which:
- Parses `~path_info` to extract the route and RuleSet ID
- Validates content-type, request body, etc.
- Uses `zasis_cl_ruleset_factory` to load the RuleSet from DB
- Uses `zasis_cl_interpreter` to execute rules against the input string
- Serializes results to JSON via `/ui2/cl_json`

---

## File Structure

```
__test/integration/
├── scenarios.mjs       Shared test scenarios (single source of truth)
├── icf.test.mjs        ICF shim runner (node:test, localhost:3040)
├── sap.test.mjs        SAP runner (node:test, real SAP system)
├── sap-auth.test.mjs   SAP-only auth tests (401/403)
├── serve.mjs           Standalone server for manual curl testing
└── helpers/
    ├── icf-server.mjs  Server setup: DB init, data seeding, Express app
    └── sap-client.mjs  SAP connection config loader

output/                 Transpiled JavaScript (generated, gitignored)
├── init.mjs            Runtime initialization + DDL schemas
├── zasis_cl_http_handler.clas.mjs
├── zasis_cl_interpreter.clas.mjs
├── zasis_cl_ruleset_factory.clas.mjs
├── cl_express_icf_shim.clas.mjs
├── %23ui2%23cl_json.clas.mjs    (note: # encoded as %23)
└── ... (hundreds of transpiled modules)
```

---

## How `start.mjs` Works (Step by Step)

```javascript
// 1. Import dependencies
import express from 'express';
import dbPkg from '@abaplint/database-sqlite';
const {SQLiteDatabaseClient} = dbPkg;
import {initializeABAP} from "../../output/init.mjs";
import {cl_express_icf_shim} from "../../output/cl_express_icf_shim.clas.mjs";

// 2. Initialize the ABAP runtime (class registry, type system, etc.)
await initializeABAP();

// 3. Create and configure the in-memory SQLite database
const db = new SQLiteDatabaseClient();
await db.connect();
await db.execute(`CREATE TABLE 'zasis_rulesethd' (...);`);
await db.execute(`CREATE TABLE 'zasis_rulesetitm' (...);`);

// 4. Register the DB as the DEFAULT connection — critical!
//    Without this, any SELECT/INSERT in ABAP code throws "database not initialized"
abap.context.databaseConnections["DEFAULT"] = db;

// 5. Seed test data using the ABAP runtime's insertDatabase API
async function seedTestData() {
  // Create an ABAP structure matching the table's fields
  const header = new abap.types.Structure({
    client: new abap.types.Character(3, {qualifiedName: "MANDT"}),
    rulesetuuid: new abap.types.Hex({length: 16}),
    rulesetid: new abap.types.Character(30),
    // ... all fields matching the DB table columns
  });
  // Set field values
  header.get().client.set("000");
  header.get().rulesetuuid.set("AABBCCDD11223344");
  header.get().rulesetid.set("TestRS");
  
  // Insert into the in-memory SQLite DB
  // Note: pass table name as string, use {values: structure} for single row
  await abap.statements.insertDatabase("zasis_rulesethd", {values: header});
}

// 6. Export startServer function (used by test file)
export async function startServer(quiet) {
  await seedTestData();
  
  const app = express();
  app.use(express.raw({type: "*/*"}));  // parse body as raw Buffer
  
  // Route all requests to the ICF shim
  app.all("/zasis/*", async function (req, res) {
    await cl_express_icf_shim.run({
      req, res,
      class: "ZASIS_CL_HTTP_HANDLER",
      base: new abap.types.String().set("/zasis")
    });
  });
  
  return app.listen(3040);
}
```

---

## How `handler.test.mjs` Works

```javascript
import { describe, it, before, after } from 'node:test';
import assert from 'node:assert/strict';
import {startServer} from './start.mjs';

let server;

// Start server once before all tests (DB + Express + seed data)
before(async () => { server = await startServer(true); });
after(async () => { server.close(); });

// Helper: sends HTTP request and parses response
async function request(method, path, { body, contentType } = {}) {
  const res = await fetch(`http://localhost:3040/zasis${path}`, { method, headers, body });
  // Parse JSON response (with workaround for hex serialization quirk)
  let text = await res.text();
  text = text.replace(/:([0-9A-Fa-f]{16,})/g, ':"$1"');  // quote unquoted hex
  return { status: res.status, body: JSON.parse(text) };
}

// Tests exercise the full HTTP flow:
describe('POST /ruleSetExecution', () => {
  it('TestRS extracts MaterialNo from barcode', ...);
  it('TestRS returns no match for unrecognized tags', ...);
  it('Context is returned in the output', ...);
  it('Empty string returns 400', ...);
  it('Unknown RuleSet returns 400', ...);
  it('Wrong Content-Type returns 400', ...);
});
```

---

## Why `node:test` Instead of Jest?

The transpiled output files use `#` in filenames (e.g., `#ui2#cl_json.clas.mjs`). The transpiler's `init.mjs` imports them as `%23ui2%23cl_json.clas.mjs` (URL-encoded). This works in Node.js's native ESM loader but **breaks Jest's module resolver**, which doesn't handle URL-encoded `%23` paths. Using Node.js's built-in `node:test` runner avoids this entirely.

**Run command**: `node --test __test/icf/handler.test.mjs`

---

## Known Quirks & Workarounds

### 1. Unquoted Hex Values in JSON

The transpiled `/ui2/cl_json` serializer doesn't quote hex (`TYPE x`) and numc (`TYPE n`) values in JSON output. For example:

```json
{"RULESETUUID":AABBCCDD112233440000000000000000,"INTERPRETATIONITM":00010000000000000000000000000000}
```

**Workaround**: The test helper applies a regex to quote values that look like unquoted hex:
```javascript
text = text.replace(/:([0-9A-Fa-f]{16,})/g, ':"$1"');
```

### 2. Field Casing Uncertainty

The transpiled `/ui2/cl_json` may serialize field names in UPPER or lower case depending on runtime context. Tests handle both:
```javascript
const results = body.RESULTS || body.results;
```

### 3. AUTHORITY-CHECK is a No-Op

In the transpiled runtime, `AUTHORITY-CHECK OBJECT ...` always sets `sy-subrc = 0` (authorized). This means:
- 403/Forbidden scenarios cannot be tested in the ICF shim
- Auth testing is covered by unit tests with a mocked `zasis_if_auth_checker`

### 4. Static Cache in `zasis_cl_ruleset_factory`

The factory class caches loaded rulesets in a static variable. Since all tests run in-process, the cache persists across tests. Currently not a problem (all tests use the same "TestRS" fixture), but if tests need isolation, call the factory's `clear_cache()` method between tests.

### 5. Type Name Mapping (ABAP → JS Runtime)

| ABAP Type | JS Runtime Constructor |
|-----------|----------------------|
| `TYPE c(n)` | `abap.types.Character(n)` |
| `TYPE n(n)` | `abap.types.Numc({length: n})` |
| `TYPE i` | `abap.types.Integer` |
| `TYPE p LENGTH l DECIMALS d` | `abap.types.Packed({length: l, decimals: d})` |
| `TYPE x LENGTH n` | `abap.types.Hex({length: n})` |
| `TYPE xstring` | `abap.types.XString()` |
| `TYPE string` | `abap.types.String()` |

### 6. `insertDatabase` API

Two call patterns:
- **Single row**: `abap.statements.insertDatabase("table_name", {values: structure})`
- **Internal table** (multiple rows): `abap.statements.insertDatabase("table_name", {table: internalTable})`
  - The `table` parameter must have an `.array()` method (be an ABAP internal table type)

---

## How to Add New Test Scenarios

### Adding a new RuleSet fixture

In `start.mjs`'s `seedTestData()`, add more INSERT statements:

```javascript
const newHeader = new abap.types.Structure({ /* ... fields ... */ });
newHeader.get().rulesetid.set("MyNewRS");
// ... set other fields ...
await abap.statements.insertDatabase("zasis_rulesethd", {values: newHeader});

// Add corresponding items...
```

### Adding a new test case

In `handler.test.mjs`:

```javascript
it('my new scenario', async () => {
  const { status, body } = await request('POST', '/ruleSetExecution/MyNewRS', {
    body: { string_to_be_interpreted: 'my input string' },
  });
  assert.equal(status, 200);
  // ... assertions on body ...
});
```

---

## How to Run

```bash
# Prerequisites: transpile first (generates output/)
npx @abaplint/transpiler-cli    # or: npm run unit (which transpiles + runs unit tests)

# Run ICF integration tests
npm run icf-test

# Run same scenarios against SAP (requires credentials)
npm run sap-test

# Run SAP-only auth tests
npm run sap-auth-test

# Start standalone server for manual curl testing
npm run icf-server
```

---

## Comparison with Other Test Approaches

| Approach | What it tests | Needs SAP? | Speed |
|----------|--------------|-----------|-------|
| `npm run unit` (transpiled unit tests) | Individual class methods, interpreter logic | No | ~2s |
| ICF shim tests (this doc) | Full HTTP handler end-to-end | No | ~400ms |
| `npm run http-test` (Jest + fetch) | Real HTTP against SAP system | Yes | ~5s+ |
| ABAP Unit (on-system) | Everything including RAP, auth, DB | Yes | ~10s |

The ICF shim tests fill the gap between isolated unit tests and full on-system integration tests. They catch:
- Routing logic bugs
- Request validation issues
- JSON serialization problems
- Factory/interpreter integration issues
- HTTP status code correctness

They cannot catch:
- Authorization (AUTHORITY-CHECK) failures
- RAP behavior (managed BO operations)
- CDS view logic (access control, associations)
- Database-specific behavior (real HANA vs SQLite differences)

---

## Dependencies (devDependencies)

| Package | Purpose |
|---------|---------|
| `express` | HTTP server framework |
| `@abaplint/runtime` | ABAP type system + statement execution in JS |
| `@abaplint/database-sqlite` | In-memory SQLite DB implementing DatabaseClient |
| `@abaplint/transpiler-cli` | Transpiles ABAP → JavaScript |

The `express-icf-shim` library is **not** an npm package — it's an ABAP library fetched by the transpiler from GitHub and transpiled alongside the project source. It becomes `output/cl_express_icf_shim.clas.mjs`.
