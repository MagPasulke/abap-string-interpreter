---
name: abapgit-auth-object
description: Create an abapGit AUTH object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit AUTH object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/AUTH)

## Goal
Create an `AUTH` (Authorization Check Field) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.auth.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_AUTH" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
An AUTH object consists of a single file:
- `<name>.auth.xml` — authorization field metadata

## Complete sample

#### `src/zfoo_carrier.auth.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_AUTH" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <AUTHX>
    <FIELDNAME>ZFOO_CARRIER</FIELDNAME>
    <ROLLNAME>ZFOO_CARRIER_ID</ROLLNAME>
    <CHECKTABLE>ZFOO_FLIGHT</CHECKTABLE>
   </AUTHX>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `FIELDNAME` | Authorization field name (uppercase, max 10 chars) |
| `ROLLNAME` | Referenced data element |
| `CHECKTABLE` | Check table for the field (optional) |

## Creation workflow
1. Take the authorization field name and target package path from the user/request.
2. Create `<name>.auth.xml` in the appropriate `src/` subfolder.
3. Set `FIELDNAME` to the uppercase object name.
4. Reference the data element via `ROLLNAME` and optionally a `CHECKTABLE`.

## Done-check
- Serializer is exactly `LCL_OBJECT_AUTH`.
- `FIELDNAME` in XML matches the filename (uppercase vs lowercase).
- `ROLLNAME` references a valid data element.
- No SAP-system-only creation step is required.
