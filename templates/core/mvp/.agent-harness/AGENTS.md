# Agent Harness

## Mission

This repository uses the AI Agent Engineering Framework.

The repository is the source of truth. Do not rely on memory when repository
documentation, source code, tests, or configuration can answer the question.

## Required Workflow

For non-trivial engineering tasks:

1. Clarify ambiguous requirements before implementation.
2. Read the relevant source, tests, docs, and harness files.
3. Create a short implementation plan.
4. Ask for user approval before writing or modifying code, tests, generated
   artifacts, configuration, or project documentation.
5. Add or update tests for behavior changes after approval is granted.
6. Make small, scoped changes.
7. Review the diff.
8. Run verification before claiming completion.
9. Update progress or handoff notes for long-running work.

## Code Change Approval Gate

Investigation, reading files, searching the repository, and drafting a plan are
allowed before approval.

Before changing source code, tests, configuration, generated artifacts, or
project documentation, stop and ask the user to approve the implementation.
End the response with:

- `Recommendation: proceed` when the change should be implemented.
- `Recommendation: do not proceed` when the change is risky, unnecessary, or
  blocked by missing information.
- `Awaiting your approval before making code changes.`

Do not make the change until the user clearly approves it. If the user already
gave explicit approval in the same request, continue without asking again unless
the planned change expands beyond that approval.

## Framework Map

- Workflows and skills: `.agent-harness/superpowers/`
- Instructions and controls: `.agent-harness/harness/`
- External tool permissions: `.agent-harness/mcp/`
- Installed stack or architecture packs: `.agent-harness/packs/`
- Progress and handoff state: `.agent-harness/progress/`
- Verification commands: `.agent-harness/scripts/`

## Installed Packs

When a task touches a stack, framework, or architecture covered by an installed
pack, read that pack before planning or editing.

Start with:

```text
.agent-harness/packs/<pack-name>/README.md
.agent-harness/packs/<pack-name>/context.md
```

Pack instructions extend the core harness. If a pack conflicts with repository
source code, tests, or explicit user requirements, treat the repository and user
requirements as the source of truth.

## Verification

Before claiming completion, run the project verification script:

```bash
./.agent-harness/scripts/verify.sh
```

On Windows:

```powershell
.\.agent-harness\scripts\verify.ps1
```

## Approval Required

Ask for approval before:

- Writing or modifying code, tests, configuration, generated artifacts, or
  project documentation.
- Adding dependencies.
- Changing public APIs.
- Running database migrations.
- Deploying to production.
- Touching secrets or credentials.
- Performing large refactors.
- Deleting files.

## Completion Format

Final responses should include:

- Summary.
- Files changed.
- Tests or checks run.
- Verification result.
- Known risks or follow-up notes.
