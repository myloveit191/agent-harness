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

- `mvp`: default, minimal framework for real projects.
- `full`: installs the MVP files plus a small scaffold for teams that want to
  grow toward a production internal framework.

## Core And Packs

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

Install metadata is written to:

```text
.agent-harness/agent-harness.json
```

The installed framework is centered on five operating rules:

1. The repository is the source of truth.
2. Ambiguous tasks must be clarified before implementation.
3. Behavior changes need tests.
4. Completion requires verification.
5. Risky actions require approval.
