# Technical Reference

This reference covers the internals, development workflow, and operational details of ZASIS. It is intended for developers contributing to the project, integrating it into a system, or understanding how it works under the hood.

---

## Contents

| Document | Description |
|---|---|
| [Architecture](architecture.md) | Package structure, core components, data model, and execution logic |
| [Off-Stack Development](off-stack-development.md) | How ABAP is developed and tested without a running SAP system |
| [Testing](testing.md) | All test layers, commands, coverage scope, and when to use each |
| [CI/CD](cicd.md) | GitHub Actions workflows — CI gate, SAP deployment, release automation |
| [Installation](installation.md) | Installing ZASIS into a SAP system via abapGit and activating the HTTP API |
| [Authorization](authorization.md) | Authorization object `ZASIS_GRL`, activity codes, and enforcement points |
| [Event Producer: bgPF Migration](event-producer-bgpf-migration.md) | Future migration path for the event producer to background processing |
