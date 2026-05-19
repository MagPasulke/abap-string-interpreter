# ZASIS — ABAP String Interpreter

> **⚠️ Pre-release:** Until v1.0.0 is reached, breaking changes may occur without prior notice.

ZASIS extracts structured data from unstructured strings. You configure regex-based RuleSets, pass in a raw string (e.g. a barcode scan), and get back clean key/value pairs — no coding required per use case.

![RuleSet Maintenance UI](assets/readme/image.png)
![RuleSet Test UI](assets/readme/image2.png)

---

## Part 1 — Functionality

### The Problem

Scanners, barcode readers, and external systems often deliver a single string that packs multiple business values into one payload. Parsing that string is repetitive work — different formats, different fields, same logic over and over.

### The Solution

ZASIS lets you define a **RuleSet** once and reuse it everywhere. A RuleSet is a named collection of rules. Each rule extracts or transforms one field from the input string using regex, offsets, or custom ABAP logic.

### Features

| Feature | Description |
| --- | --- |
| **Match extraction** | Regex match with configurable pre/post offset trimming |
| **Replace transformation** | Regex-based find & replace with a replacement string |
| **Custom logic** | Plug in any ABAP class implementing `ZASIS_IF_CUSTOMLOGIC` for arbitrary processing per rule |
| **Regex validation** | Invalid regex patterns are rejected at save time in the UI |
| **Test from UI** | Execute a RuleSet directly from the Fiori maintenance screen via the `Test RuleSet` action |
| **Authorization** | Per-RuleSet activity checks (Create, Change, Display, Delete, Execute) via auth object `ZASIS_GRL` |
| **Three APIs** | Fiori Elements UI · ABAP API · HTTP REST endpoint |

### Planned Features

- Transport integration — write RuleSet definitions to SAP transports
- JSON export of RuleSets
- Event engine for RuleSet lifecycle and execution events

### Example

**Input string** from a scanner:

```text
<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>
```

**RuleSet "MySample"** with two Match rules:

| Target Field | Regex | Offset |
| --- | --- | --- |
| `MaterialNo` | `<A7X>([^<]*)` | 5 |
| `DeliveryNote` | `<B52H>([^<]*)` | 6 |

**Result:**

```json
[
  { "targetfield": "MaterialNo",  "interpretationresult": "MyMaterialNumber" },
  { "targetfield": "DeliveryNote", "interpretationresult": "MyDeliveryNote"   }
]
```

### Usage

#### Fiori UI

1. Create service binding `ZASIS_UI_RULESET_O4` (OData V4) for service definition `ZASIS_UI_RULESET`.
2. Publish service binding `ZASIS_UI_RULESET_O4`.
3. Open the Fiori Elements preview for entity **RuleSet**.
4. Create/maintain RuleSet header and items.
5. Click **Test RuleSet** to execute against a sample string.

#### ABAP API

```abap
DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( |MySample| ).

DATA(result) = NEW zasis_cl_interpreter( )->execute(
  ruleset                  = ruleset
  string_to_be_interpreted = |<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>| ).
```

#### HTTP API

**GET** — retrieve a RuleSet definition:

```bash
curl -X GET \
  "https://your_host/zasis_ext_api/ruleSet/MySample?sap-client=001" \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic <base64>"
```

**POST** — execute a RuleSet:

```bash
curl -X POST \
  "https://your_host/zasis_ext_api/ruleSetExecution/MySample?sap-client=001" \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic <base64>" \
  -d '{"string_to_be_interpreted":"<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>"}'
```

---

## Part 2 — Architecture and Technical Details

### Target Platform

