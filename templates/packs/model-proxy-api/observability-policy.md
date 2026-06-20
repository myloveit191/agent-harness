# Observability Policy

Model proxy changes should preserve or improve operational visibility.

Prefer structured logs and metrics for:

- Request ID or trace ID.
- Tenant or project identifier when safe.
- Selected provider and model.
- Stable model alias or routing intent.
- Capability requested.
- Latency by provider call.
- Token usage and cost estimate when available.
- Retry and fallback count.
- Fallback reason such as rate limit, quota exhausted, timeout, provider error,
  context window, or unsupported capability.
- Error class and provider status code.

Logs must be redacted by default. Do not add prompt or response body logging
without explicit approval and a retention policy.
