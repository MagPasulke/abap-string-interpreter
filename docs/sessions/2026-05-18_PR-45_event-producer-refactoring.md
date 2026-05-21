# ses_1c571b3b9ffe

**Date:** 2026-05-18
**Title:** Event Producer Refactoring

## Summary

Removed old config/function group table maintenance for eventing. Moved event producer to item level (like custom logic). New interface method `on_item_interpreted`. Added resolver pattern with DI for testability. 5 new unit tests. Sync call after successful item interpretation. bgPF migration note for future async. PR #45 merged.
