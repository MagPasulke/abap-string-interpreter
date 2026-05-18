---
name: abapgit-fugr-object
description: Create an abapGit FUGR object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit FUGR object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/FUGR)

## Goal
Create a `FUGR` (Function Group) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<fugr_name>.fugr.<companion>` — all **lowercase**.
- The main XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_FUGR" serializer_version="v1.0.0">
  ```
- Companion files (includes, function modules) use a nested serializer **without** the `serializer` attribute:
  ```xml
  <abapGit version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.
- Include naming follows SAP conventions: `L<fugr>TOP`, `L<fugr>F00`, `L<fugr>I00`, `SAPL<fugr>`.

## File structure
A FUGR object consists of multiple companion files. The minimum set:

| File | Purpose |
|------|---------|
| `<fugr>.fugr.xml` | Main metadata: includes list, function definitions, dynpros |
| `<fugr>.fugr.sapl<fugr>.abap` | Main program source (system includes) |
| `<fugr>.fugr.sapl<fugr>.xml` | Main program PROGDIR metadata |
| `<fugr>.fugr.l<fugr>top.abap` | TOP include (global declarations) |
| `<fugr>.fugr.l<fugr>top.xml` | TOP include PROGDIR metadata |
| `<fugr>.fugr.l<fugr>f00.abap` | FORM routines include (optional) |
| `<fugr>.fugr.l<fugr>f00.xml` | FORM routines PROGDIR metadata |
| `<fugr>.fugr.l<fugr>i00.abap` | PAI modules include (optional) |
| `<fugr>.fugr.l<fugr>i00.xml` | PAI modules PROGDIR metadata |
| `<fugr>.fugr.<funcname>.abap` | Each function module source (named by FM, not include) |

For **table maintenance** function groups, additional files:
| `<fugr>.fugr.l<fugr>t00.abap` | Table data declarations |
| `<fugr>.fugr.l<fugr>t00.xml` | Table data PROGDIR |
| `<fugr>.fugr.screen_<nnnn>.abap` | Dynpro flow logic |
| `<fugr>.fugr.tableframe_<fugr>.abap` | TABLEFRAME function module |
| `<fugr>.fugr.tableproc_<fugr>.abap` | TABLEPROC function module |

## Complete sample — Simple function group with one function module

### `src/zfoo_utils.fugr.lzfoo_utilstop.abap`

```abap
FUNCTION-POOL ZFOO_UTILS.

DATA: gv_initialized TYPE abap_bool.
```

### `src/zfoo_utils.fugr.lzfoo_utilstop.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <PROGDIR>
    <NAME>LZFOO_UTILSTOP</NAME>
    <DBAPL>S</DBAPL>
    <DBNA>D$</DBNA>
    <SUBC>I</SUBC>
    <APPL>S</APPL>
    <FIXPT>X</FIXPT>
    <LDBNAME>D$S</LDBNAME>
    <UCCHECK>X</UCCHECK>
   </PROGDIR>
  </asx:values>
 </asx:abap>
</abapGit>
```

### `src/zfoo_utils.fugr.saplzfoo_utils.abap`

```abap
*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE LZFOO_UTILSTOP.              " Global Declarations
  INCLUDE LZFOO_UTILSUXX.              " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE LZFOO_UTILSF...              " Subroutines
* INCLUDE LZFOO_UTILSO...              " PBO-Modules
* INCLUDE LZFOO_UTILSI...              " PAI-Modules
* INCLUDE LZFOO_UTILSE...              " Events
* INCLUDE LZFOO_UTILSP...              " Local class implement.
* INCLUDE LZFOO_UTILST99.              " ABAP Unit tests
```

### `src/zfoo_utils.fugr.saplzfoo_utils.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <PROGDIR>
    <NAME>SAPLZFOO_UTILS</NAME>
    <DBAPL>S</DBAPL>
    <DBNA>D$</DBNA>
    <SUBC>F</SUBC>
    <APPL>S</APPL>
    <RLOAD>E</RLOAD>
    <FIXPT>X</FIXPT>
    <LDBNAME>D$S</LDBNAME>
    <UCCHECK>X</UCCHECK>
   </PROGDIR>
  </asx:values>
 </asx:abap>
</abapGit>
```

### `src/zfoo_utils.fugr.zfoo_fm_get_status.abap`

```abap
FUNCTION ZFOO_FM_GET_STATUS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_ID) TYPE  SYSUUID_X16
*"  EXPORTING
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  SELECT SINGLE status FROM zfoo_header
    WHERE uuid = @iv_id
    INTO @ev_status.

  IF sy-subrc <> 0.
    RAISE not_found.
  ENDIF.

