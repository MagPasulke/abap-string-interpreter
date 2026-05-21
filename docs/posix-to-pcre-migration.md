# POSIX to PCRE Regex Migration

## Context

The ABAP Cloud platform has deprecated the POSIX regex standard. Using the `regex` addition in `match()`, `replace()`, `FIND REGEX`, or `REPLACE REGEX` now produces the syntax warning:

> The regex standard POSIX is deprecated (see long text).

Reference: https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENREGEX_POSIX_SYNTAX.html

## Current Regex Usage in ZASIS

| File | Line(s) | Usage | Status |
|------|---------|-------|--------|
| `src/bo/zasis_cl_interpreter.clas.abap` | 100-101 | `match( val = ... regex = ... )` | **POSIX (deprecated)** |
| `src/bo/zasis_cl_interpreter.clas.abap` | 115-117 | `replace( val = ... regex = ... with = ... )` | **POSIX (deprecated)** |
| `src/bo/zbp_asis_i_ruleset.clas.locals_imp.abap` | 27, 87 | `cl_abap_regex=>create_pcre( ... )` | PCRE (OK) |

**Inconsistency**: The RAP behavior validates patterns as PCRE, but the interpreter executes them as POSIX.

## Key Behavioral Differences: POSIX vs PCRE

| Aspect | POSIX | PCRE |
|--------|-------|------|
| Matching strategy | Leftmost-longest | Leftmost-first |
| Whitespace in pattern | Literal | **Ignored** (extended mode `(?x)` is ON by default) |
| Dot `.` | Matches everything incl. newlines | Does NOT match newlines (unless `(?s)`) |
| `\u`, `\l` | Upper/lowercase letters | Not supported; use `\p{Lu}`, `\p{Ll}` |
| `\<`, `\>` | Word boundaries | Not supported; use `\b` |
| Replacement `$&` | Whole match | Not supported; use `$0` |

## Migration Options

### Option 1: Replace `regex` with `pcre` in built-in functions (Recommended)

```abap
" BEFORE (deprecated):
DATA(result) = match( val = string regex = pattern ).
DATA(result) = replace( val = string regex = pattern with = replacement ).

" AFTER:
DATA(result) = match( val = string pcre = pattern ).
DATA(result) = replace( val = string pcre = pattern with = replacement ).
```

Minimal change, two lines affected.

### Option 2: Use `cl_abap_regex=>create_pcre()` + `cl_abap_matcher`

```abap
DATA(regex) = cl_abap_regex=>create_pcre( pattern = pattern ).
DATA(matcher) = regex->create_matcher( text = string ).
IF matcher->match( ) = abap_true.
  result = matcher->get_match( ).
ENDIF.
```

More verbose but offers JIT compilation and finer control. Better suited if we need to reuse compiled patterns (e.g., caching regex objects in the ruleset).

## Critical Gotchas

### 1. Whitespace handling (HIGH RISK)

PCRE enables extended mode (`(?x)`) by default in ABAP, which means **spaces in patterns are ignored**. A pattern like `\d{2} \d{4}` would match `\d{2}\d{4}` — the space is silently dropped.

**Mitigation**: Prefix patterns with `(?-x)` to disable extended mode:
```abap
DATA(result) = match( val = string pcre = `(?-x)` && pattern ).
```

### 2. Leftmost-longest vs leftmost-first (MEDIUM RISK)

POSIX returns the longest possible match with alternation. PCRE returns the first alternative that matches. Example: pattern `un(fold|foldable)` against `unfoldable`:
- POSIX: returns `unfoldable`
- PCRE: returns `unfold`

**Mitigation**: Review patterns with alternation (`|`). Put longer alternatives first.

### 3. Dot and newlines (LOW RISK)

If input strings can contain newlines and patterns use `.`, add `(?s)` to preserve POSIX behavior.

### 4. Replacement string syntax (LOW RISK)

If any replacement strings use `$&` (whole match reference), change to `$0`.

## Recommended Approach

1. **Change `regex =` to `pcre =`** in the two locations in `zasis_cl_interpreter.clas.abap`
2. **Prepend `(?-x)` to patterns** at execution time for backward compatibility with stored patterns that may contain literal spaces
3. **Test all existing RuleSets** on the ABAP system after the change
4. This also **resolves the validation/execution inconsistency** (both will use PCRE)

### Minimal code change (conceptual)

```abap
" Line ~100: MATCH type
DATA(result_before_offset) = match( val  = string_to_be_interpreted
                                    pcre = `(?-x)` && regex_trimmed ).

" Line ~115: REPLACE type
DATA(result_replace) = replace( val  = string_to_be_interpreted
                                pcre = `(?-x)` && condense( rulesetitem-interpretationrule )
                                with = rulesetitem-replacement_string ).
```

## Decision Points

- Should `(?-x)` be applied unconditionally, or should we let users opt-in to extended mode?
- Should we also add `(?s)` (dot matches newlines) to fully replicate POSIX dot behavior?
- Do any existing patterns use `$&` in replacement strings?
- Should we add a note/documentation for ruleset authors about PCRE syntax?
