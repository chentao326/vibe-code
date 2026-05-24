#!/usr/bin/env bash
# git-stats collect.sh
# Usage: bash collect.sh <task-id> <start-commit>
# Writes retros/<task-id>/git-report.json

set -euo pipefail

TASK_ID="${1:-}"
START_COMMIT="${2:-HEAD}"

if [[ -z "$TASK_ID" ]]; then
  echo '{"error": "task-id required"}'
  exit 1
fi

PROJECT_ROOT="$(pwd)"
RETRO_DIR="$PROJECT_ROOT/retros/$TASK_ID"
mkdir -p "$RETRO_DIR"

TMPFILE="$RETRO_DIR/git-report.json.tmp"

# Collect summary stats
FILES_CHANGED=$(git diff --name-only "$START_COMMIT" HEAD | wc -l | tr -d ' ')
INSERTIONS=$(git diff --shortstat "$START_COMMIT" HEAD | awk '{for(i=1;i<=NF;i++) if($i ~ /^insertion/) print $(i-1)}' | head -1)
DELETIONS=$(git diff --shortstat "$START_COMMIT" HEAD | awk '{for(i=1;i<=NF;i++) if($i ~ /^deletion/) print $(i-1)}' | head -1)
COMMITS=$(git rev-list --count "$START_COMMIT"..HEAD 2>/dev/null || echo 0)

INSERTIONS="${INSERTIONS:-0}"
DELETIONS="${DELETIONS:-0}"

# Collect touched modules (top-level dirs)
MODULES=$(git diff --name-only "$START_COMMIT" HEAD | sed 's,/.*,,' | sort -u | jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]")

# Build files array using process substitution to avoid subshell issues
FILES_JSON=""
first=true
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  ins=$(git diff --numstat "$START_COMMIT" HEAD -- "$file" | awk '{print $1}')
  del=$(git diff --numstat "$START_COMMIT" HEAD -- "$file" | awk '{print $2}')
  ins="${ins:-0}"
  del="${del:-0}"
  if $first; then
    first=false
  else
    FILES_JSON+=","
  fi
  printf -v entry '{"path":"%s","insertions":%s,"deletions":%s}' "$file" "$ins" "$del"
  FILES_JSON+="$entry"
done < <(git diff --name-only "$START_COMMIT" HEAD)

# Write JSON
cat > "$TMPFILE" <<JSONEOF
{
  "files_changed": ${FILES_CHANGED},
  "insertions": ${INSERTIONS},
  "deletions": ${DELETIONS},
  "commits": ${COMMITS},
  "modules_touched": ${MODULES},
  "files": [${FILES_JSON}]
}
JSONEOF

mv "$TMPFILE" "$RETRO_DIR/git-report.json"
echo "git-stats report written to $RETRO_DIR/git-report.json"