ENDFUNCTION.
```

### `src/zfoo_utils.fugr.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_FUGR" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <INCLUDES>
    <SOBJ_NAME>LZFOO_UTILSTOP</SOBJ_NAME>
    <SOBJ_NAME>SAPLZFOO_UTILS</SOBJ_NAME>
   </INCLUDES>
   <FUNCTIONS>
    <item>
     <FUNCNAME>ZFOO_FM_GET_STATUS</FUNCNAME>
     <IMPORT>
      <RSIMP>
       <PARAMETER>IV_ID</PARAMETER>
       <REFERENCE>X</REFERENCE>
       <TYP>SYSUUID_X16</TYP>
      </RSIMP>
     </IMPORT>
     <EXPORT>
      <RSEXP>
       <PARAMETER>EV_STATUS</PARAMETER>
       <REFERENCE>X</REFERENCE>
       <TYP>CHAR1</TYP>
      </RSEXP>
     </EXPORT>
     <EXCEPTION>
      <RSEXC>
       <EXCEPTION>NOT_FOUND</EXCEPTION>
      </RSEXC>
     </EXCEPTION>
     <DOCUMENTATION>
      <RSFDO>
       <PARAMETER>IV_ID</PARAMETER>
       <KIND>P</KIND>
      </RSFDO>
      <RSFDO>
       <PARAMETER>EV_STATUS</PARAMETER>
       <KIND>P</KIND>
      </RSFDO>
      <RSFDO>
       <PARAMETER>NOT_FOUND</PARAMETER>
       <KIND>X</KIND>
      </RSFDO>
     </DOCUMENTATION>
    </item>
   </FUNCTIONS>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements (main `.fugr.xml`)
| Element | Description |
|---------|-------------|
| `INCLUDES > SOBJ_NAME` | List of include program names (TOP, main program, etc.) |
| `FUNCTIONS > item > FUNCNAME` | Function module name (uppercase) |
| `IMPORT > RSIMP` | Import parameters |
| `EXPORT > RSEXP` | Export parameters |
| `TABLES > RSTBL` | Table parameters |
| `EXCEPTION > RSEXC` | Exceptions |
| `DOCUMENTATION > RSFDO` | Parameter documentation (`KIND`: `P`=parameter, `X`=exception) |

## Key XML elements (companion `.xml` — PROGDIR)
| Element | Description |
|---------|-------------|
| `NAME` | Include/program name (uppercase) |
| `SUBC` | Program type: `F` = function pool main, `I` = include |
| `FIXPT` | `X` = fixed-point arithmetic |
| `UCCHECK` | `X` = Unicode checks active |

## Include naming conventions
For function group `ZFOO_UTILS`:
- TOP include: `LZFOO_UTILSTOP`
- UXX include (auto-generated): `LZFOO_UTILSUXX`
- FORM routines: `LZFOO_UTILSF00`, `LZFOO_UTILSF01`, ...
- PAI modules: `LZFOO_UTILSI00`, ...
- PBO modules: `LZFOO_UTILSO00`, ...
- Table data: `LZFOO_UTILST00`, ...
- Main program: `SAPLZFOO_UTILS`

Pattern: `L<FUGR_NAME><SUFFIX>` where suffix is `TOP`, `F00`, `I00`, `T00`, `UXX`.

## Creation workflow
1. Take the function group name and target package path from the user/request.
2. Create the TOP include (`l<fugr>top.abap` + `.xml`) with `FUNCTION-POOL` declaration.
3. Create the main program (`sapl<fugr>.abap` + `.xml`) with system and user includes.
4. For each function module, create `<fugr>.fugr.<funcname>.abap`.
5. Create the main `<fugr>.fugr.xml` listing all includes and function module definitions.
6. For table maintenance groups, additionally create screen, tableframe, and tableproc files.

## Done-check
- Serializer is exactly `LCL_OBJECT_FUGR` (main XML only).
- Companion XMLs use `<abapGit version="v1.0.0">` without serializer attribute.
- All includes listed in `INCLUDES` have corresponding `.abap` + `.xml` companion files.
- All function modules listed in `FUNCTIONS` have corresponding `.abap` companion files.
- Include names follow the `L<FUGR>*` / `SAPL<FUGR>` conventions.
- No SAP-system-only creation step is required.
