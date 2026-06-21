# Domain Layer

The domain layer owns business concepts and rules. It should not depend on UI,
transport, database, or external service details.

## Include

- Entities.
- Value objects.
- Domain services.
- Domain rules.

## Avoid

- Framework-specific code.
- Database queries.
- HTTP or UI concerns.

## Checklist

- Core concepts are named in domain language.
- Rules are testable without infrastructure.
- Dependencies point inward.
