# Approval Policy

Ask for human approval before code-changing actions and before actions that may
create security, production, or maintenance risk.

Approval is required before:

- Writing or modifying source code, tests, configuration, generated artifacts,
  or project documentation.
- Adding or upgrading dependencies.
- Changing public APIs or data contracts.
- Running database migrations.
- Deploying to production.
- Reading, writing, or exposing secrets.
- Deleting files or data.
- Performing broad refactors.

When asking for approval, state the action, why it is needed, and the risk.
End with one of these recommendations:

- `Recommendation: proceed`
- `Recommendation: do not proceed`

Then state:

```text
Awaiting your approval before making code changes.
```

Do not perform the write action until the user clearly approves it. If approval
is denied or unclear, continue with read-only investigation or ask a clarifying
question.
