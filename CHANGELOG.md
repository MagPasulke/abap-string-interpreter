# Changelog

## [0.8.1](https://github.com/MagPasulke/abap-string-interpreter/compare/abap-string-interpreter-v0.8.0...abap-string-interpreter-v0.8.1) (2026-07-01)


### Development & Tooling

* **abaplint:** add missing rules and fix non-7bit ASCII in comments ([#133](https://github.com/MagPasulke/abap-string-interpreter/issues/133)) ([1fab66f](https://github.com/MagPasulke/abap-string-interpreter/commit/1fab66f4d572ec34b49a0570fd3331b0887727f7))

## [0.8.0](https://github.com/MagPasulke/abap-string-interpreter/compare/abap-string-interpreter-v0.7.3...abap-string-interpreter-v0.8.0) (2026-07-01)


### Features

* add separate RAP event producer catalog ([#127](https://github.com/MagPasulke/abap-string-interpreter/issues/127)) ([2aac49e](https://github.com/MagPasulke/abap-string-interpreter/commit/2aac49e7d19fbe52e0fd388c8d4b3e1c3f6e9ae6))


### Documentation

* **technical:** align architecture/install/auth docs with split catalog RAP model ([#130](https://github.com/MagPasulke/abap-string-interpreter/issues/130)) ([cda05a7](https://github.com/MagPasulke/abap-string-interpreter/commit/cda05a721c25ab5b9b1dd7a0494058476f2b0a64))
* update user manual for PR [#127](https://github.com/MagPasulke/abap-string-interpreter/issues/127) — feat: add separate RAP event producer catalog ([#131](https://github.com/MagPasulke/abap-string-interpreter/issues/131)) ([3e09e7c](https://github.com/MagPasulke/abap-string-interpreter/commit/3e09e7c240ce0b8f907be3ce0e5b7785bfaa2622))

## [0.7.3](https://github.com/MagPasulke/abap-string-interpreter/compare/abap-string-interpreter-v0.7.2...abap-string-interpreter-v0.7.3) (2026-06-24)


### Development & Tooling

* abaplint_activate_rules ([#125](https://github.com/MagPasulke/abap-string-interpreter/issues/125)) ([3562166](https://github.com/MagPasulke/abap-string-interpreter/commit/3562166431165d5f11420472daf09b279f556537))
* **ci:** fix typecheck:ci glob failure on Windows ([#121](https://github.com/MagPasulke/abap-string-interpreter/issues/121)) ([0e16e17](https://github.com/MagPasulke/abap-string-interpreter/commit/0e16e1779c7383934a08618c87a0ac33b1831794))
* update deps ([#124](https://github.com/MagPasulke/abap-string-interpreter/issues/124)) ([a67b375](https://github.com/MagPasulke/abap-string-interpreter/commit/a67b375f3d76c0fc95ece3ade3f728ee5985459c))

## [0.7.2](https://github.com/MagPasulke/abap-string-interpreter/compare/abap-string-interpreter-v0.7.1...abap-string-interpreter-v0.7.2) (2026-06-17)


### Development & Tooling

* deps + abaplint pragmas ([0577fdf](https://github.com/MagPasulke/abap-string-interpreter/commit/0577fdff8f2a387fcdd581446446a746b4c804f4))
* **deps:** update deps & lint config ([d715ebb](https://github.com/MagPasulke/abap-string-interpreter/commit/d715ebb43b792343f14afa38654f62492fe514b7))
* **deps:** update dev dependencies to latest ([#112](https://github.com/MagPasulke/abap-string-interpreter/issues/112)) ([47b18b2](https://github.com/MagPasulke/abap-string-interpreter/commit/47b18b234d23d72ef8de3bbcbda5b82a0d5ef52a))
* **transpile:** shorten exclude list and tighten abaplint rules ([55d6fca](https://github.com/MagPasulke/abap-string-interpreter/commit/55d6fcac21c06ff66b00f38247f7fbdff203cfb7))
* update deps + enable rules ([#119](https://github.com/MagPasulke/abap-string-interpreter/issues/119)) ([e597828](https://github.com/MagPasulke/abap-string-interpreter/commit/e59782805e33413184e413debcb6d4bbf70838b5))

## [0.7.1](https://github.com/MagPasulke/abap-string-interpreter/compare/abap-string-interpreter-v0.7.0...abap-string-interpreter-v0.7.1) (2026-06-14)


### Documentation

* restructure README and introduce Technical Reference ([7985d55](https://github.com/MagPasulke/abap-string-interpreter/commit/7985d556761b74270803848e3ba36d50d89fc75d))
* update cicd.md for update-technical-docs workflow (PR [#107](https://github.com/MagPasulke/abap-string-interpreter/issues/107)) ([#109](https://github.com/MagPasulke/abap-string-interpreter/issues/109)) ([7fefa15](https://github.com/MagPasulke/abap-string-interpreter/commit/7fefa150d539d351fe502a6dadbd826b41fd4aad))


### Development & Tooling

* **docs:** add technical docs update workflow and fix issue closure ([#107](https://github.com/MagPasulke/abap-string-interpreter/issues/107)) ([e437cf3](https://github.com/MagPasulke/abap-string-interpreter/commit/e437cf301735300cef83075b95f01b6e60162661))
* **opencode:** add /ponytail-review command for over-engineering review ([#111](https://github.com/MagPasulke/abap-string-interpreter/issues/111)) ([b1c0139](https://github.com/MagPasulke/abap-string-interpreter/commit/b1c01394178d77b09f59cf7cf6eb7496920b7fe4))

## [0.7.0](https://github.com/MagPasulke/abap-string-interpreter/compare/abap-string-interpreter-v0.6.1...abap-string-interpreter-v0.7.0) (2026-06-13)


### ⚠ BREAKING CHANGES

* **interpreter:** migrate regex from POSIX to PCRE ([#53](https://github.com/MagPasulke/abap-string-interpreter/issues/53))

### Features

* add copy ruleset factory action ([#85](https://github.com/MagPasulke/abap-string-interpreter/issues/85)) ([1634710](https://github.com/MagPasulke/abap-string-interpreter/commit/1634710993ff16e65b3baeb40a1f103524d41f8a))
* add interpretation context passing to event producer and custom logic ([#17](https://github.com/MagPasulke/abap-string-interpreter/issues/17)) ([d03151d](https://github.com/MagPasulke/abap-string-interpreter/commit/d03151d6bf0f479da1293a0394455f501a99daf7)), closes [#12](https://github.com/MagPasulke/abap-string-interpreter/issues/12)
* **enhcatalog:** add Custom Logic Catalog BO with RAP managed draft ([6b3ee9a](https://github.com/MagPasulke/abap-string-interpreter/commit/6b3ee9a88deba9becbce46c5b4bb086a5ae60aa3)), closes [#77](https://github.com/MagPasulke/abap-string-interpreter/issues/77)
* export ruleset as JSON file ([#89](https://github.com/MagPasulke/abap-string-interpreter/issues/89)) ([06b2a65](https://github.com/MagPasulke/abap-string-interpreter/commit/06b2a6533c50c2036c5b8fdcc9ba9cc52cfd3d8d))
* **http:** accept and forward interpretation context from POST body ([#24](https://github.com/MagPasulke/abap-string-interpreter/issues/24)) ([3528e37](https://github.com/MagPasulke/abap-string-interpreter/commit/3528e371871b3099b7e85133a3ec9260927a66c6))
* include interpretation context in interpreter result ([#54](https://github.com/MagPasulke/abap-string-interpreter/issues/54)) ([9ed13b1](https://github.com/MagPasulke/abap-string-interpreter/commit/9ed13b17e9ac87a22e648bbad70839bae6e7f19e))
* **srv:** add ABAP Cloud HTTP handler with adapter pattern ([#74](https://github.com/MagPasulke/abap-string-interpreter/issues/74)) ([dcb6830](https://github.com/MagPasulke/abap-string-interpreter/commit/dcb6830be26e4efae4a7455fb49cad2a1f8c79b6))


### Bug Fixes

* add bump-minor-pre-major to prevent premature 1.0.0 release ([05e707a](https://github.com/MagPasulke/abap-string-interpreter/commit/05e707a3cccea71095aeda306b6af72e4e132b83))
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


### Documentation

* add ABAP Doc comments to all public methods and interfaces ([#45](https://github.com/MagPasulke/abap-string-interpreter/issues/45)) ([71ed870](https://github.com/MagPasulke/abap-string-interpreter/commit/71ed87007bd4efe8a3b12e3ddbe45776148ea1af))
* add docs:user-manual label automation + seed initial user manual ([#69](https://github.com/MagPasulke/abap-string-interpreter/issues/69)) ([223dc41](https://github.com/MagPasulke/abap-string-interpreter/commit/223dc419b8513dfc762951ac761a79a8a3fe6317))
* add pre-release breaking changes notice and update README screenshots ([#3](https://github.com/MagPasulke/abap-string-interpreter/issues/3)) ([3bdfaab](https://github.com/MagPasulke/abap-string-interpreter/commit/3bdfaab2115df175a3e840ec1c03db7cd137e54b))
* add session summary for context passing feature ([#12](https://github.com/MagPasulke/abap-string-interpreter/issues/12)) ([f9d9956](https://github.com/MagPasulke/abap-string-interpreter/commit/f9d99563e1fbc4b2f9e96706f355625b0e4310f1))
* add session summary for custom logic resolver refactoring ([c4aefc2](https://github.com/MagPasulke/abap-string-interpreter/commit/c4aefc21fcb307a89455aead8bdbf09823dda217))
* add session summary for uncaught exception fix session ([03c1e4c](https://github.com/MagPasulke/abap-string-interpreter/commit/03c1e4c969ce41220639aca47f265e048838510c))
* add unit test writing guidance to AGENTS.md ([#43](https://github.com/MagPasulke/abap-string-interpreter/issues/43)) ([6ba1d42](https://github.com/MagPasulke/abap-string-interpreter/commit/6ba1d42854def932d540007df9eb301c7e47c479))
* **agents:** add exception handling chapter to AGENTS.md ([09483f4](https://github.com/MagPasulke/abap-string-interpreter/commit/09483f4daeaf4216a5a7429c106f557870f594f3))
* **conventional-commit:** fix BREAKING CHANGE footer format in skill ([27757fc](https://github.com/MagPasulke/abap-string-interpreter/commit/27757fcbeefedf0ccd2dc99e4cc7e993ff959d33))
* extract exception handling to skill, update AGENTS.md reference ([c42017c](https://github.com/MagPasulke/abap-string-interpreter/commit/c42017c366f86fe76448fded8996b8f03517781d))
* revamp git workflow and update architecture section ([#36](https://github.com/MagPasulke/abap-string-interpreter/issues/36)) ([cf20a2e](https://github.com/MagPasulke/abap-string-interpreter/commit/cf20a2e44799a0c32fd4515f3880d2c12ecd45cc))
* revert OffsetPost back to RightTrim — matches data element label shown in Fiori UI ([a0b9b0d](https://github.com/MagPasulke/abap-string-interpreter/commit/a0b9b0d4663954e8c0b7df9238e62c0068709b54))
* update session summary with PR-49 ([68faf2b](https://github.com/MagPasulke/abap-string-interpreter/commit/68faf2bd901cea47d06af254ef646aeda1b6e660))
* update user manual for custom logic catalog status workflow ([#99](https://github.com/MagPasulke/abap-string-interpreter/issues/99)) ([060edea](https://github.com/MagPasulke/abap-string-interpreter/commit/060edeae1d6941b23f6f150968ddeb0021b425f1))
* update user manual for PR [#69](https://github.com/MagPasulke/abap-string-interpreter/issues/69) — fix OffsetPost, add Test RuleSet UI, fix event producer description ([6b9a064](https://github.com/MagPasulke/abap-string-interpreter/commit/6b9a06489319a8027b3858d54f2255738004191b)), closes [#70](https://github.com/MagPasulke/abap-string-interpreter/issues/70)
* update user manual for PR [#74](https://github.com/MagPasulke/abap-string-interpreter/issues/74) HTTP service changes ([#76](https://github.com/MagPasulke/abap-string-interpreter/issues/76)) ([c27e886](https://github.com/MagPasulke/abap-string-interpreter/commit/c27e886c7abc5b0659940cb37caced3e4731c7c8))
* update user manual for PR [#85](https://github.com/MagPasulke/abap-string-interpreter/issues/85) — feat: add copy ruleset factory action ([#104](https://github.com/MagPasulke/abap-string-interpreter/issues/104)) ([9c6ed03](https://github.com/MagPasulke/abap-string-interpreter/commit/9c6ed0361c9ee0fe37949a2e70d50a76c0ec814a))
* update user manual for PR [#89](https://github.com/MagPasulke/abap-string-interpreter/issues/89) — feat: export ruleset as JSON file ([#102](https://github.com/MagPasulke/abap-string-interpreter/issues/102)) ([4d02011](https://github.com/MagPasulke/abap-string-interpreter/commit/4d02011e3efa975fe96ef7bc8eb45905a2abf558))


### Development & Tooling

* add adt_gitpull custom tool for OpenCode ([#58](https://github.com/MagPasulke/abap-string-interpreter/issues/58)) ([d66cc31](https://github.com/MagPasulke/abap-string-interpreter/commit/d66cc3196d29ea201cdfa10ab9b75cffe17fcc5e))
* add adt_rununit OpenCode tool for remote ABAP unit test execution ([#62](https://github.com/MagPasulke/abap-string-interpreter/issues/62)) ([a5e0b15](https://github.com/MagPasulke/abap-string-interpreter/commit/a5e0b15e63dc63d6ed67e400f1063161e84dafe7))
* add naming & hygiene abaplint rules (closes [#29](https://github.com/MagPasulke/abap-string-interpreter/issues/29)) ([#39](https://github.com/MagPasulke/abap-string-interpreter/issues/39)) ([17bf657](https://github.com/MagPasulke/abap-string-interpreter/commit/17bf65750030942a64bc9cdf739a7d351243f82e))
* add version interface and pre-commit version sync hook ([#25](https://github.com/MagPasulke/abap-string-interpreter/issues/25)) ([b616039](https://github.com/MagPasulke/abap-string-interpreter/commit/b6160393f648a58c54e2e944ad0cb5d1e7ca9b8b))
* deploy-sap workflow — auto abapGit pull after CI passes on main ([#59](https://github.com/MagPasulke/abap-string-interpreter/issues/59)) ([7f42251](https://github.com/MagPasulke/abap-string-interpreter/commit/7f42251e1a4a609fd436aa3a7331c54ef81a00a8))
* enhance adt_gitpull to support pulling from different branches ([#65](https://github.com/MagPasulke/abap-string-interpreter/issues/65)) ([5b1fc4c](https://github.com/MagPasulke/abap-string-interpreter/commit/5b1fc4c7161cb3be786483de5800d5ef9bb87113))
* **lint:** add performance abaplint rules ([#34](https://github.com/MagPasulke/abap-string-interpreter/issues/34)) ([3d8728b](https://github.com/MagPasulke/abap-string-interpreter/commit/3d8728b2922c1a64a7e83a28e9a4b5c385d913b5))
* refactor custom logic to instance-based resolver pattern ([#19](https://github.com/MagPasulke/abap-string-interpreter/issues/19)) ([5185449](https://github.com/MagPasulke/abap-string-interpreter/commit/518544903cd680732b7b8be50bac34e63514a692))
* **adt:** add check-errors tool for syntax error detection after git pull ([#87](https://github.com/MagPasulke/abap-string-interpreter/issues/87)) ([6ac9fe7](https://github.com/MagPasulke/abap-string-interpreter/commit/6ac9fe792b1ab1a0b08656767d3e6381458f7758))
* **agents:** update AGENTS.md ([0ed74fb](https://github.com/MagPasulke/abap-string-interpreter/commit/0ed74fbddfc5fabbd721d570a18f7cd67a8afa77))
* **bytemark:** fakepush to resolve bytemark ([#80](https://github.com/MagPasulke/abap-string-interpreter/issues/80)) ([d611bd3](https://github.com/MagPasulke/abap-string-interpreter/commit/d611bd30cfc17dc80bad687ac422d0380e16872c))
* **ci:** bump actions/checkout to v6 in deploy-sap workflow ([2ca0ca8](https://github.com/MagPasulke/abap-string-interpreter/commit/2ca0ca8598e52e4a86cecb9840f6db35acaa2ba0))
* **ci:** bump actions/setup-node to v6 in deploy-sap workflow ([9513ece](https://github.com/MagPasulke/abap-string-interpreter/commit/9513eced06452d605b64bff9ad52b92c55fa90d7))
* **config:** add ADT MCP server and untrack vscode settings ([aa36b9f](https://github.com/MagPasulke/abap-string-interpreter/commit/aa36b9f5dcfd82d2f924dad1afb3834c3179aaf7))
* fix typecheck:ci TS5112, add opencode tools tsconfig, restructure docs ([ce52f58](https://github.com/MagPasulke/abap-string-interpreter/commit/ce52f58aaa134eef186243cac5081ff62e2dd44f))
* install .opencode dependencies for typecheck ([8b6bcee](https://github.com/MagPasulke/abap-string-interpreter/commit/8b6bcee7be523f9f1303cbd3d2f3cd567eaf272b))
* **interpreter:** expand edge case and integration coverage ([#22](https://github.com/MagPasulke/abap-string-interpreter/issues/22)) ([d555f53](https://github.com/MagPasulke/abap-string-interpreter/commit/d555f53aa038807b38da7fd94c733ce5786738eb))
* **main:** release 0.5.0 ([#57](https://github.com/MagPasulke/abap-string-interpreter/issues/57)) ([f7b32d8](https://github.com/MagPasulke/abap-string-interpreter/commit/f7b32d8e3f987437f8e592f7628d10aceee4c73e))
* **main:** release 0.6.0 ([#66](https://github.com/MagPasulke/abap-string-interpreter/issues/66)) ([2b747ad](https://github.com/MagPasulke/abap-string-interpreter/commit/2b747adcbead56c3a3ec3d5939b05f8a6731e1da))
* **main:** release 0.6.1 ([#79](https://github.com/MagPasulke/abap-string-interpreter/issues/79)) ([e682f23](https://github.com/MagPasulke/abap-string-interpreter/commit/e682f23f23a2366d47ca7c43dffd0f92467bff2b))
* moved ts config, added license in package.json, updated extensions and MCPs ([fb8628c](https://github.com/MagPasulke/abap-string-interpreter/commit/fb8628c50104a5907eb73f0c2dfe02d34acc91e7))
* **release-please:** configure changelog categories ([#93](https://github.com/MagPasulke/abap-string-interpreter/issues/93)) ([8065f87](https://github.com/MagPasulke/abap-string-interpreter/commit/8065f87d99a16e14d044073508acb3478c257f63))
* remove ignored ABAP backend artifacts from repo ([5fbe956](https://github.com/MagPasulke/abap-string-interpreter/commit/5fbe9567511ba6612f19107c304f02d8d3a12258))
* rename session summaries to YYYY-MM-DD_PR-NN_title convention ([#33](https://github.com/MagPasulke/abap-string-interpreter/issues/33)) ([58501cc](https://github.com/MagPasulke/abap-string-interpreter/commit/58501cc85638fbc53568623f2aada454b6fc703d))
* rename workflow to ci and add badge to README ([a24c5c2](https://github.com/MagPasulke/abap-string-interpreter/commit/a24c5c2842f01eccb1dc653359db16a3c2070ee5))
* set up release-please automation ([98d06ac](https://github.com/MagPasulke/abap-string-interpreter/commit/98d06ac208aa1c7e9e4d28b615bc67066533ddc3))
* **skills:** restore lock entries and align agent guidance ([#2](https://github.com/MagPasulke/abap-string-interpreter/issues/2)) ([e1d776f](https://github.com/MagPasulke/abap-string-interpreter/commit/e1d776f879f3a0aba793febb1d9a6e47c80db77e))
* **tooling:** add conventional-commit skill and update lint lockfiles ([#1](https://github.com/MagPasulke/abap-string-interpreter/issues/1)) ([fafaf2d](https://github.com/MagPasulke/abap-string-interpreter/commit/fafaf2d4f11d9e69a72532bf2caaaffe561c89c6))
* update abaplint toolsets to latest ([#37](https://github.com/MagPasulke/abap-string-interpreter/issues/37)) ([0f671b6](https://github.com/MagPasulke/abap-string-interpreter/commit/0f671b6005260d1d33f3e27719d5a7dc1b7d74c1))


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
