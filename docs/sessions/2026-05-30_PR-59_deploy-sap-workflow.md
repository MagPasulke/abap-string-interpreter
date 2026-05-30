# 2026-05-30 PR-59 deploy-sap-workflow

**Date:** 2026-05-30
**Title:** Automated SAP sync via abapGit pull after CI passes on main

## Summary

Added a `deploy-sap` GitHub Actions workflow (`.github/workflows/deploy-sap.yml`) that automatically triggers an abapGit pull on the SAP system whenever the `ci` workflow completes successfully on `main`. The core ADT pull logic was extracted from `.opencode/tools/adt_gitpull_core.ts` and moved to `scripts/adt_gitpull_core.ts` to make it centrally reusable — the opencode plugin wrapper (`.opencode/tools/adt_gitpull.ts`) and the new CI runner (`scripts/adt-gitpull-ci.ts`) both import from the shared location. The opencode tool was verified to still work correctly against the live SAP system after the refactor. No ABAP objects were modified; no test changes were needed. PR #59.
