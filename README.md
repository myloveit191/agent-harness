# agent-harness

Universal AI Agent Engineering Framework installer for any repository.

`agent-harness` installs a lightweight core plus optional stack or architecture
packs into an existing project. The default core is intentionally small: enough
structure to make an AI agent work with context, limits, verification, and
handoff without turning the repository into a documentation maze.

## Install

Run without options for an interactive install. The installer will ask for the
profile, packs, target directory, overwrite behavior, and final confirmation.

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.sh | bash
```

macOS / Linux with options:

```bash
curl -fsSL https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.sh | bash -s -- --profile mvp
```

macOS / Linux with a pack:

```bash
curl -fsSL https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.sh | bash -s -- --pack nextjs
```

macOS / Linux with multiple packs once more packs are added:

```bash
curl -fsSL https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.sh | bash -s -- --pack pack-one --pack pack-two
```

Check an existing install:

```bash
bash install.sh --check --target /path/to/project
```

Preview changes without writing files:

```bash
bash install.sh --dry-run --target /path/to/project --pack nextjs
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.ps1 | iex
```

Pass options for non-interactive installs:

```powershell
iex "& { $(irm https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.ps1) } -Profile mvp"
```

Windows PowerShell with a pack:

```powershell
iex "& { $(irm https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.ps1) } -Pack nextjs"
```

Windows PowerShell with multiple packs once more packs are added:

```powershell
iex "& { $(irm https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.ps1) } -Pack pack-one,pack-two"
```

Check an existing install:

```powershell
.\install.ps1 -Check -Target C:\path\to\project
```

Preview changes without writing files:

```powershell
.\install.ps1 -DryRun -Target C:\path\to\project -Pack nextjs
```

## Local Test

From this repository:

```bash
bash install.sh --target /path/to/project --profile mvp
```

```powershell
.\install.ps1 -Target C:\path\to\project -Profile mvp
```

Local test with a pack:

```bash
bash install.sh --target /path/to/project --pack nextjs
```

```powershell
.\install.ps1 -Target C:\path\to\project -Pack nextjs
```

Run the installer test harness:

```bash
./scripts/test-install.sh
```

## Profiles

- `mvp`: default lightweight operating harness for real projects. It gives an
  agent lifecycle, project memory, policies, progress files, superpowers, MCP
  notes, and verification without making the root noisy.
- `full`: complete project development harness for teams or larger projects.
  It installs MVP plus agent routing, specs, plans, and evaluation checklists.

## Core, Packs, And Superpowers

Core is shared by every project. It contains the agent entrypoint, workflows,
policies, progress files, and verification scripts.

Packs add stack, framework, or architecture-specific guidance. Installed packs
live under:

```text
.agent-harness/packs/<pack-name>/
```

Included packs:

- `nextjs`: for Next.js applications, including App Router, Pages Router,
  server/client boundaries, rendering, data fetching, styling, security,
  performance, and verification guidance.

Each pack should answer:

1. What should the agent read first?
2. Which boundaries must not be broken?
3. Which verification should run?
4. What risks are common?
5. When is approval required?

Superpowers are optional skills and task workflows. Bundled and external
superpowers live under:

```text
.agent-harness/superpowers/
```

Superpowers must not override lifecycle gates, approval policy, verification
policy, tool policy, or `.agent-harness/project/` memory.

## Safety

The installer does not require a Git repository.

By default, it refuses to overwrite existing files. Use `--force` on
macOS/Linux or `-Force` on Windows to replace existing files. When force is
enabled, overwritten files are backed up with a timestamp suffix first.

Use `--yes` on macOS/Linux or `-Yes` on Windows to skip the final confirmation
when scripting installs.

## What MVP Installs

```text
AGENTS.md
.agent-harness/
```

Root `AGENTS.md` is only a small pointer. The actual framework lives under
`.agent-harness/` so the project root stays clean.

The MVP core now includes a product lifecycle harness:

```text
.agent-harness/gates/
.agent-harness/workflows/lifecycle.md
.agent-harness/project/
.agent-harness/superpowers/
```

Use `.agent-harness/workflows/lifecycle.md` as the stage map from idea to
growth. Use `.agent-harness/project/` as editable project memory for:

- idea
- discovery
- product
- architecture
- execution
- evaluation
- operations
- growth

Use `.agent-harness/gates/` to decide whether a stage should continue, adjust,
narrow, or stop.

## What Full Adds

The `full` profile installs MVP first, then adds:

```text
.agent-harness/agent/
.agent-harness/evals/
.agent-harness/plans/
.agent-harness/specs/
```

Use `full` when the project needs explicit runtime routing, specs, plans, and
agent quality checklists across multiple sessions or contributors.

Install metadata is written to:

```text
.agent-harness/agent-harness.json
```

The installed framework is centered on eight operating rules:

1. The repository is the source of truth.
2. Product work should move through idea, discovery, product, architecture,
   execution, evaluation, operations, and growth.
3. Ambiguous tasks must be clarified before implementation.
4. Code-changing actions require user approval before implementation.
5. Behavior changes need tests.
6. Completion requires verification.
7. Risky actions require approval.
8. External superpowers are optional and lower priority than harness policy.

## Examples

Filled examples live under:

```text
examples/
```

Start with `examples/blearnica/` to see how idea, discovery, product,
architecture, execution, and evaluation memory can be filled.

When an agent recommends a code change, it should present the intended action,
state whether it recommends proceeding, and wait for explicit user approval
before editing code, tests, configuration, generated artifacts, or project
documentation.
