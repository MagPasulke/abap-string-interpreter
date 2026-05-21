# abaplint Runtime: PCRE Support Patch

## Problem

The `@abaplint/runtime` package does not recognize the `pcre` parameter in `match()` and `replace()` built-in functions. It only handles `input.regex`, causing a TypeError when `pcre` is used.

## Affected Files

Both in `@abaplint/runtime/src/builtin/`:

### `match.js` (line 8-13)

Current code only checks `input.regex`:

```js
if (typeof input.regex === "string") {
    reg = input.regex;
}
else {
    reg = input.regex.get();
}
```

### `replace.js` (line 41-46)

Same pattern:

```js
if (typeof input.regex === "string") {
    sub = new RegExp(ABAPRegExp.convert(input.regex), "g");
}
else if (input.regex) {
    sub = new RegExp(ABAPRegExp.convert(input.regex.get()), "g");
}
```

## Fix

Treat `pcre` as an alias for `regex`. JavaScript's `RegExp` is already PCRE-compatible.

### `match.js`

```js
const regexInput = input.pcre || input.regex;
if (typeof regexInput === "string") {
    reg = regexInput;
}
else {
    reg = regexInput.get();
}
```

### `replace.js`

```js
const regexInput = input.pcre || input.regex;
if (typeof regexInput === "string") {
    sub = new RegExp(ABAPRegExp.convert(regexInput), "g");
}
else if (regexInput) {
    sub = new RegExp(ABAPRegExp.convert(regexInput.get()), "g");
}
```

## Notes

- JavaScript RegExp is Perl-compatible, so no engine change needed
- ABAP's `(?-x)` prefix (disable extended mode) is a valid regex group in JS — it's simply ignored as a no-op, which is the correct behavior
- The transpiler CLI (`@abaplint/transpiler-cli`) may also need updating if it maps `pcre` to a different JS parameter name during transpilation — check if the generated `.mjs` files pass `pcre` or `regex` to the runtime
- Effort: ~10 lines changed across 2 files + corresponding TypeScript source

## Upstream

Repository: https://github.com/abaplint/transpiler (contains the runtime)
