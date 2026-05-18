---
name: abapgit-g4ba-object
description: Create an abapGit G4BA object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit G4BA object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create a `G4BA` (OData V4 Backend Service Group) object directly as abapGit-serialized repository files, outside an SAP system. G4BA is the OData V4 service catalog entry generated when a service binding is published.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.g4ba.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_G4BA" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.
- G4BA names typically match the corresponding service binding name (SRVB).

## File structure
A G4BA object consists of a single file:
- `<name>.g4ba.xml` — OData V4 service group metadata

## Complete sample

#### `src/zfoo_ui_flight_o4.g4ba.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_G4BA" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <_-IWBEP_-I_V4_MSGA>
    <_-IWBEP_-I_V4_MSGA>
     <GROUP_ID>ZFOO_UI_FLIGHT_O4</GROUP_ID>
     <SERVICE_ID>/IWBEP/COMMON</SERVICE_ID>
     <REPOSITORY_ID>DEFAULT</REPOSITORY_ID>
     <GWBEP_VERSION>031</GWBEP_VERSION>
    </_-IWBEP_-I_V4_MSGA>
   </_-IWBEP_-I_V4_MSGA>
   <_-IWBEP_-I_V4_MSGR>
    <_-IWBEP_-I_V4_MSGR>
     <GROUP_ID>ZFOO_UI_FLIGHT_O4</GROUP_ID>
     <GWBEP_VERSION>031</GWBEP_VERSION>
     <ASSIGNMENT_REPO_ID>SADL</ASSIGNMENT_REPO_ID>
     <EXTERNAL_GROUP_ID>ZFOO_UI_FLIGHT_O4</EXTERNAL_GROUP_ID>
    </_-IWBEP_-I_V4_MSGR>
   </_-IWBEP_-I_V4_MSGR>
   <_-IWBEP_-I_V4_MSGT>
    <_-IWBEP_-I_V4_MSGT>
     <GROUP_ID>ZFOO_UI_FLIGHT_O4</GROUP_ID>
     <LANGUAGE>E</LANGUAGE>
     <DESCRIPTION>Flight Management - OData V4 UI Service</DESCRIPTION>
    </_-IWBEP_-I_V4_MSGT>
   </_-IWBEP_-I_V4_MSGT>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `GROUP_ID` | Service group name (uppercase, matches SRVB name) |
| `SERVICE_ID` | `/IWBEP/COMMON` (standard IWBEP service) |
| `REPOSITORY_ID` | `DEFAULT` |
| `GWBEP_VERSION` | Gateway version (`031` typical for current systems) |
| `ASSIGNMENT_REPO_ID` | `SADL` (Service Adaptation Description Language) |
| `EXTERNAL_GROUP_ID` | External name, typically same as `GROUP_ID` |
| `DESCRIPTION` | Human-readable description |

## Notes
- G4BA objects use IWBEP namespace XML tags: `_-IWBEP_-I_V4_MSGA`, `_-IWBEP_-I_V4_MSGR`, `_-IWBEP_-I_V4_MSGT`.
- The escaped dashes (`_-` prefix/suffix) represent the `/IWBEP/` namespace in XML.
- G4BA is **automatically generated** when publishing a V4 service binding. Manual creation follows the same structure.

## Creation workflow
1. Take the service group name and target package path from the user/request.
2. Create `<name>.g4ba.xml` in the same package as the corresponding SRVB.
3. Set all `GROUP_ID` and `EXTERNAL_GROUP_ID` to the uppercase object name.
4. Keep `SERVICE_ID` as `/IWBEP/COMMON` and `REPOSITORY_ID` as `DEFAULT`.

## Done-check
- Serializer is exactly `LCL_OBJECT_G4BA`.
- `GROUP_ID` in XML matches the filename (uppercase vs lowercase).
- IWBEP namespace XML tags use the `_-IWBEP_-` escaped format.
- No SAP-system-only creation step is required.
