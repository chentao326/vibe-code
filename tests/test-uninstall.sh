#!/usr/bin/env bash
# Tests for uninstall.sh — uses mock HOME to avoid touching real system paths
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
UNINSTALL_SH="$PROJECT_DIR/uninstall.sh"
INSTALL_SH="$PROJECT_DIR/install.sh"

PASS=0
FAIL=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1: $2"; FAIL=$((FAIL + 1)); }

cleanup() { rm -rf "$MOCK_HOME"; }
MOCK_HOME=$(mktemp -d)
trap cleanup EXIT

# Extract expected skill count: count vibe- words from the SKILLS array lines
SKILL_COUNT=$(sed -n '/^SKILLS=(/,/^)/p' "$UNINSTALL_SH" | grep -oE 'vibe-[a-z-]+' | wc -l | tr -d ' ')

echo ""
echo "=== uninstall.sh tests ==="
echo ""

# Test 1: SKILLS array has 13 entries + vibe-code root
if [[ "$SKILL_COUNT" -eq 13 ]]; then
  pass "SKILLS array has 13 skills"
else
  fail "SKILLS array has 13 skills" "got $SKILL_COUNT"
fi

# Test 2: SKILLS in uninstall.sh matches install.sh
UNINSTALL_SKILLS=$(sed -n '/^SKILLS=(/,/^)/p' "$UNINSTALL_SH" | grep -oE 'vibe-[a-z-]+' | sort | tr '\n' ' ')
INSTALL_SKILLS=$(sed -n '/^SKILLS=(/,/^)/p' "$INSTALL_SH" | grep -oE 'vibe-[a-z-]+' | sort | tr '\n' ' ')
if [[ "$UNINSTALL_SKILLS" == "$INSTALL_SKILLS" ]]; then
  pass "uninstall.sh SKILLS matches install.sh"
else
  fail "uninstall.sh SKILLS matches install.sh" "mismatch"
fi

# Setup mock environment
MOCK_CODEX="$MOCK_HOME/.codex/skills"
MOCK_CLAUDE="$MOCK_HOME/.claude/skills"
MOCK_CURSOR="$MOCK_HOME/.cursor/skills"
mkdir -p "$MOCK_CODEX" "$MOCK_CLAUDE" "$MOCK_CURSOR"

# Test 3: removes symlink
touch "$MOCK_HOME/fake-skill-dir"
ln -s "$MOCK_HOME/fake-skill-dir" "$MOCK_CODEX/vibe-init"
HOME="$MOCK_HOME" bash "$UNINSTALL_SH" > /dev/null 2>&1
if [[ ! -L "$MOCK_CODEX/vibe-init" ]]; then
  pass "removes symlinked skill"
else
  fail "removes symlinked skill" "symlink still exists"
fi

# Test 4: removes directory (copy mode)
mkdir -p "$MOCK_CODEX/vibe-assess"
echo "fake" > "$MOCK_CODEX/vibe-assess/SKILL.md"
HOME="$MOCK_HOME" bash "$UNINSTALL_SH" > /dev/null 2>&1
if [[ ! -d "$MOCK_CODEX/vibe-assess" ]]; then
  pass "removes directory (copy-mode skill)"
else
  fail "removes directory (copy-mode skill)" "directory still exists"
fi

# Test 5: removes vibe-code root symlink
touch "$MOCK_HOME/vibe-code-root"
ln -s "$MOCK_HOME/vibe-code-root" "$MOCK_CODEX/vibe-code"
HOME="$MOCK_HOME" bash "$UNINSTALL_SH" > /dev/null 2>&1
if [[ ! -L "$MOCK_CODEX/vibe-code" ]]; then
  pass "removes vibe-code root symlink"
else
  fail "removes vibe-code root symlink" "symlink still exists"
fi

# Test 6: non-existent target dirs don't cause errors
rm -rf "$MOCK_HOME/.cursor"  # cursor dir removed intentionally
HOME="$MOCK_HOME" bash "$UNINSTALL_SH" > /dev/null 2>&1
EXIT_CODE=$?
if [[ "$EXIT_CODE" -eq 0 ]]; then
  pass "missing target dir handled gracefully (exit 0)"
else
  fail "missing target dir handled gracefully" "exit $EXIT_CODE"
fi

# Test 7: non-vibe files left untouched
touch "$MOCK_HOME/other-file"
ln -s "$MOCK_HOME/other-file" "$MOCK_CODEX/other-tool"
HOME="$MOCK_HOME" bash "$UNINSTALL_SH" > /dev/null 2>&1
if [[ -L "$MOCK_CODEX/other-tool" ]]; then
  pass "non-vibe symlinks left untouched"
else
  fail "non-vibe symlinks left untouched" "incorrectly removed"
fi

# Test 8: uninstall is idempotent (running twice doesn't error)
HOME="$MOCK_HOME" bash "$UNINSTALL_SH" > /dev/null 2>&1
EXIT2=$?
if [[ "$EXIT2" -eq 0 ]]; then
  pass "idempotent: second run exits 0"
else
  fail "idempotent: second run exits 0" "exit $EXIT2"
fi

# Test 9: processing all three target dirs
# Reset mock: create symlinks in all 3 target dirs
rm -rf "$MOCK_HOME"
mkdir -p "$MOCK_CODEX" "$MOCK_CLAUDE" "$MOCK_CURSOR"
touch "$MOCK_HOME/dummy"
ln -s "$MOCK_HOME/dummy" "$MOCK_CODEX/vibe-init"
ln -s "$MOCK_HOME/dummy" "$MOCK_CLAUDE/vibe-init"
ln -s "$MOCK_HOME/dummy" "$MOCK_CURSOR/vibe-init"
HOME="$MOCK_HOME" bash "$UNINSTALL_SH" > /dev/null 2>&1
REMAINING=0
[[ -L "$MOCK_CODEX/vibe-init" ]] && REMAINING=$((REMAINING + 1))
[[ -L "$MOCK_CLAUDE/vibe-init" ]] && REMAINING=$((REMAINING + 1))
[[ -L "$MOCK_CURSOR/vibe-init" ]] && REMAINING=$((REMAINING + 1))
if [[ "$REMAINING" -eq 0 ]]; then
  pass "cleans all 3 target dirs"
else
  fail "cleans all 3 target dirs" "$REMAINING symlinks remain"
fi

echo ""
echo "---"
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
