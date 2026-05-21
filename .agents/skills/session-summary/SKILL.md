---
name: session-summary
description: Create a session summary file in docs/sessions/ before merging a PR. Captures date, PR number, title, and concise summary of work done.
---

# Session Summary Skill

Create a session summary file **before merging the PR**. The summary must be committed to the feature branch.

## File Naming Convention

`docs/sessions/YYYY-MM-DD_PR-NN_short-title.md`

- **YYYY-MM-DD** — date of the session
- **PR-NN** — PR number (e.g. `PR-32`). Use `no-pr` if no PR was created.
- **short-title** — kebab-case summary (2-5 words)

Examples:
- `2026-05-21_PR-32_consolidate-duplicate-messages.md`
- `2026-05-20_PR-19_refactor-customlogic-resolver.md`
- `2026-05-21_no-pr_http-context-and-input-validation.md`

## Template

```markdown
# YYYY-MM-DD PR-NN short-title

**Date:** YYYY-MM-DD
**Title:** Short descriptive title

## Summary

One paragraph. Include: what was done, key changes, artifacts created/modified, test results, PR number. Keep concise but complete enough to reconstruct context later.
```

## Rules

1. Use the naming convention above — makes files sortable by date and searchable by PR
2. Write summary BEFORE merge (commit to feature branch)
3. Include PR number
4. Mention test results (pass/fail counts)
5. Reference issue numbers if applicable
6. Keep to one paragraph — no bullet lists, no verbose explanations
