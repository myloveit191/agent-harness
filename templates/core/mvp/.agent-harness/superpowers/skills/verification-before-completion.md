# Verification Before Completion

Do not claim completion until verification has run or the reason it could not
run is clearly stated.

Prefer this order:

1. Targeted tests for changed behavior.
2. Typecheck or static checks.
3. Lint.
4. Build.
5. Full verification script.

If verification fails, either fix the issue or report the failure plainly.
