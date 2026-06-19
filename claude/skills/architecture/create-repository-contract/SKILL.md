---
name: create-repository-contract
description: Define a domain-owned repository interface; implementations live in infrastructure and return domain types only. Use when a use case needs data access.
---

# create-repository-contract

The **interface** is domain-owned: it lives in the feature's domain layer. Adapters that implement it live in infrastructure (see the `create-infrastructure` skill). The use case depends on the interface, never on a concrete adapter.

## Rules

- Put the interface in the feature's domain layer, alongside the entities and value objects it returns.
- Method naming: `find*` for reads, `create` / `update` / `delete` for writes.
- **Return domain types only** (entities and value objects), never raw API shapes, DB rows, or DTOs. Mapping from the external shape happens inside the infrastructure adapter.
- Params are a small typed domain object, not a bag of loose primitives. The params type is itself a domain type.
- If the project ships shared repository base interfaces (generic `find` / `create` / CRUD contracts), extend those instead of redeclaring the same methods.

## Illustrative example (neutral domain)

```ts
// domain layer
export interface OrderRange {
  from: PeriodId
  to: PeriodId
}

export interface OrderRepository {
  findAll(range: OrderRange): Promise<Order[]>
}
```

The DI container binds this interface to a live adapter or an in-memory adapter at the composition root.
