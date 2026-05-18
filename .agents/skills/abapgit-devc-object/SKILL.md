---
name: abapgit-devc-object
description: Create an abapGit DEVC object outside SAP systems using user-defined names and repository reference files.
---

# Create abapGit DEVC object

> **abapGit docs**: [Supported Object Types](https://docs.abapgit.org/user-guide/reference/supported.html) | [File Formats](https://docs.abapgit.org/development-guide/serializers/file-formats.html) | [Folders & Files](https://docs.abapgit.org/user-guide/reference/folders-filenames.html)

## Goal
Create a `DEVC` (Package) object directly as abapGit-serialized repository files, outside an SAP system.

## abapGit serialization rules
- Files are **UTF-8 with BOM**, **LF** line endings, **2-space** indentation.
- Package files always use the fixed filename: `package.devc.xml` — one per folder.
- abapGit does **not** store SAP package names in the repository. Folder names map to package names during import based on the [folder logic](https://docs.abapgit.org/user-guide/repo-settings/dot-abapgit.html#folder-logic) setting.
- The XML metadata file must start with:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <abapGit version="v1.0.0" serializer="LCL_OBJECT_DEVC" serializer_version="v1.0.0">
  ```

## Naming rule
- The filename is always `package.devc.xml` (not the SAP package name).
- Place it in the folder that represents the package.

## File structure
A DEVC object consists of a single file per package folder:
- `package.devc.xml` — package metadata

## Complete sample

### Sample A — Root package

#### `src/package.devc.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DEVC" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DEVC>
    <CTEXT>My Custom Application</CTEXT>
   </DEVC>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Sample B — Sub-package

#### `src/model/package.devc.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DEVC" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DEVC>
    <CTEXT>My Custom Application - Data Model</CTEXT>
   </DEVC>
  </asx:values>
 </asx:abap>
</abapGit>
```

## Key XML elements
| Element | Description |
|---------|-------------|
| `CTEXT` | Package description text |

## Creation workflow
1. Create the folder structure under `src/` matching the desired package hierarchy.
2. Place a `package.devc.xml` file in each folder.
3. Set `CTEXT` to a meaningful description of the package's purpose.
4. Sub-packages are represented as subdirectories, each with their own `package.devc.xml`.

## Done-check
- Serializer is exactly `LCL_OBJECT_DEVC`.
- Filename is `package.devc.xml` (never the SAP package name).
- Every folder under `src/` that should become a package has a `package.devc.xml`.
- `CTEXT` is filled with a descriptive text.
- No SAP-system-only creation step is required.
