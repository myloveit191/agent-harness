# Full Profile Overlay

This profile installs the MVP framework plus the team and project controls
needed to run a complete project development harness.

Use `full` when the project needs explicit specs, plans, routing, quality gates,
or multi-session coordination from idea to growth.

The full profile extends, but does not replace, the MVP lifecycle:

- `.agent-harness/workflows/lifecycle.md` remains the stage map.
- `.agent-harness/project/` remains the durable product memory.
- `.agent-harness/gates/` controls stage transitions.
- `.agent-harness/specs/` stores larger change specifications.
- `.agent-harness/plans/` stores implementation plans for multi-session work.
- `.agent-harness/evals/` stores quality gates for agent work.
- `.agent-harness/agent/` stores routing and runtime rules for teams.

For product-building work, update project memory first. Use specs and plans only
when the change is too large to keep in a normal task response.
