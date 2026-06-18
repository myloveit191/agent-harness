# agent-harness

Universal AI Agent Engineering Framework installer for any repository.

`agent-harness` installs a lightweight set of agent instructions, workflows,
policies, progress files, and verification scripts into an existing project.
The default profile is intentionally small: enough structure to make an AI
agent work with context, limits, verification, and handoff without turning the
repository into a documentation maze.

## Install

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.sh | bash
```

macOS / Linux with options:

```bash
curl -fsSL https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.sh | bash -s -- --profile mvp
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.ps1 | iex
```

Windows PowerShell with options:

```powershell
iex "& { $(irm https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.ps1) } -Profile mvp"
```

## Local Test

From this repository:

```bash
bash install.sh --target /path/to/project --profile mvp
```

```powershell
.\install.ps1 -Target C:\path\to\project -Profile mvp
```

## Profiles

- `mvp`: default, minimal framework for real projects.
- `full`: installs the MVP files plus a small scaffold for teams that want to
  grow toward a production internal framework.

## Safety

The installer does not require a Git repository.

By default, it refuses to overwrite existing files. Use `--force` on
macOS/Linux or `-Force` on Windows to replace existing files. When force is
enabled, overwritten files are backed up with a timestamp suffix first.

## What MVP Installs

```text
AGENTS.md
.agent-harness/
```

Root `AGENTS.md` is only a small pointer. The actual framework lives under
`.agent-harness/` so the project root stays clean.

The installed framework is centered on five operating rules:

1. The repository is the source of truth.
2. Ambiguous tasks must be clarified before implementation.
3. Behavior changes need tests.
4. Completion requires verification.
5. Risky actions require approval.
