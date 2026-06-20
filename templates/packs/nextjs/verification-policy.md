# Verification Policy

Use repository scripts. Do not invent commands before checking `package.json`.

## Standard Checks

Run the relevant available checks from the Next.js package or workspace root:

```bash
npm run lint
npm run typecheck
npm test
npm run build
```

Equivalent commands with `pnpm`, `yarn`, or `bun` are preferred when the
repository uses those package managers.

## How To Choose Commands

- If the repo has a lockfile or package manager field, use that package manager.
- If scripts are package-scoped in a monorepo, run the scoped command for the
  app you touched.
- If no test script exists, report that tests were unavailable.
- If build is expensive but the change affects routing, rendering, runtime,
  config, or imports, still prefer running the build.

## UI Verification

For visible UI changes:

- Run the app locally when feasible.
- Check desktop and mobile widths.
- Verify loading, empty, error, and long-content states when relevant.
- Use existing browser or end-to-end tooling when present.

## Completion

Report:

- Commands run.
- Passing and failing checks.
- Skipped checks and why.
- Any remaining risk, especially around rendering mode, caching, or deployment
  runtime.
