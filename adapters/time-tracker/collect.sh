#!/usr/bin/env bash
# time-tracker collect.sh
# Usage:
#   bash collect.sh start  <task-id>   — record start timestamp
#   bash collect.sh report <task-id>   — record end timestamp, write report

set -euo pipefail

ACTION="${1:-}"
TASK_ID="${2:-}"

if [[ -z "$ACTION" || -z "$TASK_ID" ]]; then
  echo "Usage: bash collect.sh <start|report> <task-id>"
  exit 1
fi

PROJECT_ROOT="$(pwd)"
RETRO_DIR="$PROJECT_ROOT/retros/$TASK_ID"
mkdir -p "$RETRO_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")
START_FILE="$RETRO_DIR/time-start.txt"
REPORT_FILE="$RETRO_DIR/time-report.json"

case "$ACTION" in
  start)
    echo "$TIMESTAMP" > "$START_FILE"
    echo "time-tracker: start recorded at $TIMESTAMP"
    ;;

  report)
    if [[ ! -f "$START_FILE" ]]; then
      echo '{"error": "no start timestamp found", "duration_minutes": null}' > "$REPORT_FILE"
      echo "time-tracker: no start timestamp — skipped"
      exit 0
    fi

    STARTED_AT=$(cat "$START_FILE")
    COMPLETED_AT="$TIMESTAMP"

    # Calculate wall-clock duration in minutes
    start_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S+00:00" "$STARTED_AT" +%s 2>/dev/null || date -d "$STARTED_AT" +%s 2>/dev/null)
    end_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S+00:00" "$COMPLETED_AT" +%s 2>/dev/null || date -d "$COMPLETED_AT" +%s 2>/dev/null)
    duration=$(( (end_epoch - start_epoch) / 60 ))

    cat > "$REPORT_FILE" << JSONEOF
{
  "started_at": "${STARTED_AT}",
  "completed_at": "${COMPLETED_AT}",
  "duration_minutes": ${duration}
}
JSONEOF

    echo "time-tracker report written to $REPORT_FILE (duration: ${duration}min)"
    ;;

  *)
    echo "Unknown action: $ACTION (use start or report)"
    exit 1
    ;;
esac
