# Model Portability Policy

Model changes should be routine configuration changes, not code migrations.

Before adding, removing, or switching a model, document:

- Primary model and ordered fallback models.
- Manual override method such as environment variable, config file, request
  field, or admin setting.
- Capability matrix for chat, tools, structured output, streaming, vision,
  embeddings, context window, and reasoning controls.
- Prompt compatibility notes for provider-specific system prompts, safety
  behavior, formatting quirks, and unsupported parameters.
- Tool or function-calling compatibility, including schema restrictions and
  argument parsing differences.
- Structured-output compatibility, including JSON mode, schema validation, and
  repair behavior.
- Quota, rate-limit, cost, latency, and data-residency constraints.

Keep model aliases stable. Application code should request intent-oriented
names such as `default-chat`, `coding-fast`, `coding-strong`, `embedding`, or
`vision` when the project supports them. Map those aliases to concrete provider
models in one registry or routing configuration.

When falling back across model families, verify that the replacement model can
honor the same contract. If it cannot, make the limitation explicit and either
reject the request cleanly or use a separate compatibility path.
