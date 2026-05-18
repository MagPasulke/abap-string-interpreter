---
name: abapgit-suso-object
description: Create an abapGit SUSO object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit SUSO object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create a `SUSO` (Authorization Object) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.suso.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_SUSO" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.
- SUSO names are max 10 characters.

## File structure
A SUSO object consists of a single file:
- `<name>.suso.xml` — authorization object metadata

## Complete sample

#### `src/zfoo_flght.suso.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_SUSO" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <TOBJ>
    <OBJCT>ZFOO_FLGHT</OBJCT>
    <FIEL1>ZFOO_CARRIER</FIEL1>
    <FIEL2>ACTVT</FIEL2>
    <OCLSS>ZFOO</OCLSS>
   </TOBJ>
   <TOBJT>
    <LANGU>E</LANGU>
    <OBJECT>ZFOO_FLGHT</OBJECT>
    <TTEXT>Flight Management: Read and Write Access</TTEXT>
   </TOBJT>
   <TOBJVORFLG>
    <OBJCT>ZFOO_FLGHT</OBJCT>
    <FLAG3>N</FLAG3>
    <FLAG4>A</FLAG4>
    <FLAG5>A</FLAG5>
   </TOBJVORFLG>
   <TACTZ>
    <TACTZ>
     <BROBJ>ZFOO_FLGHT</BROBJ>
     <ACTVT>01</ACTVT>
    </TACTZ>
    <TACTZ>
     <BROBJ>ZFOO_FLGHT</BROBJ>
     <ACTVT>02</ACTVT>
    </TACTZ>
    <TACTZ>
     <BROBJ>ZFOO_FLGHT</BROBJ>
     <ACTVT>03</ACTVT>
    </TACTZ>
    <TACTZ>
     <BROBJ>ZFOO_FLGHT</BROBJ>
     <ACTVT>06</ACTVT>
    </TACTZ>
   </TACTZ>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `TOBJ > OBJCT` | Authorization object name (uppercase, max 10 chars) |
| `TOBJ > FIEL1..FIEL10` | Authorization fields (AUTH objects) |
| `TOBJ > OCLSS` | Authorization object class (SUSC, max 4 chars) |
| `TOBJT > TTEXT` | Description text |
| `TOBJVORFLG` | Default field flags (`N`=no check, `A`=all values) |
| `TACTZ > ACTVT` | Permitted activities (`01`=Create, `02`=Change, `03`=Display, `06`=Delete) |

## Creation workflow
1. Take the authorization object name and target package path from the user/request.
2. Create `<name>.suso.xml` in the appropriate `src/` subfolder.
3. Set `OBJCT` to the uppercase object name.
4. Add authorization fields (`FIEL1`, `FIEL2`, etc.) — these must be AUTH objects.
5. Assign to an authorization class via `OCLSS`.
6. Define permitted activities in `TACTZ`.

## Done-check
- Serializer is exactly `LCL_OBJECT_SUSO`.
- `OBJCT` in XML matches the filename (uppercase vs lowercase).
- `OCLSS` references an existing SUSC authorization class.
- All `FIEL*` values reference existing AUTH fields.
- No SAP-system-only creation step is required.
