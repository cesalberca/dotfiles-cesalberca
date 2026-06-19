---
name: create-domain-model
description: Author a pure, framework-free domain model (value objects, entities, domain services) with immutability and injected time. Use when adding domain logic to a feature.
---

# create-domain-model

Pure code, zero framework dependencies. Depends only on a shared kernel and sibling domain types. The model lives in the domain layer and is imported only by the application (use case) layer and the feature's own infrastructure.

## Rules

- **Value objects**: a private constructor plus a static `create(props)` factory; all props `readonly`; behaviour methods return new instances instead of mutating. Validate invariants in the factory.
- **Money**: store integer minor units (cents), never floats. Expose a conversion accessor (for example a minor-units getter) for use at the DTO boundary, not inside the domain.
- **Entities**: plain records with an `id`. Prefer a record/interface over a class; entities hold data, behaviour belongs to value objects or domain services.
- **Unions over enums**: model closed sets as string-literal unions (`type Status = 'open' | 'closed'`), not enums.
- **Domain services**: small pure functions or classes (for example `aggregateByCategory(points): CategoryTotal[]`). No I/O. Never read the current time directly: inject a clock or the current period so the function stays deterministic and testable.
- **Mothers**: every value object and entity gets a test-mother (`*.mother.ts`) exposing builders for tests (for example `OrderMother.paid()`).

## Illustrative example (neutral domain)

A `Price` value object: `Price.create({ amountInCents })`, readonly props, `add(other): Price` returns a new instance, integer cents only. An `Order` entity is a plain record `{ id, lines, status }`. A domain service `totalFor(order, clock): Price` injects the clock rather than reading now.

## Test first

Write unit tests beside the source, **zero mocks** for the domain (it has no collaborators to mock). Seed inputs with mothers. Detect the test command from the project (read package.json scripts / detect the package manager by lockfile) or use the `validate` skill.
