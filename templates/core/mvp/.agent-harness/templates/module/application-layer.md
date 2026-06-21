# Application Layer

The application layer coordinates use cases and turns user intent into domain
operations.

## Include

- Use cases.
- Application services.
- Transaction boundaries.
- Authorization checks when they belong to use case policy.

## Avoid

- UI rendering.
- Direct framework coupling when a local abstraction already exists.
- Hidden business rules that should live in the domain layer.

## Checklist

- Each use case has a clear input and output.
- Side effects are explicit.
- Error paths are testable.
