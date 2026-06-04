# ZASIS — User Manual

> **ZASIS** (ABAP String Interpreter) is an ABAP component that extracts structured field values from unstructured strings — such as barcodes, data matrix codes, or scanner output — using configurable, regex-based RuleSets.

---

## Table of Contents

1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
   - [RuleSet](#ruleset)
   - [Rule Items](#rule-items)
   - [Rule Types](#rule-types)
   - [Offsets](#offsets)
   - [Context](#context)
3. [Configuring RuleSets](#configuring-rulesets)
   - [Creating a RuleSet](#creating-a-ruleset)
   - [Adding Rule Items](#adding-rule-items)
   - [Testing a RuleSet from the UI](#testing-a-ruleset-from-the-ui)
4. [ABAP API](#abap-api)
5. [HTTP API Reference](#http-api-reference)
   - [Execute RuleSet — POST /ruleSetExecution/{ruleSetId}](#execute-ruleset)
   - [Retrieve RuleSet — GET /ruleSet/{ruleSetId}](#retrieve-ruleset)
   - [Error Responses](#error-responses)
5. [Custom Logic](#custom-logic)
6. [Event Producers](#event-producers)
7. [Authorization](#authorization)
8. [Troubleshooting](#troubleshooting)

---

## Overview

ZASIS allows you to define **RuleSets** — named collections of ordered regex rules — and then execute them against an input string via an HTTP API or directly in ABAP. Each rule maps to a **target field** (e.g. `MaterialNo`, `DeliveryNote`) and produces an extraction result.

**Typical flow:**

```
Scanner / barcode reader
        │
        │  raw string  (e.g. "<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>")
        ▼
  POST /ruleSetExecution/{ruleSetId}
        │
        ▼
  ZASIS applies each rule in order
        │
        ▼
  Structured JSON result
  { "MaterialNo": "MyMaterialNumber", "DeliveryNote": "MyDeliveryNote" }
```

---

## Core Concepts

### RuleSet

A **RuleSet** is the top-level configuration unit. It has:

| Attribute    | Description                                                   |
|-------------|---------------------------------------------------------------|
| `RuleSetId` | Unique identifier used in API calls (alphanumeric, max 10 chars) |
| Name / description | Human-readable label shown in the Fiori UI             |

A RuleSet is immutable at runtime; all rule items are loaded once and cached in memory.

### Rule Items

Each RuleSet contains an ordered list of **Rule Items**. Every item defines:

| Attribute             | Description                                                                  |
|-----------------------|------------------------------------------------------------------------------|
| `TargetField`         | The name of the output field this rule populates (e.g. `MaterialNo`)         |
| `InterpretationRule`  | A PCRE-compatible regular expression                                          |
| `InterpretationType`  | `1` = MATCH, `2` = REPLACE (see [Rule Types](#rule-types))                  |
| `OffsetPre`           | Characters to skip from the **start** of the regex match (MATCH only)       |
| `RightTrim`           | Characters to trim from the **end** of the regex match (MATCH only)         |
| `ReplacementString`   | The replacement value used with REPLACE rules                                 |
| `CustomLogic`         | Optional: ABAP class name implementing `ZASIS_IF_CUSTOMLOGIC` (overrides regex) |
| `EventProducer`       | Optional: ABAP class name implementing `ZASIS_IF_EVENT_PRODUCER`             |

Rules are executed **in the order they are defined**. The result of one rule does not feed into the next; every rule operates on the original input string.

### Rule Types

#### MATCH (type `1`)

Extracts a substring from the input using a regex. The regex must match a portion of the input string; if it does not match, the result for that item is `no match`.

After a successful match, **offsets** are applied to trim characters from the start and end of the matched region (see [Offsets](#offsets)).

**Example:**

Input: `<A7X>MyMaterialNumber<B52H>`

Regex: `(?<=<A7X>).*?(?=<B52H>)`

Result: `MyMaterialNumber`

#### REPLACE (type `2`)

Performs a full regex-based substitution on the input string and returns the transformed result. If the regex does not match, the result for that item is `no match`.

**Offsets are not applied to REPLACE results.**

**Known limitation:** If the replacement produces the exact same string as the input (e.g. replacing `A` with `A`), ZASIS treats this as a non-match and returns `no match` instead of the (identical) result.

**Example:**

Input: `PREFIX_MyValue_SUFFIX`

Regex: `PREFIX_(.*)_SUFFIX`

Replacement: `$1`

Result: `MyValue`

### Offsets

Offsets apply **only to MATCH results** and allow you to trim characters without adjusting the regex:

- **`OffsetPre`**: number of characters to remove from the **beginning** of the matched string.
- **`RightTrim`**: number of characters to remove from the **end** of the matched string.

**Example:**

Match result: `[MyValue]`  
`OffsetPre = 1`, `RightTrim = 1`  
Final result: `MyValue`

If the sum of offsets equals or exceeds the match length, the result will be empty or invalid — validate your regex and offsets together.

### Context

Callers can pass arbitrary key-value pairs as **context** alongside the input string. Context is:

- **Passed through** to custom logic classes and event producers.
- **Returned as-is** in the API response so the caller can correlate it.
- **Not evaluated** by the MATCH/REPLACE rule engine itself.

Context is optional. If omitted, the `context` field in the response will be an empty array.

---

## Configuring RuleSets

### Creating a RuleSet

RuleSets are managed via the **ZASIS Fiori application** (OData V4, exposed via SAP Launchpad or direct URL). Use the app to:

1. Navigate to **RuleSet** → **New**.
2. Enter a unique `RuleSetId` and a descriptive name.
3. Save the header record.

### Adding Rule Items

Within a saved RuleSet:

1. Open the RuleSet and navigate to the **Rule Items** section.
2. Click **Add**.
3. Fill in the fields (see [Rule Items](#rule-items) table above).
4. Order items using the sequence controls — the execution order matches the display order.
5. Save. Changes take effect immediately on the next API call (the cache is invalidated on save).

### Testing a RuleSet from the UI

The Fiori maintenance screen provides a **Test RuleSet** action that lets you run the interpreter against a sample input string without making an HTTP call:

1. Open a saved RuleSet.
2. Click **Test RuleSet**.
3. Enter a sample input string in the prompt.
4. Confirm. The UI displays one result message per rule item, showing the extracted value or `no match`.

This is useful for verifying regex patterns and offset values during configuration.

---

## ABAP API

ZASIS can be called directly from ABAP without going through HTTP. This is the preferred integration path for ABAP-to-ABAP calls within the same system.

### Basic usage

```abap
" 1. Load the RuleSet by its ID (cached in memory after first load)
DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( |MySample| ).

" 2. Execute the interpreter
DATA(result) = NEW zasis_cl_interpreter( )->execute(
  ruleset                  = ruleset
  string_to_be_interpreted = |<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>| ).
```

The `result` is of type `zasis_interpret_output` and contains:

- `result-results` — an internal table with one row per rule item; each row has `targetfield` and `interpretationresult`.
- `result-context` — the context table passed in (echoed back unchanged).

### With context

Pass optional key-value context that is forwarded to custom logic classes and event producers:

```abap
DATA(context) = VALUE zasis_tt_interpret_context(
  ( ctx_key = 'plant'  value = '1000'      )
  ( ctx_key = 'source' value = 'scanner_01' ) ).

DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( |MySample| ).

DATA(result) = NEW zasis_cl_interpreter( )->execute(
  ruleset                  = ruleset
  string_to_be_interpreted = |<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>|
  context                  = context ).
```

### Error handling

Both `zasis_cx_exc` (application errors) and `zasis_cx_no_auth` (authorization) must be handled:

```abap
TRY.
    DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( |MySample| ).

    DATA(result) = NEW zasis_cl_interpreter( )->execute(
      ruleset                  = ruleset
      string_to_be_interpreted = lv_input ).

    " Process result-results ...

  CATCH zasis_cx_no_auth INTO DATA(auth_exc).
    " User lacks execute authorization for this RuleSet
    MESSAGE auth_exc TYPE 'E'.

  CATCH zasis_cx_exc INTO DATA(app_exc).
    " Application error (e.g. empty input string, unknown rule type)
    MESSAGE app_exc TYPE 'E'.
ENDTRY.
```

### Reading results

```abap
LOOP AT result-results INTO DATA(item).
  WRITE: / item-targetfield, item-interpretationresult.
ENDLOOP.
```

Items with no regex match contain `no match` in `interpretationresult`.

---

## HTTP API Reference

The ZASIS REST API is registered as an SAP ICF service. The base path is determined by your ICF service configuration — contact your system administrator for the host and port.

All requests and responses use `Content-Type: application/json`.

---

### Execute RuleSet

**`POST /ruleSetExecution/{ruleSetId}`**

Interprets the input string against all rules of the specified RuleSet and returns one result per rule item.

#### Path Parameters

| Parameter   | Description                                 |
|------------|---------------------------------------------|
| `ruleSetId` | The ID of the RuleSet to execute             |

#### Request Body

```json
{
  "string_to_be_interpreted": "<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>",
  "context": [
    { "ctx_key": "plant", "value": "1000" },
    { "ctx_key": "source", "value": "scanner_01" }
  ]
}
```

| Field                      | Type            | Required | Description                                      |
|---------------------------|-----------------|----------|--------------------------------------------------|
| `string_to_be_interpreted` | `string`        | Yes      | The raw input string to interpret                |
| `context`                  | `array<object>` | No       | Key-value pairs forwarded to custom logic/events |

#### Response — 200 OK

```json
{
  "RESULTS": [
    {
      "TARGETFIELD": "MaterialNo",
      "INTERPRETATIONRESULT": "MyMaterialNumber"
    },
    {
      "TARGETFIELD": "DeliveryNote",
      "INTERPRETATIONRESULT": "MyDeliveryNote"
    }
  ],
  "CONTEXT": [
    { "CTX_KEY": "plant", "VALUE": "1000" }
  ]
}
```

- `RESULTS` — one entry per rule item, in rule-item order.
- `INTERPRETATIONRESULT` — the extracted/transformed value, or `no match` if the rule did not match.
- `CONTEXT` — the context passed in the request, echoed back unchanged.

#### Response — 400 Bad Request

Returned when:
- `string_to_be_interpreted` is missing or empty
- The `ruleSetId` does not exist
- The `Content-Type` header is not `application/json`
- The API path is malformed

```json
{
  "ERROR": {
    "CODE": "ZASIS_MSGS/...",
    "MESSAGE": "Human-readable error description",
    "STATUS": "400"
  }
}
```

#### Response — 403 Forbidden

Returned when the calling user lacks the required authorization for the RuleSet (see [Authorization](#authorization)).

---

### Retrieve RuleSet

**`GET /ruleSet/{ruleSetId}`**

Returns the header and all rule items of a RuleSet. Use this to inspect the current configuration without executing it.

#### Path Parameters

| Parameter   | Description                   |
|------------|-------------------------------|
| `ruleSetId` | The ID of the RuleSet to fetch |

#### Response — 200 OK

Returns the full RuleSet structure including header metadata and ordered rule items.

#### Response — 400 / 403

Same error format as the POST endpoint.

---

### Error Responses

All errors follow the same envelope structure:

```json
{
  "ERROR": {
    "CODE": "ZASIS_MSGS/...",
    "MESSAGE": "...",
    "STATUS": "400"
  }
}
```

| HTTP Status | Cause                                                                 |
|------------|-----------------------------------------------------------------------|
| `400`       | Invalid input, unknown RuleSet, wrong content-type, malformed path    |
| `403`       | Authorization check failed for the given RuleSet and user             |
| `405`       | HTTP method not supported (only GET and POST are valid)               |

---

## Custom Logic

When a Rule Item has a **CustomLogic** class assigned, the standard MATCH/REPLACE regex processing is **bypassed entirely** for that item. The named ABAP class is called instead.

### When to use

- The extraction logic is too complex for a single regex.
- Results depend on multiple input fields or lookup tables.
- Post-processing of a regex match is required.

### Implementation

Create an ABAP class that implements the interface `ZASIS_IF_CUSTOMLOGIC`:

```abap
INTERFACE zasis_if_customlogic PUBLIC.
  METHODS execute
    IMPORTING
      string_to_be_interpretet     TYPE string
      ruleset                      TYPE REF TO zasis_if_ruleset
      current_rule_item            TYPE zasis_rulesetitm
      context                      TYPE zasis_tt_interpret_context OPTIONAL
    RETURNING
      VALUE(interpretation_result) TYPE string
    RAISING
      zasis_cx_exc.
ENDINTERFACE.
```

| Parameter                  | Description                                               |
|---------------------------|-----------------------------------------------------------|
| `string_to_be_interpretet` | The raw input string (note: intentional typo in parameter name) |
| `ruleset`                  | Reference to the full RuleSet; read-only access to all items     |
| `current_rule_item`        | The specific rule item being processed                    |
| `context`                  | Key-value context from the caller                         |
| `interpretation_result`    | Return the extracted value; return initial (`''`) for no match  |

Return an initial (empty) string to signal *no match* — ZASIS will display `no match` in the output for that item.

Raise `zasis_cx_exc` to signal an unrecoverable error; this will abort the entire interpretation and return a 400 response.

### Registration

In the RuleSet configuration, enter the fully qualified ABAP class name in the **Custom Logic** field of the rule item. The class resolver validates that the class implements `ZASIS_IF_CUSTOMLOGIC` before calling it.

---

## Event Producers

An **Event Producer** class is called **after** a rule item produces a successful match (either from regex or custom logic). It allows you to react to interpretation results — for example, to publish a Business Event or update a status.

> **Note:** Event producers are **not** called when a rule item produces `no match`.

### Implementation

Create an ABAP class implementing `ZASIS_IF_EVENT_PRODUCER`. The class receives:

- The full RuleSet reference
- The target field name
- The interpretation result for that item
- The caller-supplied context

Event producers run synchronously within the same HTTP call. Any `zasis_cx_exc` raised by an event producer is caught and suppressed — it does not affect the interpretation result returned to the caller.

### Registration

Enter the ABAP class name in the **Event Producer** field of the rule item in the RuleSet configuration.

---

## Authorization

ZASIS uses a dedicated authorization object (`ZASIS_GRL`) to control access to RuleSet execution and maintenance.

| Authorization Check | Triggered by                              |
|--------------------|-------------------------------------------|
| Execute            | Every call to `POST /ruleSetExecution/{ruleSetId}` |
| Read               | Every call to `GET /ruleSet/{ruleSetId}`  |
| Maintain           | Saving changes via the Fiori application  |

Users without the required authorization receive a `403 Forbidden` response on API calls, or see no data in the Fiori application.

Contact your SAP system administrator to assign the appropriate roles.

---

## Troubleshooting

### Rule returns `no match` unexpectedly

1. Verify the regex against the actual input string using a PCRE-compatible tester (e.g. regex101.com with PCRE2 flavor).
2. Check for invisible characters or encoding differences in the scanned input.
3. For MATCH rules: confirm the regex returns a non-empty match.
4. For REPLACE rules: ensure the replacement result is different from the input string (see [Known limitation](#replace-type-2)).
5. Check that `OffsetPre` + `RightTrim` does not exceed the match length.

### HTTP 400 — Unknown RuleSet

Verify that the `ruleSetId` in the URL exactly matches the ID configured in the Fiori application (case-sensitive).

### HTTP 400 — Content-Type error

Ensure the request includes the header `Content-Type: application/json`.

### HTTP 403 — Forbidden

The calling user lacks the required authorization. Contact your system administrator to verify role assignments for authorization object `ZASIS_GRL`.

### Custom logic class not found or not called

- Confirm the class name is spelled correctly and fully qualified.
- Confirm the class implements `ZASIS_IF_CUSTOMLOGIC` exactly (not a sub-interface or local copy).
- Activate and transport the class to the target system.

### Context not appearing in response

Context is only returned if it was sent in the request body. Confirm the `context` array is included and well-formed JSON.
