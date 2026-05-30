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

## When to use

Only when the user explicitly requests running unit tests on SAP. Typical scenarios:
- After syncing code to SAP via `adt_gitpull`, user says "run tests" or "run unit tests"
- User wants to verify a specific class passes tests: "run tests for ZASIS_CL_INTERPRETER"
- Final verification before merging a PR

**Never call autonomously.** Always wait for user trigger.
