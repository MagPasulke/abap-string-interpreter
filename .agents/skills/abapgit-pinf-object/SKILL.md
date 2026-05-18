---
name: abapgit-pinf-object
description: Create an abapGit PINF object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit PINF object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create a `PINF` (Package Interface) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.pinf.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_PINF" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A PINF object consists of a single file:
- `<name>.pinf.xml` — package interface metadata

## Complete sample

### Sample A — Package interface exposing individual objects

#### `src/zfoo_public.pinf.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_PINF" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <PINF>
    <ATTRIBUTES>
     <INTF_NAME>ZFOO_PUBLIC</INTF_NAME>
     <DESCRIPT>Public API - Flight Management</DESCRIPT>
    </ATTRIBUTES>
    <ELEMENTS>
     <SCOMELDTLN>
      <INTF_NAME>ZFOO_PUBLIC</INTF_NAME>
      <ELEM_TYPE>CLAS</ELEM_TYPE>
      <ELEM_KEY>ZFOO_CL_FLIGHT_API</ELEM_KEY>
     </SCOMELDTLN>
     <SCOMELDTLN>
      <INTF_NAME>ZFOO_PUBLIC</INTF_NAME>
      <ELEM_TYPE>INTF</ELEM_TYPE>
      <ELEM_KEY>ZFOO_IF_FLIGHT</ELEM_KEY>
     </SCOMELDTLN>
    </ELEMENTS>
   </PINF>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Package interface referencing a sub-package interface

#### `src/zfoo_main.pinf.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_PINF" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <PINF>
    <ATTRIBUTES>
     <INTF_NAME>ZFOO_MAIN</INTF_NAME>
     <DESCRIPT>Main Public Interface</DESCRIPT>
    </ATTRIBUTES>
    <ELEMENTS>
     <SCOMELDTLN>
      <INTF_NAME>ZFOO_MAIN</INTF_NAME>
      <ELEM_TYPE>PINF</ELEM_TYPE>
      <ELEM_KEY>ZFOO_PUBLIC</ELEM_KEY>
     </SCOMELDTLN>
    </ELEMENTS>
   </PINF>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `INTF_NAME` | Package interface name (uppercase) |
| `DESCRIPT` | Short description |
| `ELEMENTS > SCOMELDTLN` | Each exposed element |
| `ELEM_TYPE` | Object type (`CLAS`, `INTF`, `TABL`, `PINF`, etc.) |
| `ELEM_KEY` | Object name (uppercase) |

## Creation workflow
1. Take the package interface name and target package path from the user/request.
2. Create `<name>.pinf.xml` in the same folder as the owning `package.devc.xml`.
3. Set `INTF_NAME` to the uppercase object name.
4. List all objects to expose in `ELEMENTS` using `SCOMELDTLN` entries.
5. Use `ELEM_TYPE=PINF` to reference sub-package interfaces.

## Done-check
- Serializer is exactly `LCL_OBJECT_PINF`.
- `INTF_NAME` in XML matches the filename (uppercase vs lowercase).
- All `ELEM_KEY` entries reference objects that exist in the project.
- No SAP-system-only creation step is required.
