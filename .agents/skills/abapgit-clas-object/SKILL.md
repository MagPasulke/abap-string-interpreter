---
name: abapgit-clas-object
description: Create an abapGit CLAS object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit CLAS object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/CLAS_full)

## Goal
Create a `CLAS` (Class) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<class_name>.clas.<part>` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A CLAS object consists of multiple files. Only `.clas.abap` and `.clas.xml` are mandatory:
- `<name>.clas.abap` — main class source (DEFINITION + IMPLEMENTATION)
- `<name>.clas.xml` — class metadata
- `<name>.clas.locals_def.abap` — optional: local type definitions
- `<name>.clas.locals_imp.abap` — optional: local class implementations
- `<name>.clas.testclasses.abap` — optional: ABAP Unit test classes
- `<name>.clas.macros.abap` — optional: macro definitions

Optional files are only created when content exists.

## Complete sample

### Sample A — Simple class (minimal)

#### `src/zcl_foo_calculator.clas.abap`

```abap
CLASS zcl_foo_calculator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS add
      IMPORTING
        a TYPE i
        b TYPE i
      RETURNING
        VALUE(result) TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_foo_calculator IMPLEMENTATION.

  METHOD add.
    result = a + b.
  ENDMETHOD.

ENDCLASS.
```

#### `src/zcl_foo_calculator.clas.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>ZCL_FOO_CALCULATOR</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>Simple Calculator</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
   </VSEOCLASS>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Class with test classes and local types

#### `src/zcl_foo_processor.clas.abap`

```abap
CLASS zcl_foo_processor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS process
      IMPORTING
        input TYPE string
      RETURNING
        VALUE(output) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_foo_processor IMPLEMENTATION.

  METHOD process.
    output = to_upper( input ).
  ENDMETHOD.

ENDCLASS.
```

#### `src/zcl_foo_processor.clas.testclasses.abap`

```abap
CLASS ltcl_processor DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_process FOR TESTING.
ENDCLASS.

CLASS ltcl_processor IMPLEMENTATION.
  METHOD test_process.
    DATA(cut) = NEW zcl_foo_processor( ).
    cl_abap_unit_assert=>assert_equals(
      act = cut->process( 'hello' )
      exp = 'HELLO' ).
  ENDMETHOD.
ENDCLASS.
```

#### `src/zcl_foo_processor.clas.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>ZCL_FOO_PROCESSOR</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>Text Processor</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
    <WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>
   </VSEOCLASS>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample C — Exception class

#### `src/zcx_foo_error.clas.abap`

```abap
CLASS zcx_foo_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF general_error,
        msgid TYPE symsgid VALUE 'ZFOO_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF general_error.

    METHODS constructor
      IMPORTING
        textid   LIKE if_t100_message=>t100key OPTIONAL
        previous LIKE previous OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_foo_error IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
```

#### `src/zcx_foo_error.clas.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>ZCX_FOO_ERROR</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>Custom Error Exception</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
    <CATEGORY>40</CATEGORY>
   </VSEOCLASS>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `CLSNAME` | Class name (uppercase, max 30 chars) |
| `LANGU` | Original language (`E` = English) |
| `DESCRIPT` | Short description |
| `STATE` | `1` = active |
| `CLSCCINCL` | `X` = class has local classes include |
| `FIXPT` | `X` = fixed-point arithmetic |
| `UNICODE` | `X` = Unicode checks active |
| `WITH_UNIT_TESTS` | `X` = class has unit tests (add when `.testclasses.abap` exists) |
| `CATEGORY` | Exception category: `40` = cx_static_check, `30` = cx_dynamic_check, `10` = cx_no_check |

## Creation workflow
1. Take the class name and target package path from the user/request.
2. Create `<name>.clas.abap` with DEFINITION and IMPLEMENTATION sections.
3. Create `<name>.clas.xml` with VSEOCLASS metadata.
4. Create optional companion files (`.locals_def.abap`, `.locals_imp.abap`, `.testclasses.abap`) only when needed.
5. Set `WITH_UNIT_TESTS` to `X` when test classes are present.

## Done-check
- Serializer is exactly `LCL_OBJECT_CLAS`.
- `CLSNAME` in XML matches the filename (uppercase vs lowercase).
- `.clas.abap` contains both `DEFINITION` and `IMPLEMENTATION` blocks.
- Optional companion files are only created when they have content.
- `WITH_UNIT_TESTS` matches presence of `.testclasses.abap`.
- No SAP-system-only creation step is required.
