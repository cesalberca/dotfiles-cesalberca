---
name: wire-dependencies
description: Wire a feature into the DI container or composition root, including per-source live-vs-fixture mode resolution and hexagonal-safe cross-feature ports. Use when registering a feature or a cross-feature dependency.
---

# wire-dependencies

Wire a feature into the DI container / composition root. Works with a hand-rolled container OR a DI library (tsyringe, awilix, etc.). Uses constructor injection.

## Container API

Whatever container you use, expect this shape:

- `register(instance)` / `get(ClassRef)` - register and resolve a concrete by its type (keyed on a static id on the class).
- `registerWithKey(key, instance)` / `getWithKey(key)` - a key variant for interfaces (for example repositories), since an interface has no runtime type to key on. The key can be a string, symbol, or token; the symbol convention is one option, not a requirement.
- `validate()` - throws if any declared dependency is unresolved. Call it once, after all registrations.

## Composition root

The composition root is the single place that registers everything, then validates. It:

- Builds the container (typically a module-level singleton).
- Calls every `registerX(container, { env })` for each feature.
- Calls `validate()` once at the end.

Keep this as the only place that knows about concrete wiring. Layers below it depend on abstractions, not on the container's contents.

## Per-source live-vs-fixture mode

Resolve mode per source so each integration can be live or fixture independently. Precedence:

1. Global override wins. If the project's fixture-mode env var is set (detect the name the project uses, for example a `*_DATA_MODE=in-memory` or `USE_FIXTURES=true` flag), use fixture mode for all sources.
2. Else, if this source's credentials are present and non-empty, use live.
3. Else, use fixture.

Log the decision once per source so it is obvious at startup which mode each integration runs in.

```text
function resolveMode(source, env):
    if env.fixtureModeFlag: return "fixture"     # global override wins
    if credentialsPresent(source, env): return "live"
    return "fixture"                              # log once
```

## Cross-feature dependency (hexagonal-safe)

A feature must never import another feature's internals. To depend on another feature:

1. The consumer defines a domain port (an interface it owns) describing what it needs (illustrative: `MonthlyIncomeSource`).
2. The consumer's infrastructure provides a thin adapter implementing that port by delegating to the other feature's published use case (its application entry, not its domain or infrastructure).
3. Wire that adapter at the composition root.

This keeps domain and application free of other features; only the composition root knows the two features exist together. See `create-infrastructure` for the consumer-side adapter.
