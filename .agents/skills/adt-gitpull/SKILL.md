---
name: adt-gitpull
description: Trigger an abapGit repository pull on the SAP system to sync the current codebase.
---

## Tool

Use the built-in `adt_gitpull` custom tool. It requires **no parameters**.

## What it does

1. Reads SAP credentials from `.env` in the project root (`SAP_ADT_URL`, `SAP_ADT_USER`, `SAP_ADT_PASSWORD`)
2. Determines the git remote URL (`origin`)
3. Connects to the SAP system via ADT API
4. Lists all abapGit repositories linked in the system
5. Finds the one matching the local remote URL
6. Triggers a pull (imports current branch state into the SAP system)

## When to use

Only when the user explicitly requests a sync to SAP. Typical scenarios:
- After merging a PR into `main`, user says "sync to SAP" or "pull to SAP"
- User wants to verify ABAP Unit tests on the system after pushing changes

**Never call autonomously.** Always wait for user trigger.

## Prerequisites

- `.env` in project root with valid credentials (see `.env.example`):
  ```
  SAP_ADT_URL=https://your-sap-system:44300
  SAP_ADT_USER=DEVELOPER
  SAP_ADT_PASSWORD=secret
  ```
- The repository must already be linked in the SAP system via abapGit (SE38 → ZABAPGIT or ADT)

## Error handling

The tool returns readable error strings (never throws). Common errors:
- **Missing credentials** — `.env` not found or variables not set
- **TLS certificate errors** — system uses self-signed cert, needs `NODE_TLS_REJECT_UNAUTHORIZED=0` or proper CA config
- **Repo not found** — the git remote URL doesn't match any linked repo in the SAP system
- **500 Internal Server Error** — abapGit ADT Backend (`/sap/bc/adt/abapgit`) not activated in SICF

## Implementation

- Tool wrapper: `.opencode/tools/adt_gitpull.ts`
- Core logic (reusable): `.opencode/tools/adt_gitpull_core.ts`
- Dependency: `abap-adt-api` (devDependency in `package.json`)
