---
name: abapgit-bdef-object
description: Create an abapGit BDEF object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit BDEF object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create a `BDEF` (Behavior Definition) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.bdef.<extension>` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_BDEF" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A BDEF object consists of two files:
- `<name>.bdef.asbdef` — behavior definition source
- `<name>.bdef.xml` — metadata

## Complete sample

### Sample A — Interface behavior (managed, with draft)

#### `src/zfoo_i_flight.bdef.asbdef`

```text
managed implementation in class zbp_foo_i_flight unique;
strict ( 2 );
with draft;

define behavior for ZFOO_I_FLIGHT alias Flight
persistent table zfoo_flight
draft table zfoodr_flight
etag master LocalLastChangedAt
lock master total etag LastChangedAt
authorization master ( global )
{
  field ( readonly )
    FlightUUID;

  field ( numbering : managed )
    FlightUUID;

  create;
  update;
  delete;

  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;

  mapping for zfoo_flight
  {
    FlightUUID = flight_uuid;
    FlightId = flight_id;
    Carrier = carrier;
    LastChangedAt = last_changed_at;
    LocalLastChangedAt = local_last_changed_at;
  }
}
```

#### `src/zfoo_i_flight.bdef.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_BDEF" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <BDEF>
    <NAME>ZFOO_I_FLIGHT</NAME>
    <TYPE>BDEF/BDO</TYPE>
    <DESCRIPTION>Flight Booking - BO Behavior</DESCRIPTION>
    <DESCRIPTION_TEXT_LIMIT>60</DESCRIPTION_TEXT_LIMIT>
    <LANGUAGE>EN</LANGUAGE>
    <MASTER_LANGUAGE>EN</MASTER_LANGUAGE>
    <ABAP_LANGU_VERSION>5</ABAP_LANGU_VERSION>
    <SOURCE_URI>./zfoo_i_flight/source/main</SOURCE_URI>
    <SOURCE_TYPE>ABAP_SOURCE</SOURCE_TYPE>
    <SOURCE_FIXED_POINT_ARITHMETIC>true</SOURCE_FIXED_POINT_ARITHMETIC>
    <SOURCE_UNICODE_CHECKS_ACTIVE>true</SOURCE_UNICODE_CHECKS_ACTIVE>
   </BDEF>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Projection behavior

#### `src/zfoo_c_flight.bdef.asbdef`

```text
projection;
strict ( 2 );
use draft;

define behavior for ZFOO_C_FLIGHT alias Flight
{
  use create;
  use update;
  use delete;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;
}
```

#### `src/zfoo_c_flight.bdef.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_BDEF" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <BDEF>
    <NAME>ZFOO_C_FLIGHT</NAME>
    <TYPE>BDEF/BDO</TYPE>
    <DESCRIPTION>Flight Booking - Projection Behavior</DESCRIPTION>
    <DESCRIPTION_TEXT_LIMIT>60</DESCRIPTION_TEXT_LIMIT>
    <LANGUAGE>EN</LANGUAGE>
    <MASTER_LANGUAGE>EN</MASTER_LANGUAGE>
    <ABAP_LANGU_VERSION>5</ABAP_LANGU_VERSION>
    <SOURCE_URI>./zfoo_c_flight/source/main</SOURCE_URI>
    <SOURCE_TYPE>ABAP_SOURCE</SOURCE_TYPE>
    <SOURCE_FIXED_POINT_ARITHMETIC>true</SOURCE_FIXED_POINT_ARITHMETIC>
    <SOURCE_UNICODE_CHECKS_ACTIVE>true</SOURCE_UNICODE_CHECKS_ACTIVE>
   </BDEF>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `NAME` | Behavior definition name (uppercase, matches CDS root view) |
| `TYPE` | Always `BDEF/BDO` |
| `DESCRIPTION` | Short description (max 60 chars) |
| `LANGUAGE` / `MASTER_LANGUAGE` | `EN` = English |
| `ABAP_LANGU_VERSION` | `5` = ABAP for Cloud Development |
| `SOURCE_URI` | `./<lowercase_name>/source/main` |

## Creation workflow
1. Take the behavior name and target package path from the user/request.
2. Create `<name>.bdef.asbdef` with the behavior definition source.
3. Create `<name>.bdef.xml` with BDEF metadata.
4. Set `SOURCE_URI` to `./<lowercase_name>/source/main`.
5. Interface behaviors use `managed`/`unmanaged` implementation; projections use `projection`.

## Done-check
- Serializer is exactly `LCL_OBJECT_BDEF`.
- `NAME` in XML matches the filename (uppercase vs lowercase).
- `SOURCE_URI` follows the `./<name>/source/main` pattern.
- `.asbdef` source is syntactically valid RAP behavior definition.
- No SAP-system-only creation step is required.
