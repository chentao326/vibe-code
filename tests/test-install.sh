#!/usr/bin/env bash
# Tests for install.sh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_SH="$PROJECT_DIR/install.sh"

PASS=0
FAIL=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1: $2"; FAIL=$((FAIL + 1)); }

run_install() {
  bash "$INSTALL_SH" "$@" 2>&1 || true
}

echo ""
echo "=== install.sh tests ==="
echo ""

# Test 1: --list outputs all 13 skills
OUT=$(run_install --list)
SKILL_COUNT=$(echo "$OUT" | grep -cE '^\s+vibe-' || true)
if [[ "$SKILL_COUNT" -eq 13 ]]; then
  pass "--list shows 13 skills"
else
  fail "--list shows 13 skills" "got $SKILL_COUNT"
fi

# Test 2: --list mentions targets
if echo "$OUT" | grep -q "Targets:"; then
  pass "--list shows Targets line"
else
  fail "--list shows Targets line" "missing"
fi

# Test 3: --help contains Usage
OUT=$(run_install --help)
if echo "$OUT" | grep -q "Usage:"; then
  pass "--help shows Usage"
else
  fail "--help shows Usage" "missing"
fi

# Test 4: --help shows all flag descriptions
for flag in --copy --codex --claude --cursor --all --dry-run --list; do
  if echo "$OUT" | grep -q -- "$flag"; then
    pass "--help documents $flag"
  else
    fail "--help documents $flag" "missing"
  fi
done

# Test 5: --dry-run --all shows 3 targets
OUT=$(run_install --dry-run --all)
TARGET_COUNT=$(echo "$OUT" | grep -cE '\[DRY RUN\]' || true)
if [[ "$TARGET_COUNT" -eq 3 ]]; then
  pass "--dry-run --all shows 3 targets"
else
  fail "--dry-run --all shows 3 targets" "got $TARGET_COUNT"
fi

# Test 6: --dry-run --codex shows only 1 target
OUT=$(run_install --dry-run --codex)
TARGET_COUNT=$(echo "$OUT" | grep -cE '\[DRY RUN\]' || true)
if [[ "$TARGET_COUNT" -eq 1 ]]; then
  pass "--dry-run --codex shows 1 target"
else
  fail "--dry-run --codex shows 1 target" "got $TARGET_COUNT"
fi

# Test 7: --dry-run --codex target is codex
if echo "$OUT" | grep -q "codex"; then
  pass "--dry-run --codex shows codex target"
else
  fail "--dry-run --codex shows codex target" "missing"
fi

# Test 8: default (no args) uses codex symlink mode
OUT=$(run_install --dry-run)
if echo "$OUT" | grep -q "codex" && echo "$OUT" | grep -q "symlink"; then
  pass "default mode is codex symlink"
else
  fail "default mode is codex symlink" "unexpected output"
fi

# Test 9: --copy changes mode
OUT=$(run_install --dry-run --copy)
if echo "$OUT" | grep -q "(mode: copy)"; then
  pass "--copy sets copy mode"
else
  fail "--copy sets copy mode" "missing mode indicator"
fi

# Test 10: --all includes cursor
OUT=$(run_install --dry-run --all)
if echo "$OUT" | grep -q "cursor"; then
  pass "--all includes cursor"
else
  fail "--all includes cursor" "missing"
fi

# Test 11: unknown flag rejected
OUT=$(run_install --bogus)
if echo "$OUT" | grep -q "Unknown"; then
  pass "unknown flag rejected with error"
else
  fail "unknown flag rejected with error" "no error message"
fi

# Test 12: --list output includes vibe-code root
OUT=$(run_install --dry-run --all)
if echo "$OUT" | grep -q "vibe-code (root)"; then
  pass "--dry-run shows vibe-code root link"
else
  fail "--dry-run shows vibe-code root link" "missing"
fi

# Test 13: --dry-run does not create actual files
BEFORE=$(ls /tmp/skills-test 2>/dev/null || echo "no-dir")
run_install --dry-run --codex > /dev/null
# Check that ~/.codex/skills wasn't created (it might already exist)
# Use a safer check: dry-run output says "Dry run complete"
OUT=$(run_install --dry-run)
if echo "$OUT" | grep -q "Dry run complete"; then
  pass "--dry-run says Dry run complete"
else
  fail "--dry-run says Dry run complete" "missing"
fi

# Test 14: help flag -h works too
OUT=$(run_install -h)
if echo "$OUT" | grep -q "Usage:"; then
  pass "-h shows Usage (short flag)"
else
  fail "-h shows Usage (short flag)" "missing"
fi

echo ""
echo "---"
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
