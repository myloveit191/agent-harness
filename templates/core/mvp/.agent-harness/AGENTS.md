# Agent Harness

## Mission

This repository uses the AI Agent Engineering Framework.

The repository is the source of truth. Do not rely on memory when repository
documentation, source code, tests, or configuration can answer the question.

## Required Workflow

For non-trivial engineering tasks:

1. Locate the current lifecycle stage in `.agent-harness/workflows/`.
2. Clarify ambiguous requirements before implementation.
3. Read the relevant source, tests, docs, and harness files.
4. Create a short implementation plan.
5. Ask for user approval before writing or modifying code, tests, generated
   artifacts, configuration, or project documentation.
6. Add or update tests for behavior changes after approval is granted.
7. Make small, scoped changes.
8. Review the diff.
9. Run verification before claiming completion.
10. Update progress, decisions, or handoff notes for long-running work.

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

- Product lifecycle workflows: `.agent-harness/workflows/`
- Project memory and decisions: `.agent-harness/project/`
- External tool permissions: `.agent-harness/mcp/`
- Installed stack or architecture packs: `.agent-harness/packs/`
- Progress and handoff state: `.agent-harness/progress/`
- Verification commands: `.agent-harness/scripts/`

## Product Lifecycle

For product or project-building work, move through the lifecycle in order unless
the user explicitly asks to focus on a later stage:

1. Idea: capture the idea, problem, users, desired outcome, and timing.
2. Discovery: validate the problem with real evidence and assumptions.
3. Product: define vision, MVP scope, success criteria, and user stories.
4. Architecture: model the domain before data, API, or infrastructure choices.
5. Execution: split work into phases, tasks, and definition of done.
6. Evaluation: define tests, metrics, feedback loops, and postmortems.
7. Operations: plan deployment, monitoring, incidents, and maintenance.
8. Growth: plan expansion only after core value and operations are proven.

Use `.agent-harness/workflows/lifecycle.md` as the stage map and the files in
`.agent-harness/project/` as the editable project memory.

When moving between stages, read the matching gate in `.agent-harness/gates/`
and record the decision in the relevant project memory file.

## External Superpowers

External skills or superpowers are optional capabilities. They can add
techniques, checklists, prompts, or task-specific workflows, but they must not
override core harness policies, lifecycle gates, approval rules, verification
rules, tool policy, or `.agent-harness/project/` memory.

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
