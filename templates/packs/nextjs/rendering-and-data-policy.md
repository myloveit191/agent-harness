# Rendering And Data Policy

Rendering mode, caching, and data fetching are user-visible behavior. Treat
changes to them as behavior changes requiring verification.

## Server Rendering And Static Generation

- Preserve existing static, dynamic, and incremental rendering behavior unless
  the task asks to change it.
- Check route-level config and framework conventions before adding dynamic
  behavior.
- Avoid accidentally making a static route dynamic by reading cookies, headers,
  search params, or uncached data in the wrong place.
- Keep data fetching close to the route or server component that owns it unless
  the repository has an established data layer.

## Client Data

- Use the project's existing client data library when one exists.
- Keep loading, empty, and error states explicit for client-fetched data.
- Avoid duplicating server-fetched data on the client unless needed for
  interactivity or freshness.

## Mutations

- Follow the existing pattern for server actions, route handlers, API routes,
  or RPC calls.
- Validate inputs at the server boundary.
- Handle success, validation failure, network failure, and authorization
  failure explicitly.
- Revalidate or invalidate cached data in the same style the project already
  uses.

## Environment

- Read environment variable usage before adding new variables.
- Use server-only environment variables for secrets.
- Only expose variables with the project's established public prefix pattern.
