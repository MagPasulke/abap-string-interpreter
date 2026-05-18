---
name: abapgit-srvd-object
description: Create an abapGit SRVD object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit SRVD object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create a `SRVD` (Service Definition) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.srvd.<extension>` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_SRVD" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A SRVD object consists of two files:
- `<name>.srvd.srvdsrv` — service definition source
- `<name>.srvd.xml` — metadata

## Complete sample

#### `src/zfoo_ui_flight.srvd.srvdsrv`

```text
@EndUserText.label: 'Flight Management Service'
define service ZFOO_UI_FLIGHT {
  expose ZFOO_C_FLIGHT as Flight;
}
```

#### `src/zfoo_ui_flight.srvd.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_SRVD" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <SRVD>
    <NAME>ZFOO_UI_FLIGHT</NAME>
    <TYPE>SRVD/SRV</TYPE>
    <DESCRIPTION>Flight Management Service</DESCRIPTION>
    <LANGUAGE>EN</LANGUAGE>
    <MASTER_LANGUAGE>EN</MASTER_LANGUAGE>
    <SOURCE_URI>./zfoo_ui_flight/source/main</SOURCE_URI>
    <SOURCE_TYPE>ABAP_SOURCE</SOURCE_TYPE>
    <SOURCE_ORIGIN_DESCRIPTION>ABAP Development Tools</SOURCE_ORIGIN_DESCRIPTION>
    <SRVD_SOURCE_TYPE>S</SRVD_SOURCE_TYPE>
    <SRVD_SOURCE_TYPE_DESC>Definition</SRVD_SOURCE_TYPE_DESC>
   </SRVD>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `NAME` | Service definition name (uppercase) |
| `TYPE` | Always `SRVD/SRV` |
| `DESCRIPTION` | Short description |
| `SOURCE_URI` | `./<lowercase_name>/source/main` |
| `SRVD_SOURCE_TYPE` | `S` = Definition |

## Creation workflow
1. Take the service definition name and target package path from the user/request.
2. Create `<name>.srvd.srvdsrv` with the `define service` source.
3. Create `<name>.srvd.xml` with SRVD metadata.
4. `expose` lists all CDS consumption views to expose via OData.
5. Set `SOURCE_URI` to `./<lowercase_name>/source/main`.

## Done-check
- Serializer is exactly `LCL_OBJECT_SRVD`.
- `NAME` in XML matches the filename (uppercase vs lowercase).
- `.srvdsrv` uses `define service ... { expose ... }` syntax.
- All exposed entities reference existing CDS consumption views.
- No SAP-system-only creation step is required.
