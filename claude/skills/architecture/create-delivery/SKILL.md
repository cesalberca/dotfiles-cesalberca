---
name: create-delivery
description: Build the delivery/UI layer that calls a use case via DI and renders from a plain DTO; secrets stay server-side. Use when rendering a feature on screen.
---

# create-delivery

The delivery layer renders a feature on screen. It calls a use case via DI and renders from a plain DTO. It never imports infrastructure.

## Boundary

- The server/composition boundary resolves a use case from the container and runs it, then passes a plain DTO to the view.
- The view layer holds only view state (toggles, local UI flags) and does NO data fetching.
- Secrets stay server-side and are never imported by client/UI code.

If the project uses RSC (for example Next.js), server components may call use cases directly; otherwise call them from the controller/loader layer (route handler, loader, resolver, BFF) and hand the result to the view.

## Server / composition side

- A single composition entry builds the container, resolves the use case, runs it, and produces a plain DTO. Illustrative:

```text
dto = container.get(GetOrdersByStatus).run({ month })
render OrdersByStatusView(data = dto)
```

- Load secrets/config from server-only environment access. Never import infrastructure, gateways, or secret config from client/UI code.

## View side

- A typed component receiving the DTO as props, for example `Component<{ data: SomeDto }>`.
- Holds only view state. No data fetching, no use-case calls beyond what the boundary already passed in.
- Per-unit loading + error states (one per card/section/widget), not a single global spinner.
- Exported via the feature's delivery entry only, so other layers cannot reach into it.

See `create-use-case` for the use case the boundary calls, and `wire-dependencies` for resolving it from the container.
