---
name: abapgit-intf-object
description: Create an abapGit INTF object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit INTF object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/INTF)

## Goal
Create an `INTF` (Interface) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<interface_name>.intf.abap` and `<interface_name>.intf.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_INTF" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
An INTF object consists of two files:
- `<name>.intf.abap` — interface source code
- `<name>.intf.xml` — interface metadata

## Complete sample

### Sample A — Simple interface

#### `src/zif_foo_processor.intf.abap`

```abap
INTERFACE zif_foo_processor
  PUBLIC.

  METHODS process
    IMPORTING
      input         TYPE string
    RETURNING
      VALUE(result) TYPE string
    RAISING
      zcx_foo_error.

ENDINTERFACE.
```

#### `src/zif_foo_processor.intf.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_INTF" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOINTERF>
    <CLSNAME>ZIF_FOO_PROCESSOR</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>Processor Interface</DESCRIPT>
    <EXPOSURE>2</EXPOSURE>
    <STATE>1</STATE>
    <UNICODE>X</UNICODE>
   </VSEOINTERF>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Interface with constants and types

#### `src/zif_foo_constants.intf.abap`

```abap
INTERFACE zif_foo_constants
  PUBLIC.

  TYPES:
    BEGIN OF ty_config,
      key   TYPE char30,
      value TYPE string,
    END OF ty_config,
    tt_config TYPE STANDARD TABLE OF ty_config WITH KEY key.

  CONSTANTS:
    BEGIN OF status,
      active   TYPE char1 VALUE 'A',
      inactive TYPE char1 VALUE 'I',
    END OF status.

ENDINTERFACE.
```

#### `src/zif_foo_constants.intf.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_INTF" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOINTERF>
    <CLSNAME>ZIF_FOO_CONSTANTS</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>Application Constants</DESCRIPT>
    <EXPOSURE>2</EXPOSURE>
    <STATE>1</STATE>
    <UNICODE>X</UNICODE>
   </VSEOINTERF>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `CLSNAME` | Interface name (uppercase, max 30 chars) |
| `LANGU` | Original language (`E` = English) |
| `DESCRIPT` | Short description |
| `EXPOSURE` | `2` = public |
| `STATE` | `1` = active |
| `UNICODE` | `X` = Unicode checks active |

## Creation workflow
1. Take the interface name and target package path from the user/request.
2. Create `<name>.intf.abap` with the INTERFACE definition.
3. Create `<name>.intf.xml` with VSEOINTERF metadata.
4. Set `CLSNAME` to the uppercase interface name.

## Done-check
- Serializer is exactly `LCL_OBJECT_INTF`.
- `CLSNAME` in XML matches the filename (uppercase vs lowercase).
- `.intf.abap` has `INTERFACE ... ENDINTERFACE.` block.
- `EXPOSURE` is `2` for public interfaces.
- No SAP-system-only creation step is required.
