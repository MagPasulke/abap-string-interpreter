---
name: abapgit-iwmo-object
description: Create an abapGit IWMO object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit IWMO object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create an `IWMO` (Gateway OData Model) object directly as abapGit-serialized repository files, outside an SAP system. IWMO represents the OData V2 model metadata registered in the SAP Gateway catalog.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames use a **fixed-width padded format**: `<technical_name><padded_spaces><version>.iwmo.xml` — all **lowercase**.
- The technical name is left-aligned and space-padded to a fixed width, followed by the 4-digit version number.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_IWMO" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.
- The filename combines `TECHNICAL_NAME` + spaces + `VERSION` to fill a fixed-width field.

## File structure
An IWMO object consists of a single file:
- `<padded_name_and_version>.iwmo.xml` — OData model metadata

## Complete sample

Filename: `zfoo_ui_flight_o2             0001.iwmo.xml` (name padded with spaces to fixed width)

#### `src/zfoo_ui_flight_o2             0001.iwmo.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_IWMO" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <_-IWBEP_-I_MGW_OHD>
    <_-IWBEP_-I_MGW_OHD>
     <TECHNICAL_NAME>ZFOO_UI_FLIGHT_O2</TECHNICAL_NAME>
     <VERSION>0001</VERSION>
     <CLASS_NAME>CL_SADL_GW_RAP_EXPOSURE_MPC</CLASS_NAME>
     <ABAP_LANGUAGE_VERSION>5</ABAP_LANGUAGE_VERSION>
    </_-IWBEP_-I_MGW_OHD>
   </_-IWBEP_-I_MGW_OHD>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `TECHNICAL_NAME` | OData model technical name (uppercase) |
| `VERSION` | 4-digit version number (`0001`) |
| `CLASS_NAME` | MPC (Model Provider Class), e.g. `CL_SADL_GW_RAP_EXPOSURE_MPC` for RAP-based |
| `ABAP_LANGUAGE_VERSION` | `5` = ABAP for Cloud Development |

## Filename padding convention
- The IWMO object key is composed of `TECHNICAL_NAME` (up to 30 chars) + `VERSION` (4 chars).
- In the filename, the key is written as a single fixed-width field: the technical name followed by enough spaces to fill 30 characters, then the version number.
- Example: `zfoo_ui_flight_o2` (17 chars) + 13 spaces + `0001` = 34-char field before `.iwmo.xml`.

## Notes
- IWMO is the **OData V2** model counterpart. For OData V4, use G4BA instead.
- IWMO XML tags use IWBEP namespace: `_-IWBEP_-I_MGW_OHD`.
- For RAP-based services, `CLASS_NAME` is `CL_SADL_GW_RAP_EXPOSURE_MPC`.

## Creation workflow
1. Take the model name and target package path from the user/request.
2. Create the IWMO file with the padded filename convention.
3. Set `TECHNICAL_NAME` to the uppercase model name.
4. Set `VERSION` to `0001` for new models.
5. Set `CLASS_NAME` to the appropriate MPC class.

## Done-check
- Serializer is exactly `LCL_OBJECT_IWMO`.
- Filename uses the padded fixed-width convention.
- `TECHNICAL_NAME` + `VERSION` match the filename content.
- IWBEP namespace XML tags use the `_-IWBEP_-` escaped format.
- No SAP-system-only creation step is required.
