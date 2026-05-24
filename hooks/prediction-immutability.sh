#!/usr/bin/env bash
# prediction-immutability.sh
# Blocks edits that modify the prediction section of predictions/*.md files.
# The prediction section (## 预估 ...) is immutable; only the retro section (## 复盘) can be edited.
#
# Bypass for formatting fixes: CHEAT_BYPASS_IMMUTABILITY=1

set -euo pipefail

FILE="$1"
ACTION="$2"

# Match predictions/ directory anywhere in the path (handles both relative and absolute)
if [[ ! "$FILE" =~ predictions/ ]]; then
  exit 0
fi

# Read proposed change from stdin
PROPOSED=$(cat)

# Determine which section each changed line belongs to.
# We scan the diff for @@ hunk headers and check whether changed lines
# (starting with + or -) fall before or after a prediction/retro marker.
#
# Algorithm:
# 1. Find all section boundary line numbers from the diff context
# 2. For each + or - line, determine which section it's in
# 3. If any change touches the prediction section (not retro), block it

# Collect deleted (-) and added (+) lines that are NOT section headers themselves
CHANGED_LINES=$(echo "$PROPOSED" | { grep -E '^[+-]' || true; } | { grep -vE '^[+-]{3}' || true; } | { grep -vE '^[+-]{2}\s*#' || true; })

if [[ -z "$CHANGED_LINES" ]]; then
  exit 0
fi

# Check if any changed line is a prediction-related marker being edited
# These are section headers that define the immutability boundary
PRED_MARKERS=$(echo "$PROPOSED" | grep -E '^[+-]\s*##\s*预估' || true)
RETRO_MARKERS=$(echo "$PROPOSED" | grep -E '^[+-]\s*##\s*复盘' || true)

# Use hunk context to determine section for each changed line.
# A hunk like: @@ -5,7 +5,7 @@
# means the original file's line 5-11 maps to new file's line 5-11.
# We track what section each line range falls into.

# Simpler approach: for each hunk, extract the context lines (no prefix = unchanged context)
# and check if they contain prediction or retro markers. Then classify the hunk.

# Extract hunks and classify each
CURRENT_SECTION="unknown"
HAS_VIOLATION=false

while IFS= read -r line; do
  # Track hunk headers: @@ -old_start,old_count +new_start,new_count @@
  if [[ "$line" =~ ^@@\ +-[0-9]+ ]]; then
    CURRENT_SECTION="unknown"
    continue
  fi

  # Skip file headers
  [[ "$line" =~ ^(---|\+\+\+) ]] && continue

  # Context lines (no prefix) define the section for subsequent changes
  if [[ "$line" =~ ^[[:space:]]*##\ 预估\ v[0-9]+ ]]; then
    CURRENT_SECTION="prediction"
    continue
  fi
  if [[ "$line" =~ ^[[:space:]]*##\ 复盘 ]]; then
    CURRENT_SECTION="retro"
    continue
  fi

  # Check if this is a changed line (+ or -) in prediction section
  if [[ "$line" =~ ^[+-] ]] && [[ "$CURRENT_SECTION" == "prediction" ]]; then
    # Ignore if the change is just whitespace or the section header itself
    content="${line:1}"
    if [[ ! "$content" =~ ^[[:space:]]*##\ 预估 ]]; then
      HAS_VIOLATION=true
      break
    fi
  fi
done <<< "$PROPOSED"

# Fallback: if we couldn't track sections via context lines, check if the diff
# shows prediction markers being modified directly
if ! $HAS_VIOLATION; then
  # Check for +/- lines containing prediction content if we see prediction context
  IN_PRED_SECTION=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*(##\ 预估\ v[0-9]+) ]]; then
      IN_PRED_SECTION=true
      continue
    fi
    if [[ "$line" =~ ^[[:space:]]*(##\ 复盘) ]]; then
      IN_PRED_SECTION=false
      continue
    fi
    if $IN_PRED_SECTION && [[ "$line" =~ ^[+-] ]]; then
      content="${line:1}"
      # Skip empty lines and section headers
      [[ -z "${content// }" ]] && continue
      [[ "$content" =~ ^[[:space:]]*## ]] && continue
      HAS_VIOLATION=true
      break
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
