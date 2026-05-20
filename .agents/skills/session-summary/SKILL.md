---
name: session-summary
description: Create a session summary file in docs/sessions/ before merging a PR. Captures session ID, date, title, and concise summary of work done.
---

# Session Summary Skill

Create a session summary file **before merging the PR**. The summary must be committed to the feature branch.

## File Location

`docs/sessions/<session_id>.md`

Use the OpenCode session ID (visible in task_id prefix, e.g. `ses_1b8a7d8f6ffe`).

## Template

```markdown
# <session_id>

**Date:** YYYY-MM-DD
**Title:** Short descriptive title

## Summary

One paragraph. Include: what was done, key changes, artifacts created/modified, test results, PR number. Keep concise but complete enough to reconstruct context later.
```

## Rules

1. One file per session, session ID as filename
2. Write summary BEFORE merge (commit to feature branch)
3. Include PR number
4. Mention test results (pass/fail counts)
5. Reference issue numbers if applicable
6. Keep to one paragraph — no bullet lists, no verbose explanations
