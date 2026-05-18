---
name: abapgit-tobj-object
description: Create an abapGit TOBJ object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit TOBJ object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html)

## Goal
Create a `TOBJ` (Table Maintenance Object / View Maintenance Dialog) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.tobj.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_TOBJ" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.
- The TOBJ name is typically the table name with an `S` suffix in `OBJECTTYPE`.

## File structure
A TOBJ object consists of a single file:
- `<name>.tobj.xml` — table maintenance object metadata

## Complete sample

#### `src/zfoo_config.tobj.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_TOBJ" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <OBJH>
    <OBJECTNAME>ZFOO_CONFIG</OBJECTNAME>
    <OBJECTTYPE>S</OBJECTTYPE>
    <CLIDEP>X</CLIDEP>
    <OBJCATEG>CUST</OBJCATEG>
    <OBJTRANSP>2</OBJTRANSP>
    <IMPORTABLE>3</IMPORTABLE>
   </OBJH>
   <OBJT>
    <LANGUAGE>E</LANGUAGE>
    <OBJECTNAME>ZFOO_CONFIG</OBJECTNAME>
    <OBJECTTYPE>S</OBJECTTYPE>
    <DDTEXT>Flight Management - Configuration</DDTEXT>
   </OBJT>
   <OBJS>
    <OBJS>
     <OBJECTNAME>ZFOO_CONFIG</OBJECTNAME>
     <OBJECTTYPE>S</OBJECTTYPE>
     <TABNAME>ZFOO_CONFIG</TABNAME>
     <DDIC>X</DDIC>
     <PRIM_TABLE>X</PRIM_TABLE>
    </OBJS>
   </OBJS>
   <TOBJ>
    <TDDAT>
     <TABNAME>ZFOO_CONFIG</TABNAME>
     <CCLASS>ZACO</CCLASS>
    </TDDAT>
    <TVDIR>
     <TABNAME>ZFOO_CONFIG</TABNAME>
     <AREA>ZFOO_CONF_MAINT</AREA>
     <TYPE>1</TYPE>
     <LISTE>0001</LISTE>
     <BASTAB>X</BASTAB>
    </TVDIR>
   </TOBJ>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `OBJH > OBJECTNAME` | Table/view name (uppercase) |
| `OBJH > OBJECTTYPE` | `S` = single table, `V` = view |
| `OBJH > CLIDEP` | `X` = client-dependent |
| `OBJH > OBJCATEG` | `CUST` = customizing, `APPL` = application data |
| `OBJH > OBJTRANSP` | `2` = transported via customizing request |
| `OBJT > DDTEXT` | Description text |
| `OBJS > TABNAME` | Database table name |
| `OBJS > PRIM_TABLE` | `X` = primary table in the maintenance view |
| `TOBJ > TDDAT > CCLASS` | Customizing class |
| `TOBJ > TVDIR > AREA` | Function group for the maintenance dialog (FUGR) |
| `TOBJ > TVDIR > TYPE` | `1` = one-step dialog |
| `TOBJ > TVDIR > LISTE` | Screen number for overview (`0001`) |

## Creation workflow
1. Take the table name and target package path from the user/request.
2. Create `<name>.tobj.xml` in the appropriate `src/` subfolder.
3. Set `OBJECTNAME` and `TABNAME` to the target table.
4. Set `AREA` to the function group that hosts the maintenance dialog.
5. A TOBJ is typically created together with a FUGR (maintenance function group).

## Done-check
- Serializer is exactly `LCL_OBJECT_TOBJ`.
- `OBJECTNAME` in XML matches the filename (uppercase vs lowercase).
- `AREA` references an existing FUGR function group.
- `TABNAME` references an existing TABL table.
- No SAP-system-only creation step is required.
