# Architecture Policy

Keep the proxy architecture layered:

- Public API layer: validates input, authenticates callers, and returns the
  unified response shape.
- Routing layer: selects provider/model using policy, capability, health,
  tenant, cost, latency, or fallback rules.
- Provider adapter layer: translates unified requests and responses to provider
  APIs.
- Observability layer: records redacted request metadata, provider choice,
  latency, token usage, cost estimates, fallback, and error class.

Avoid mixing provider-specific API details into controllers, route handlers, or
public DTOs. Adding a provider should usually mean adding or changing an adapter,
registry entry, tests, and routing configuration.

