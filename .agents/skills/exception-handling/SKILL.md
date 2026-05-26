---
name: exception-handling
description: Reference guide for the ZASIS exception handling pattern — class hierarchy, message class, T100 integration, how to raise exceptions, and rules for adding new exceptions.
---

# Exception Handling

All exceptions inherit from `cx_static_check` (checked exceptions declared in method signatures).

## Class Hierarchy

```
cx_static_check
├── zasis_cx_exc              (general-purpose, non-final) — src/utils/
│   └── zasis_cx_ruleset_ui   (RAP/UI-specific, final) — src/bo/
└── zasis_cx_no_auth          (authorization, final) — src/auth/
```

## Message Class

A single message class **`ZASIS_MSGS`** (`src/bo/zasis_msgs.msag.xml`) centralizes all user-facing messages. Each message has a 3-digit number and up to 4 placeholder variables (`&1`–`&4`).

## T100 Message Integration

All exception classes implement `if_t100_message` (and `if_t100_dyn_msg`). Messages are bound to exceptions via **constant structures** declared in the exception class:

```abap
CONSTANTS: BEGIN OF unknown_ruleset,
             msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
             msgno TYPE symsgno      VALUE '007',
             attr1 TYPE scx_attrname VALUE 'RULESET',
             attr2 TYPE scx_attrname VALUE '',
             attr3 TYPE scx_attrname VALUE '',
             attr4 TYPE scx_attrname VALUE '',
           END OF unknown_ruleset.
```

The `attr1`–`attr4` fields reference **instance attribute names** of the exception class. At runtime, the framework resolves `&1`–`&4` placeholders by reading those attribute values from the exception instance.

## How to Raise Exceptions

**Simple (no variables):**
```abap
RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>string_to_interpret_empty ).
```

**With message variable (attribute supplies `&1`):**
```abap
RAISE EXCEPTION NEW zasis_cx_exc(
  textid  = zasis_cx_exc=>unknown_ruleset
  ruleset = lv_ruleset_id
).
```

**Authorization (minimal, default text):**
```abap
RAISE EXCEPTION NEW zasis_cx_no_auth( ).
```

## RAP Behavior Messages (`zasis_cx_ruleset_ui`)

This subclass additionally implements `if_abap_behv_message`, allowing the same exception to serve as a RAP validation/action message with severity control:

- Constructor accepts a `severity` parameter (default: `if_abap_behv_message=>severity-error`)
- Used inside RAP behavior implementations — the exception is appended to `reported`/`failed` tables and rendered in Fiori Elements UIs

## Rules for Adding New Exceptions

1. **Add the message text** to `ZASIS_MSGS` with the next available message number
2. **Add a constant structure** in the appropriate exception class mapping `msgid`, `msgno`, and `attr1`–`attr4` to class attributes
3. **Add corresponding attributes** (READ-ONLY) to the exception class if the message has placeholders
4. **Wire the attribute** in the constructor (accept as parameter, assign to instance attribute)
5. If the exception is for **RAP validations/actions**, use `zasis_cx_ruleset_ui`; otherwise use `zasis_cx_exc`
6. For **authorization failures**, use `zasis_cx_no_auth`
