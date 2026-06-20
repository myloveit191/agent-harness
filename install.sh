#!/usr/bin/env bash
set -euo pipefail

PROFILE="mvp"
TARGET_DIR="$PWD"
FORCE=0
YES=0
CHECK=0
DRY_RUN=0
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
  bash install.sh --check [--target DIR]
  bash install.sh --dry-run [--profile mvp|full] [--pack NAME] [--target DIR] [--force]

Options:
  --profile   Template profile to install. Defaults to mvp.
  --pack      Stack or architecture pack to install. Can be repeated.
  --target    Directory to install into. Defaults to current directory.
  --force     Back up and overwrite existing files.
  --yes       Skip final confirmation in scripted usage.
  --check     Check an existing installation without changing files.
  --dry-run   Show planned file changes without changing files.
  -h, --help  Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      if [ "$#" -lt 2 ] || [[ "${2:-}" == --* ]]; then
        echo "Missing value for --profile. Expected mvp or full." >&2
        exit 1
      fi
      PROFILE="${2:-}"
      shift 2
      ;;
    --target)
      if [ "$#" -lt 2 ] || [[ "${2:-}" == --* ]]; then
        echo "Missing value for --target. Expected a directory path." >&2
        exit 1
      fi
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --pack)
      if [ "$#" -lt 2 ] || [[ "${2:-}" == --* ]]; then
        echo "Missing value for --pack. Expected a pack name." >&2
        exit 1
      fi
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
    --check)
      CHECK=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
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

list_profile_files() {
  local source_dir="$1"
  local destination_dir="$2"

  "$FIND_BIN" "$source_dir" -type f | while IFS= read -r file_path; do
    rel_path="${file_path#$source_dir/}"
    printf '%s\n' "$destination_dir/$rel_path"
  done
}

list_install_files() {
  local templates_dir="$1"
  local target_dir="$2"

  list_profile_files "$templates_dir/core/mvp" "$target_dir"
  if [ "$PROFILE" = "full" ]; then
    list_profile_files "$templates_dir/core/full" "$target_dir"
  fi

  if [ "${#PACKS[@]}" -gt 0 ]; then
    for pack in "${PACKS[@]}"; do
      list_profile_files "$templates_dir/packs/$pack" "$target_dir/.agent-harness/packs/$pack"
    done
  fi

  printf '%s\n' "$target_dir/.agent-harness/agent-harness.json"
}

run_dry_run() {
  local templates_dir="$1"
  local target_dir="$2"

  echo "agent-harness dry run"
  echo ""
  echo "Profile: $PROFILE"
  echo "Packs:   $(pack_list_text)"
  echo "Target:  $target_dir"
  if [ "$FORCE" -eq 1 ]; then
    echo "Force:   backup and overwrite"
  else
    echo "Force:   no"
  fi
  echo ""

  list_install_files "$templates_dir" "$target_dir" | while IFS= read -r dest_path; do
    if [ -e "$dest_path" ]; then
      if [ "$FORCE" -eq 1 ]; then
        echo "BACKUP+OVERWRITE $dest_path"
      else
        echo "WOULD FAIL       $dest_path"
      fi
    else
      echo "CREATE           $dest_path"
    fi
  done
}

check_path_exists() {
  local path="$1"
  local label="$2"

  if [ -e "$path" ]; then
    echo "OK   $label"
    return 0
  fi

  echo "FAIL $label missing: $path"
  return 1
}

check_file_exists() {
  local path="$1"
  local label="$2"

  if [ -f "$path" ]; then
    echo "OK   $label"
    return 0
  fi

  echo "FAIL $label missing: $path"
  return 1
}

check_metadata() {
  local metadata_path="$1"
  local target_dir="$2"
  local packs_file="$3"
  local python_bin

  if command -v python3 >/dev/null 2>&1; then
    python_bin="python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    python_bin="python"
  else
    echo "WARN Metadata JSON not parsed because Python is unavailable."
    : > "$packs_file"
    return 0
  fi

  if ! "$python_bin" - "$metadata_path" "$packs_file" <<'PY'
import json
import sys

metadata_path = sys.argv[1]
packs_file = sys.argv[2]

with open(metadata_path, "r", encoding="utf-8") as handle:
    metadata = json.load(handle)

profile = metadata.get("profile")
packs = metadata.get("packs")

if profile not in ("mvp", "full"):
    raise SystemExit(f"Invalid metadata profile: {profile!r}")
if not isinstance(packs, list) or not all(isinstance(pack, str) for pack in packs):
    raise SystemExit("Invalid metadata packs: expected an array of strings")

with open(packs_file, "w", encoding="utf-8") as handle:
    for pack in packs:
        handle.write(pack + "\n")

print(f"OK   metadata valid: profile={profile}, packs={len(packs)}")
PY
  then
    echo "FAIL metadata invalid: $metadata_path"
    return 1
  fi

  return 0
}

