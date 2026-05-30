---
name: adt-gitpull
description: Trigger an abapGit repository pull on the SAP system to sync the current codebase.
---

## Tool

Use the built-in `adt_gitpull` custom tool.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `branch`  | No       | Branch to pull (short name like `main` or full ref like `refs/heads/feat/my-feature`). If omitted, auto-detects from the currently checked-out git branch. |

## What it does

1. Reads SAP credentials from `.env` in the project root (`SAP_ADT_URL`, `SAP_ADT_USER`, `SAP_ADT_PASSWORD`)
2. Determines the git remote URL (`origin`)
3. Resolves the branch to pull — uses the explicit `branch` parameter if provided, otherwise detects from `git rev-parse --abbrev-ref HEAD`
4. Connects to the SAP system via ADT API
5. Lists all abapGit repositories linked in the system
6. Finds the one matching the local remote URL
7. Switches the SAP repo to the target branch (via `switchRepoBranch`) if it differs from the currently configured branch
8. Pulls the resolved branch (always passes explicit `refs/heads/<branch>` to the API)

## When to use

Only when the user explicitly requests a sync to SAP. Typical scenarios:
- After merging a PR into `main`, user says "sync to SAP" or "pull to SAP"
- User wants to test a feature branch on the SAP system before merging
- User wants to verify ABAP Unit tests on the system after pushing changes

**Never call autonomously.** Always wait for user trigger.

## Important: Chat mode only

This tool (and `adt_rununit`) must **only be used in interactive chat mode** — never in autonomous/background agent runs. When using in chat mode:
- Always wait for user confirmation before calling
- After calling, wait for the user to confirm the result on the SAP side before proceeding with further steps

## Prerequisites

- `.env` in project root with valid credentials (see `.env.example`):
  ```
  SAP_ADT_URL=https://your-sap-system:44300
  SAP_ADT_USER=DEVELOPER
  SAP_ADT_PASSWORD=secret
  ```

