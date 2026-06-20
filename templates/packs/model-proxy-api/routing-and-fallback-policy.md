# Routing And Fallback Policy

Routing should be explicit and testable.

Common routing inputs:

- Requested capability.
- Preferred provider or model.
- Stable model alias or task intent.
- Tenant, project, user, or environment.
- Provider health, latency, rate limits, and cost.
- Fallback chain.

Fallback behavior must define:

- Which errors are retryable.
- Timeout and retry limits.
- Which quota, rate-limit, overload, or provider outage signals trigger model
  failover.
- Whether streaming can fall back after partial output.
- How usage and cost are reported after fallback.
- Whether the original request is safe to retry.
- Whether fallback can cross provider, model family, quality tier, cost class,
  or data-residency boundary.

Do not silently change model quality, capability, data residency, or cost class
without a clear routing rule or approval.

Prefer explicit ordered chains for routine failover, such as
`coding-strong -> coding-fast -> general-chat`, and test them with simulated
429, timeout, and provider error responses.
