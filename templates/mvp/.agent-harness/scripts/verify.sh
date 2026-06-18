#!/usr/bin/env bash
set -euo pipefail

run_if_executable() {
  local command_path="$1"

  if [ -x "$command_path" ]; then
    echo "Running $command_path..."
    "$command_path"
  else
    echo "Skipping $command_path because it does not exist or is not executable."
  fi
}

run_package_script() {
  local script_name="$1"

  if [ -f "package.json" ] && command -v npm >/dev/null 2>&1; then
    if npm run | grep -E "^[[:space:]]+$script_name$" >/dev/null 2>&1; then
      echo "Running npm run $script_name..."
      npm run "$script_name"
      return
    fi
  fi

  echo "Skipping npm run $script_name because it is not available."
}

run_if_executable "./scripts/lint.sh"
run_if_executable "./scripts/typecheck.sh"
run_if_executable "./scripts/test.sh"
run_if_executable "./scripts/build.sh"

run_package_script "lint"
run_package_script "typecheck"
run_package_script "test"
run_package_script "build"

echo "Verification completed."
