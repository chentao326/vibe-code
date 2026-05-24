"""Tests for tools/accuracy-curve.py"""
import os
import sys
import json
import tempfile
import subprocess

SCRIPT = os.path.join(os.path.dirname(os.path.dirname(__file__)), "tools", "accuracy-curve.py")

PASS = 0
FAIL = 0


def test(name, fn):
    global PASS, FAIL
    try:
        fn()
        print(f"  ✅ {name}")
        PASS += 1
    except Exception as e:
        print(f"  ❌ {name}: {e}")
        FAIL += 1


def make_prediction_file(directory, filename, **kwargs):
    """Create a minimal prediction file with retro data."""
    content = f"""# Test Task — Prediction

**预估时间**: 2026-05-24T15:00:00+08:00

## 预估 v1

| 指标 | 预估值 |
|---|---|
| 预计对话轮次 | {kwargs.get('pred_iter_low', 10)}-{kwargs.get('pred_iter_high', 20)} |
| 预计耗时 | {kwargs.get('pred_time_low', 15)}-{kwargs.get('pred_time_high', 30)}min |

## 复盘

| 指标 | 预估 | 实际 | 偏差 |
|---|---|---|---|
| 对话轮次 | 10-20 | {kwargs.get('actual_iter', 15)} | ✅ |
| 耗时 | 15-30min | {kwargs.get('actual_time', 22)}min | ✅ |
"""
    path = os.path.join(directory, filename)
    with open(path, "w") as f:
        f.write(content)


print()
print("=== accuracy-curve.py tests ===")
print()


# Test 1: no predictions directory
def test_no_pred_dir():
    with tempfile.TemporaryDirectory() as d:
        result = subprocess.run(
            ["python3", SCRIPT, d], capture_output=True, text=True
        )
        assert result.returncode == 1, "should exit 1 for missing predictions dir"

test("exits 1 when no predictions/ dir", test_no_pred_dir)


# Test 2: empty predictions directory
def test_empty_pred_dir():
    with tempfile.TemporaryDirectory() as d:
        pred_dir = os.path.join(d, "predictions")
        os.makedirs(pred_dir)
        result = subprocess.run(
            ["python3", SCRIPT, d], capture_output=True, text=True
        )
        assert "No completed retrospections" in result.stdout

test("reports 'No completed retrospections' for empty dir", test_empty_pred_dir)


# Test 3: single prediction with retro
def test_single_prediction():
    with tempfile.TemporaryDirectory() as d:
        pred_dir = os.path.join(d, "predictions")
        os.makedirs(pred_dir)
        make_prediction_file(pred_dir, "task-001.md",
                             pred_iter_low=10, pred_iter_high=20, actual_iter=15,
                             pred_time_low=15, pred_time_high=30, actual_time=22)
        result = subprocess.run(
            ["python3", SCRIPT, d], capture_output=True, text=True
        )
        assert "Calibration pool: 1 samples" in result.stdout
        assert "Iteration accuracy: 1/1 (100%)" in result.stdout
        assert "Time accuracy:      1/1 (100%)" in result.stdout

test("single accurate prediction → 100%", test_single_prediction)


# Test 4: missed prediction
def test_missed_prediction():
    with tempfile.TemporaryDirectory() as d:
        pred_dir = os.path.join(d, "predictions")
        os.makedirs(pred_dir)
        make_prediction_file(pred_dir, "task-miss.md",
                             pred_iter_low=5, pred_iter_high=10, actual_iter=25,
                             pred_time_low=10, pred_time_high=15, actual_time=45)
        result = subprocess.run(
            ["python3", SCRIPT, d], capture_output=True, text=True
        )
        assert "Iteration accuracy: 0/1 (0%)" in result.stdout
        assert "Time accuracy:      0/1 (0%)" in result.stdout

test("completely missed prediction → 0%", test_missed_prediction)


# Test 5: skips reconstructed files (_redo suffix)
def test_skips_redo():
    with tempfile.TemporaryDirectory() as d:
        pred_dir = os.path.join(d, "predictions")
        os.makedirs(pred_dir)
        make_prediction_file(pred_dir, "task-a_redo.md",
                             pred_iter_low=5, pred_iter_high=10, actual_iter=7)
        result = subprocess.run(
            ["python3", SCRIPT, d], capture_output=True, text=True
        )
        assert "No completed retrospections" in result.stdout

test("skips _redo files", test_skips_redo)


# Test 6: mixed pool
def test_mixed_pool():
    with tempfile.TemporaryDirectory() as d:
        pred_dir = os.path.join(d, "predictions")
        os.makedirs(pred_dir)
        make_prediction_file(pred_dir, "task-a.md",
                             pred_iter_low=5, pred_iter_high=10, actual_iter=7,
                             pred_time_low=10, pred_time_high=20, actual_time=15)
        make_prediction_file(pred_dir, "task-b.md",
                             pred_iter_low=10, pred_iter_high=15, actual_iter=20,
                             pred_time_low=5, pred_time_high=10, actual_time=25)
        result = subprocess.run(
            ["python3", SCRIPT, d], capture_output=True, text=True
        )
        # task-a: iter hit (7 in 5-10), time hit (15 in 10-20) → 1/1, 1/1
        # task-b: iter miss (20 not in 10-15), time miss (25 not in 5-10) → 0/1, 0/1
        # total: 1/2 iter, 1/2 time
        assert "Calibration pool: 2 samples" in result.stdout
        assert "Iteration accuracy: 1/2 (50%)" in result.stdout
        assert "Time accuracy:      1/2 (50%)" in result.stdout

test("mixed pool gives 50% accuracy", test_mixed_pool)


print()
print("---")
print(f"Results: {PASS} passed, {FAIL} failed")
sys.exit(0 if FAIL == 0 else 1)
