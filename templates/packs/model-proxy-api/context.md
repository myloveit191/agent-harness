# Model Proxy API Context

A model proxy API sits between applications and model providers such as OpenAI,
Anthropic, Google, Mistral, local models, or internal inference endpoints.

Before editing, identify:

- The public API contract exposed by this project.
- Supported capabilities such as chat, embeddings, vision, tool calling, JSON
  mode, streaming, or batch jobs.
- The primary model, fallback models, and manual override mechanism.
- Capability differences between model families that may affect prompts, tool
  calls, structured output, context limits, or streaming.
- Provider adapters and model registry locations.
- Routing, fallback, retry, timeout, and rate-limit behavior.
- Authentication, tenant isolation, and secret handling.
- Observability fields used for latency, tokens, cost, provider choice, and
  failures.

Do not assume provider APIs are interchangeable. Map provider-specific requests,
responses, errors, and usage fields into the project's unified contract.

Prefer model changes through configuration, registry entries, routing rules, or
adapter mappings. Avoid scattering provider or model names through business
logic, prompts, tests, or UI code.
