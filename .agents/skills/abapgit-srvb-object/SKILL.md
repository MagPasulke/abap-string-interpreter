---
name: abapgit-srvb-object
description: Create an abapGit SRVB object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit SRVB object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create a `SRVB` (Service Binding) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.srvb.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_SRVB" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A SRVB object consists of a single file:
- `<name>.srvb.xml` — service binding metadata

## Complete sample

#### `src/zfoo_ui_flight_o4.srvb.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_SRVB" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <SRVB>
    <METADATA>
     <NAME>ZFOO_UI_FLIGHT_O4</NAME>
     <TYPE>SRVB/SVB</TYPE>
     <DESCRIPTION>Flight Management - OData V4 UI Service</DESCRIPTION>
    </METADATA>
    <CONTENT>
     <BIND_TYPE_IMPL>
      <NAME>ZFOO_UI_FLIGHT_O4</NAME>
     </BIND_TYPE_IMPL>
     <BIND_TYPE>ODATA</BIND_TYPE>
     <BIND_TYPE_VERSION>V4</BIND_TYPE_VERSION>
     <SERVICES>
      <item>
       <SERVICE_NAME>ZFOO_UI_FLIGHT</SERVICE_NAME>
       <SERVICE_CONTENT>
        <item>
         <SERVICE_VERSION>0001</SERVICE_VERSION>
         <RELEASE_STATE>NOT_RELEASED</RELEASE_STATE>
         <SRVD_REF>
          <URI>/sap/bc/adt/ddic/srvd/sources/zfoo_ui_flight</URI>
          <TYPE>SRVD/SRV</TYPE>
          <NAME>ZFOO_UI_FLIGHT</NAME>
         </SRVD_REF>
         <BIND_TYPE_DATA>
          <CONTENT>
           <ENCODING>base64</ENCODING>
          </CONTENT>
         </BIND_TYPE_DATA>
        </item>
       </SERVICE_CONTENT>
      </item>
     </SERVICES>
    </CONTENT>
    <CONTRACT>C1</CONTRACT>
    <RELEASE_SUPPORTED>true</RELEASE_SUPPORTED>
    <PUBLISHED>true</PUBLISHED>
    <BINDING_CREATED>true</BINDING_CREATED>
   </SRVB>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `NAME` | Service binding name (uppercase) |
| `TYPE` | Always `SRVB/SVB` |
| `DESCRIPTION` | Short description |
| `BIND_TYPE` | `ODATA` |
| `BIND_TYPE_VERSION` | `V2` or `V4` |
| `SERVICE_NAME` | Referenced service definition name |
| `SRVD_REF > NAME` | Service definition name (uppercase) |
| `SRVD_REF > URI` | `/sap/bc/adt/ddic/srvd/sources/<lowercase_srvd_name>` |
| `CONTRACT` | `C1` = SAP standard contract |
| `PUBLISHED` | `true` = service is published |

## Naming convention
Service bindings typically follow: `<srvd_name>_O2` (OData V2) or `<srvd_name>_O4` (OData V4).

## Creation workflow
1. Take the service binding name and target package path from the user/request.
2. Create `<name>.srvb.xml` with the full binding metadata.
3. Set `BIND_TYPE_VERSION` to `V2` or `V4`.
4. Reference the correct service definition in `SRVD_REF`.
5. Set `SRVD_REF > URI` using the lowercase service definition name.

## Done-check
- Serializer is exactly `LCL_OBJECT_SRVB`.
- `NAME` in XML matches the filename (uppercase vs lowercase).
- `SRVD_REF` correctly references an existing service definition.
- `BIND_TYPE_VERSION` is valid (`V2` or `V4`).
- No SAP-system-only creation step is required.
