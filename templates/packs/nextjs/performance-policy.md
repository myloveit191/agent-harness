# Performance Policy

Performance changes should improve real user experience without changing
behavior accidentally.

## Check Before Changing

- Current rendering mode and cache behavior.
- Client bundle size and large dependencies.
- Image, font, and script loading strategy.
- Route-level loading states.
- Network waterfalls caused by client-only fetching.
- Server runtime constraints.

## Rules

- Keep server-renderable UI on the server unless interactivity requires a
  client component.
- Avoid importing large libraries into shared client entry points.
- Use dynamic imports for heavy browser-only features when appropriate.
- Prefer optimized images and stable media dimensions.
- Avoid blocking global layouts with slow route-specific work.
- Keep loading states close to the route segment or component they represent.

## Verification

For performance-sensitive tasks, run the production build when available and
inspect warnings about bundle size, dynamic rendering, image optimization, and
unsupported runtime APIs.
