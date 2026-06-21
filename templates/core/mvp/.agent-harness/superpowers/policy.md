# Superpowers Policy

Superpowers are optional capabilities. They may add techniques, checklists,
prompts, or task-specific workflows, but they must not override the harness.

## Priority

Use this order when instructions conflict:

1. Explicit user request.
2. Repository source, tests, configuration, and documentation.
3. `.agent-harness/AGENTS.md`.
4. `.agent-harness/harness/` policies.
5. `.agent-harness/workflows/lifecycle.md` and `.agent-harness/gates/`.
6. `.agent-harness/project/` memory.
7. Installed packs.
8. Bundled or external superpowers.

## Rules

- Superpowers must not bypass approval gates.
- Superpowers must not bypass verification requirements.
- Superpowers must not create a competing project memory store.
- Project decisions belong in `.agent-harness/project/`.
- External superpowers should live under `.agent-harness/superpowers/external/`.
