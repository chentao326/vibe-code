#!/usr/bin/env bash
# vibe-code / uninstall.sh
# Removes symlinked skills from all agent directories.

set -euo pipefail

SKILLS=(
  vibe-init vibe-assess vibe-retro vibe-bump vibe-status
  vibe-score vibe-score-blind vibe-seed vibe-recommend vibe-trends
  vibe-profile vibe-learn-from vibe-migrate
)

TARGET_DIRS=(
  "$HOME/.codex/skills"
  "$HOME/.claude/skills"
  "$HOME/.cursor/skills"
)

echo "Removing vibe-code skills..."

for dir in "${TARGET_DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    for s in "${SKILLS[@]}" "vibe-code"; do
      local_path="$dir/$s"
      if [[ -L "$local_path" ]]; then
        rm "$local_path"
        echo "  ✓ removed: $local_path"
      elif [[ -d "$local_path" ]]; then
        rm -rf "$local_path"
        echo "  ✓ removed (copy): $local_path"
      fi
    done
  fi
done

echo "✅ Uninstall complete (your project data untouched)."
