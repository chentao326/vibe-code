#!/usr/bin/env bash
# lint-collector collect.sh
# Usage: bash collect.sh <task-id>
# Auto-detects lint tool and collects results.

set -euo pipefail

TASK_ID="${1:-}"
if [[ -z "$TASK_ID" ]]; then
  echo '{"error": "task-id required"}'
  exit 1
fi

PROJECT_ROOT="$(pwd)"
RETRO_DIR="$PROJECT_ROOT/retros/$TASK_ID"
mkdir -p "$RETRO_DIR"

# Try to detect and run lint
LINT_OUTPUT=""
TOOL="none"

if [[ -f "$PROJECT_ROOT/package.json" ]] && command -v npx &>/dev/null; then
  TOOL="eslint"
  LINT_OUTPUT=$(cd "$PROJECT_ROOT" && npx eslint . --format json 2>/dev/null || echo "[]")
elif [[ -f "$PROJECT_ROOT/pyproject.toml" ]] && command -v ruff &>/dev/null; then
  TOOL="ruff"
  LINT_OUTPUT=$(cd "$PROJECT_ROOT" && ruff check --output-format json . 2>/dev/null || echo "[]")
elif command -v golangci-lint &>/dev/null; then
  TOOL="golangci-lint"
  LINT_OUTPUT=$(cd "$PROJECT_ROOT" && golangci-lint run --out-format json ./... 2>/dev/null || echo "[]")
fi

LINT_OUTPUT="${LINT_OUTPUT:-[]}"
echo "{\"tool\": \"$TOOL\", \"output\": $LINT_OUTPUT}" > "$RETRO_DIR/lint-report.json"
echo "lint report written to $RETRO_DIR/lint-report.json (tool: $TOOL)"
