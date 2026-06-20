# Next.js Pack

Use this pack when the repository is a Next.js application or contains a
Next.js app inside a workspace.

Start here:

1. `context.md`
2. `routing-policy.md`
3. `rendering-and-data-policy.md`
4. `server-client-boundary-policy.md`
5. `styling-and-ui-policy.md`
6. `security-policy.md`
7. `performance-policy.md`
8. `verification-policy.md`

## Agent Priorities

- Treat the repository configuration as the source of truth.
- Identify whether the app uses the App Router, Pages Router, or both before
  changing routes, layouts, data loading, or metadata.
- Preserve server/client component boundaries unless the task explicitly
  requires changing them.
- Prefer framework-native APIs and existing project conventions.
- Verify with lint, typecheck, tests, and a production build when available.

## Read First

Inspect these files and directories when they exist:

```text
package.json
next.config.js
next.config.mjs
next.config.ts
app/
pages/
src/app/
src/pages/
components/
src/components/
middleware.ts
middleware.js
public/
```

In monorepos, first find the package that owns the Next.js app, then run all
commands from that package unless the workspace defines root-level scripts.

## Common Tasks

- New route or page: read the router policy first.
- Data fetching, caching, or revalidation: read the rendering and data policy.
- Browser-only behavior: read the server/client boundary policy.
- Visual work: read the styling and UI policy.
- Auth, middleware, cookies, headers, or env vars: read the security policy.
- Bundle size, images, fonts, or runtime behavior: read the performance policy.
- Completion: read the verification policy.
