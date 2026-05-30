# Changelog

## [0.5.0](https://github.com/MagPasulke/abap-string-interpreter/compare/v0.4.0...v0.5.0) (2026-05-30)


### Features

* add adt_gitpull custom tool for OpenCode ([#58](https://github.com/MagPasulke/abap-string-interpreter/issues/58)) ([d66cc31](https://github.com/MagPasulke/abap-string-interpreter/commit/d66cc3196d29ea201cdfa10ab9b75cffe17fcc5e))
* add adt_rununit OpenCode tool for remote ABAP unit test execution ([#62](https://github.com/MagPasulke/abap-string-interpreter/issues/62)) ([a5e0b15](https://github.com/MagPasulke/abap-string-interpreter/commit/a5e0b15e63dc63d6ed67e400f1063161e84dafe7))
* deploy-sap workflow — auto abapGit pull after CI passes on main ([#59](https://github.com/MagPasulke/abap-string-interpreter/issues/59)) ([7f42251](https://github.com/MagPasulke/abap-string-interpreter/commit/7f42251e1a4a609fd436aa3a7331c54ef81a00a8))
* enhance adt_gitpull to support pulling from different branches ([#65](https://github.com/MagPasulke/abap-string-interpreter/issues/65)) ([5b1fc4c](https://github.com/MagPasulke/abap-string-interpreter/commit/5b1fc4c7161cb3be786483de5800d5ef9bb87113))


### Bug Fixes

* **ci:** add --esm flag to tsx to support top-level await in CI runner ([#60](https://github.com/MagPasulke/abap-string-interpreter/issues/60)) ([5e0b1ed](https://github.com/MagPasulke/abap-string-interpreter/commit/5e0b1edd4ffa6baf19b997d1d62b586fc5570f57))
* **ci:** replace top-level await with async IIFE in CI runner ([#61](https://github.com/MagPasulke/abap-string-interpreter/issues/61)) ([b8995c5](https://github.com/MagPasulke/abap-string-interpreter/commit/b8995c555da7b5f78c48ed0d9dd4f3007461d4af))
* **ci:** split typecheck into ci and local variants ([ca1a5f1](https://github.com/MagPasulke/abap-string-interpreter/commit/ca1a5f131cbc6e93b41d6e3b477e2a1dcbaa0782))
* structured JSON error responses for HTTP API ([cab73f2](https://github.com/MagPasulke/abap-string-interpreter/commit/cab73f2d7210eb82ed1b0ec4d31b7b5df7679935))
