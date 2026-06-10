# Changelog

## [1.0.0](https://github.com/MagPasulke/abap-string-interpreter/compare/abap-string-interpreter-v0.6.1...abap-string-interpreter-v1.0.0) (2026-06-10)


### ⚠ BREAKING CHANGES

* **interpreter:** migrate regex from POSIX to PCRE ([#53](https://github.com/MagPasulke/abap-string-interpreter/issues/53))

### Features

* add ABAP Doc comments to all public methods and interfaces ([#45](https://github.com/MagPasulke/abap-string-interpreter/issues/45)) ([71ed870](https://github.com/MagPasulke/abap-string-interpreter/commit/71ed87007bd4efe8a3b12e3ddbe45776148ea1af))
* add adt_gitpull custom tool for OpenCode ([#58](https://github.com/MagPasulke/abap-string-interpreter/issues/58)) ([d66cc31](https://github.com/MagPasulke/abap-string-interpreter/commit/d66cc3196d29ea201cdfa10ab9b75cffe17fcc5e))
* add adt_rununit OpenCode tool for remote ABAP unit test execution ([#62](https://github.com/MagPasulke/abap-string-interpreter/issues/62)) ([a5e0b15](https://github.com/MagPasulke/abap-string-interpreter/commit/a5e0b15e63dc63d6ed67e400f1063161e84dafe7))
* add docs:user-manual label automation + seed initial user manual ([#69](https://github.com/MagPasulke/abap-string-interpreter/issues/69)) ([223dc41](https://github.com/MagPasulke/abap-string-interpreter/commit/223dc419b8513dfc762951ac761a79a8a3fe6317))
* add interpretation context passing to event producer and custom logic ([#17](https://github.com/MagPasulke/abap-string-interpreter/issues/17)) ([d03151d](https://github.com/MagPasulke/abap-string-interpreter/commit/d03151d6bf0f479da1293a0394455f501a99daf7)), closes [#12](https://github.com/MagPasulke/abap-string-interpreter/issues/12)
* add naming & hygiene abaplint rules (closes [#29](https://github.com/MagPasulke/abap-string-interpreter/issues/29)) ([#39](https://github.com/MagPasulke/abap-string-interpreter/issues/39)) ([17bf657](https://github.com/MagPasulke/abap-string-interpreter/commit/17bf65750030942a64bc9cdf739a7d351243f82e))
* add version interface and pre-commit version sync hook ([#25](https://github.com/MagPasulke/abap-string-interpreter/issues/25)) ([b616039](https://github.com/MagPasulke/abap-string-interpreter/commit/b6160393f648a58c54e2e944ad0cb5d1e7ca9b8b))
* deploy-sap workflow — auto abapGit pull after CI passes on main ([#59](https://github.com/MagPasulke/abap-string-interpreter/issues/59)) ([7f42251](https://github.com/MagPasulke/abap-string-interpreter/commit/7f42251e1a4a609fd436aa3a7331c54ef81a00a8))
* enhance adt_gitpull to support pulling from different branches ([#65](https://github.com/MagPasulke/abap-string-interpreter/issues/65)) ([5b1fc4c](https://github.com/MagPasulke/abap-string-interpreter/commit/5b1fc4c7161cb3be786483de5800d5ef9bb87113))
* **http:** accept and forward interpretation context from POST body ([#24](https://github.com/MagPasulke/abap-string-interpreter/issues/24)) ([3528e37](https://github.com/MagPasulke/abap-string-interpreter/commit/3528e371871b3099b7e85133a3ec9260927a66c6))
* include interpretation context in interpreter result ([#54](https://github.com/MagPasulke/abap-string-interpreter/issues/54)) ([9ed13b1](https://github.com/MagPasulke/abap-string-interpreter/commit/9ed13b17e9ac87a22e648bbad70839bae6e7f19e))
* **lint:** add performance abaplint rules ([#34](https://github.com/MagPasulke/abap-string-interpreter/issues/34)) ([3d8728b](https://github.com/MagPasulke/abap-string-interpreter/commit/3d8728b2922c1a64a7e83a28e9a4b5c385d913b5))
* refactor custom logic to instance-based resolver pattern ([#19](https://github.com/MagPasulke/abap-string-interpreter/issues/19)) ([5185449](https://github.com/MagPasulke/abap-string-interpreter/commit/518544903cd680732b7b8be50bac34e63514a692))
* **srv:** add ABAP Cloud HTTP handler with adapter pattern ([#74](https://github.com/MagPasulke/abap-string-interpreter/issues/74)) ([dcb6830](https://github.com/MagPasulke/abap-string-interpreter/commit/dcb6830be26e4efae4a7455fb49cad2a1f8c79b6))


### Bug Fixes

* add WITH_UNIT_TESTS indicator to validator class XML ([#78](https://github.com/MagPasulke/abap-string-interpreter/issues/78)) ([95b3044](https://github.com/MagPasulke/abap-string-interpreter/commit/95b3044a7a503a1712ef9b60bcd88ca9691f3880))
* align DDIC structure naming to _line suffix convention ([#50](https://github.com/MagPasulke/abap-string-interpreter/issues/50)) ([43b7f27](https://github.com/MagPasulke/abap-string-interpreter/commit/43b7f27baed2d60b5cd046c83126fd880f7fc307))
* align release-please config to properly bump version files ([#81](https://github.com/MagPasulke/abap-string-interpreter/issues/81)) ([3e39d9b](https://github.com/MagPasulke/abap-string-interpreter/commit/3e39d9b5b8f8f273b0e9dc509cdc208b2daff223))
* **ci:** add --esm flag to tsx to support top-level await in CI runner ([#60](https://github.com/MagPasulke/abap-string-interpreter/issues/60)) ([5e0b1ed](https://github.com/MagPasulke/abap-string-interpreter/commit/5e0b1edd4ffa6baf19b997d1d62b586fc5570f57))
* **ci:** replace top-level await with async IIFE in CI runner ([#61](https://github.com/MagPasulke/abap-string-interpreter/issues/61)) ([b8995c5](https://github.com/MagPasulke/abap-string-interpreter/commit/b8995c555da7b5f78c48ed0d9dd4f3007461d4af))
* **ci:** split typecheck into ci and local variants ([ca1a5f1](https://github.com/MagPasulke/abap-string-interpreter/commit/ca1a5f131cbc6e93b41d6e3b477e2a1dcbaa0782))
* **ci:** use COPILOT_PAT + agent_assignment for Copilot issue assignment ([78dde76](https://github.com/MagPasulke/abap-string-interpreter/commit/78dde76a6ae34018305d20060cef44023925a785))
* inline variable declarations to resolve abaplint prefer_inline errors ([#38](https://github.com/MagPasulke/abap-string-interpreter/issues/38)) ([0e304c2](https://github.com/MagPasulke/abap-string-interpreter/commit/0e304c2e74f929c3c7f7f4fe174a42ccf9e77043))
* **interpreter:** return no match for REPLACE rules with non-matching regex ([#23](https://github.com/MagPasulke/abap-string-interpreter/issues/23)) ([1ed86d0](https://github.com/MagPasulke/abap-string-interpreter/commit/1ed86d0266ed33e5aeb18664ef73ca16a5ef7c88))
* **lint:** add proper exception handling to resolve uncaught exception errors ([#20](https://github.com/MagPasulke/abap-string-interpreter/issues/20)) ([b985bc0](https://github.com/MagPasulke/abap-string-interpreter/commit/b985bc029082d74a71c40e0dfeae016391d9c57f))
* Make deploy workflow manual and gated by CI ([#64](https://github.com/MagPasulke/abap-string-interpreter/issues/64)) ([b6b38ed](https://github.com/MagPasulke/abap-string-interpreter/commit/b6b38ed13c9c612e6a3c853d2533d759f2856130))
* migrate http-test env from VS Code settings to http-client.env.json ([#52](https://github.com/MagPasulke/abap-string-interpreter/issues/52)) ([0a26c6e](https://github.com/MagPasulke/abap-string-interpreter/commit/0a26c6e591af254bc6b61efc92f2433d2ac42e56))
* resolve potential bugs - RETURN in loop, overly broad CATCH ([#42](https://github.com/MagPasulke/abap-string-interpreter/issues/42)) ([0046363](https://github.com/MagPasulke/abap-string-interpreter/commit/00463637c27e344d2be1b8ba696dbbb701e11f34))
* structured JSON error responses for HTTP API ([cab73f2](https://github.com/MagPasulke/abap-string-interpreter/commit/cab73f2d7210eb82ed1b0ec4d31b7b5df7679935))
* technical debt - typos, dead code, inconsistent casing ([#31](https://github.com/MagPasulke/abap-string-interpreter/issues/31)) ([#40](https://github.com/MagPasulke/abap-string-interpreter/issues/40)) ([eb18170](https://github.com/MagPasulke/abap-string-interpreter/commit/eb18170bd74f14591c5130f6557d699cf06888dd))
* **utils:** check sy-subrc after SELECT and READ TABLE in domain fix values query provider ([#35](https://github.com/MagPasulke/abap-string-interpreter/issues/35)) ([68b8081](https://github.com/MagPasulke/abap-string-interpreter/commit/68b8081d6fc4bc47e3216f28215a19b33160a91c))


### Code Refactoring

* **interpreter:** migrate regex from POSIX to PCRE ([#53](https://github.com/MagPasulke/abap-string-interpreter/issues/53)) ([4212dd4](https://github.com/MagPasulke/abap-string-interpreter/commit/4212dd410ee199aa51d31fb6874af040f06cfb04))

## [0.6.1](https://github.com/MagPasulke/abap-string-interpreter/compare/v0.6.0...v0.6.1) (2026-06-10)


### Bug Fixes

* add WITH_UNIT_TESTS indicator to validator class XML ([#78](https://github.com/MagPasulke/abap-string-interpreter/issues/78)) ([95b3044](https://github.com/MagPasulke/abap-string-interpreter/commit/95b3044a7a503a1712ef9b60bcd88ca9691f3880))

## [0.6.0](https://github.com/MagPasulke/abap-string-interpreter/compare/v0.5.0...v0.6.0) (2026-06-09)


### Features

* add docs:user-manual label automation + seed initial user manual ([#69](https://github.com/MagPasulke/abap-string-interpreter/issues/69)) ([223dc41](https://github.com/MagPasulke/abap-string-interpreter/commit/223dc419b8513dfc762951ac761a79a8a3fe6317))
* **srv:** add ABAP Cloud HTTP handler with adapter pattern ([#74](https://github.com/MagPasulke/abap-string-interpreter/issues/74)) ([dcb6830](https://github.com/MagPasulke/abap-string-interpreter/commit/dcb6830be26e4efae4a7455fb49cad2a1f8c79b6))


### Bug Fixes

* **ci:** use COPILOT_PAT + agent_assignment for Copilot issue assignment ([78dde76](https://github.com/MagPasulke/abap-string-interpreter/commit/78dde76a6ae34018305d20060cef44023925a785))
* Make deploy workflow manual and gated by CI ([#64](https://github.com/MagPasulke/abap-string-interpreter/issues/64)) ([b6b38ed](https://github.com/MagPasulke/abap-string-interpreter/commit/b6b38ed13c9c612e6a3c853d2533d759f2856130))

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
