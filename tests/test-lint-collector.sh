#!/usr/bin/env bash
# Tests for adapters/lint-collector/collect.sh
# Uses PATH override with mock lint tools
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COLLECT_SH="$PROJECT_DIR/adapters/lint-collector/collect.sh"

PASS=0
FAIL=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1: $2"; FAIL=$((FAIL + 1)); }

run_collect() {
  PATH="$MOCK_BIN:$PATH" bash "$COLLECT_SH" "$@" 2>&1 || true
}

cleanup() {
  rm -rf "$TEST_DIR"
  [[ -n "${ORIG_HOME:-}" ]] || true
}

TEST_DIR=$(mktemp -d)
MOCK_BIN="$TEST_DIR/bin"
mkdir -p "$MOCK_BIN"
trap cleanup EXIT

# Create mock lint tools that output valid JSON
cat > "$MOCK_BIN/npx" << 'NPMOCK'
#!/usr/bin/env bash
[[ "$1" == "eslint" ]] && echo '[{"file":"a.js","errorCount":0}]' || echo '[]'
NPMOCK
chmod +x "$MOCK_BIN/npx"

cat > "$MOCK_BIN/ruff" << 'RUFMOCK'
#!/usr/bin/env bash
echo '[{"code":"F401","message":"unused import"}]'
RUFMOCK
chmod +x "$MOCK_BIN/ruff"

cat > "$MOCK_BIN/golangci-lint" << 'GLMOCK'
#!/usr/bin/env bash
echo '{"Issues":[]}'
GLMOCK
chmod +x "$MOCK_BIN/golangci-lint"

echo ""
echo "=== lint-collector tests ==="
echo ""

# Test 1: missing task-id errors
OUT=$(run_collect "")
if echo "$OUT" | grep -q "task-id required"; then
  pass "rejects missing task-id"
else
  fail "rejects missing task-id" "no error"
fi

# Test 2: no tools available → tool=none (isolate PATH from mocks)
EMPTY_BIN="$TEST_DIR/empty-bin"
mkdir -p "$EMPTY_BIN"
cd "$TEST_DIR"
rm -f "$TEST_DIR/package.json" "$TEST_DIR/pyproject.toml" 2>/dev/null || true
PATH="$EMPTY_BIN:/bin:/usr/bin" bash "$COLLECT_SH" "test-none" > /dev/null 2>&1
REPORT="$TEST_DIR/retros/test-none/lint-report.json"
TOOL=$(python3 -c "import json; print(json.load(open('$REPORT'))['tool'])" 2>/dev/null || echo "parse-error")
if [[ "$TOOL" == "none" ]]; then
  pass "no tools available → tool=none"
else
  fail "no tools available → tool=none" "got $TOOL"
fi

# Test 3: eslint path (package.json + npx)
touch "$TEST_DIR/package.json"
cd "$TEST_DIR"
OUT=$(run_collect "test-eslint" 2>&1)
REPORT="$TEST_DIR/retros/test-eslint/lint-report.json"
TOOL=$(python3 -c "import json; print(json.load(open('$REPORT'))['tool'])" 2>/dev/null || echo "parse-error")
if [[ "$TOOL" == "eslint" ]]; then
  pass "eslint detected (package.json + npx)"
else
  fail "eslint detected (package.json + npx)" "got $TOOL"
fi
rm "$TEST_DIR/package.json"

# Test 4: ruff path (pyproject.toml + ruff)
touch "$TEST_DIR/pyproject.toml"
OUT=$(run_collect "test-ruff" 2>&1)
REPORT="$TEST_DIR/retros/test-ruff/lint-report.json"
TOOL=$(python3 -c "import json; print(json.load(open('$REPORT'))['tool'])" 2>/dev/null || echo "parse-error")
if [[ "$TOOL" == "ruff" ]]; then
  pass "ruff detected (pyproject.toml + ruff)"
else
  fail "ruff detected (pyproject.toml + ruff)" "got $TOOL"
fi
rm "$TEST_DIR/pyproject.toml"

# Test 5: golangci-lint path (no config files, tool exists)
OUT=$(run_collect "test-golangci" 2>&1)
REPORT="$TEST_DIR/retros/test-golangci/lint-report.json"
TOOL=$(python3 -c "import json; print(json.load(open('$REPORT'))['tool'])" 2>/dev/null || echo "parse-error")
if [[ "$TOOL" == "golangci-lint" ]]; then
  pass "golangci-lint detected (no config, tool exists)"
else
  fail "golangci-lint detected (no config, tool exists)" "got $TOOL"
fi

# Test 6: eslint takes priority over ruff when both configs present
touch "$TEST_DIR/package.json"
touch "$TEST_DIR/pyproject.toml"
OUT=$(run_collect "test-priority" 2>&1)
REPORT="$TEST_DIR/retros/test-priority/lint-report.json"
TOOL=$(python3 -c "import json; print(json.load(open('$REPORT'))['tool'])" 2>/dev/null || echo "parse-error")
if [[ "$TOOL" == "eslint" ]]; then
  pass "eslint > ruff priority (both configs present)"
else
  fail "eslint > ruff priority" "got $TOOL"
fi
rm "$TEST_DIR/package.json" "$TEST_DIR/pyproject.toml"

# Test 7: output is valid JSON in all cases
ALL_VALID=true
for tid in test-none test-eslint test-ruff test-golangci test-priority; do
  r="$TEST_DIR/retros/$tid/lint-report.json"
  if ! python3 -c "import json; json.load(open('$r'))" 2>/dev/null; then
    ALL_VALID=false
    echo "    invalid JSON in $tid"
  fi
done
if $ALL_VALID; then
  pass "all reports are valid JSON"
else
  fail "all reports are valid JSON" "some invalid"
fi

# Test 8: lint report created in correct directory
if [[ -f "$TEST_DIR/retros/test-golangci/lint-report.json" ]]; then
  pass "report written to retros/<task-id>/lint-report.json"
else
  fail "report written to correct path" "not found"
fi

echo ""
echo "---"
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
