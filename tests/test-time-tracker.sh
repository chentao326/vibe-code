#!/usr/bin/env bash
# Tests for adapters/time-tracker/collect.sh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COLLECT_SH="$PROJECT_DIR/adapters/time-tracker/collect.sh"

PASS=0
FAIL=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1: $2"; FAIL=$((FAIL + 1)); }

run_collect() {
  bash "$COLLECT_SH" "$@" 2>&1 || true
}

cleanup() {
  rm -rf "$TEST_DIR"
}

TEST_DIR=$(mktemp -d)
trap cleanup EXIT
cd "$TEST_DIR"

echo ""
echo "=== time-tracker adapter tests ==="
echo ""

# Test 1: no args
OUT=$(run_collect)
if echo "$OUT" | grep -q "Usage"; then
  pass "no-args prints usage"
else
  fail "no-args prints usage" "got: $OUT"
fi

# Test 2: invalid action
OUT=$(run_collect invalid task1)
if echo "$OUT" | grep -q "Unknown action"; then
  pass "rejects invalid action"
else
  fail "rejects invalid action" "got: $OUT"
fi

# Test 3: start creates timestamp file
TID="task-001"
run_collect start "$TID" > /dev/null
if [[ -f "retros/$TID/time-start.txt" ]]; then
  pass "start creates time-start.txt"
else
  fail "start creates time-start.txt" "file not found"
fi

# Test 4: start timestamp is valid ISO 8601
TS=$(cat "retros/$TID/time-start.txt")
if echo "$TS" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\+00:00$'; then
  pass "start timestamp is valid ISO 8601"
else
  fail "start timestamp is valid ISO 8601" "got: $TS"
fi

# Test 5: report without start
rm -f "retros/$TID/time-start.txt"
run_collect report "$TID" > /dev/null
if python3 -c "import json; d=json.load(open('retros/$TID/time-report.json')); assert d['duration_minutes'] is None" 2>/dev/null; then
  pass "report without start: duration_minutes = null"
else
  fail "report without start" "should set duration_minutes to null"
fi

# Test 6: report with start calculates duration
TID2="task-002"
run_collect start "$TID2" > /dev/null
sleep 1
run_collect report "$TID2" > /dev/null
DUR=$(python3 -c "import json; print(json.load(open('retros/$TID2/time-report.json'))['duration_minutes'])")
if [[ "$DUR" -ge 0 ]]; then
  pass "report with start: duration_minutes = $DUR (>= 0)"
else
  fail "report with start" "should be >= 0, got $DUR"
fi

# Test 7: report has all fields
FIELDS=$(python3 -c "
import json
d=json.load(open('retros/$TID2/time-report.json'))
keys = set(d.keys())
expected = {'started_at','completed_at','duration_minutes'}
assert keys == expected, f'missing: {expected - keys}, extra: {keys - expected}'
print('ok')
" 2>&1)
if [[ "$FIELDS" == "ok" ]]; then
  pass "report JSON has correct schema"
else
  fail "report JSON has correct schema" "$FIELDS"
fi

echo ""
echo "---"
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
