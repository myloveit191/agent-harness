# agent-harness Handoff

## Current State

Repository: `https://github.com/myloveit191/agent-harness`

Local workspace: `D:\harness`

`agent-harness` is now a universal AI Agent Engineering Framework installer. It
installs a clean nested layout into any project:

```text
AGENTS.md
.agent-harness/
```

Root `AGENTS.md` is only a pointer. The actual framework lives under
`.agent-harness/`.

The project currently supports:

- Core templates:
  - `templates/core/mvp`
  - `templates/core/full`
- Pack templates:
  - `templates/packs/model-proxy-api`
- Bash installer:
  - `install.sh`
- PowerShell installer:
  - `install.ps1`
- Metadata file generated on install:
  - `.agent-harness/agent-harness.json`
- Current version:
  - `0.2.0`

## Public Install Commands

Interactive install:

```bash
curl -fsSL https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.sh | bash
```

```powershell
irm https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.ps1 | iex
```

Non-interactive install with the `model-proxy-api` pack:

```bash
curl -fsSL https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.sh | bash -s -- --profile mvp --pack model-proxy-api --yes
```

```powershell
iex "& { $(irm https://raw.githubusercontent.com/myloveit191/agent-harness/main/install.ps1) } -Profile mvp -Pack model-proxy-api -Yes"
```

## Important Design Decisions

1. No flat layout.
   - The root project should stay clean.
   - Only `AGENTS.md` and `.agent-harness/` are installed at root.

2. Core and packs are separate.
   - Core is shared by every project.
   - Packs add stack, framework, or architecture-specific guidance.

3. First pack is `model-proxy-api`.
   - Chosen because the next real project is expected to be a proxy model API
     that can route across multiple model providers.

4. Installers are safe by default.
   - Existing files are not overwritten unless `--force` or `-Force` is used.
   - Forced overwrites create timestamped backups first.

5. Interactive mode is default when no options are passed.
   - It asks for profile, packs, target directory, overwrite behavior, and final
     confirmation.
   - Non-interactive mode remains available when options are passed.

## Implemented Features

### Installer

Bash:

- `--profile mvp|full`
- `--pack <name>` repeatable
- `--target <dir>`
- `--force`
- `--yes`
- Interactive prompt mode when no options are passed

PowerShell:

- `-Profile mvp|full`
- `-Pack model-proxy-api`
- `-Pack pack-one,pack-two`
- `-Target <dir>`
- `-Force`
- `-Yes`
- Interactive prompt mode when no options are passed

### Metadata

Generated at:

```text
.agent-harness/agent-harness.json
```

Example:

```json
{
  "version": "0.2.0",
  "profile": "mvp",
  "layout": "nested",
  "packs": ["model-proxy-api"],
  "installedAt": "2026-06-18T09:20:45Z"
}
```

### `model-proxy-api` Pack

Located at:

```text
templates/packs/model-proxy-api/
```

Files:

```text
README.md
context.md
architecture-policy.md
provider-adapter-policy.md
routing-and-fallback-policy.md
security-policy.md
observability-policy.md
verification-policy.md
```

Purpose:

- Guide agents working on APIs that proxy requests to multiple model providers.
- Keep provider-specific behavior behind adapters.
- Preserve a stable unified public API.
- Emphasize routing, fallback, security, observability, and deterministic tests.

## Verification Already Performed

The following scenarios were tested successfully:

- PowerShell core-only install.
- Git Bash core-only install.
- PowerShell install with `model-proxy-api`.
- Git Bash install with `model-proxy-api`.
- `full + model-proxy-api`.
- Missing pack fails cleanly.
- Mixed valid and invalid packs fail before copying partial files.
- No-force overwrite fails safely.
- Force overwrite backs up core files, pack files, and metadata.
- Verify scripts run from:
  - `.\.agent-harness\scripts\verify.ps1`
  - `./.agent-harness/scripts/verify.sh`
- Bash missing argument handling:
  - `--pack`
  - `--target`
  - `--profile`
- PowerShell invalid pack name handling.

Known limitation:

- Interactive typing itself was not fully simulated through the tool terminal,
  but non-interactive paths and parser behavior were tested. Bash interactive
  prompts read from `/dev/tty`, which is important for `curl | bash`.

## Suggested Next Roadmap

### 0.3.0

Add `check` and `dry-run`.

Recommended first task:

```text
--check / -Check
```

Check should report:

- Root `AGENTS.md` exists.
- `.agent-harness/` exists.
- `.agent-harness/AGENTS.md` exists.
- `.agent-harness/agent-harness.json` exists and is valid.
- Metadata profile and packs are readable.
- Packs listed in metadata exist under `.agent-harness/packs/`.
- Verify script exists.
- Old flat layout folders are not present at root:
  - `.harness/`
  - `.mcp/`
  - `.superpowers/`
  - `progress/`
  - `scripts/`

Then add:

```text
--dry-run / -DryRun
```

Dry-run should show which files would be created, skipped, overwritten, or
backed up without changing the target project.

### 0.4.0

Add update mode:

```text
--update / -Update
```

It should read `.agent-harness/agent-harness.json`, detect current profile and
packs, then update core and packs safely.

### 0.5.0

Add the first stack-specific pack.

Pick based on the actual implementation stack of the upcoming
`proxy-model-api` project:

- `typescript-api`
- or `spring-boot-api`

### 0.6.0

Add examples:

```text
examples/
+-- model-proxy-api/
+-- minimal-project/
+-- full-profile-project/
```

### 1.0.0

Stabilize:

- installer
- metadata
- core templates
- pack contract
- check/dry-run/update
- at least one real project example

## Changelog

### 0.2.1 Unreleased

- Hardened Bash argument validation for missing values:
  - `--pack`
  - `--target`
  - `--profile`
- Hardened PowerShell pack validation to reject uppercase or invalid pack names.

### 0.2.0

- Added core/packs architecture.
- Moved templates from:
  - `templates/mvp`
  - `templates/full`
- To:
  - `templates/core/mvp`
  - `templates/core/full`
- Added `templates/packs/model-proxy-api`.
- Added pack install support:
  - Bash `--pack <name>`
  - PowerShell `-Pack <name>`
- Added support for multiple packs.
- Added generated metadata:
  - `.agent-harness/agent-harness.json`
- Added interactive installer mode.
- Added `--yes` and `-Yes`.
- Updated README for core/packs usage.

### 0.1.1

- Switched to nested-only install layout:

```text
AGENTS.md
.agent-harness/
```

- Removed root-level framework folders from installed output.
- Updated installer output paths.
- Updated verify script paths.

### 0.1.0

- Initial `agent-harness` installer.
- Added Bash installer.
- Added PowerShell installer.
- Added MVP template.
- Added full profile overlay.
- Added safe overwrite behavior with timestamped backups.
- Added root `AGENTS.md`.
- Added verification scripts:
  - `verify.sh`
  - `verify.ps1`

## Latest Commits

```text
b2bd7d9 Harden installer argument validation
6f42901 Add interactive installer prompts
c47eb9f Add core and pack template system
d8dc6d7 Use nested agent harness layout
677a64d Initial agent harness installer
```
