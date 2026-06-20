#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"
TEST_ROOT="$(mktemp -d /tmp/agent-harness-tests.XXXXXX)"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_file() {
  local path="$1"
  [ -f "$path" ] || fail "missing file: $path"
}

assert_dir() {
  local path="$1"
  [ -d "$path" ] || fail "missing directory: $path"
}

assert_grep() {
  local pattern="$1"
  local path="$2"
  grep -q "$pattern" "$path" || fail "expected pattern '$pattern' in $path"
}

assert_not_exists() {
  local path="$1"
  [ ! -e "$path" ] || fail "expected path not to exist: $path"
}

run_expect_fail() {
  local output="$1"
  shift

  if "$@" >"$output" 2>&1; then
    fail "command unexpectedly succeeded: $*"
  fi
}

bash -n "$INSTALL_SH"
pass "install.sh syntax"

MVP_TARGET="$TEST_ROOT/mvp"
bash "$INSTALL_SH" --target "$MVP_TARGET" --profile mvp --yes >"$TEST_ROOT/mvp.out"
assert_file "$MVP_TARGET/AGENTS.md"
assert_file "$MVP_TARGET/.agent-harness/AGENTS.md"
assert_file "$MVP_TARGET/.agent-harness/agent-harness.json"
assert_file "$MVP_TARGET/.agent-harness/scripts/verify.sh"
assert_file "$MVP_TARGET/.agent-harness/scripts/verify.ps1"
assert_grep '"packs": \[\]' "$MVP_TARGET/.agent-harness/agent-harness.json"
pass "mvp install"

(cd "$MVP_TARGET" && ./.agent-harness/scripts/verify.sh >"$TEST_ROOT/verify.out")
assert_grep "Verification completed." "$TEST_ROOT/verify.out"
pass "installed verification script"

bash "$INSTALL_SH" --check --target "$MVP_TARGET" >"$TEST_ROOT/check.out"
assert_grep "Check passed." "$TEST_ROOT/check.out"
pass "check installed mvp"

BROKEN_TARGET="$TEST_ROOT/broken"
cp -R "$MVP_TARGET" "$BROKEN_TARGET"
rm "$BROKEN_TARGET/.agent-harness/agent-harness.json"
run_expect_fail "$TEST_ROOT/check-broken.out" bash "$INSTALL_SH" --check --target "$BROKEN_TARGET"
assert_grep "Check failed." "$TEST_ROOT/check-broken.out"
pass "check fails for missing metadata"

FULL_TARGET="$TEST_ROOT/full"
bash "$INSTALL_SH" --target "$FULL_TARGET" --profile full --yes >"$TEST_ROOT/full.out"
assert_file "$FULL_TARGET/.agent-harness/README.md"
assert_file "$FULL_TARGET/.agent-harness/agent/router/task-router.md"
pass "full install"

PACK_TARGET="$TEST_ROOT/pack"
bash "$INSTALL_SH" --target "$PACK_TARGET" --profile mvp --pack model-proxy-api --yes >"$TEST_ROOT/pack.out"
assert_file "$PACK_TARGET/.agent-harness/packs/model-proxy-api/README.md"
assert_grep '"packs": \["model-proxy-api"\]' "$PACK_TARGET/.agent-harness/agent-harness.json"
bash "$INSTALL_SH" --check --target "$PACK_TARGET" >"$TEST_ROOT/check-pack.out"
assert_grep "installed pack model-proxy-api" "$TEST_ROOT/check-pack.out"
pass "pack install and check"

DRY_TARGET="$TEST_ROOT/dry-run-target"
bash "$INSTALL_SH" --dry-run --target "$DRY_TARGET" --profile mvp --yes >"$TEST_ROOT/dry-run.out"
assert_grep "CREATE" "$TEST_ROOT/dry-run.out"
assert_not_exists "$DRY_TARGET"
pass "dry-run does not create target"

bash "$INSTALL_SH" --dry-run --target "$MVP_TARGET" --profile mvp --yes >"$TEST_ROOT/dry-run-existing.out"
assert_grep "WOULD FAIL" "$TEST_ROOT/dry-run-existing.out"
bash "$INSTALL_SH" --dry-run --target "$MVP_TARGET" --profile mvp --force --yes >"$TEST_ROOT/dry-run-force.out"
assert_grep "BACKUP+OVERWRITE" "$TEST_ROOT/dry-run-force.out"
pass "dry-run overwrite reporting"

run_expect_fail "$TEST_ROOT/invalid-pack.out" bash "$INSTALL_SH" --target "$TEST_ROOT/invalid-pack" --pack ModelProxy --yes
assert_grep "Invalid pack name: ModelProxy" "$TEST_ROOT/invalid-pack.out"
pass "invalid pack name fails"

run_expect_fail "$TEST_ROOT/missing-pack.out" bash "$INSTALL_SH" --target "$TEST_ROOT/missing-pack" --pack missing-pack --yes
assert_grep "Pack does not exist: missing-pack" "$TEST_ROOT/missing-pack.out"
pass "missing pack fails"

run_expect_fail "$TEST_ROOT/no-force.out" bash "$INSTALL_SH" --target "$MVP_TARGET" --profile mvp --yes
assert_grep "Refusing to overwrite existing file" "$TEST_ROOT/no-force.out"
pass "no-force overwrite fails"

bash "$INSTALL_SH" --target "$MVP_TARGET" --profile mvp --force --yes >"$TEST_ROOT/force.out"
find "$MVP_TARGET" -name '*.backup.*' -print | grep -q .
pass "force overwrite creates backups"

printf 'All install tests passed.\n'
