#!/usr/bin/env bash
set -euo pipefail

PROFILE="mvp"
TARGET_DIR="$PWD"
FORCE=0
REPO_URL="${AGENT_HARNESS_REPO:-https://github.com/myloveit191/agent-harness}"
REF="${AGENT_HARNESS_REF:-main}"

if [ -x "/usr/bin/find" ]; then
  FIND_BIN="/usr/bin/find"
else
  FIND_BIN="find"
fi

usage() {
  cat <<'EOF'
agent-harness installer

Usage:
  bash install.sh [--profile mvp|full] [--target DIR] [--force]

Options:
  --profile   Template profile to install. Defaults to mvp.
  --target    Directory to install into. Defaults to current directory.
  --force     Back up and overwrite existing files.
  -h, --help  Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    --target)
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ "$PROFILE" != "mvp" ] && [ "$PROFILE" != "full" ]; then
  echo "Invalid profile: $PROFILE. Expected mvp or full." >&2
  exit 1
fi

if [ -z "$TARGET_DIR" ]; then
  echo "Target directory cannot be empty." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd || true)"
TEMP_DIR=""

cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

resolve_templates_dir() {
  if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ] && [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/install.sh" ] && [ -d "$SCRIPT_DIR/templates" ]; then
    printf '%s\n' "$SCRIPT_DIR/templates"
    return 0
  fi

  TEMP_DIR="$(mktemp -d)"
  ARCHIVE="$TEMP_DIR/agent-harness.tar.gz"

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required when templates are not available locally." >&2
    return 1
  fi

  echo "Downloading templates from $REPO_URL ($REF)..."
  curl -fsSL "$REPO_URL/archive/refs/heads/$REF.tar.gz" -o "$ARCHIVE"
  tar -xzf "$ARCHIVE" -C "$TEMP_DIR"

  FOUND="$("$FIND_BIN" "$TEMP_DIR" -type d -path '*/templates' | head -n 1)"
  if [ -z "$FOUND" ]; then
    echo "Could not find templates directory in downloaded archive." >&2
    return 1
  fi

  printf '%s\n' "$FOUND"
}

copy_profile() {
  local source_dir="$1"
  local target_dir="$2"
  local timestamp="$3"

  if [ ! -d "$source_dir" ]; then
    echo "Template profile does not exist: $source_dir" >&2
    exit 1
  fi

  while IFS= read -r dir_path; do
    rel_path="${dir_path#$source_dir/}"
    if [ "$rel_path" = "$dir_path" ]; then
      continue
    fi
    mkdir -p "$target_dir/$rel_path"
  done < <("$FIND_BIN" "$source_dir" -type d)

  while IFS= read -r file_path; do
    rel_path="${file_path#$source_dir/}"
    dest_path="$target_dir/$rel_path"
    mkdir -p "$(dirname "$dest_path")"

    if [ -e "$dest_path" ]; then
      if [ "$FORCE" -ne 1 ]; then
        echo "Refusing to overwrite existing file: $dest_path" >&2
        echo "Re-run with --force to back it up and replace it." >&2
        exit 1
      fi
      backup_path="$dest_path.backup.$timestamp"
      cp -p "$dest_path" "$backup_path"
      echo "Backed up $dest_path -> $backup_path"
    fi

    cp -p "$file_path" "$dest_path"
  done < <("$FIND_BIN" "$source_dir" -type f)
}

TEMPLATES_DIR="$(resolve_templates_dir)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

copy_profile "$TEMPLATES_DIR/mvp" "$TARGET_DIR" "$TIMESTAMP"
if [ "$PROFILE" = "full" ]; then
  copy_profile "$TEMPLATES_DIR/full" "$TARGET_DIR" "$TIMESTAMP"
fi

chmod +x "$TARGET_DIR/.agent-harness/scripts/verify.sh" 2>/dev/null || true

cat <<EOF

agent-harness installed.

Profile: $PROFILE
Target:  $TARGET_DIR

Next steps:
  1. Review AGENTS.md.
  2. Customize .agent-harness/harness/instructions/context-map.md.
  3. Run verification:
     ./.agent-harness/scripts/verify.sh

EOF
