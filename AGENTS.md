# ZASIS - ABAP String Interpreter

## Project Overview

ZASIS is an ABAP-based String Interpreter that allows configuring RuleSets to extract structured information from strings (e.g. barcodes, data matrix codes, scanned values). It uses regex-based rules (MATCH and REPLACE types) with configurable offsets and supports custom logic extensibility.

**This is an ABAP project without a live SAP system connection.** All source files are stored in the **abapGit serialized file format** so the repository can be synced to an ABAP system via [abapGit](https://docs.abapgit.org/). The workspace contains `.clas.abap`, `.intf.abap`, `.ddls.asddls`, `.tabl.xml`, `.doma.xml`, `.dtel.xml`, `.bdef.asbdef`, `.srvd.srvdsrv`, and other abapGit-standard file types. There are many agent skills available (prefixed `abapgit-*`) that help create files in the correct abapGit format for each object type (CLAS, INTF, TABL, DDLS, DOMA, DTEL, BDEF, SRVD, SRVB, FUGR, etc.). **Always use the appropriate skill when creating new ABAP repository objects** to ensure correct file structure and XML metadata.

**Target System**: ABAP Cloud Trial 2022 SP01 (ABAP Platform 2022 / SAP BASIS 757 SP0004).

---

## Git Workflow

**NEVER commit or push directly to `main`.** Always follow this workflow:

1. Create a feature branch (e.g., `feat/my-feature`, `fix/my-bugfix`)
2. Commit changes to the feature branch, **always use the `conventional-commit` skill**
3. Push the feature branch to the remote
4. Create a Pull Request (PR) against `main`
5. Merge the PR (squash preferred)
6. Delete the feature branch (local + remote)

This applies to ALL changes — code, documentation, skills, configuration. No exceptions.

**PR merging is the user's responsibility by default.** Agents must:
- **Ask the user** before creating a PR (do not create PRs autonomously)
- **Never merge PRs** unless the user explicitly instructs the agent to merge
- Wait for the user's explicit confirmation before creating or merging

**Clean commit history on feature branches.** Agents must:
- **Never amend commits** — each change gets its own commit
- **Never force-push** (`--force`, `--force-with-lease`) — history must remain linear and traceable
- If a fix is needed after a commit, create a new commit with a clear message (e.g., `fix: resolve duplicate attribute in zasis_cx_exc`)
- The commit history should tell the story of what happened, including fixes

---

## Architecture & Package Structure

```
src/                          Root package (ZASIS)
├── app/                      Application / UI layer (placeholder for future UI components)
├── bo/                       Business Objects — core domain logic & RAP service
├── config/                   Configuration management & eventing
│   └── eventing/             Event producer configuration & maintenance
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

### srv (HTTP Service)

REST API for external consumers:

- **`zasis_cl_http_handler`** — Routes GET (retrieve RuleSet) and POST (execute RuleSet) requests
- Local request validator for path parsing and content-type checks

### config (Configuration & Eventing)

- Event configuration tables and maintenance function group (`zasis_conf_maint`)
- `zasis_if_event_producer` interface for event-driven extensibility

### utils (Utilities)

- **`zasis_constants`** — Static constants (rule types, HTTP methods, content types)
- **`zasis_cx_exc`** — Custom exception class with T100 messages (invalid route, unknown ruleset, etc.)
- **`zasis_cl_get_domain_fix_values`** — RAP query provider for domain fixed values

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

### New Feature Implementation

When implementing a new feature, **always use the `grill-me` skill first** to interview the user about the design and plan before writing any code. This ensures shared understanding of requirements, dependencies, and edge cases before implementation begins.

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

---

## Session Tracking

At the end of each session — **before merging the PR** — create a session summary using the `session-summary` skill. Session summaries are stored as individual files in `docs/sessions/` with the session ID as filename. The summary must be committed to the feature branch before merge.
