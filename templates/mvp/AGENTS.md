# AGENTS.md

## Mission

This repository uses the AI Agent Engineering Framework.

The repository is the source of truth. Do not rely on memory when repository
documentation, source code, tests, or configuration can answer the question.

## Required Workflow

For non-trivial engineering tasks:

1. Clarify ambiguous requirements before implementation.
2. Read the relevant source, tests, docs, and harness files.
3. Create a short implementation plan.
4. Add or update tests for behavior changes.
5. Make small, scoped changes.
6. Review the diff.
7. Run verification before claiming completion.
8. Update progress or handoff notes for long-running work.

## Framework Map

- Workflows and skills: `.superpowers/`
- Instructions and controls: `.harness/`
- External tool permissions: `.mcp/`
- Progress and handoff state: `progress/`
- Verification commands: `scripts/`

## Verification

Before claiming completion, run the project verification script:

```bash
./scripts/verify.sh
```

On Windows:

```powershell
.\scripts\verify.ps1
```

## Approval Required

Ask for approval before:

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

