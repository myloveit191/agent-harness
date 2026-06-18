# Model Proxy API Pack

Use this pack for services that proxy requests to multiple model providers and
expose one stable API to applications.

Read these files before changing provider routing, request/response mapping,
security, observability, streaming, fallback, or cost-sensitive behavior:

- `context.md`
- `architecture-policy.md`
- `provider-adapter-policy.md`
- `routing-and-fallback-policy.md`
- `security-policy.md`
- `observability-policy.md`
- `verification-policy.md`

Core principle: provider-specific behavior belongs behind adapters. The public
API should stay stable even when providers, models, routing rules, or fallback
chains change.

