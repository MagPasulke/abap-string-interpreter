---
name: adt-rununit
description: Run ABAP Unit tests on the remote SAP system via ADT.
---

## Tool

Use the built-in `adt_rununit` custom tool.

### Parameters (all optional)

| Parameter | Description |
|-----------|-------------|
| `objectType` | `CLAS` (class) or `DEVC` (package). Defaults to `DEVC` when omitted. |
| `objectName` | ABAP object name (e.g. `ZASIS_CL_INTERPRETER` or `ZASIS`). If omitted, uses `SAP_ROOT_PACKAGE` from `.env`. |

### Examples

- Run all tests in the root package: `adt_rununit()` (no args)
- Run tests for a specific class: `adt_rununit(objectType="CLAS", objectName="ZASIS_CL_INTERPRETER")`
- Run tests for a specific package: `adt_rununit(objectType="DEVC", objectName="ZASIS")`

## What it does

1. Reads SAP credentials from `.env` in the project root (`SAP_ADT_URL`, `SAP_ADT_USER`, `SAP_ADT_PASSWORD`)
2. Resolves target object (from parameters or `SAP_ROOT_PACKAGE` env var)
3. Connects to the SAP system via ADT API
4. Triggers ABAP Unit test execution on the target object
5. Returns a formatted summary: pass/fail counts, execution time, and failure details (class, method, assertion, stack)

## When to use

Only when the user explicitly requests running unit tests on SAP. Typical scenarios:
- After syncing code to SAP via `adt_gitpull`, user says "run tests" or "run unit tests"
- User wants to verify a specific class passes tests: "run tests for ZASIS_CL_INTERPRETER"
- Final verification before merging a PR

**Never call autonomously.** Always wait for user trigger.

## Prerequisites

- `.env` in project root with valid credentials (see `.env.example`):
  ```
  SAP_ADT_URL=https://your-sap-system:44300
  SAP_ADT_USER=DEVELOPER
  SAP_ADT_PASSWORD=secret
  SAP_ROOT_PACKAGE=ZASIS
  ```
