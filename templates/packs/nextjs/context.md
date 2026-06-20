# Next.js Context

Next.js projects can vary significantly by router, runtime, package manager,
deployment target, and styling system. Do not assume defaults from memory.

## Initial Discovery

Before planning, inspect:

- `package.json` for Next.js version, scripts, package manager, dependencies,
  test tooling, lint tooling, and workspace layout.
- `next.config.*` for output mode, redirects, rewrites, image configuration,
  experimental flags, transpiled packages, and environment assumptions.
- `app/` or `src/app/` for App Router usage.
- `pages/` or `src/pages/` for Pages Router usage.
- `middleware.*` for request-time behavior.
- `tsconfig.json`, `jsconfig.json`, and path aliases.
- Styling setup such as Tailwind, CSS Modules, Sass, PostCSS, component
  libraries, or design-system packages.
- Test setup such as Playwright, Vitest, Jest, Testing Library, Cypress, or
  Storybook.

## Boundaries

- Do not convert between App Router and Pages Router unless explicitly asked.
- Do not introduce a new state manager, CSS framework, UI kit, or data fetching
  library without approval.
- Do not change deployment output mode, runtime, or caching semantics casually.
- Do not edit generated folders such as `.next/`, `out/`, coverage output, or
  package-manager lockfiles unless the task requires it.
- Do not expose server-only values to client components.

## Planning Questions

Clarify before implementation when the task does not specify:

- Which route, layout, or package is in scope.
- Whether the change should affect desktop, mobile, or both.
- Whether behavior must work during static generation, server rendering,
  client navigation, or edge runtime.
- Which deployment target matters when configuration implies multiple targets.
