# ses_1bb9da513ffe

**Date:** 2026-05-20
**Title:** Context Passing (v0.1.0, closes #12)

## Summary

Added optional `zasis_tt_interpret_context` key-value parameter flowing caller→interpreter→event producer/custom logic. New DDIC: structure + table type. Updated 3 interfaces, interpreter pass-through impl. 4 new unit tests (16 total). Version bump 0.0.1→0.1.0. Created follow-up issues: #13 (refactor customlogic to instance), #14 (HTTP handler context), #15 (return context in result), #16 (typed event producer error handling). Updated TABL skill (STRG fields omit LENG). PR #17 merged.
