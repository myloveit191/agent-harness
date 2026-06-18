#!/usr/bin/env bash
set -euo pipefail

PROFILE="mvp"
TARGET_DIR="$PWD"
FORCE=0
YES=0
REPO_URL="${AGENT_HARNESS_REPO:-https://github.com/myloveit191/agent-harness}"
REF="${AGENT_HARNESS_REF:-main}"
VERSION="0.2.0"
PACKS=()
ORIGINAL_ARG_COUNT="$#"

if [ -x "/usr/bin/find" ]; then
  FIND_BIN="/usr/bin/find"
else
  FIND_BIN="find"
fi

usage() {
  cat <<'EOF'
agent-harness installer

Usage:
  bash install.sh [--profile mvp|full] [--pack NAME] [--target DIR] [--force]

Options:
  --profile   Template profile to install. Defaults to mvp.
  --pack      Stack or architecture pack to install. Can be repeated.
  --target    Directory to install into. Defaults to current directory.
  --force     Back up and overwrite existing files.
  --yes       Skip final confirmation in scripted usage.
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
    --pack)
      PACKS+=("${2:-}")
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --yes)
      YES=1
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

copy_pack() {
  local templates_dir="$1"
  local pack_name="$2"
  local target_dir="$3"
  local timestamp="$4"
  local source_dir="$templates_dir/packs/$pack_name"
  local destination_dir="$target_dir/.agent-harness/packs/$pack_name"

  if [ ! -d "$source_dir" ]; then
    echo "Pack does not exist: $pack_name" >&2
    exit 1
  fi

  copy_profile "$source_dir" "$destination_dir" "$timestamp"
}

json_pack_array() {
  local first=1
  printf '['
  for pack in "${PACKS[@]}"; do
    if [ "$first" -eq 0 ]; then
      printf ', '
    fi
    printf '"%s"' "$pack"
    first=0
  done
  printf ']'
}

pack_list_text() {
  local first=1
  if [ "${#PACKS[@]}" -eq 0 ]; then
    printf 'none'
    return
  fi

  for pack in "${PACKS[@]}"; do
    if [ "$first" -eq 0 ]; then
      printf ', '
    fi
    printf '%s' "$pack"
    first=0
  done
}

tty_print() {
  printf '%s\n' "$*" > /dev/tty
}

tty_prompt() {
  local prompt="$1"
  local answer
  printf '%s' "$prompt" > /dev/tty
  IFS= read -r answer < /dev/tty || answer=""
  printf '%s' "$answer"
}

