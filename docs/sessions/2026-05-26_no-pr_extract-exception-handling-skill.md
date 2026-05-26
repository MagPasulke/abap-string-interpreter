# 2026-05-26 no-pr extract-exception-handling-skill

**Date:** 2026-05-26
**Title:** Extract Exception Handling to Skill

## Summary

Extracted the "Exception Handling" section from `AGENTS.md` into a dedicated skill at `.agents/skills/exception-handling/SKILL.md`, following the same frontmatter-plus-content pattern used by the other project skills. The skill covers class hierarchy, the `ZASIS_MSGS` message class, T100 message integration, how to raise exceptions, RAP behavior messages, and rules for adding new exceptions. `AGENTS.md` was updated to replace the full section with a short reference pointing to the new skill file. No production code was changed; no tests were run (documentation-only change).
