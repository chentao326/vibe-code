#!/usr/bin/env bash
#
# vibe-code / install.sh
# Installs vibe-code skills into supported AI coding tools.
#
# Usage: bash install.sh [--copy] [--target <name>|--all] [--dry-run] [--list]
#
# Targets:
#   codex    Claude Codex (~/.codex/skills)
#   claude   Claude Code CLI (~/.claude/skills)
#   cursor   Cursor editor (~/.cursor/skills)

set -euo pipefail

SKILLS=(
  vibe-init
  vibe-assess
  vibe-retro
  vibe-bump
  vibe-status
  vibe-score
  vibe-score-blind
  vibe-seed
  vibe-recommend
  vibe-trends
  vibe-profile
  vibe-learn-from
  vibe-migrate
)

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
MODE="symlink"
TARGETS=()
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    --claude) TARGETS+=("claude") ;;
    --codex) TARGETS+=("codex") ;;
    --cursor) TARGETS+=("cursor") ;;
    --all) TARGETS=("codex" "claude" "cursor") ;;
    --dry-run) DRY_RUN=true ;;
    --list)
      echo "Skills to install:"
      for s in "${SKILLS[@]}"; do
        echo "  $s"
      done
      echo ""
      echo "Targets: codex (~/.codex/skills), claude (~/.claude/skills), cursor (~/.cursor/skills)"
      exit 0
      ;;
    --help|-h)
      echo "Usage: bash install.sh [--copy] [--codex|--claude|--cursor|--all] [--dry-run] [--list]"
      echo ""
      echo "Options:"
      echo "  --copy      Copy files instead of symlinking (default: symlink)"
      echo "  --codex     Install for Claude Codex"
      echo "  --claude    Install for Claude Code CLI"
      echo "  --cursor    Install for Cursor editor"
      echo "  --all       Install for all supported tools"
      echo "  --dry-run   Show what would be done without doing it"
      echo "  --list      List all skills and targets"
      exit 0
      ;;
    *) echo "❌ Unknown: $arg"; exit 1 ;;
  esac
done

# Default: codex only
[[ ${#TARGETS[@]} -eq 0 ]] && TARGETS=("codex")

# Validate prerequisites
[[ -f "$SCRIPT_DIR/SKILL.md" ]] || { echo "❌ Missing SKILL.md at $SCRIPT_DIR"; exit 1; }
for s in "${SKILLS[@]}"; do
  [[ -f "$SCRIPT_DIR/skills/$s/SKILL.md" ]] || { echo "❌ Missing: skills/$s/SKILL.md"; exit 1; }
done

get_target_dir() {
  case "$1" in
    codex)  echo "$HOME/.codex/skills" ;;
    claude) echo "$HOME/.claude/skills" ;;
    cursor) echo "$HOME/.cursor/skills" ;;
  esac
}

install_to() {
  local label="$1" target_dir="$2"; shift 2

  if $DRY_RUN; then
    echo ""
    echo "[DRY RUN] Installing vibe-code for $label (mode: $MODE)"
    echo "  target: $target_dir/"
    for s in "$@"; do
      echo "  → $s"
    done
    echo "  → vibe-code (root)"
    return
  fi

  mkdir -p "$target_dir"
  echo ""
  echo "Installing vibe-code for $label (mode: $MODE)"
  echo "  target: $target_dir/"
  echo ""

  for s in "$@"; do
    local src="$SCRIPT_DIR/skills/$s" dst="$target_dir/$s"
    [[ -e "$dst" || -L "$dst" ]] && rm -rf "$dst"
    if [[ "$MODE" == "symlink" ]]; then
      ln -s "$src" "$dst"
      echo "  ✓ $s"
    else
      cp -R "$src" "$dst"
      echo "  ✓ $s (copy)"
    fi
  done

  local root_dst="$target_dir/vibe-code"
  [[ -e "$root_dst" || -L "$root_dst" ]] && rm -rf "$root_dst"
  if [[ "$MODE" == "symlink" ]]; then
    ln -s "$SCRIPT_DIR" "$root_dst"
    echo "  ✓ vibe-code (root)"
  else
    cp -R "$SCRIPT_DIR" "$root_dst"
    rm -rf "$root_dst/.git"
    echo "  ✓ vibe-code (root, copy)"
  fi
}

for target in "${TARGETS[@]}"; do
  install_to "$target" "$(get_target_dir "$target")" "${SKILLS[@]}"
done

if $DRY_RUN; then
  echo ""
  echo "🔍 Dry run complete — no changes made."
else
  echo ""
  echo "✅ Install complete!"
  echo "Next: cd into your project and say: 初始化 vibe-code"
fi
