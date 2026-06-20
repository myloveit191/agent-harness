# Server And Client Boundary Policy

Next.js code often crosses server and browser runtimes. Confirm the runtime
before using APIs.

## Server Code

Server code may use Node.js or framework server APIs when the configured runtime
supports them. Before adding server-only APIs, check:

- Route runtime configuration.
- Deployment target.
- Existing use of Node.js APIs, edge runtime APIs, or server actions.
- Whether the code can be imported by client components.

## Client Code

Client components are appropriate for:

- Browser events.
- Local interactive state.
- Effects.
- Browser-only APIs.
- Client-side third-party widgets.

Rules:

- Add `"use client"` only at the smallest useful boundary.
- Do not move large route trees to the client just to support one interactive
  child component.
- Do not import server-only modules, secrets, database clients, or filesystem
  code into client components.
- Guard browser globals such as `window`, `document`, and `localStorage` when
  code may run during rendering.

## Shared Components

- Keep shared components server-compatible by default.
- Split interactive controls into small client components when possible.
- Check bundle impact before adding heavy dependencies to client components.
