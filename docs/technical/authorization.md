# Authorization

ZASIS enforces authorization across RAP behavior handlers, CDS access control (DCL), and runtime execution paths (ABAP API and HTTP service). All checks are based on the same authorization object.

---

## Authorization Object: `ZASIS_GRL`

The authorization object `ZASIS_GRL` controls access to RuleSets, catalog maintenance, and configuration maintenance operations. It has two fields:

| Field | Domain | Description |
|---|---|---|
| `ZASIS_RULE` | `ZASIS_RULESETID` | The RuleSet ID. Use `*` to grant access to all RuleSets. For the catalogs and the configuration, the DCL checks this field against the class name or config key (see below). |
| `ACTVT` | `ACTVT` | The activity code (see table below). |

### Activity Codes

| Activity | Code | Where enforced |
|---|---|---|
| Create | `01` | RAP behavior (`ZBP_ASIS_I_RULESET`, `ZBP_ASIS_I_CUSTLOGCAT`, `ZBP_ASIS_I_EVTPRODCAT`, `ZBP_ASIS_I_CONFIG`) |
| Change | `02` | RAP behavior (`ZBP_ASIS_I_RULESET`, `ZBP_ASIS_I_CUSTLOGCAT`, `ZBP_ASIS_I_EVTPRODCAT`, `ZBP_ASIS_I_CONFIG`) |
| Display | `03` | CDS DCL (`ZASIS_I_*` / `ZASIS_C_*` views), HTTP GET |
| Delete | `06` | RAP behavior (`ZBP_ASIS_I_RULESET`, `ZBP_ASIS_I_CUSTLOGCAT`, `ZBP_ASIS_I_EVTPRODCAT`, `ZBP_ASIS_I_CONFIG`) |
| Execute | `16` | ABAP API (`ZASIS_CL_INTERPRETER`), HTTP POST |

---

## Enforcement Points

### RAP Behavior (`ZBP_ASIS_I_RULESET`)

Authorization checks are performed in the RAP behavior implementation for all create, change, delete, and display operations on RuleSets. The `testRuleSet` action (which executes the interpreter from the Fiori UI) checks activity `16` (Execute).

### RAP Behavior (Catalog Maintenance)

Both catalog behavior implementations — `ZBP_ASIS_I_CUSTLOGCAT` and `ZBP_ASIS_I_EVTPRODCAT` — perform entity-level checks (not RuleSet-ID-specific instance checks) for create (`01`), update (`02`), and delete (`06`) using `ZASIS_GRL` with `ZASIS_RULE` set to `DUMMY`.

### RAP Behavior (Configuration Maintenance)

`ZBP_ASIS_I_CONFIG` performs the same entity-level checks as the catalog behaviors: create (`01`), update (`02`), and delete (`06`) on `ZASIS_GRL` with `ZASIS_RULE` set to `DUMMY`.

### CDS Access Control (DCL)

Catalog and RuleSet CDS entities are protected via DCL roles in `src/auth/` and enforce display activity `03` through `aspect pfcg_auth(...)`. For the custom logic and event producer catalogs, this includes:
- `ZASIS_AC_CUSTLOGCATALOG` and `ZASIS_AC_C_CUSTLOGCATALOG`
- `ZASIS_AC_EVTPRODCATALOG` and `ZASIS_AC_C_EVTPRODCATALOG`
- `ZASIS_AC_CONFIG` and `ZASIS_AC_C_CONFIG` (key field `ConfigKey` is mapped to `ZASIS_RULE`)

The configuration reader `ZASIS_CL_CONFIG` (used at runtime, e.g. for the bulk item limit) reads table `ZASIS_CONFIG` directly and performs no authorization check.

### ABAP API (`ZASIS_CL_INTERPRETER`)

When the interpreter is called directly via the ABAP API, it checks activity `16` (Execute) against the RuleSet ID being processed. If the check fails, `ZASIS_CX_NO_AUTH` is raised.

### HTTP Service (`ZASIS_CL_HTTP_HANDLER_CORE`)

The HTTP handler delegates authorization to the interpreter and the factory. Authorization failures result in an HTTP `403 Forbidden` response with a structured error body:

```json
{
  "ERROR": {
    "CODE": "ZASIS_MSGS/AUTH",
    "MESSAGE": "Not authorized",
    "STATUS": "403"
  }
}
```

---

## Assigning Authorizations

### Configuration Maintenance

To maintain configuration entries via `ZASIS_UI_CONFIG` (or F4579 *Custom Business Configurations*), a user needs `ZASIS_GRL` with:

| Field | Value | Purpose |
|---|---|---|
| `ACTVT` | `03` | Display entries (DCL). Without it, the list is empty. |
| `ACTVT` | `01`, `02`, `06` | Create, change, delete entries (as required) |
| `ZASIS_RULE` | `*` or the config keys, e.g. `BULK_MAX_ITEMS` | Checked by the DCL against `ConfigKey`; ignored (`DUMMY`) for create/change/delete |

Recommended: a dedicated admin role with `ZASIS_RULE = BULK_MAX_ITEMS` (or `*` for all current and future keys) and `ACTVT = 01, 02, 03, 06`. Because `ZASIS_RULE` is shared with RuleSet IDs, `*` also grants these activities on all RuleSets and catalogs; use explicit key values where this must be avoided. Note that `01`/`02`/`06` are checked without `ZASIS_RULE`, so any user with those activities for any RuleSet can also create, change, and delete config entries; they only need display access (`03`) on the key to see the entry.

### General

Create authorization profiles in your SAP system that include `ZASIS_GRL` with the appropriate activity codes and RuleSet IDs. Assign these profiles to roles and then to users via the standard SAP role and authorization management tools (transaction `PFCG`).

For development and testing environments, a broad profile granting `*` for `ZASIS_RULE` and all activity codes simplifies setup. In production, apply least-privilege — restrict `ZASIS_RULE` to specific RuleSet IDs and limit activity codes to what each user role requires.
