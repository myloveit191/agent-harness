# Infrastructure Layer

The infrastructure layer adapts the application and domain layers to databases,
external APIs, files, queues, and other outside systems.

## Include

- Repository implementations.
- External service clients.
- Mappers.
- Persistence-specific configuration.

## Avoid

- Product decisions.
- Domain rules that are not infrastructure concerns.

## Checklist

- External failures are handled deliberately.
- Data mapping is explicit.
- Secrets and credentials are not hardcoded.
