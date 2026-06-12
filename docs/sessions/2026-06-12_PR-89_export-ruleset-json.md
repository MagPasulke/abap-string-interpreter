# 2026-06-12 PR-89 export-ruleset-json

**Date:** 2026-06-12
**Title:** JSON export endpoint for rulesets

## Summary

Implemented phase 1 of #46: a GET /ruleSetExport/{rulesetId} HTTP endpoint that returns a downloadable JSON file with schema versioning and human-readable type mapping (MATCH/REPLACE). Created export DTO structures (zasis_srv_export, zasis_srv_export_itm), a mapper class (zasis_cl_export_mapper) in srv/ that excludes both header and item UUIDs, and a virtual element calculation class (zasis_cl_calc_export_url) in bo/ for Fiori Elements DataFieldWithUrl annotation. Updated the consumption CDS view and DDLX with the virtual ExportUrl element. Added export constants to zasis_constants. All tests green: npm test (0 lint issues, 62 unit tests pass), ICF shim integration (24/24), SAP ABAP Unit (69/69). Created issue #88 for future cloud/on-prem URL split.
