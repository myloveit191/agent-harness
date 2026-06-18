# Verification Policy

Verification is required before completion.

Run:

```bash
./scripts/verify.sh
```

On Windows:

```powershell
.\scripts\verify.ps1
```

If a project does not have lint, typecheck, test, or build commands yet, the
verification script should skip them clearly rather than fail by default.

Completion should report:

- Commands run.
- Pass/fail result.
- Any skipped checks.
- Any remaining risk.

