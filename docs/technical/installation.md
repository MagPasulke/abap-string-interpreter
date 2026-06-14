# Installation

This page describes how to install ZASIS into a SAP system and activate its access points.

---

## Prerequisites

- SAP ABAP Platform 2023 / SAP BASIS 758 (ABAP Cloud Developer Trial or on-premise with equivalent release)
- [abapGit](https://docs.abapgit.org/user-guide/getting-started/install.html) installed in the target system
- A user with sufficient authorizations to create packages, install repository objects, and activate services

---

## Step 1: Install via abapGit

1. Open abapGit in your SAP system (transaction `ZABAPGIT` or the ADT abapGit plugin).
2. Create a new online repository pointing to this repository's URL.
3. Assign a target package (e.g. `ZASIS`) and pull the repository.
4. Activate all objects after the pull completes.

---

## Step 2: Activate the Fiori UI (OData V4 Service Binding)

**RuleSet Maintenance UI:**

The service definition `ZASIS_UI_RULESET` is installed via abapGit. The corresponding service binding is gitignored and must be created manually:

1. In ADT, create a new **OData V4 UI** service binding bound to the service definition `ZASIS_UI_RULESET`.
2. Give it a name of your choice (e.g. `ZASIS_UI_RULESET_O4`).
3. Click **Publish** to activate it.
4. The Fiori Elements RuleSet maintenance UI is now available via the published service URL.

**Enhancement Catalog UI** (for registering custom logic implementations):

The service definition `ZASIS_UI_CUSTLOGCATALOG` is installed via abapGit. The service binding must be created manually, the same way as for the RuleSet UI:

1. In ADT, create a new **OData V4 UI** service binding bound to the service definition `ZASIS_UI_CUSTLOGCATALOG`.
2. Give it a name of your choice (e.g. `ZASIS_UI_CUSTCATALOG_O4`).
3. Click **Publish** to activate it.
4. The Enhancement Catalog UI is now available via the published service URL.

---

## Step 3: Activate the HTTP REST API

ZASIS provides two HTTP handler entry points. Choose the one that matches your system type and configuration.

### Option A: Cloud HTTP Service (Recommended for ABAP Cloud / BTP)

This option uses the cloud-native HTTP service framework (`IF_HTTP_SERVICE_EXTENSION`).

1. In ADT, locate the HTTP Service object `ZASIS_EXT_API_CLD`.
2. Activate it.
3. The service is now reachable at the path configured in the service definition.

Handler class: **`ZASIS_CL_HTTP_HANDLER_CLD`**

This handler adapts `IF_WEB_HTTP_REQUEST` / `IF_WEB_HTTP_RESPONSE` and delegates to the shared core handler. All adapter calls are wrapped in error handling that returns HTTP 500 on I/O failures.

---

### Option B: Classic SICF Node (On-Premise / ABAP Platform)

This option uses the classic Internet Communication Framework (`IF_HTTP_EXTENSION`).

1. Open transaction `SICF`.
2. Navigate to `default_host` (or a sub-path of your choice).
3. Create a new service node — for example, `zasis_ext_api`.
4. In the service node properties, assign the handler class **`ZASIS_CL_HTTP_HANDLER`**.
5. Activate the service node.
6. The HTTP API is now reachable at the configured ICF path (e.g. `/sap/bc/zasis_ext_api`).

Handler class: **`ZASIS_CL_HTTP_HANDLER`**

This handler adapts `IF_HTTP_REQUEST` / `IF_HTTP_RESPONSE` and delegates to the same shared core handler. Adapter calls are not individually wrapped — exceptions from the SAP ICF layer propagate to the ICF runtime.

---

## Comparison: Cloud HTTP Service vs SICF

| Aspect | Cloud HTTP Service (`_CLD`) | SICF (`ZASIS_CL_HTTP_HANDLER`) |
|---|---|---|
| SAP interface | `IF_HTTP_SERVICE_EXTENSION` | `IF_HTTP_EXTENSION` |
| Activation | ADT — activate HTTP Service object | SICF transaction — create and activate node |
| Suitable for | ABAP Cloud, BTP ABAP Environment | On-premise ABAP Platform |
| Adapter error handling | Wrapped — I/O errors return HTTP 500 | Unwrapped — I/O exceptions propagate |
| Body read method | `GET_TEXT()` | `GET_CDATA()` |
| Path header field | `~path` | `~path_info` |

Both handlers share identical business logic via `ZASIS_CL_HTTP_HANDLER_CORE`.

> **Planned:** A clean separation between a cloud release (containing only cloud-compatible artifacts) and an on-premise release (containing only on-premise artifacts) is planned for a future version — see [issue #88](https://github.com/MagPasulke/abap-string-interpreter/issues/88). From that point on, each release variant will ship only the artifacts relevant to its target environment.

---

## Verifying the Installation

After activating the HTTP service, send a test request:

```bash
curl -u <user>:<password> \
  -X GET \
  https://<host>/<path>/ruleSet/<yourRuleSetId>
```

A `200 OK` response with the RuleSet JSON confirms the service is active and authorization is working. A `400` with an error envelope indicates the RuleSet ID was not found (expected if no RuleSets have been created yet). A `403` indicates an authorization issue — check that the user has the `ZASIS_GRL` authorization object assigned.
