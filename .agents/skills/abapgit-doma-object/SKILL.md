---
name: abapgit-doma-object
description: Create an abapGit DOMA object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit DOMA object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/DOMA)

## Goal
Create a `DOMA` (Domain) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.doma.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_DOMA" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A DOMA object consists of a single file:
- `<name>.doma.xml` — domain metadata

## Complete sample

### Sample A — Simple domain (CHAR type)

#### `src/zfoo_status.doma.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DOMA" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD01V>
    <DOMNAME>ZFOO_STATUS</DOMNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <DATATYPE>CHAR</DATATYPE>
    <LENG>000001</LENG>
    <OUTPUTLEN>000001</OUTPUTLEN>
    <DDTEXT>Status</DDTEXT>
    <DOMMASTER>E</DOMMASTER>
   </DD01V>
   <DD07V_TAB>
    <DD07V>
     <DOMNAME>ZFOO_STATUS</DOMNAME>
     <VALPOS>0001</VALPOS>
     <DDLANGUAGE>E</DDLANGUAGE>
     <DOMVALUE_L>A</DOMVALUE_L>
     <DDTEXT>Active</DDTEXT>
    </DD07V>
    <DD07V>
     <DOMNAME>ZFOO_STATUS</DOMNAME>
     <VALPOS>0002</VALPOS>
     <DDLANGUAGE>E</DDLANGUAGE>
     <DOMVALUE_L>I</DOMVALUE_L>
     <DDTEXT>Inactive</DDTEXT>
    </DD07V>
   </DD07V_TAB>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Numeric domain (INT1 type, no fixed values)

#### `src/zfoo_quantity.doma.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DOMA" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD01V>
    <DOMNAME>ZFOO_QUANTITY</DOMNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <DATATYPE>INT1</DATATYPE>
    <LENG>000003</LENG>
    <OUTPUTLEN>000003</OUTPUTLEN>
    <DDTEXT>Quantity</DDTEXT>
    <DOMMASTER>E</DOMMASTER>
   </DD01V>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `DOMNAME` | Domain name (uppercase, max 30 chars) |
| `DDLANGUAGE` | Original language (`E` = English) |
| `DATATYPE` | ABAP data type: `CHAR`, `NUMC`, `DATS`, `TIMS`, `DEC`, `INT1`, `INT2`, `INT4`, `RAW`, `FLTP`, etc. |
| `LENG` | Internal length (zero-padded 6 digits) |
| `OUTPUTLEN` | Output length (zero-padded 6 digits) |
| `DDTEXT` | Short description |
| `DOMMASTER` | Master language (`E` = English) |
| `DD07V_TAB` | Optional: fixed values list |

## Creation workflow
1. Take the domain name and target package path from the user/request.
2. Create `<name>.doma.xml` in the appropriate `src/` subfolder.
3. Set `DOMNAME` to the uppercase object name.
4. Choose the correct `DATATYPE` and `LENG` for the use case.
5. Add `DD07V_TAB` entries only if the domain has fixed values.

## Done-check
- Serializer is exactly `LCL_OBJECT_DOMA`.
- `DOMNAME` in XML matches the filename (uppercase vs lowercase).
- `DATATYPE` and `LENG` are valid ABAP dictionary types.
- Fixed values (if any) have sequential `VALPOS` starting at `0001`.
- No SAP-system-only creation step is required.
