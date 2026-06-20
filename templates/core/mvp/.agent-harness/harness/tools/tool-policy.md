# Tool Policy

Agents may use local read, search, edit, and verification tools needed for the
task.

## Allowed By Default

- Reading files.
- Searching the repository.
- Inspecting diffs and repository status.
- Drafting an implementation plan.
- Running tests, typechecks, lint, and builds.

## Approval Required

- Writing or modifying source code.
- Writing or modifying tests.
- Writing or modifying project configuration.
- Writing or modifying generated artifacts.
- Writing or modifying project documentation.
- Installing dependencies.
- Running destructive commands.
- Accessing secrets.
- Running migrations.
- Deploying or changing production systems.
- Making large cross-cutting refactors.

## Operating Rule

Use the narrowest tool that can complete the job. Before write actions, present
the intended change and wait for user approval. If approval is pending, end with
a clear recommendation on whether to proceed.
