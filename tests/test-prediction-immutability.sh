#!/usr/bin/env bash
# Tests for hooks/prediction-immutability.sh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
HOOK_SH="$PROJECT_DIR/hooks/prediction-immutability.sh"

PASS=0
FAIL=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1: $2"; FAIL=$((FAIL + 1)); }

echo ""
echo "=== prediction-immutability hook tests ==="
echo ""

# Test 1: non-predictions file passes through
if echo "any content" | bash "$HOOK_SH" "tasks/some-task.md" "Edit" 2>/dev/null; then
  pass "non-predictions/ file allowed"
else
  fail "non-predictions/ file allowed" "should exit 0"
fi

# Test 2: edit without prediction markers passes
NO_MARKERS="--- a/predictions/test.md
+++ b/predictions/test.md
@@ -1,3 +1,3 @@
 some text here
-more text
+changed text
"
if echo "$NO_MARKERS" | bash "$HOOK_SH" "predictions/test-task.md" "Edit" 2>/dev/null; then
  pass "edit without prediction markers passes"
else
  fail "edit without prediction markers passes" "should not block"
fi

# Test 3: edit inside prediction section is blocked
PRED_EDIT=$(cat <<'DIFFEOF'
--- a/predictions/test.md
+++ b/predictions/test.md
@@ -4,8 +4,8 @@
 ## 预估 v1

-预计耗时 | 15-20 min
+预计耗时 | 5-10 min

 ## 复盘
DIFFEOF
)
HOOK_EXIT=0
echo "$PRED_EDIT" | bash "$HOOK_SH" "predictions/test-task.md" "Edit" 2>/dev/null || HOOK_EXIT=$?
if [[ "$HOOK_EXIT" -ne 0 ]]; then
  pass "prediction section edit blocked"
else
  fail "prediction section edit blocked" "should exit non-zero"
fi

# Test 4: retro-only edit passes
RETRO_EDIT=$(cat <<'DIFFEOF'
--- a/predictions/test.md
+++ b/predictions/test.md
@@ -10,3 +10,3 @@
 ## 复盘
-实际耗时: 20min
+实际耗时: 25min
DIFFEOF
)
if echo "$RETRO_EDIT" | bash "$HOOK_SH" "predictions/test-task.md" "Edit" 2>/dev/null; then
  pass "retro-only edit passes"
else
  fail "retro-only edit passes" "should allow retro section edits"
fi

# Test 5: Write on new prediction file passes
if printf 'new file\n' | bash "$HOOK_SH" "predictions/new.md" "Write" 2>/dev/null; then
  pass "Write on new predictions file passes"
else
  fail "Write on new predictions file passes" "should allow new files"
fi

# Test 6: absolute path with predictions/ still matched
if echo "x" | bash "$HOOK_SH" "/home/user/project/predictions/t.md" "Edit" 2>/dev/null; then
  pass "absolute path with predictions/ handled"
else
  fail "absolute path with predictions/ handled" "should match"
fi

# Test 7: prediction v2 section is also protected
PRED_V2_EDIT=$(cat <<'DIFFEOF'
--- a/predictions/test.md
+++ b/predictions/test.md
@@ -2,7 +2,7 @@

 ## 预估 v2
-预计耗时 | 10-20 min
+预计耗时 | 5-10 min

 ## 复盘
DIFFEOF
)
HOOK_EXIT=0
echo "$PRED_V2_EDIT" | bash "$HOOK_SH" "predictions/test-task.md" "Edit" 2>/dev/null || HOOK_EXIT=$?
if [[ "$HOOK_EXIT" -ne 0 ]]; then
  pass "prediction v2 section also protected"
else
  fail "prediction v2 section also protected" "should exit non-zero"
fi

# Test 8: bypass via env var
if echo "$PRED_EDIT" | CHEAT_BYPASS_IMMUTABILITY=1 bash "$HOOK_SH" "predictions/test-task.md" "Edit" 2>/dev/null; then
  pass "CHEAT_BYPASS_IMMUTABILITY=1 bypass works"
else
  fail "CHEAT_BYPASS_IMMUTABILITY=1 bypass works" "should allow with bypass"
fi

# Test 9: appending new retro content (only + lines after retro marker)
APPEND_RETRO=$(cat <<'DIFFEOF'
--- a/predictions/test.md
+++ b/predictions/test.md
@@ -12,3 +12,5 @@
 ## 复盘
 实际耗时: 20min
+
+新增观察: 一切顺利
DIFFEOF
)
if echo "$APPEND_RETRO" | bash "$HOOK_SH" "predictions/test-task.md" "Edit" 2>/dev/null; then
  pass "appending to retro section passes"
else
  fail "appending to retro section passes" "should allow retro appends"
fi

echo ""
echo "---"
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
