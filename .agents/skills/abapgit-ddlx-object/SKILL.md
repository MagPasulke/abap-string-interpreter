---
name: abapgit-ddlx-object
description: Create an abapGit DDLX object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit DDLX object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/DDLX)

## Goal
Create a `DDLX` (CDS Metadata Extension) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.ddlx.<extension>` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_DDLX" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A DDLX object consists of two files:
- `<name>.ddlx.asddlxs` — CDS metadata extension source
- `<name>.ddlx.xml` — metadata

## Complete sample

#### `src/zfoo_c_flight.ddlx.asddlxs`

```text
@Metadata.layer: #CUSTOMER

@UI.headerInfo: {
  typeName: 'Flight',
  typeNamePlural: 'Flights',
  description.value: 'FlightId'
}
annotate entity ZFOO_C_FLIGHT with
{
  @UI.facet: [{
    id: 'FlightDetails',
    purpose: #STANDARD,
    type: #IDENTIFICATION_REFERENCE,
    label: 'Flight Details',
    position: 10
  }]

  @UI.hidden: true
  FlightId;

  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem: [{ position: 10 }]
  @UI.identification: [{ position: 10 }]
  Carrier;

  @UI.lineItem: [{ position: 20 }]
  @UI.identification: [{ position: 20 }]
  Connection;

  @UI.lineItem: [{ position: 30 }]
  @UI.identification: [{ position: 30 }]
  FlightDate;
}
```

#### `src/zfoo_c_flight.ddlx.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DDLX" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DDLX>
    <METADATA>
     <NAME>ZFOO_C_FLIGHT</NAME>
     <DESCRIPTION>ZFOO_C_FLIGHT - Metadata Extension</DESCRIPTION>
     <MASTER_LANGUAGE>EN</MASTER_LANGUAGE>
    </METADATA>
   </DDLX>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `NAME` | Metadata extension name (uppercase, matches annotated CDS view) |
| `DESCRIPTION` | Short description |
| `MASTER_LANGUAGE` | `EN` = English |

## Common UI annotations
| Annotation | Purpose |
|-----------|---------|
| `@Metadata.layer` | `#CUSTOMER`, `#PARTNER`, `#INDUSTRY`, `#CORE` |
| `@UI.headerInfo` | List report / object page header |
| `@UI.facet` | Object page facets (sections) |
| `@UI.lineItem` | Columns in list report |
| `@UI.selectionField` | Filter bar fields |
| `@UI.identification` | Fields on object page |
| `@UI.hidden` | Hide technical fields |

## Creation workflow
1. Take the metadata extension name and target package path from the user/request.
2. Create `<name>.ddlx.asddlxs` with the `annotate entity` source.
3. Create `<name>.ddlx.xml` with DDLX metadata.
4. The `NAME` typically matches the CDS consumption view being annotated.

## Done-check
- Serializer is exactly `LCL_OBJECT_DDLX`.
- `NAME` in XML matches the filename (uppercase vs lowercase).
- `.asddlxs` file uses `annotate entity <CDS_VIEW> with` syntax.
- `@Metadata.layer` is set.
- No SAP-system-only creation step is required.
