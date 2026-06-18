# Routing And Fallback Policy

Routing should be explicit and testable.

Common routing inputs:

- Requested capability.
- Preferred provider or model.
- Tenant, project, user, or environment.
- Provider health, latency, rate limits, and cost.
- Fallback chain.

Fallback behavior must define:

- Which errors are retryable.
- Timeout and retry limits.
- Whether streaming can fall back after partial output.
- How usage and cost are reported after fallback.
- Whether the original request is safe to retry.

Do not silently change model quality, capability, data residency, or cost class
without a clear routing rule or approval.

