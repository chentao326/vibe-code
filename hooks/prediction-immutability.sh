#!/usr/bin/env bash
# prediction-immutability.sh
# Blocks edits that modify the prediction section of predictions/*.md files.
# The prediction section (## 预估 ...) is immutable; only the retro section (## 复盘) can be edited.
#
# Supports two input formats on stdin:
#   Format A (diff): unified diff from git diff or test harness — processed with hunk tracking
#   Format B (JSON):  PreToolUse hook input — parsed for file path + content changes
#   Auto-detection: stdin starting with '{' is treated as JSON, otherwise diff
#
# Bypass: CHEAT_BYPASS_IMMUTABILITY=1

set -euo pipefail

FILE="${1:-}"
ACTION="${2:-}"

# Match predictions/ directory anywhere in the path
if [[ ! "$FILE" =~ predictions/ ]]; then
  exit 0
fi

PROPOSED=$(cat)

# ── Format B: JSON (PreToolUse hook input) ──
if [[ "$PROPOSED" =~ ^[[:space:]]*\{ ]]; then
  # Extract file from JSON
  JSON_FILE=$(echo "$PROPOSED" | grep -oE '"file"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  [[ -n "$JSON_FILE" && ! "$JSON_FILE" =~ predictions/ ]] && exit 0

  # Extract old_string and new_string from arguments
  OLD_STR=$(echo "$PROPOSED" | grep -oE '"old_string"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"old_string"\s*:\s*"//' | sed 's/"$//')
  NEW_STR=$(echo "$PROPOSED" | grep -oE '"new_string"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"new_string"\s*:\s*"//' | sed 's/"$//')

  # Check if old_string or new_string touches prediction marker content
  # If either string contains text that sits between ## 预估 and ## 复盘
  COMBINED="${OLD_STR:-}${NEW_STR:-}"
  if echo "$COMBINED" | grep -qE '(预计对话轮次|预计耗时|Bug 风险|预期满意度|综合分|概率分布|关键假设|Composite|\*\*综合分|任务快照)'; then
    if [[ "${CHEAT_BYPASS_IMMUTABILITY:-0}" == "1" ]]; then
      echo "⚠️  IMMUTABILITY BYPASSED for $FILE"
      exit 0
    fi
    echo "❌ IMMUTABILITY VIOLATION: Cannot modify prediction section of $FILE"
    echo "   Detected prediction content in proposed change."
    echo "   Bypass: set CHEAT_BYPASS_IMMUTABILITY=1"
    exit 1
  fi

  # Also block if the section header itself is being modified
  if echo "$COMBINED" | grep -qE '## 预估'; then
    if [[ "${CHEAT_BYPASS_IMMUTABILITY:-0}" == "1" ]]; then
      echo "⚠️  IMMUTABILITY BYPASSED for $FILE"
      exit 0
    fi
    echo "❌ IMMUTABILITY VIOLATION: Cannot modify prediction section of $FILE"
    echo "   Prediction header '## 预估' detected in proposed change."
    exit 1
  fi

  exit 0
fi

# ── Format A: Diff ──

CHANGED_LINES=$(echo "$PROPOSED" | { grep -E '^[+-]' || true; } | { grep -vE '^[+-]{3}' || true; } | { grep -vE '^[+-]{2}\s*#' || true; })

if [[ -z "$CHANGED_LINES" ]]; then
  exit 0
fi

CURRENT_SECTION="unknown"
HAS_VIOLATION=false

while IFS= read -r line; do
  if [[ "$line" =~ ^@@\ +-[0-9]+ ]]; then
    CURRENT_SECTION="unknown"
    continue
  fi

  [[ "$line" =~ ^(---|\+\+\+) ]] && continue

  if [[ "$line" =~ ^[[:space:]]*##\ 预估\ v[0-9]+ ]]; then
    CURRENT_SECTION="prediction"
    continue
  fi
  if [[ "$line" =~ ^[[:space:]]*##\ 复盘 ]]; then
    CURRENT_SECTION="retro"
    continue
  fi

  if [[ "$line" =~ ^[+-] ]] && [[ "$CURRENT_SECTION" == "prediction" ]]; then
    content="${line:1}"
    if [[ ! "$content" =~ ^[[:space:]]*##\ 预估 ]]; then
      HAS_VIOLATION=true
      break
    fi
  fi
done <<< "$PROPOSED"

# Fallback: direct diff scan
if ! $HAS_VIOLATION; then
  IN_PRED_SECTION=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*(##\ 预估\ v[0-9]+) ]]; then
      IN_PRED_SECTION=true; continue
    fi
    if [[ "$line" =~ ^[[:space:]]*(##\ 复盘) ]]; then
      IN_PRED_SECTION=false; continue
    fi
    if $IN_PRED_SECTION && [[ "$line" =~ ^[+-] ]]; then
      content="${line:1}"
      [[ -z "${content// }" ]] && continue
      [[ "$content" =~ ^[[:space:]]*## ]] && continue
      HAS_VIOLATION=true; break
    fi
  done <<< "$PROPOSED"
fi

if $HAS_VIOLATION; then
  if [[ "${CHEAT_BYPASS_IMMUTABILITY:-0}" == "1" ]]; then
    echo "⚠️  IMMUTABILITY BYPASSED (CHEAT_BYPASS_IMMUTABILITY=1) for $FILE"
    exit 0
  fi
  echo "❌ IMMUTABILITY VIOLATION: Cannot modify prediction section of $FILE"
  echo "   The prediction section (## 预估 vN) is immutable."
  echo "   You can only append to the retrospective section (## 复盘)."
  echo "   To bypass: set CHEAT_BYPASS_IMMUTABILITY=1 (for formatting fixes only)"
  exit 1
fi

exit 0
