---
name: abapgit-msag-object
description: Create an abapGit MSAG object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit MSAG object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Test Repo](https://github.com/abapGit-tests/MSAG)

## Goal
Create a `MSAG` (Message Class) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Filenames: `<object_name>.msag.xml` — all **lowercase**.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_MSAG" serializer_version="v1.0.0">
  ```

## Naming rule
- Use the exact object names provided by the user/request.
- Do not use placeholder names for implementation.

## File structure
A MSAG object consists of a single file:
- `<name>.msag.xml` — message class with all messages

## Complete sample

#### `src/zfoo_messages.msag.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_MSAG" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <T100A>
    <ARBGB>ZFOO_MESSAGES</ARBGB>
    <MASTERLANG>E</MASTERLANG>
    <STEXT>Application Messages</STEXT>
   </T100A>
   <T100>
    <T100>
     <SPRSL>E</SPRSL>
     <ARBGB>ZFOO_MESSAGES</ARBGB>
     <MSGNR>001</MSGNR>
     <TEXT>Operation completed successfully</TEXT>
    </T100>
    <T100>
     <SPRSL>E</SPRSL>
     <ARBGB>ZFOO_MESSAGES</ARBGB>
     <MSGNR>002</MSGNR>
     <TEXT>Entry &amp;1 already exists</TEXT>
    </T100>
    <T100>
     <SPRSL>E</SPRSL>
     <ARBGB>ZFOO_MESSAGES</ARBGB>
     <MSGNR>003</MSGNR>
     <TEXT>Entry &amp;1 not found</TEXT>
    </T100>
    <T100>
     <SPRSL>E</SPRSL>
     <ARBGB>ZFOO_MESSAGES</ARBGB>
     <MSGNR>004</MSGNR>
     <TEXT>Invalid input: &amp;1 &amp;2</TEXT>
    </T100>
   </T100>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| **T100A** | Message class header |
| `ARBGB` | Message class ID (uppercase, max 20 chars) |
| `MASTERLANG` | Master language (`E` = English) |
| `STEXT` | Message class description |
| **T100** | Individual message entries |
| `SPRSL` | Language key (`E` = English) |
| `MSGNR` | Message number (3-digit, zero-padded: `001`–`999`) |
| `TEXT` | Message text. Use `&1`–`&4` for placeholders (XML-encoded as `&amp;1`) |

## Creation workflow
1. Take the message class name and target package path from the user/request.
2. Create `<name>.msag.xml` in the appropriate `src/` subfolder.
3. Set `ARBGB` in both `T100A` and all `T100` entries to the uppercase message class name.
4. Number messages sequentially starting at `001`.
5. Use `&amp;1` through `&amp;4` for message placeholders (XML encoding of `&1`).

## Done-check
- Serializer is exactly `LCL_OBJECT_MSAG`.
- `ARBGB` in XML matches the filename (uppercase vs lowercase).
- `ARBGB` is consistent across `T100A` and all `T100` entries.
- Message numbers are 3-digit zero-padded strings.
- Placeholders use `&amp;1` (XML-encoded ampersand).
- No SAP-system-only creation step is required.
