# Session: PCRE Migration Research

- **Date**: 2026-05-21
- **Branch**: `experimental/pcre-migration`
- **Status**: Unfinished — awaiting ABAP system testing
- **PR**: None (experimental branch, not merged)

## Summary

Researched migration from deprecated POSIX regex to PCRE in the interpreter engine (`zasis_cl_interpreter.clas.abap`). Applied the minimal code change (`regex =` → `pcre = '(?-x)' && ...`) on an experimental branch.

## What was done

1. Identified all regex usage in the codebase (2 POSIX locations in interpreter, 2 PCRE locations in RAP behavior)
2. Documented key behavioral differences (whitespace handling, leftmost-longest vs leftmost-first, dot/newline)
3. Created research document: [`docs/posix-to-pcre-migration.md`](../posix-to-pcre-migration.md)
4. Applied code change on `experimental/pcre-migration` branch
5. Lint passes (valid ABAP Cloud syntax)

## Blocking issue

The `@abaplint/runtime` transpiler does not support the `pcre` parameter in `match()`/`replace()` built-in functions. Local unit tests (`npm run unit`) fail with:

```
TypeError: Cannot read properties of undefined (reading 'get')
    at Object.match (…/builtin/match.js:12:27)
```

## Next steps

- Sync branch to ABAP system via abapGit
- Run ABAP Unit tests on the real system
- Verify existing RuleSets still produce correct results
- Consider contributing `pcre` support to `@abaplint/runtime`
- If all passes, create PR against `main`
