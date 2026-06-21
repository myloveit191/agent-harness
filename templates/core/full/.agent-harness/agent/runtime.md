# Agent Runtime

Describe how agents are routed, how context is selected, and which policies
apply before tool use.

## Runtime Order

For non-trivial work:

1. Read `.agent-harness/AGENTS.md`.
2. Read `.agent-harness/workflows/lifecycle.md`.
3. Identify the current lifecycle stage.
4. Read the matching files under `.agent-harness/project/`.
5. Read the matching gate under `.agent-harness/gates/`.
6. Read any relevant specs, plans, packs, source code, tests, and docs.
7. Decide whether the task needs a new spec or plan.
8. Identify the verification method before implementation.
9. Follow the approval and verification gates from the core harness.

## Context Selection

Prefer durable context in this order:

1. Explicit user request.
2. Repository source, tests, config, and docs.
3. `.agent-harness/project/` product memory.
4. Active specs in `.agent-harness/specs/active/`.
5. Active plans in `.agent-harness/plans/active/`.
6. Gates in `.agent-harness/gates/`.
7. Installed packs in `.agent-harness/packs/`.
8. Progress and handoff notes.

## When To Create A Spec

Create a spec for changes that affect product behavior, architecture,
cross-module contracts, release scope, growth bets, or user-facing workflows.

Small bug fixes and narrow implementation tasks can use a short plan instead.

## When To Create A Plan

Create a plan for multi-step implementation, long-running work, or work that
will span sessions. Link the plan to the relevant lifecycle stage and spec when
one exists.

## Before Implementation

The agent must identify:

- Current lifecycle stage.
- Relevant project memory files.
- Required stage gate.
- Whether a spec or plan is needed.
- Verification method.
