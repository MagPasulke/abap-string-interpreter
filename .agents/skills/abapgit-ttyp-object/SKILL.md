---
name: abapgit-ttyp-object
description: Create an abapGit TTYP object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit TTYP object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/TTYP)

## Goal
Create a `TTYP` (Table Type) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.ttyp.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_TTYP" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A TTYP object consists of a single file:
- `<name>.ttyp.xml` — table type metadata

## Complete sample

### Sample A — Standard table of a structure

#### `src/zfoo_tt_items.ttyp.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_TTYP" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD40V>
    <TYPENAME>ZFOO_TT_ITEMS</TYPENAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <ROWTYPE>ZFOO_ITEM</ROWTYPE>
    <ROWKIND>S</ROWKIND>
    <DATATYPE>STRU</DATATYPE>
    <ACCESSMODE>T</ACCESSMODE>
    <KEYDEF>D</KEYDEF>
    <KEYKIND>N</KEYKIND>
    <DDTEXT>Table Type for Items</DDTEXT>
   </DD40V>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Sorted table with explicit key

#### `src/zfoo_tt_sorted_items.ttyp.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_TTYP" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD40V>
    <TYPENAME>ZFOO_TT_SORTED_ITEMS</TYPENAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <ROWTYPE>ZFOO_ITEM</ROWTYPE>
    <ROWKIND>S</ROWKIND>
    <DATATYPE>STRU</DATATYPE>
    <ACCESSMODE>S</ACCESSMODE>
    <KEYDEF>K</KEYDEF>
    <KEYKIND>U</KEYKIND>
    <DDTEXT>Sorted Table Type for Items</DDTEXT>
   </DD40V>
   <DD42V>
    <DD42V>
     <TYPENAME>ZFOO_TT_SORTED_ITEMS</TYPENAME>
     <KEYFDPOS>0001</KEYFDPOS>
     <ROTEFLDNM>ITEM_ID</ROTEFLDNM>
    </DD42V>
   </DD42V>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `TYPENAME` | Table type name (uppercase, max 30 chars) |
| `DDLANGUAGE` | Original language (`E` = English) |
| `ROWTYPE` | Line type (structure or data element name) |
| `ROWKIND` | Row kind: `S` = structure, `E` = data element |
| `DATATYPE` | `STRU` for structure, or ABAP type for elementary |
| `ACCESSMODE` | `T` = standard, `S` = sorted, `H` = hashed |
| `KEYDEF` | `D` = default key, `K` = key components defined |
| `KEYKIND` | `N` = non-unique, `U` = unique |
| `DD42V` | Optional: explicit key field definitions |

## Creation workflow
1. Take the table type name and target package path from the user/request.
2. Create `<name>.ttyp.xml` in the appropriate `src/` subfolder.
3. Set `TYPENAME` to the uppercase object name.
4. Set `ROWTYPE` to the referenced structure or data element.
5. Choose `ACCESSMODE`, `KEYDEF`, and `KEYKIND` as required.

## Done-check
- Serializer is exactly `LCL_OBJECT_TTYP`.
- `TYPENAME` in XML matches the filename (uppercase vs lowercase).
- `ROWTYPE` references a valid existing or to-be-created object.
- `ACCESSMODE`/`KEYDEF`/`KEYKIND` combination is valid.
- No SAP-system-only creation step is required.
