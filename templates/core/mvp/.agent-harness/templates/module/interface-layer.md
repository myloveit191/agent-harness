# Interface Layer

The interface layer exposes module behavior to users, APIs, CLIs, jobs, or
other modules.

## Include

- Controllers.
- Route handlers.
- DTOs.
- Presenters or adapters.

## Avoid

- Domain rules.
- Database access.
- Large orchestration that belongs in application services.

## Checklist

- Inputs are validated at the boundary.
- Responses match the public contract.
- Interface changes are covered by tests or documented checks.
