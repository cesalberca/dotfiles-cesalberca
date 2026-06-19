---
name: tdd-slice
description: Drive a feature vertical slice test-first: domain unit, then use-case, then integration, then E2E, with a green gate before advancing. Use at the start of every feature.
---

# tdd-slice

Red, green, refactor, per slice. Auto-detect the test runner from the project (package.json scripts / lockfile) and use the project's configured tools.

## Order

Write the failing test for each layer before its implementation. Advance only when the current layer is green.

1. Domain unit - the domain service/value-object logic. Zero mocks: domain is pure. See `create-domain-model`.
2. Use-case unit - exercise the use case with an in-memory repository seeded via test data builders. Assert the DTO shape returned to callers (flat, explicit units, ISO dates as relevant). See `create-use-case`.
3. Integration - adapter/repository mapping against captured-shape fixtures, not live HTTP. See `create-infrastructure`.
4. E2E - boot the app against an in-memory or seeded data mode, bypass auth with a pre-issued session, and assert the user-visible result renders.

## Determinism

Inject the clock or current time/period; never call `Date.now()` (or equivalent) in domain. Tests must be reproducible.

- Integration tests read captured fixtures, never live external calls.
- Domain tests use no mocks.

## Gate (must be green to advance)

Run the `validate` skill before ticking a phase. It should cover, at minimum: lint, typecheck, boundary checks (see `architecture-guardrails`), unit + integration tests, and build; add E2E once an end-to-end path exists.
