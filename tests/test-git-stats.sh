#!/usr/bin/env bash
# Tests for adapters/git-stats/collect.sh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COLLECT_SH="$PROJECT_DIR/adapters/git-stats/collect.sh"

PASS=0
FAIL=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1: $2"; FAIL=$((FAIL + 1)); }

# Helper: run and capture both stdout+stderr, ignore exit code
run_collect() {
  bash "$COLLECT_SH" "$@" 2>&1 || true
}

cleanup() {
  rm -rf "$TEST_DIR"
}

TEST_DIR=$(mktemp -d)
trap cleanup EXIT

cd "$TEST_DIR"
git init --quiet
git config user.email "test@test"
git config user.name "Test"

echo "line1" > file1.txt
echo "line1" > file2.txt
git add file1.txt file2.txt
git commit -m "initial" --quiet

START_COMMIT=$(git rev-parse HEAD)

echo "line2" >> file1.txt
echo "line2" >> file2.txt
mkdir -p subdir
echo "newfile" > subdir/file3.txt
git add file1.txt file2.txt subdir/file3.txt
git commit -m "add changes" --quiet

echo ""
echo "=== git-stats adapter tests ==="
echo ""

# Test 1: missing task-id
OUT=$(run_collect "")
if echo "$OUT" | grep -q "task-id required"; then
  pass "rejects missing task-id"
else
  fail "rejects missing task-id" "should error on missing task-id"
fi

# Test 2: produces valid JSON
TASK_ID="test-task-001"
run_collect "$TASK_ID" "$START_COMMIT" > /dev/null

REPORT="$TEST_DIR/retros/$TASK_ID/git-report.json"
if [[ -f "$REPORT" ]]; then
  pass "creates report file"
else
  fail "creates report file" "$REPORT not found"
fi

# Test 3: JSON is valid
if python3 -c "import json; json.load(open('$REPORT'))" 2>/dev/null; then
  pass "output is valid JSON"
else
  fail "output is valid JSON" "json.load failed"
fi

# Test 4: correct file count
FILES_CHANGED=$(python3 -c "import json; print(json.load(open('$REPORT'))['files_changed'])")
if [[ "$FILES_CHANGED" == "3" ]]; then
  pass "files_changed = 3 (correct)"
else
  fail "files_changed = 3" "got $FILES_CHANGED"
fi

# Test 5: correct commit count
COMMITS=$(python3 -c "import json; print(json.load(open('$REPORT'))['commits'])")
if [[ "$COMMITS" == "1" ]]; then
  pass "commits = 1 (correct)"
else
  fail "commits = 1" "got $COMMITS"
fi

# Test 6: files array has correct entries
FILE_COUNT=$(python3 -c "import json; print(len(json.load(open('$REPORT'))['files']))")
if [[ "$FILE_COUNT" == "3" ]]; then
  pass "files array has 3 entries"
else
  fail "files array has 3 entries" "got $FILE_COUNT"
fi

# Test 7: insertions + deletions > 0 (total changes)
TOTAL=$(python3 -c "
import json
d=json.load(open('$REPORT'))
print(d['insertions'] + d['deletions'])
")
if [[ "$TOTAL" -gt 0 ]]; then
  pass "total changes > 0 ($TOTAL)"
else
  fail "total changes > 0" "got $TOTAL"
fi

# Test 8: modules_touched is valid JSON array (check from file directly)
if python3 -c "
import json
d=json.load(open('$REPORT'))
modules = d['modules_touched']
assert isinstance(modules, list), f'expected list, got {type(modules).__name__}'
print('ok')
" 2>/dev/null; then
  pass "modules_touched is valid JSON array"
else
  VAL=$(python3 -c "import json; print(repr(json.load(open('$REPORT'))['modules_touched']))" 2>/dev/null)
  fail "modules_touched is valid JSON array" "got $VAL"
fi

# Test 9: no-args errors
OUT=$(run_collect)
if echo "$OUT" | grep -q "task-id required"; then
  pass "no-args errors with task-id required"
else
  fail "no-args errors" "got: $OUT"
fi

echo ""
echo "---"
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
