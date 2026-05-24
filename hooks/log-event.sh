#!/usr/bin/env bash
# meta-logging: logs session events to .vibe-cache/usage.jsonl
set -euo pipefail
LOG_DIR="${1:-.vibe-cache}"
mkdir -p "$LOG_DIR"
EVENT="${2:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "{\"ts\":\"$TIMESTAMP\",\"event\":\"$EVENT\"}" >> "$LOG_DIR/usage.jsonl"
