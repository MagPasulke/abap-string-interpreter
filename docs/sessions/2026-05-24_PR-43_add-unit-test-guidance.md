# 2026-05-24 PR-43 add-unit-test-guidance

**Date:** 2026-05-24
**Title:** Add unit test writing guidance to AGENTS.md

## Summary

Updated AGENTS.md to include mandatory unit test writing guidance. Added a new workflow step 6 ("Write/enhance unit tests") between Implement and Run lint+test, renumbering subsequent steps accordingly. Added a new "Writing & Maintaining Tests" subsection under the Testing section with four policy bullets: new functionality must include tests, modified behavior must have tests updated, tests must pass locally before committing, and existing test classes should be extended rather than duplicated. All lint and 39 unit tests pass. Version bumped to 0.2.4. PR #43.
