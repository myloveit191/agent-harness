# Routing Policy

Identify the routing model before editing route files.

## App Router

Common files:

```text
app/layout.*
app/page.*
app/loading.*
app/error.*
app/not-found.*
app/route.*
app/**/page.*
app/**/layout.*
```

Rules:

- Keep layouts focused on shared shell, providers, metadata, and nested route
  structure.
- Put route-specific UI in `page.*` and route handlers in `route.*`.
- Use route groups and dynamic segments consistently with the existing tree.
- Preserve colocated loading, error, and not-found behavior when moving files.
- Check metadata exports before changing titles, descriptions, or Open Graph
  behavior.

## Pages Router

Common files:

```text
pages/_app.*
pages/_document.*
pages/index.*
pages/api/**
pages/**/[param].*
```

Rules:

- Keep `_app.*` and `_document.*` changes minimal because they affect every
  page.
- Use existing data fetching style for `getStaticProps`, `getServerSideProps`,
  and `getStaticPaths`.
- Keep API routes compatible with the runtime and request/response helpers
  already used by the project.

## Mixed Router Projects

If both routers exist:

- Determine which router owns the requested route.
- Avoid duplicating paths across routers.
- Check navigation, shared components, and middleware impacts across both
  route trees.
