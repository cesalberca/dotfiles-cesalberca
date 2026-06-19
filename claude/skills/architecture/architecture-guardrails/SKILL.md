---
name: architecture-guardrails
description: Enforce layer and module boundaries (domain/application/infrastructure/delivery) via package exports and a dependency linter. Use before committing a phase or when an import looks like it crosses a layer.
---

# architecture-guardrails

Two gates, both must pass. Run them via the project's lint or guardrails script if one exists; otherwise inspect imports manually.

## Gate 1 - physical boundaries (package exports)

Each feature/module exposes only concrete subpaths through its `package.json` `exports` map. No barrel/index re-export files.

```json
// illustrative
"exports": {
  "./application/*": "./src/application/*.ts",
  "./delivery/*": "./src/delivery/*.tsx",
  "./di": "./src/infrastructure/<feature>.di.ts"
}
```

- Do not export `./domain` or `./infrastructure`. Their internals stay unresolvable from outside the module.
- Consumers import concrete files, not a barrel (illustrative: `@scope/<feature>/application/<some-use-case>`).
- Because there is no index, a cross-feature import of another module's internals fails to resolve at the module level.

## Gate 2 - logical boundaries (dependency linter)

Use the project's configured boundary linter (dependency-cruiser, eslint-plugin-boundaries, etc.). Encode these layer rules:

- domain: depends only on a shared kernel + sibling domain. Pure, no framework.
- application (use cases): depends on domain + a framework-agnostic core; may depend on a foreign module's `application` when an explicit dependency exists. Never imports infrastructure or delivery.
- infrastructure: depends on domain + core + (foreign) application. Implements domain repository interfaces. Never imports delivery.
- delivery (UI/controllers): depends on application + domain *types* + core + a shared UI layer. Never imports infrastructure.
- No feature imports another feature's `domain` or `infrastructure`, even via relative paths. Cross-feature only via a consumer-owned domain port wired at the composition root.

## Report format

```
VIOLATION: <file> -> <rule> -> <fix>
```

Zero violations is the bar.

## Composition root

After boundaries pass, confirm the DI container resolves every declared token. See the `wire-dependencies` skill for composition-root validation.
