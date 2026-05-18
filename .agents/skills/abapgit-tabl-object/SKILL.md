---
name: abapgit-tabl-object
description: Create an abapGit TABL object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit TABL object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/TABL)

## Goal
Create a `TABL` (Table / Structure) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.tabl.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_TABL" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A TABL object consists of a single file:
- `<name>.tabl.xml` — table/structure metadata

## Complete sample

### Sample A — Transparent table (TRANSP)

#### `src/zfoo_flight.tabl.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_TABL" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD02V>
    <TABNAME>ZFOO_FLIGHT</TABNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <TABCLASS>TRANSP</TABCLASS>
    <CLIDEP>X</CLIDEP>
    <DDTEXT>Flight Data</DDTEXT>
    <MASTERLANG>E</MASTERLANG>
    <MAINFLAG>N</MAINFLAG>
    <CONTFLAG>A</CONTFLAG>
    <EXCLASS>4</EXCLASS>
   </DD02V>
   <DD09L>
    <TABNAME>ZFOO_FLIGHT</TABNAME>
    <AS4LOCAL>A</AS4LOCAL>
    <TABKAT>0</TABKAT>
    <TABART>APPL0</TABART>
    <BUFALLOW>N</BUFALLOW>
   </DD09L>
   <DD03P_TABLE>
    <DD03P>
     <FIELDNAME>CLIENT</FIELDNAME>
     <KEYFLAG>X</KEYFLAG>
     <ADMINFIELD>0</ADMINFIELD>
     <INTTYPE>C</INTTYPE>
     <INTLEN>000006</INTLEN>
     <NOTNULL>X</NOTNULL>
     <DATATYPE>CLNT</DATATYPE>
     <LENG>000003</LENG>
     <MASK>  CLNT</MASK>
    </DD03P>
    <DD03P>
     <FIELDNAME>FLIGHT_ID</FIELDNAME>
     <KEYFLAG>X</KEYFLAG>
     <ROLLNAME>ZFOO_FLIGHT_ID</ROLLNAME>
     <ADMINFIELD>0</ADMINFIELD>
     <NOTNULL>X</NOTNULL>
     <COMPTYPE>E</COMPTYPE>
    </DD03P>
    <DD03P>
     <FIELDNAME>CARRIER</FIELDNAME>
     <ROLLNAME>ZFOO_CARRIER</ROLLNAME>
     <ADMINFIELD>0</ADMINFIELD>
     <COMPTYPE>E</COMPTYPE>
    </DD03P>
    <DD03P>
     <FIELDNAME>CONNECTION</FIELDNAME>
     <ADMINFIELD>0</ADMINFIELD>
     <INTTYPE>C</INTTYPE>
     <INTLEN>000008</INTLEN>
     <DATATYPE>CHAR</DATATYPE>
     <LENG>000004</LENG>
     <MASK>  CHAR</MASK>
    </DD03P>
    <DD03P>
     <FIELDNAME>FLIGHT_DATE</FIELDNAME>
     <ADMINFIELD>0</ADMINFIELD>
     <INTTYPE>D</INTTYPE>
     <INTLEN>000016</INTLEN>
     <DATATYPE>DATS</DATATYPE>
     <LENG>000008</LENG>
     <MASK>  DATS</MASK>
    </DD03P>
    <DD03P>
     <FIELDNAME>LAST_CHANGED_AT</FIELDNAME>
     <ROLLNAME>TIMESTAMPL</ROLLNAME>
     <ADMINFIELD>0</ADMINFIELD>
     <COMPTYPE>E</COMPTYPE>
    </DD03P>
   </DD03P_TABLE>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Structure (INTTAB)

#### `src/zfoo_flight_result.tabl.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_TABL" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD02V>
    <TABNAME>ZFOO_FLIGHT_RESULT</TABNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <TABCLASS>INTTAB</TABCLASS>
    <DDTEXT>Flight Result Structure</DDTEXT>
    <MASTERLANG>E</MASTERLANG>
    <EXCLASS>4</EXCLASS>
   </DD02V>
   <DD03P_TABLE>
    <DD03P>
     <FIELDNAME>FLIGHT_ID</FIELDNAME>
     <ROLLNAME>ZFOO_FLIGHT_ID</ROLLNAME>
     <ADMINFIELD>0</ADMINFIELD>
     <COMPTYPE>E</COMPTYPE>
    </DD03P>
    <DD03P>
     <FIELDNAME>STATUS</FIELDNAME>
     <ADMINFIELD>0</ADMINFIELD>
     <INTTYPE>C</INTTYPE>
     <INTLEN>000002</INTLEN>
     <DATATYPE>CHAR</DATATYPE>
     <LENG>000001</LENG>
     <MASK>  CHAR</MASK>
    </DD03P>
   </DD03P_TABLE>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| **DD02V** | Table header |
| `TABNAME` | Table/structure name (uppercase, max 30 chars) |
| `TABCLASS` | `TRANSP` = transparent table, `INTTAB` = structure, `CLUSTER` = cluster table, `POOL` = pool table |
| `CLIDEP` | `X` = client-dependent (only for TRANSP) |
| `CONTFLAG` | Delivery class: `A` = application, `C` = customizing, `L` = temporary, `S` = system |
| **DD09L** | Technical settings (only for TRANSP) |
| `TABART` | Data class: `APPL0`, `APPL1`, etc. |
| `BUFALLOW` | Buffering: `N` = not allowed, `X` = allowed |
| **DD03P** | Field definition |
| `FIELDNAME` | Field name |
| `KEYFLAG` | `X` = key field |
| `ROLLNAME` | Data element reference (use `COMPTYPE` = `E`) |
| `DATATYPE`+`LENG` | Direct type (when no ROLLNAME) |
| `COMPTYPE` | `E` = data element, `S` = structure, `R` = reference |

## Creation workflow
1. Take the table/structure name and target package path from the user/request.
2. Create `<name>.tabl.xml` in the appropriate `src/` subfolder.
3. For transparent tables: include `DD02V`, `DD09L`, and `DD03P_TABLE`.
4. For structures: include `DD02V` and `DD03P_TABLE` (no `DD09L`).
5. Fields can reference data elements via `ROLLNAME`+`COMPTYPE=E` or define types directly.
6. Always include `CLIENT` as first key field for client-dependent tables.

## Done-check
- Serializer is exactly `LCL_OBJECT_TABL`.
- `TABNAME` in XML matches the filename (uppercase vs lowercase).
- `TABCLASS` is set correctly (`TRANSP` or `INTTAB`).
- Key fields have `KEYFLAG` = `X` and `NOTNULL` = `X`.
- `DD09L` is present only for transparent tables.
- No SAP-system-only creation step is required.
