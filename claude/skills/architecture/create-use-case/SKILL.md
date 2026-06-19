---
name: create-use-case
description: Author an application use case (Query or Command) with constructor injection that returns a plain serializable DTO; never imports infrastructure or UI. Use when wiring data to a view.
---

# create-use-case

One use case per file in the application layer. A Query reads, a Command writes.

## Rules

- A single public method: **`run(input): Promise<Output>`**. Keep everything else private.
- **Constructor injection only**: receive repository interfaces and other ports, never concrete implementations.
- Use guard clauses and early returns.
- Output is a **plain serializable DTO**: primitives, arrays, and plain objects only. No class instances, no value objects, no live date objects. Do the conversion (money to minor units, dates to ISO strings) here, at this boundary.
- DTOs must survive process / serialization boundaries (RSC, IPC, JSON). Anything that does not round-trip through serialization must be flattened before it leaves `run`.
- Allowed imports: the feature's own domain plus the framework-agnostic core/shared kernel. **Never** import infrastructure or delivery/UI.
- Cross-feature data: depend on the other feature's **published use case** behind a domain port wired at the composition root. Never reach into another feature's infrastructure or domain internals.

## Illustrative example (neutral domain)

`GetOrdersByStatus` takes an `OrderRepository` (interface, see the `create-repository-contract` skill) in its constructor. `run({ range })` fetches `Order[]`, aggregates, and returns `{ status: string, totalInCents: number }[]` -> all primitives, ready to cross any serialization boundary.

## Test

Write unit tests with the feature's in-memory repository seeded via mothers. Mock only the repository (or other injected ports) if needed; the use case logic itself runs unmocked. Detect the test command from the project or use the `validate` skill.
