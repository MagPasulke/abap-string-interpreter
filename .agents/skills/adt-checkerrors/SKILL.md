---
name: adt-checkerrors
description: Run ATC syntax check on the SAP system to detect syntax errors after git pull.
---

## Tool

Use the built-in `adt_checkerrors` custom tool.

### Parameters

None. Uses `SAP_ROOT_PACKAGE` from `.env` as the check scope.

## What it does

1. Reads SAP credentials from `.env` (`SAP_ADT_URL`, `SAP_ADT_USER`, `SAP_ADT_PASSWORD`, `SAP_ROOT_PACKAGE`)
2. Connects to the SAP system via ADT API
3. Runs ATC (ABAP Test Cockpit) with the `SYNTAX_CHECK` variant on the root package
4. Retrieves the worklist with all findings
5. Returns findings with object name, type, line number, priority (P1/P2/P3), check title, and message text

## Output

Findings are returned without severity interpretation. Priority is a ranking (1=high, 2=medium, 3=low), not a severity level. When real syntax errors exist (e.g. unknown types, missing methods), the finding count increases significantly and messages contain obvious compilation failure text.

## When to use

- After `adt_gitpull` to verify no syntax errors were introduced
- Can also be triggered via `adt_gitpull(checkErrors=true)` which chains this check after pull
- When debugging activation failures on the SAP system

**Never call autonomously.** Always wait for user trigger.

## Important: Chat mode only

This tool (and `adt_gitpull`, `adt_rununit`) must **only be used in interactive chat mode** — never in autonomous/background agent runs.

## Prerequisites

- `.env` in project root with valid credentials:
  ```
  SAP_ADT_URL=https://your-sap-system:44300
  SAP_ADT_USER=DEVELOPER
  SAP_ADT_PASSWORD=secret
  SAP_ROOT_PACKAGE=$ZASIS
  ```
- ATC check variant `SYNTAX_CHECK` must exist on the target SAP system
