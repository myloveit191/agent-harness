# Approval Policy

Ask for human approval before actions that may create security, production, or
maintenance risk.

Approval is required before:

- Adding or upgrading dependencies.
- Changing public APIs or data contracts.
- Running database migrations.
- Deploying to production.
- Reading, writing, or exposing secrets.
- Deleting files or data.
- Performing broad refactors.

When asking for approval, state the action, why it is needed, and the risk.
