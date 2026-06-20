# Architecture Policy

Keep the proxy architecture layered:

- Public API layer: validates input, authenticates callers, and returns the
  unified response shape.
- Routing layer: selects provider/model using policy, capability, health,
  tenant, cost, latency, or fallback rules.
- Model registry layer: stores stable aliases, concrete provider model IDs,
  capability metadata, limits, and compatibility notes.
- Provider adapter layer: translates unified requests and responses to provider
  APIs.
- Observability layer: records redacted request metadata, provider choice,
  latency, token usage, cost estimates, fallback, and error class.

Avoid mixing provider-specific API details into controllers, route handlers,
prompts, public DTOs, or business logic. Adding or switching a provider should
usually mean adding or changing an adapter, registry entry, tests, and routing
configuration.
