# Tool Policy

Agents may use local read, search, edit, and verification tools needed for the
task.

## Allowed By Default

- Reading files.
- Searching the repository.
- Editing files related to the task.
- Running tests, typechecks, lint, and builds.

## Approval Required

- Installing dependencies.
- Running destructive commands.
- Accessing secrets.
- Running migrations.
- Deploying or changing production systems.
- Making large cross-cutting refactors.

## Operating Rule

Use the narrowest tool that can complete the job and report any verification
that could not be run.
