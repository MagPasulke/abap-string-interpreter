---
name: abapgit-dtel-object
description: Create an abapGit DTEL object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit DTEL object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/DTEL)

## Goal
Create a `DTEL` (Data Element) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.dtel.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_DTEL" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A DTEL object consists of a single file:
- `<name>.dtel.xml` — data element metadata

## Complete sample

### Sample A — Data element with direct type (CHAR)

#### `src/zfoo_customer_name.dtel.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DTEL" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD04V>
    <ROLLNAME>ZFOO_CUSTOMER_NAME</ROLLNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <HEADLEN>55</HEADLEN>
    <SCRLEN1>10</SCRLEN1>
    <SCRLEN2>20</SCRLEN2>
    <SCRLEN3>40</SCRLEN3>
    <DDTEXT>Customer Name</DDTEXT>
    <REPTEXT>Customer Name</REPTEXT>
    <SCRTEXT_S>Cust. Name</SCRTEXT_S>
    <SCRTEXT_M>Customer Name</SCRTEXT_M>
    <SCRTEXT_L>Customer Name</SCRTEXT_L>
    <DTELMASTER>E</DTELMASTER>
    <DATATYPE>CHAR</DATATYPE>
    <LENG>000040</LENG>
    <OUTPUTLEN>000040</OUTPUTLEN>
   </DD04V>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Data element referencing a domain

#### `src/zfoo_flight_status.dtel.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DTEL" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD04V>
    <ROLLNAME>ZFOO_FLIGHT_STATUS</ROLLNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <DOMNAME>ZFOO_STATUS</DOMNAME>
    <HEADLEN>20</HEADLEN>
    <SCRLEN1>10</SCRLEN1>
    <SCRLEN2>15</SCRLEN2>
    <SCRLEN3>20</SCRLEN3>
    <DDTEXT>Flight Status</DDTEXT>
    <REPTEXT>Flight Status</REPTEXT>
    <SCRTEXT_S>Status</SCRTEXT_S>
    <SCRTEXT_M>Flight Status</SCRTEXT_M>
    <SCRTEXT_L>Flight Status</SCRTEXT_L>
    <DTELMASTER>E</DTELMASTER>
   </DD04V>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `ROLLNAME` | Data element name (uppercase, max 30 chars) |
| `DDLANGUAGE` | Original language (`E` = English) |
| `DOMNAME` | Referenced domain (omit if using direct type) |
| `DATATYPE` | Direct ABAP type (omit if using `DOMNAME`) |
| `LENG` | Length (omit if using `DOMNAME`) |
| `OUTPUTLEN` | Output length (omit if using `DOMNAME`) |
| `HEADLEN` | Max heading length |
| `SCRLEN1/2/3` | Max label lengths (short/medium/long) |
| `DDTEXT` | Description |
| `REPTEXT` | Column header text |
| `SCRTEXT_S/M/L` | Field labels (short/medium/long) |
| `DTELMASTER` | Master language |

## Creation workflow
1. Take the data element name and target package path from the user/request.
2. Create `<name>.dtel.xml` in the appropriate `src/` subfolder.
3. Set `ROLLNAME` to the uppercase object name.
4. Either reference a `DOMNAME` or specify `DATATYPE` + `LENG` + `OUTPUTLEN` directly.
5. Provide all text fields (`DDTEXT`, `REPTEXT`, `SCRTEXT_S/M/L`).

## Done-check
- Serializer is exactly `LCL_OBJECT_DTEL`.
- `ROLLNAME` in XML matches the filename (uppercase vs lowercase).
- Either `DOMNAME` or `DATATYPE`+`LENG` is provided (not both).
- All label texts are filled.
- No SAP-system-only creation step is required.
