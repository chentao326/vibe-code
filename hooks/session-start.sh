#!/usr/bin/env bash
# session-start.sh
# Called at the start of each new conversation session.
# Renders a brief status report from .vibe-state.json

set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
STATE_FILE="$PROJECT_DIR/.vibe-state.json"

if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

CAL_SAMPLES=$(python3 -c "import json; print(json.load(open('$STATE_FILE'))['calibration_samples'])" 2>/dev/null || echo "0")
PENDING_RETROS=$(python3 -c "import json; print(len(json.load(open('$STATE_FILE'))['pending_retros']))" 2>/dev/null || echo "0")
WIP=$(python3 -c "import json; print(len(json.load(open('$STATE_FILE'))['wip_tasks']))" 2>/dev/null || echo "0")
LAST_RETRO=$(python3 -c "import json; print(json.load(open('$STATE_FILE'))['last_retro_at'] or 'never')" 2>/dev/null || echo "never")

echo ""
echo "📊 Vibe Code Status"
echo "   Calibration: $CAL_SAMPLES samples | ⏰ Pending retros: $PENDING_RETROS | 📝 WIP: $WIP"
echo "   Last retro: $LAST_RETRO"
echo ""
