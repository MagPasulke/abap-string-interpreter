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

**Custom Logic Catalog UI** (for registering custom logic implementations):

The service definition `ZASIS_UI_CUSTLOGCATALOG` is installed via abapGit. The service binding must be created manually, the same way as for the RuleSet UI:

1. In ADT, create a new **OData V4 UI** service binding bound to the service definition `ZASIS_UI_CUSTLOGCATALOG`.
2. Give it a name of your choice (e.g. `ZASIS_UI_CUSTCATALOG_O4`).
3. Click **Publish** to activate it.
4. The Custom Logic Catalog UI is now available via the published service URL.

**Event Producer Catalog UI** (for registering event producer implementations):

The service definition `ZASIS_UI_EVTPRODCATALOG` is installed via abapGit. The service binding must be created manually:

1. In ADT, create a new **OData V4 UI** service binding bound to the service definition `ZASIS_UI_EVTPRODCATALOG`.
2. Give it a name of your choice (e.g. `ZASIS_UI_EVTPRODCATALOG_O4`).
3. Click **Publish** to activate it.
4. The Event Producer Catalog UI is now available via the published service URL.

**Configuration UI** (for maintaining technical configuration such as `BULK_MAX_ITEMS`):

The service definition `ZASIS_UI_CONFIG` is installed via abapGit. The service binding must be created manually:

1. In ADT, create a new **OData V4 UI** service binding bound to the service definition `ZASIS_UI_CONFIG`.
2. Give it a name of your choice (e.g. `ZASIS_UI_CONFIG_O4`).
3. Click **Publish** to activate it.
4. Entries can now be maintained via the service binding preview.

Maintaining configuration requires `ZASIS_GRL` (see [Authorization](authorization.md#configuration-maintenance)).

---

## Step 3: Activate the HTTP REST API

ZASIS provides two HTTP handler entry points. Choose the one that matches your system type and configuration.

### Option A: Cloud HTTP Service (Recommended for ABAP Cloud / BTP)

This option uses the cloud-native HTTP service framework (`IF_HTTP_SERVICE_EXTENSION`).

Activate the HTTP Service object `ZASIS_EXT_API_CLD` following the activation procedure for your target system, as described in the ADT help ("Working with the HTTP Service Editor") or the [SAP documentation](https://help.sap.com/docs/ABAP_PLATFORM_NEW/753088fc00704d0a80e7fbd6803c8adb/59842b6f9d6d4a8cbdcca4456a10e0b2.html). The procedure differs between ABAP Cloud and on-premise systems. ADT shows the service URL in the HTTP Service object.

Handler class: **`ZASIS_CL_HTTP_HANDLER_CLD`**

This handler adapts `IF_WEB_HTTP_REQUEST` / `IF_WEB_HTTP_RESPONSE` and delegates to the shared core handler. All adapter calls are wrapped in error handling that returns HTTP 500 on I/O failures.

---

### Option B: Classic SICF Node (On-Premise / ABAP Platform)

This option uses the classic Internet Communication Framework (`IF_HTTP_EXTENSION`).

Recommended ICF hierarchy — a customer node directly under `default_host`, outside SAP's `/sap` tree:

```
default_host
└── zasis          (no handler)
    └── api        (handler ZASIS_CL_HTTP_HANDLER)
```

1. Open transaction `SICF`.
2. On `default_host`, create the service node `zasis` without a handler.
3. Under `zasis`, create the service node `api` and assign the handler class **`ZASIS_CL_HTTP_HANDLER`**.
4. Activate both nodes.
5. The HTTP API is now reachable at `/zasis/api`, e.g. `https://<host>:<port>/zasis/api/ruleSetExecution/<ruleSetId>`.

Keep custom nodes out of `/sap/...`: that subtree belongs to SAP and can change with upgrades. The handler only evaluates the path below its node, so a different location works too.

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

## Optional: Developer tooling via ADT

The ADT scripts (`adt_gitpull`, `adt_checkerrors`, `adt_rununit`, CI `deploy-sap`) connect to the SAP system via the ADT REST API. Additional requirements:

- **abapGit ADT backend** – `adt_gitpull` and `deploy-sap` call `/sap/bc/adt/abapgit/repos`. The abapGit standalone report (`ZABAPGIT_STANDALONE`) alone does not provide this endpoint; on-premise systems need the abapGit developer version plus the [ADT backend](https://github.com/abapGit/ADT_Backend).
- **Package** – `SAP_ROOT_PACKAGE` in `.env` must match the package the repository is linked to, e.g. the local package `$ZASIS`.
- **TLS certificate** – the host in `SAP_ADT_URL` must match the system's certificate. If the certificate is signed by a CA that Node.js does not trust (the ABAP Cloud Developer Trial uses `SAP Global Root CA`, host `A4H.wdf.sap.corp`), set `SAP_ADT_CA_FILE` to a PEM file of that CA. Do not disable certificate checks.

See `.env.example` for all variables.
