# ZASIS - ABAP String Interpreter

## Project Overview

ZASIS is an ABAP-based String Interpreter that allows configuring RuleSets to extract structured information from strings (e.g. barcodes, data matrix codes, scanned values). It uses regex-based rules (MATCH and REPLACE types) with configurable offsets and supports custom logic extensibility.

**This is an ABAP project without a live SAP system connection.** All source files are stored in the **abapGit serialized file format** so the repository can be synced to an ABAP system via [abapGit](https://docs.abapgit.org/). The workspace contains `.clas.abap`, `.intf.abap`, `.ddls.asddls`, `.tabl.xml`, `.doma.xml`, `.dtel.xml`, `.bdef.asbdef`, `.srvd.srvdsrv`, and other abapGit-standard file types. There are many agent skills available (prefixed `abapgit-*`) that help create files in the correct abapGit format for each object type (CLAS, INTF, TABL, DDLS, DOMA, DTEL, BDEF, SRVD, SRVB, FUGR, etc.). **Always use the appropriate skill when creating new ABAP repository objects** to ensure correct file structure and XML metadata.

**Target System**: ABAP Cloud Trial 2022 SP01 (ABAP Platform 2022 / SAP BASIS 757 SP0004).

### Versioning

The project version is maintained in two places that **must always be kept in sync**:

1. `package.json` — `"version"` field (used by npm scripts and release tooling)
2. `src/zasis_if_version.intf.abap` — `version` constant (used at ABAP runtime)

When bumping the version, **always update both files** to the same value.

---

## Git Workflow

**NEVER commit or push directly to `main`.** Always follow this workflow:

### When to enter the workflow

Only enter this workflow when the user signals intent to **implement something** (feature, fix, refactor, config change). Do NOT enter for general questions, Q&A, or exploratory discussions.

**As soon as intent is detected**, load the `grill-me` skill and begin interviewing — before creating the branch. Skip grilling only for trivial tasks (typos, renames, small fixes), or when the user explicitly opts out ("just do it").

### Implementation Workflow

1. **Grill** — load `grill-me` skill and clarify intent (see above). Skip if trivial or user opts out.
2. **Create feature branch** from `main` (infer name from user's request, e.g., `feat/add-empty-regex-validation`)
3. **Push with empty commit** (`git commit --allow-empty -m "chore: initialize feature branch"` && `git push`)
4. **Open draft PR** against `main`
5. **Implement** the changes
6. **Write/enhance unit tests** — Add unit tests for new functionality and update existing tests for modified behavior
7. **Run `npm run lint && npm test`**
   - If pass → commit & push
   - If fail → attempt one fix cycle; if still failing, report errors to user and wait for guidance
8. **Repeat steps 5–7** for each logical unit of work (multiple commits are encouraged for traceability)
9. **Bump version** — suggest patch/minor/major based on the nature of changes, then update both version files in a single commit:
   - `package.json` → `"version"` field
   - `src/zasis_if_version.intf.abap` → `version` constant
   - Guidelines: `patch` for fixes/refactors/style; `minor` for new features or capabilities; `major` for breaking changes
10. **Create session summary** as the final commit (using `session-summary` skill)
11. **Mark PR ready for review**
    - PR description includes: "⚠️ Please sync to SAP system via abapGit and run ABAP Unit tests before merging."

This applies to ALL changes — code, documentation, skills, configuration. No exceptions.

### Commit Rules

- **Always use the `conventional-commit` skill** for every commit
- **Never amend commits** — each change gets its own commit
- **Never force-push** (`--force`, `--force-with-lease`) — history must remain linear and traceable
- **Only commit when tests pass** — never push code that fails `npm run lint && npm test`
- If a fix is needed after a commit, create a new commit with a clear message (e.g., `fix: resolve duplicate attribute in zasis_cx_exc`)
- The commit history should tell the story of what happened, including fixes

### Merging

- **Agent never merges autonomously** — user always merges, or explicitly asks agent to merge
- Before merging, user must sync to SAP system and confirm ABAP Unit tests pass
- Squash merge preferred (collapses branch commits into one on `main`)
- Delete feature branch (local + remote) after merge

> **Future note:** This conservative approach (manual on-stack sync & test from feature branch + manual merge) may be replaced with automated pipeline sync and auto-merge on green in the future.

---

## Architecture & Package Structure

```
src/                          Root package (ZASIS)
├── app/                      Application / UI layer (placeholder for future UI components)
├── auth/                     Authorization — auth checks, access control (DCL), auth objects
├── bo/                       Business Objects — core domain logic & RAP service
├── dm/                       Data Model — database tables, domains, data elements, CDS views
├── srv/                      HTTP Service — REST API handler (GET/POST for RuleSet operations)
└── utils/                    Shared utilities — constants, exceptions, domain value helpers
```

### dm (Data Model)

Database schema and type definitions:

- **Tables**: `zasis_rulesethd` (RuleSet header), `zasis_rulesetitm` (RuleSet items/rules), `zasis_ruleset_refs` (cache)
- **CDS Views**: `zasis_i_ruleset` (composite root), `zasis_i_rulesetheader`, `zasis_i_rulesetitem`
- **Domains/Data Elements**: Types for UUID, RuleSet ID, regex patterns, offsets, target fields, interpretation types (MATCH=1, REPLACE=2)
- **Table Types**: `zasis_tt_rulesetitm`, `zasis_tt_interpretationresult`, `zasis_tt_rulesetrefs`

### bo (Business Objects)

Core domain logic, RAP behavior, and consumption layer:

- **`zasis_cl_interpreter`** — Main execution engine; interprets strings against rulesets using regex MATCH/REPLACE rules
- **`zasis_cl_ruleset`** — Immutable ruleset container (header + items)
- **`zasis_cl_ruleset_factory`** — Factory with in-memory caching and auth checks
- **`zbp_asis_i_ruleset`** — RAP Behavior Implementation for managed entity with draft
- **Consumption CDS**: `zasis_c_ruleset`, `zasis_c_rulesetitem` (Fiori Elements annotations)
- **Service Definition**: `zasis_ui_ruleset.srvd` — OData V4 service exposing RuleSet and RuleSetItem
- **Interfaces**: `zasis_if_interpreter`, `zasis_if_ruleset`, `zasis_if_customlogic`

### auth (Authorization)

Authorization layer:

- **`zasis_cl_auth_checker`** — Authorization check implementation
- **`zasis_if_auth_checker`** — Authorization checker interface
- **`zasis_cx_no_auth`** — Authorization exception
- **Access Control (DCL)**: `zasis_ac_ruleset`, `zasis_ac_rulesetheader`, `zasis_ac_rulesetitm`, `zasis_ac_c_ruleset`, `zasis_ac_c_rulesetitm`
- **Auth Objects**: `zasis_grl` (SUSO), `zasis_rule` (AUTH), `zasi` (SUSC)

### srv (HTTP Service)

REST API for external consumers:

- **`zasis_cl_http_handler`** — Routes GET (retrieve RuleSet) and POST (execute RuleSet) requests
- Local request validator for path parsing and content-type checks

### utils (Utilities)

- **`zasis_constants`** — Static constants (rule types, HTTP methods, content types)
- **`zasis_cx_exc`** — Custom exception class with T100 messages (invalid route, unknown ruleset, etc.)
- **`zasis_cl_get_domain_fix_values`** — RAP query provider for domain fixed values
- **`zasis_cl_class_validator`** — Class validation utility

---

## Exception Handling

All exceptions inherit from `cx_static_check` (checked exceptions declared in method signatures).

### Class Hierarchy

```
cx_static_check
├── zasis_cx_exc              (general-purpose, non-final) — src/utils/
│   └── zasis_cx_ruleset_ui   (RAP/UI-specific, final) — src/bo/
└── zasis_cx_no_auth          (authorization, final) — src/auth/
```

### Message Class

A single message class **`ZASIS_MSGS`** (`src/bo/zasis_msgs.msag.xml`) centralizes all user-facing messages. Each message has a 3-digit number and up to 4 placeholder variables (`&1`–`&4`).

### T100 Message Integration

All exception classes implement `if_t100_message` (and `if_t100_dyn_msg`). Messages are bound to exceptions via **constant structures** declared in the exception class:

```abap
CONSTANTS: BEGIN OF unknown_ruleset,
             msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
             msgno TYPE symsgno      VALUE '007',
             attr1 TYPE scx_attrname VALUE 'RULESET',
             attr2 TYPE scx_attrname VALUE '',
             attr3 TYPE scx_attrname VALUE '',
             attr4 TYPE scx_attrname VALUE '',
           END OF unknown_ruleset.
```

The `attr1`–`attr4` fields reference **instance attribute names** of the exception class. At runtime, the framework resolves `&1`–`&4` placeholders by reading those attribute values from the exception instance.

### How to Raise Exceptions

**Simple (no variables):**
```abap
RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>string_to_interpret_empty ).
```

**With message variable (attribute supplies `&1`):**
```abap
RAISE EXCEPTION NEW zasis_cx_exc(
  textid  = zasis_cx_exc=>unknown_ruleset
  ruleset = lv_ruleset_id
).
```

**Authorization (minimal, default text):**
```abap
RAISE EXCEPTION NEW zasis_cx_no_auth( ).
```

### RAP Behavior Messages (`zasis_cx_ruleset_ui`)

This subclass additionally implements `if_abap_behv_message`, allowing the same exception to serve as a RAP validation/action message with severity control:

- Constructor accepts a `severity` parameter (default: `if_abap_behv_message=>severity-error`)
- Used inside RAP behavior implementations — the exception is appended to `reported`/`failed` tables and rendered in Fiori Elements UIs

### Rules for Adding New Exceptions

1. **Add the message text** to `ZASIS_MSGS` with the next available message number
2. **Add a constant structure** in the appropriate exception class mapping `msgid`, `msgno`, and `attr1`–`attr4` to class attributes
3. **Add corresponding attributes** (READ-ONLY) to the exception class if the message has placeholders
4. **Wire the attribute** in the constructor (accept as parameter, assign to instance attribute)
5. If the exception is for **RAP validations/actions**, use `zasis_cx_ruleset_ui`; otherwise use `zasis_cx_exc`
6. For **authorization failures**, use `zasis_cx_no_auth`

---

## MCP Servers

Two MCP servers are configured in `.vscode/mcp.json` to assist development:

1. **`abap-mcp`** (`mcp_abap-mcp_*` tools) — General ABAP development assistance:
   - `mcp_abap-mcp_abap_feature_matrix` — Check ABAP feature availability across platform versions to ensure compatibility with the target release (757)
   - `mcp_abap-mcp_abap_lint` — ABAP linting support
   - `mcp_abap-mcp_sap_community_search` / `mcp_abap-mcp_search` — Search SAP community and documentation
   - `mcp_abap-mcp_sap_get_object_details` / `mcp_abap-mcp_sap_search_objects` — Look up SAP standard object details

2. **`sap-released-objects`** (`mcp_sap-released-_sap_*` tools) — SAP released objects reference:
   - `mcp_sap-released-_sap_check_clean_core_compliance` — **Verify that used SAP objects are released for Cloud development / Clean Core compliance**
   - `mcp_sap-released-_sap_find_successor` — Find successors for deprecated objects
   - `mcp_sap-released-_sap_get_object_details` — Get details about released objects
   - `mcp_sap-released-_sap_search_objects` — Search for released SAP objects

**Use `mcp_abap-mcp_abap_feature_matrix`** when writing new ABAP code to verify syntax/feature availability on the target platform version.
**Use `mcp_sap-released-_sap_check_clean_core_compliance`** when referencing SAP standard objects to ensure Clean Core compliance.

### When to Research Before Implementing

For **complex ABAP RESTful RAP features** (e.g. new behavior definitions, validations, determinations, actions, draft handling, side effects, authorization, feature control, event bindings), **always research SAP documentation first** using the MCP tools before writing code. Use `mcp_abap-mcp_sap_community_search`, `mcp_abap-mcp_search`, or `mcp_abap-mcp_sap_get_object_details` to look up the correct patterns, annotations, and syntax. This is not necessary for simple, well-known coding tasks — but RAP has many nuances and version-specific behaviors that require consulting official documentation to get right.

### Token Efficiency

**The `caveman` skill should be used by default** to minimize token consumption. It cuts token usage while keeping full technical accuracy. Supports intensity levels: `lite`, `full` (default), `ultra`, plus `wenyan` variants for classical Chinese compression. Only disable when the user explicitly requests verbose/normal output ("stop caveman", "normal mode").

---

## Testing

The project has multiple test layers. See `package.json` for npm scripts:

| Script | Command | Description |
|--------|---------|-------------|
| `npm run lint` | `abaplint` | Static analysis using abaplint (rules in `abaplint.json`) |
| `npm run unit` | Transpile + run in Node.js | Transpiles ABAP to JS via `abap_transpile.json` and runs unit tests |
| `npm test` | `lint` + `unit` | Runs both lint and transpiled unit tests |
| `npm run http-test` | `httpyac` | Integration tests against a running HTTP server (`__test/http/tests.http`) |

### Important Testing Notes

- **ABAP Transpile Tests** (`npm run unit`): Runs unit tests of the project via abap transpile.
- **HTTP Integration Tests** (`npm run http-test`): Require the SAP ABAP server to be running and accessible. Environment variables (`baseUrl`, `client`, `auth_b64`) must be configured in `.vscode/settings.json` under `rest-client.environmentVariables.local`.
- **ABAP Unit Tests**: The authoritative test suite runs on the ABAP system itself. **After making changes, always ask the user to sync the project to the ABAP system via abapGit, run the ABAP Unit tests there, and confirm the results before considering the change complete.**

### Writing & Maintaining Tests

- **New functionality** must include unit tests that verify the expected behavior
- **Modified behavior** must have existing tests updated to reflect the changes
- Tests must pass locally (`npm run unit`) before committing
- When adding tests for a class, check existing test classes first and extend them rather than creating parallel test structures

---
