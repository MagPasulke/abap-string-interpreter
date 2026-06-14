# Authorization

ZASIS enforces authorization at two levels: the RAP behavior layer (Fiori UI) and the runtime layer (ABAP API and HTTP service). Both layers use the same authorization object.

---

## Authorization Object: `ZASIS_GRL`

The authorization object `ZASIS_GRL` controls access to RuleSets. It has two fields:

| Field | Domain | Description |
|---|---|---|
| `ZASIS_RULE` | `ZASIS_RULESETID` | The RuleSet ID. Use `*` to grant access to all RuleSets. |
| `ACTVT` | `ACTVT` | The activity code (see table below). |

### Activity Codes

| Activity | Code | Where enforced |
|---|---|---|
| Create | `01` | RAP behavior (Fiori UI) |
| Change | `02` | RAP behavior (Fiori UI) |
| Display | `03` | RAP behavior (Fiori UI), HTTP GET |
| Delete | `06` | RAP behavior (Fiori UI) |
| Execute | `16` | ABAP API (`ZASIS_CL_INTERPRETER`), HTTP POST |

---

## Enforcement Points

### RAP Behavior (`ZBP_ASIS_I_RULESET`)

Authorization checks are performed in the RAP behavior implementation for all create, change, delete, and display operations on RuleSets. The `testRuleSet` action (which executes the interpreter from the Fiori UI) checks activity `16` (Execute).

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

Create authorization profiles in your SAP system that include `ZASIS_GRL` with the appropriate activity codes and RuleSet IDs. Assign these profiles to roles and then to users via the standard SAP role and authorization management tools (transaction `PFCG`).

For development and testing environments, a broad profile granting `*` for `ZASIS_RULE` and all activity codes simplifies setup. In production, apply least-privilege — restrict `ZASIS_RULE` to specific RuleSet IDs and limit activity codes to what each user role requires.