run_check() {
  local target_dir="$1"
  local status=0
  local packs_file

  echo "agent-harness check"
  echo ""
  echo "Target: $target_dir"
  echo ""

  check_file_exists "$target_dir/AGENTS.md" "root AGENTS.md" || status=1
  check_path_exists "$target_dir/.agent-harness" ".agent-harness directory" || status=1
  check_file_exists "$target_dir/.agent-harness/AGENTS.md" "framework AGENTS.md" || status=1
  check_file_exists "$target_dir/.agent-harness/agent-harness.json" "metadata" || status=1
  check_file_exists "$target_dir/.agent-harness/scripts/verify.sh" "Bash verification script" || status=1
  check_file_exists "$target_dir/.agent-harness/scripts/verify.ps1" "PowerShell verification script" || status=1

  packs_file="$(mktemp)"
  : > "$packs_file"
  if [ -f "$target_dir/.agent-harness/agent-harness.json" ]; then
    check_metadata "$target_dir/.agent-harness/agent-harness.json" "$target_dir" "$packs_file" || status=1
  fi

  while IFS= read -r pack; do
    pack="${pack%$'\r'}"
    if [ -z "$pack" ]; then
      continue
    fi
    check_path_exists "$target_dir/.agent-harness/packs/$pack" "installed pack $pack" || status=1
  done < "$packs_file"
  rm -f "$packs_file"

  for legacy_path in "$target_dir/.harness" "$target_dir/.mcp" "$target_dir/.superpowers" "$target_dir/progress"; do
    if [ -e "$legacy_path" ]; then
      echo "WARN legacy flat-layout path exists: $legacy_path"
    else
      echo "OK   legacy flat-layout path absent: $legacy_path"
    fi
  done

  echo ""
  if [ "$status" -eq 0 ]; then
    echo "Check passed."
  else
    echo "Check failed."
  fi

  return "$status"
}

json_pack_array() {
  local first=1
  printf '['
  if [ "${#PACKS[@]}" -gt 0 ]; then
    for pack in "${PACKS[@]}"; do
      if [ "$first" -eq 0 ]; then
        printf ', '
      fi
      printf '"%s"' "$pack"
      first=0
    done
  fi
  printf ']'
}

pack_list_text() {
  local first=1
  if [ "${#PACKS[@]}" -eq 0 ]; then
    printf 'none'
    return
  fi

  if [ "${#PACKS[@]}" -gt 0 ]; then
    for pack in "${PACKS[@]}"; do
      if [ "$first" -eq 0 ]; then
        printf ', '
      fi
      printf '%s' "$pack"
      first=0
    done
  fi
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

normalize_pack_name() {
  local pack_name="$1"
  pack_name="$(printf '%s' "$pack_name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  case "$pack_name" in
    next|nextjs|next-js|next.js|"next js"|"Next.js"|"Next JS"|"next JS")
      printf 'nextjs'
      ;;
    *)
      printf '%s' "$pack_name"
      ;;
  esac
}

run_interactive_config() {
  if [ "$ORIGINAL_ARG_COUNT" -ne 0 ]; then
    return
  fi

  if [ ! -r /dev/tty ]; then
    echo "No interactive terminal detected; using defaults. Pass --pack nextjs to install the Next.js pack." >&2
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
          PACKS+=("$(normalize_pack_name "$requested")")
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

if [ "$CHECK" -eq 1 ] && [ "$DRY_RUN" -eq 1 ]; then
  echo "Use either --check or --dry-run, not both." >&2
  exit 1
fi

if [ "$CHECK" -eq 1 ] && [ "$ORIGINAL_ARG_COUNT" -ne 0 ]; then
  TEMPLATES_DIR=""
else
  TEMPLATES_DIR="$(resolve_templates_dir)"
fi
run_interactive_config

if [ "$PROFILE" != "mvp" ] && [ "$PROFILE" != "full" ]; then
  echo "Invalid profile: $PROFILE. Expected mvp or full." >&2
  exit 1
fi

if [ -z "$TARGET_DIR" ]; then
  echo "Target directory cannot be empty." >&2
  exit 1
fi

if [ "$CHECK" -eq 1 ]; then
  if [ -d "$TARGET_DIR" ]; then
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
  fi
  run_check "$TARGET_DIR"
  exit $?
fi

if [ "${#PACKS[@]}" -gt 0 ]; then
  for pack_index in "${!PACKS[@]}"; do
    pack="$(normalize_pack_name "${PACKS[$pack_index]}")"
    PACKS[$pack_index]="$pack"
    if ! [[ "$pack" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
      echo "Invalid pack name: $pack. Use lowercase letters, numbers, and hyphens." >&2
      exit 1
    fi
  done
fi

if [ -d "$TARGET_DIR" ]; then
  TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
else
  case "$TARGET_DIR" in
    /*) ;;
    *) TARGET_DIR="$PWD/$TARGET_DIR" ;;
  esac
fi

TIMESTAMP="$(date +%Y%m%d%H%M%S)"

if [ "${#PACKS[@]}" -gt 0 ]; then
  for pack in "${PACKS[@]}"; do
    if [ ! -d "$TEMPLATES_DIR/packs/$pack" ]; then
      echo "Pack does not exist: $pack" >&2
      exit 1
    fi
  done
fi

if [ "$DRY_RUN" -eq 1 ]; then
  run_dry_run "$TEMPLATES_DIR" "$TARGET_DIR"
  exit 0
fi

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

copy_profile "$TEMPLATES_DIR/core/mvp" "$TARGET_DIR" "$TIMESTAMP"
if [ "$PROFILE" = "full" ]; then
  copy_profile "$TEMPLATES_DIR/core/full" "$TARGET_DIR" "$TIMESTAMP"
fi

if [ "${#PACKS[@]}" -gt 0 ]; then
  for pack in "${PACKS[@]}"; do
    copy_pack "$TEMPLATES_DIR" "$pack" "$TARGET_DIR" "$TIMESTAMP"
  done
fi

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
