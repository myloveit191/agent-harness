# Provider Adapter Policy

Each provider should be isolated behind an adapter.

Adapters are responsible for:

- Mapping unified request fields to provider-specific request fields.
- Mapping provider responses back to the unified response shape.
- Mapping provider errors to stable internal error classes.
- Handling provider-specific usage, token, model, and finish-reason fields.
- Supporting or explicitly rejecting capabilities such as streaming, tools,
  vision, embeddings, and JSON output.

Do not leak provider raw responses, credentials, or provider-specific error
payloads through the public API unless the project explicitly allows it.

