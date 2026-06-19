---
name: create-infrastructure
description: Implement a repository interface with a real adapter plus an in-memory adapter, mapping external shapes to domain; centralize pagination and rate-limit/backoff in a shared gateway. Use when connecting a feature to real or fixture data.
---

# create-infrastructure

The infrastructure layer implements the domain repository interfaces. It depends on domain + core + (foreign) application; it never imports delivery/UI. Its single job: talk to an external source and map that source's shapes to your domain types.

## Rules

- One adapter per external source, plus one in-memory adapter. Example (illustrative): `orders.api-repository.ts`, `orders.db-repository.ts`, and `orders.in-memory-repository.ts`.
- The in-memory adapter is seeded from object mothers / fixtures, so the feature can run on fixture data with no network.
- Live adapters receive an injected gateway/client via the constructor. Never call raw `fetch` or an SDK inline inside the adapter.
- Each adapter exposes a static DI id (for example `static readonly ID`) so the container can resolve it.
- Map external shapes to domain INSIDE the adapter and nowhere else. All source-schema knowledge (field names, encodings, units, pagination cursors) lives here. The rest of the codebase only sees domain types.
- No domain logic and no UI in adapters.

## Mapping (where external becomes domain)

Convert every external field into its domain type at the adapter boundary. Illustrative examples:

- A raw number representing money -> your domain `Money` value object (normalize units, for example to integer minor units).
- A raw date/timestamp string -> your domain date/time value object (normalize timezone).
- An external enum/string -> your domain union or value object.
- Deduplicate on a stable external id when one is present.

Downstream code (use cases, delivery) must never see the external shape.

## Shared gateway

Centralize pagination and rate-limit/backoff in a shared gateway, and keep all source-schema knowledge in the adapter. The gateway is generic transport (paging through results, honoring rate limits, retrying with backoff on throttling responses); the adapter is the only place that knows what the data means. Inject the gateway into the live adapter; never construct transport inline.

## Wiring (framework-agnostic pseudocode)

Choose the adapter by mode (live vs fixture), then register it behind the repository interface and register any use cases that depend on it. See `wire-dependencies` for the mode-resolution precedence and container API.

```text
function registerOrders(container, { env }):
    mode = resolveMode("orders-source", env)        # per-source: live or fixture
    repo = mode == "live"
        ? new OrdersApiRepository(container.get(GATEWAY_ID), sourceConfig)
        : new OrdersInMemoryRepository()            # seeded from fixtures
    container.registerWithKey(ORDERS_REPOSITORY, repo)
    container.register(new GetOrders(container.getWithKey(ORDERS_REPOSITORY)))
```

The interface (`ORDERS_REPOSITORY` above) is defined by the domain. See `create-repository-contract`.

## Testing

Unit-test the mapping against captured-shape fixtures: snapshot a real external response once, then assert the adapter maps it to the expected domain object. No live HTTP in tests.
