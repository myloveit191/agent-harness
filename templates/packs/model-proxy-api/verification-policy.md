# Verification Policy

When changing model proxy behavior, run the core verification script and add
targeted checks for the changed surface.

Prefer tests for:

- Provider adapter request/response mapping.
- Unified error mapping.
- Routing rule selection.
- Fallback and retry behavior.
- Capability checks such as streaming, tools, vision, embeddings, or JSON mode.
- Auth, tenant isolation, rate limits, and request size limits when touched.
- Observability fields for provider, model, latency, usage, fallback, and error
  class.

Use mock providers for deterministic tests. Live provider smoke tests should be
opt-in because they can cost money, require secrets, and produce flaky results.