available_pack_names() {
  local packs_dir="$TEMPLATES_DIR/packs"
  if [ ! -d "$packs_dir" ]; then
    return
  fi

  for pack_dir in "$packs_dir"/*; do
    if [ -d "$pack_dir" ]; then
      basename "$pack_dir"
    fi
  done | sort
}

run_interactive_config() {
  if [ "$ORIGINAL_ARG_COUNT" -ne 0 ] || [ ! -r /dev/tty ]; then
    return
  fi

  tty_print ""
  tty_print "Agent Harness Installer $VERSION"
  tty_print ""
  tty_print "Choose profile:"
  tty_print "  1) mvp  (recommended)"
  tty_print "  2) full"
  profile_answer="$(tty_prompt "Profile [1]: ")"
  case "$profile_answer" in
    2|full|Full|FULL) PROFILE="full" ;;
    *) PROFILE="mvp" ;;
  esac

  available_packs=()
  while IFS= read -r pack_name; do
    available_packs+=("$pack_name")
  done < <(available_pack_names)
  PACKS=()
  if [ "${#available_packs[@]}" -gt 0 ]; then
    tty_print ""
    tty_print "Choose packs. Enter numbers or names separated by commas, or leave empty for none:"
    local index=1
    for pack in "${available_packs[@]}"; do
      tty_print "  $index) $pack"
      index=$((index + 1))
    done

    packs_answer="$(tty_prompt "Packs [none]: ")"
    if [ -n "$packs_answer" ]; then
      old_ifs="$IFS"
      IFS=','
      read -ra requested_packs <<< "$packs_answer"
      IFS="$old_ifs"

      for requested in "${requested_packs[@]}"; do
        requested="$(printf '%s' "$requested" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        if [ -z "$requested" ]; then
          continue
        fi

        if [[ "$requested" =~ ^[0-9]+$ ]] && [ "$requested" -ge 1 ] && [ "$requested" -le "${#available_packs[@]}" ]; then
          PACKS+=("${available_packs[$((requested - 1))]}")
        else
          PACKS+=("$requested")
        fi
      done
    fi
  fi

  tty_print ""
  target_answer="$(tty_prompt "Target directory [$TARGET_DIR]: ")"
  if [ -n "$target_answer" ]; then
    TARGET_DIR="$target_answer"
  fi

  if [ -e "$TARGET_DIR/AGENTS.md" ] || [ -e "$TARGET_DIR/.agent-harness" ]; then
    tty_print ""
    tty_print "Existing agent-harness files were found in the target."
    overwrite_answer="$(tty_prompt "Back up and overwrite existing files? [y/N]: ")"
    case "$overwrite_answer" in
      y|Y|yes|YES) FORCE=1 ;;
      *) FORCE=0 ;;
    esac
  fi

  tty_print ""
  tty_print "Install summary:"
  tty_print "  Profile: $PROFILE"
  tty_print "  Packs:   $(pack_list_text)"
  tty_print "  Target:  $TARGET_DIR"
  if [ "$FORCE" -eq 1 ]; then
    tty_print "  Force:   backup and overwrite"
  else
    tty_print "  Force:   no"
  fi

  if [ "$YES" -ne 1 ]; then
    confirm_answer="$(tty_prompt "Continue? [Y/n]: ")"
    case "$confirm_answer" in
      n|N|no|NO)
        tty_print "Install cancelled."
        exit 0
        ;;
    esac
  fi
}

write_metadata() {
  local target_dir="$1"
  local timestamp="$2"
  local metadata_path="$target_dir/.agent-harness/agent-harness.json"
  local installed_at
  installed_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local packs_json
  packs_json="$(json_pack_array)"

  mkdir -p "$(dirname "$metadata_path")"

  if [ -e "$metadata_path" ]; then
    if [ "$FORCE" -ne 1 ]; then
      echo "Refusing to overwrite existing file: $metadata_path" >&2
      echo "Re-run with --force to back it up and replace it." >&2
      exit 1
    fi
    backup_path="$metadata_path.backup.$timestamp"
    cp -p "$metadata_path" "$backup_path"
    echo "Backed up $metadata_path -> $backup_path"
  fi

  cat > "$metadata_path" <<EOF
{
  "version": "$VERSION",
  "profile": "$PROFILE",
  "layout": "nested",
  "packs": $packs_json,
  "installedAt": "$installed_at"
}
EOF
}

TEMPLATES_DIR="$(resolve_templates_dir)"
run_interactive_config

if [ "$PROFILE" != "mvp" ] && [ "$PROFILE" != "full" ]; then
  echo "Invalid profile: $PROFILE. Expected mvp or full." >&2
  exit 1
fi

if [ -z "$TARGET_DIR" ]; then
  echo "Target directory cannot be empty." >&2
  exit 1
fi

for pack in "${PACKS[@]}"; do
  if ! [[ "$pack" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
    echo "Invalid pack name: $pack. Use lowercase letters, numbers, and hyphens." >&2
    exit 1
  fi
done

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

TIMESTAMP="$(date +%Y%m%d%H%M%S)"

for pack in "${PACKS[@]}"; do
  if [ ! -d "$TEMPLATES_DIR/packs/$pack" ]; then
    echo "Pack does not exist: $pack" >&2
    exit 1
  fi
done

copy_profile "$TEMPLATES_DIR/core/mvp" "$TARGET_DIR" "$TIMESTAMP"
if [ "$PROFILE" = "full" ]; then
  copy_profile "$TEMPLATES_DIR/core/full" "$TARGET_DIR" "$TIMESTAMP"
fi

for pack in "${PACKS[@]}"; do
  copy_pack "$TEMPLATES_DIR" "$pack" "$TARGET_DIR" "$TIMESTAMP"
done

write_metadata "$TARGET_DIR" "$TIMESTAMP"

chmod +x "$TARGET_DIR/.agent-harness/scripts/verify.sh" 2>/dev/null || true

cat <<EOF

agent-harness installed.

Profile: $PROFILE
Packs:   $(pack_list_text)
Target:  $TARGET_DIR

Next steps:
  1. Review AGENTS.md.
  2. Customize .agent-harness/harness/instructions/context-map.md.
  3. Run verification:
     ./.agent-harness/scripts/verify.sh

EOF
