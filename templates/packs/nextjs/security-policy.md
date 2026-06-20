# Security Policy

Security-sensitive Next.js work includes auth, middleware, cookies, headers,
redirects, rewrites, environment variables, server actions, route handlers, API
routes, file uploads, and third-party scripts.

## Rules

- Never expose secrets to client components or public environment variables.
- Validate request input at server boundaries.
- Preserve auth checks when moving route handlers, pages, layouts, or
  middleware.
- Use safe redirect handling; do not trust arbitrary redirect targets.
- Keep cookies, headers, and cache behavior intentional.
- Check CSRF, same-site cookie behavior, and authorization requirements for
  mutations.
- Do not log tokens, cookies, credentials, or personal data.
- Keep Content Security Policy and security headers compatible with existing
  scripts, images, and deployment requirements.

## Approval Required

Ask for approval before:

- Adding authentication providers.
- Changing session or cookie configuration.
- Making private data public or cacheable.
- Adding third-party tracking scripts.
- Changing security headers globally.
