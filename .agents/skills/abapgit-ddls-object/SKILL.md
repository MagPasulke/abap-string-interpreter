---
name: abapgit-ddls-object
description: Create an abapGit DDLS object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit DDLS object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/DDLS)

## Goal
Create a `DDLS` (Data Definition Language Source / CDS View) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.ddls.<extension>` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_DDLS" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A DDLS object consists of up to three files:
- `<name>.ddls.asddls` — CDS source code
- `<name>.ddls.xml` — metadata
- `<name>.ddls.baseinfo` — optional: dependency information (JSON)

## Complete sample

### Sample A — Basic CDS view entity

#### `src/zfoo_i_flight.ddls.asddls`

```text
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Master Data'
define view entity ZFOO_I_FLIGHT
  as select from zfoo_flight
{
  key flight_id    as FlightId,
      carrier      as Carrier,
      connection   as Connection,
      flight_date  as FlightDate
}
```

#### `src/zfoo_i_flight.ddls.baseinfo`

```json
{
  "BASEINFO": {
    "FROM": [
      "ZFOO_FLIGHT"
    ],
    "ASSOCIATED": [],
    "BASE": []
  }
}
```

#### `src/zfoo_i_flight.ddls.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DDLS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DDLS>
    <DDLNAME>ZFOO_I_FLIGHT</DDLNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <DDTEXT>Flight Master Data</DDTEXT>
    <SOURCE_TYPE>V</SOURCE_TYPE>
   </DDLS>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Abstract entity (e.g. action input parameter)

#### `src/zfoo_a_discount.ddls.asddls`

```text
@EndUserText.label: 'Discount Input Parameter'
define abstract entity ZFOO_A_DISCOUNT
{
  discount_percent : abap.int1;
}
```

#### `src/zfoo_a_discount.ddls.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DDLS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DDLS>
    <DDLNAME>ZFOO_A_DISCOUNT</DDLNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <DDTEXT>Discount Input Parameter</DDTEXT>
    <SOURCE_TYPE>A</SOURCE_TYPE>
   </DDLS>
  </asx:values>
 </asx:abap>
</abapGit>
```

> **Note:** Abstract entities do not have a `.baseinfo` file since they have no data source.

### Sample C — Consumption projection view

#### `src/zfoo_c_flight.ddls.asddls`

```text
@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'Flight - Consumption View'
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZFOO_C_FLIGHT
  provider contract transactional_query
  as projection on ZFOO_I_FLIGHT
{
  key FlightId,
      @Search.defaultSearchElement: true
      Carrier,
      Connection,
      FlightDate
}
```

#### `src/zfoo_c_flight.ddls.baseinfo`

```json
{
  "BASEINFO": {
    "FROM": [
      "ZFOO_I_FLIGHT"
    ],
    "ASSOCIATED": [],
    "BASE": [
      "ZFOO_I_FLIGHT"
    ]
  }
}
```

#### `src/zfoo_c_flight.ddls.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DDLS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DDLS>
    <DDLNAME>ZFOO_C_FLIGHT</DDLNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <DDTEXT>Flight - Consumption View</DDTEXT>
    <SOURCE_TYPE>P</SOURCE_TYPE>
   </DDLS>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `DDLNAME` | CDS view name (uppercase, max 30 chars) |
| `DDLANGUAGE` | Original language (`E` = English) |
| `DDTEXT` | Short description |
| `SOURCE_TYPE` | `V` = view/view entity, `P` = projection view, `E` = extend view, `F` = custom entity, `A` = abstract entity, `W` = view entity (legacy, avoid — use `V`) |

## Key baseinfo fields
| Field | Description |
|-------|-------------|
| `FROM` | Data sources used in `select from` |
| `ASSOCIATED` | Targets of associations |
| `BASE` | Base view for projections |

## Creation workflow
1. Take the CDS view name and target package path from the user/request.
2. Create `<name>.ddls.asddls` with the CDS source.
3. Create `<name>.ddls.xml` with DDLS metadata.
4. Optionally create `<name>.ddls.baseinfo` with dependency information.
5. Set `SOURCE_TYPE` according to the view type.

## Done-check
- Serializer is exactly `LCL_OBJECT_DDLS`.
- `DDLNAME` in XML matches the filename (uppercase vs lowercase).
- The `.asddls` file contains valid CDS syntax.
- `SOURCE_TYPE` matches the CDS view type.
- `.baseinfo` lists all referenced entities correctly.
- No SAP-system-only creation step is required.
