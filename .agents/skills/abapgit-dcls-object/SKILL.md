---
name: abapgit-dcls-object
description: Create an abapGit DCLS object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit DCLS object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/DCLS)

## Goal
Create a `DCLS` (CDS Access Control) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.dcls.<extension>` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_DCLS" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A DCLS object consists of two files:
- `<name>.dcls.asdcls` — access control source code
- `<name>.dcls.xml` — metadata

## Complete sample

### Sample A — Access control with own conditions

#### `src/zfoo_ac_flight.dcls.asdcls`

```text
@EndUserText.label: 'Access Control for Flight'
@MappingRole: true
define role ZFOO_AC_FLIGHT {
    grant
        select
            on
                ZFOO_I_FLIGHT
                    where
                        (CARRIER) = aspect pfcg_auth(ZFOO_AUTH, ZFOO_CARR, ACTVT='03');
}
```

#### `src/zfoo_ac_flight.dcls.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DCLS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DCLS>
    <DCLNAME>ZFOO_AC_FLIGHT</DCLNAME>
    <DCLLANGUAGE>E</DCLLANGUAGE>
    <DDTEXT>Access Control for Flight</DDTEXT>
   </DCLS>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Inherited access control (projection)

#### `src/zfoo_ac_c_flight.dcls.asdcls`

```text
@EndUserText.label: 'Access Control for Flight Projection'
@MappingRole: true
define role ZFOO_AC_C_FLIGHT {
    grant
        select
            on
                ZFOO_C_FLIGHT
                    where
                        inheriting conditions from entity ZFOO_I_FLIGHT;
}
```

#### `src/zfoo_ac_c_flight.dcls.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DCLS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DCLS>
    <DCLNAME>ZFOO_AC_C_FLIGHT</DCLNAME>
    <DCLLANGUAGE>E</DCLLANGUAGE>
    <DDTEXT>Access Control for Flight Projection</DDTEXT>
   </DCLS>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `DCLNAME` | Access control name (uppercase, max 30 chars) |
| `DCLLANGUAGE` | Original language (`E` = English) |
| `DDTEXT` | Short description |

## Creation workflow
1. Take the access control name and target package path from the user/request.
2. Create `<name>.dcls.asdcls` with the `define role` source.
3. Create `<name>.dcls.xml` with DCLS metadata.
4. Use `inheriting conditions from entity` for projection views.
5. Use `aspect pfcg_auth(...)` for direct authorization checks.

## Done-check
- Serializer is exactly `LCL_OBJECT_DCLS`.
- `DCLNAME` in XML matches the filename (uppercase vs lowercase).
- `.asdcls` file uses `define role ... { grant select on ... }` syntax.
- `@MappingRole: true` annotation is present.
- No SAP-system-only creation step is required.
