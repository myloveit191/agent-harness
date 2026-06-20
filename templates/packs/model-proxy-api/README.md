# Model Proxy API Pack

Use this pack for projects that call AI models through a stable interface and
need to switch between providers or models quickly when the primary model hits
usage limits, rate limits, outages, cost ceilings, latency problems, or
capability gaps.

Common examples:

- Start with Codex, then fall back to Gemini when Codex usage is exhausted.
- Route coding, chat, embeddings, vision, or structured-output requests to
  different providers without rewriting application code.
- Keep prompts, tools, schemas, and response handling portable across model
  families.

Read these files before changing provider routing, request/response mapping,
security, observability, streaming, fallback, or cost-sensitive behavior:

- `context.md`
- `architecture-policy.md`
- `model-portability-policy.md`
- `provider-adapter-policy.md`
- `routing-and-fallback-policy.md`
- `security-policy.md`
- `observability-policy.md`
- `verification-policy.md`

Core principle: provider-specific behavior belongs behind adapters. The public
API should stay stable even when providers, models, routing rules, or fallback
chains change.