- Developed on [ABAP Cloud Trial 2022 SP01](https://hub.docker.com/r/sapse/abap-cloud-developer-trial) (ABAP Platform 2022 / SAP BASIS 757 SP0004)
- May run on lower releases but this has not been tested

### Package Structure

```text
src/
├── app/      Fiori / UI placeholders
├── auth/     Authorization checks (ZASIS_IF_AUTH_CHECKER, ZASIS_CL_AUTH_CHECKER)
├── bo/       Business objects — interpreter, RuleSet, RAP behavior, service definition
├── dm/       Data model — tables, domains, data elements, CDS views
├── srv/      HTTP service handler
└── utils/    Constants, exceptions, helpers
```

### Core Components

| Class / Object | Responsibility |
| --- | --- |
| `ZASIS_CL_INTERPRETER` | Execution engine — iterates RuleSet items, applies Match/Replace/Custom Logic |
| `ZASIS_CL_RULESET_FACTORY` | Loads RuleSets from DB, manages in-memory cache |
| `ZASIS_CL_RULESET` | Immutable RuleSet container (header + items) |
| `ZASIS_CL_HTTP_HANDLER` | ICF handler — routes GET/POST, delegates to interpreter |
| `ZBP_ASIS_I_RULESET` | RAP behavior — validations, authorization, `testRuleSet` action |
| `ZASIS_IF_CUSTOMLOGIC` | Interface for pluggable custom extraction logic |

### Data Model

| Table | Purpose |
| --- | --- |
| `ZASIS_RULESETHD` | RuleSet header (UUID, RuleSetId, attachment) |
| `ZASIS_RULESETITM` | RuleSet items (regex rule, type, offsets, replacement, custom logic) |

Rule types: `1` = Match, `2` = Replace (domain `ZASIS_RULEITEM_TYPE`).

Key field constraints:

- `InterpretationRule` — CHAR 1000 (regex pattern)
- `OFFSET_PRE` / `OFFSET_POST` — INT1 (0–255), applied only in Match mode
- `ReplacementString` — CHAR 15, used only in Replace mode
- `CustomLogic` — CHAR 30 (ABAP class name)

### Execution Logic

**Match** — `match( val = input, regex = rule )` then trim result by `OFFSET_PRE` from left and `OFFSET_POST` from right.

**Replace** — `replace( val = input, regex = rule, with = replacement_string )`. No offsets applied.

**Custom Logic** — If `CUSTOM_LOGIC` is filled, the interpreter dynamically calls the static `EXECUTE` method on the specified class. The class must implement `ZASIS_IF_CUSTOMLOGIC`. Regular Match/Replace processing is skipped for that item.

### Authorization

Authorization object **`ZASIS_GRL`** with fields `ZASIS_RULE` (RuleSet ID) and `ACTVT` (activity):

| Activity | Code |
| --- | --- |
| Create | `01` |
| Change | `02` |
| Display | `03` |
| Delete | `06` |
| Execute | `16` |

Enforced in both the RAP behavior layer (UI) and the runtime API/HTTP layer.

### Installation

1. Install repository into SAP system via [abapGit](https://docs.abapgit.org/user-guide/projects/online/install.html).
2. Create service binding `ZASIS_UI_RULESET_O4` (for service definition `ZASIS_UI_RULESET`) and publish it to enable the Fiori maintenance UI.
3. To expose HTTP API, create and activate SICF service node:
   - Transaction `SICF` → path `default_host/sap`
   - Create subnode `zasis_ext_api`
   - Assign handler class `ZASIS_CL_HTTP_HANDLER`

### Error Handling

| Condition | HTTP Status |
| --- | --- |
| Invalid route or missing RuleSet ID | `400` |
| Non-JSON content type on POST | `400` |
| Unknown RuleSet | `400` |
| Missing authorization | `403` |
| Unsupported HTTP method | `405` |

In the RAP UI, invalid regex patterns and non-existent custom logic classes are caught during save/precheck and reported as inline error messages.

### Testing

| Script | Command | Description |
| --- | --- | --- |
| `npm run lint` | `abaplint` | Static analysis |
| `npm run unit` | `abap_transpile` + Node.js | Transpiled ABAP unit tests |
| `npm test` | lint + unit | Both |
| `npm run http-test` | `httpyac` | HTTP integration tests |

`http-test` requires a running SAP system instance. Connection details must be maintained in `.vscode/settings.json`:

```jsonc
{
    "rest-client.environmentVariables": {
        "local": {
            "baseUrl": "http://vhcala4hci:50000/zasis_ext_api",
            "client": "001",
            "auth_b64": "ACB1234"
        }
    }
}
```
