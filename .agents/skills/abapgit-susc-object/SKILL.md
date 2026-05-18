---
name: abapgit-susc-object
description: Create an abapGit SUSC object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit SUSC object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create a `SUSC` (Authorization Object Class) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.susc.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_SUSC" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.
- SUSC names are max 4 characters.

## File structure
A SUSC object consists of a single file:
- `<name>.susc.xml` — authorization object class metadata

## Complete sample

#### `src/zfoo.susc.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_SUSC" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <TOBC>
    <OCLSS>ZFOO</OCLSS>
   </TOBC>
   <TOBCT>
    <LANGU>E</LANGU>
    <OCLSS>ZFOO</OCLSS>
    <CTEXT>Flight Management - Authorization Class</CTEXT>
   </TOBCT>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `TOBC > OCLSS` | Authorization object class name (uppercase, max 4 chars) |
| `TOBCT > LANGU` | Language key (`E` = English) |
| `TOBCT > OCLSS` | Same class name as in TOBC |
| `TOBCT > CTEXT` | Description text |

## Creation workflow
1. Take the authorization class name and target package path from the user/request.
2. Create `<name>.susc.xml` in the appropriate `src/` subfolder.
3. Set `OCLSS` to the uppercase object name (max 4 chars).
4. SUSC groups authorization objects (SUSO) under a common class.

## Done-check
- Serializer is exactly `LCL_OBJECT_SUSC`.
- `OCLSS` in XML matches the filename (uppercase vs lowercase).
- Name is max 4 characters.
- No SAP-system-only creation step is required.
