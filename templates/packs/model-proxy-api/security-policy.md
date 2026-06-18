# Security Policy

Model proxy APIs handle sensitive prompts, responses, credentials, and tenant
data.

Approval or extra review is required before:

- Changing authentication or authorization.
- Changing tenant isolation.
- Logging request or response bodies.
- Exposing provider raw errors.
- Touching provider API keys or secrets.
- Changing rate limits, quotas, or billing-sensitive behavior.

Default rules:

- Never log API keys or secrets.
- Redact prompts and responses unless explicit policy allows capture.
- Enforce request size limits.
- Keep provider credentials server-side.
- Return stable, sanitized errors to callers.

