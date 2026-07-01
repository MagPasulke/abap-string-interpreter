# Architecture

## Package Structure

ZASIS follows a layered package structure that separates concerns across seven sub-packages under the root `ZASIS` package:

```
src/
├── app/          Fiori / UI placeholders (reserved for future UI components)
├── auth/         Authorization — auth checker class, auth objects, DCL access control for CDS views
├── bo/           Business objects — interpreter engine, RuleSet container + factory, RAP managed BO, OData V4 service
├── catalogs/     Catalog package group — custom logic catalog, event producer catalog, and shared catalog objects
├── dm/           Data model — DB tables, CDS interface views, domains, data elements, table types
├── srv/          HTTP service — REST handler routing GET/POST for RuleSet retrieval and interpretation
└── utils/        Shared utilities — constants, custom exception, domain value query provider, class validator
```

Within `src/catalogs/`, responsibilities are split into:
- `enhcatalog/` — RAP BO for registering custom logic implementations (`ZASIS_UI_CUSTLOGCATALOG`)
- `evtcatalog/` — RAP BO for registering event producer implementations (`ZASIS_UI_EVTPRODCATALOG`)
- `sharedobjects/` — shared status/description domain objects and status text virtual element provider

---

## Core Components

| Class / Object | Responsibility |
|---|---|
| `ZASIS_CL_INTERPRETER` | Execution engine — iterates RuleSet items, applies Match, Replace, or Custom Logic per rule |
| `ZASIS_CL_RULESET_FACTORY` | Loads RuleSets from the database, manages an in-memory cache per session |
| `ZASIS_CL_RULESET` | Immutable RuleSet container holding header and items after load |
| `ZASIS_CL_HTTP_HANDLER_CORE` | Framework-agnostic HTTP handler — routing, dispatch, error handling, JSON serialization |
| `ZASIS_CL_HTTP_HANDLER` | Classic SICF entry point — adapts `IF_HTTP_EXTENSION` and delegates to core |
| `ZASIS_CL_HTTP_HANDLER_CLD` | Cloud HTTP Service entry point — adapts `IF_HTTP_SERVICE_EXTENSION` and delegates to core |
| `ZBP_ASIS_I_RULESET` | RAP behavior — validations, authorization checks, `testRuleSet` action, draft handling |
| `ZBP_ASIS_I_CUSTLOGCAT` | RAP behavior for custom logic catalog maintenance and class/interface validation |
| `ZBP_ASIS_I_EVTPRODCAT` | RAP behavior for event producer catalog maintenance and class/interface validation |
| `ZASIS_IF_CUSTOMLOGIC` | Interface for pluggable custom extraction logic per rule item |
| `ZASIS_CL_AUTH_CHECKER` | Wraps `AUTHORITY-CHECK` for interpreter and HTTP handler authorization |

### HTTP Handler Architecture

The HTTP layer uses a three-class design to keep business logic independent of the SAP HTTP framework:

```
ZASIS_CL_HTTP_HANDLER        (implements IF_HTTP_EXTENSION — classic SICF)
ZASIS_CL_HTTP_HANDLER_CLD    (implements IF_HTTP_SERVICE_EXTENSION — cloud HTTP service)
         |                              |
         +----------+  +---------------+
                    |  |
          ZASIS_CL_HTTP_HANDLER_CORE
          (no SAP framework dependency — uses custom IF abstractions)
```

The two entry-point handlers each adapt their respective SAP HTTP object model to the custom interfaces `ZASIS_IF_HTTP_REQUEST` and `ZASIS_IF_HTTP_RESPONSE`, then call the shared core. This makes the core independently testable — it can be exercised in Node.js via the ICF shim without any SAP runtime present.

---

## Data Model

### Database Tables

| Table | Purpose |
|---|---|
| `ZASIS_RULESETHD` | RuleSet header — UUID, RuleSetId, name, attachment flag |
| `ZASIS_RULESETITM` | RuleSet items — regex rule, type, offsets, replacement string, custom logic class name |
| `ZASIS_CUSTLOGCAT` | Active records for custom logic class registrations |
| `ZASIS_EVTPRODCAT` | Active records for event producer class registrations |
| `ZASISDR_CLCAT` | Draft table for custom logic catalog RAP BO |
| `ZASISDR_EPCAT` | Draft table for event producer catalog RAP BO |

### Rule Types

Rule types are stored as a domain value in `ZASIS_RULEITEM_TYPE`:

| Value | Meaning |
|---|---|
| `1` | Match — extract a substring using regex, then trim by offsets |
| `2` | Replace — apply regex find-and-replace with a fixed replacement string |

### Key Field Constraints

| Field | Type | Notes |
|---|---|---|
| `InterpretationRule` | CHAR 1000 | The regex pattern |
| `OFFSET_PRE` | INT1 (0–255) | Trims from the left of the match result; Match mode only |
| `OFFSET_POST` | INT1 (0–255) | Trims from the right of the match result; Match mode only |
| `ReplacementString` | CHAR 15 | Used in Replace mode only |
| `CustomLogic` | CHAR 30 | ABAP class name; when filled, bypasses Match/Replace processing |

---

## Execution Logic

When `ZASIS_CL_INTERPRETER` processes a string, it iterates over all items of the loaded RuleSet in sequence. For each item:

**Match** — Calls the built-in `match( val = input pcre = rule )` function. If a match is found, `OFFSET_PRE` characters are removed from the left and `OFFSET_POST` characters from the right of the result using string offset/length syntax. If the result is empty or no match was found, the item yields no output.

**Replace** — Calls the built-in `replace( val = input pcre = rule with = replacement_string )` function. Because `replace()` returns the original string unchanged when no match is found, the interpreter compares the result to the original input: if they differ, the result is returned; if they are equal, the item yields no output. Known limitation: if the replacement produces the same string as the input (e.g. regex `A` with replacement `A` on `ABC`), it is falsely treated as no-match.

**Custom Logic** — If the `CustomLogic` field is filled, the interpreter resolves the named class dynamically and calls its `EXECUTE` method. The class must implement `ZASIS_IF_CUSTOMLOGIC`. Regular Match/Replace processing is skipped for that item.

After each item where a result is produced, the interpreter optionally calls the configured event producer (if any) with the rule item, the result, and the caller-supplied context.

**Context** is a key-value collection (`ZASIS_TT_INTERPRET_CONTEXT`) passed in by the caller. The interpreter forwards it unchanged to the event producer and custom logic implementations, and echoes it back in the output. It is never modified by the interpreter itself.
