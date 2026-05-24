#!/usr/bin/env python3
"""
accuracy-curve.py — 预估准确率收敛曲线

扫描 predictions/*.md，提取预估 vs 实际数据，计算并可视化准确率趋势。

Usage:
  python3 tools/accuracy-curve.py <project-dir>
"""

import json, os, sys, re
from datetime import datetime

def parse_prediction(filepath):
    """Extract prediction and actual data from a prediction file."""
    with open(filepath) as f:
        content = f.read()
    
    result = {"file": filepath}
    
    # Extract predicted iterations
    m = re.search(r'预计对话轮次\s*\|\s*(\d+)\s*[-–]\s*(\d+)', content)
    if m:
        result["pred_iter_low"] = int(m.group(1))
        result["pred_iter_high"] = int(m.group(2))
    
    # Extract predicted time
    m = re.search(r'预计耗时\s*\|\s*(\d+)\s*[-–]\s*(\d+)\s*min', content)
    if m:
        result["pred_time_low"] = int(m.group(1))
        result["pred_time_high"] = int(m.group(2))
    
    # Extract actual data from retro section
    m = re.search(r'对话轮次\s*\|\s*.*\|\s*(\d+)', content)
    if m:
        result["actual_iter"] = int(m.group(1))
    
    m = re.search(r'耗时\s*\|\s*.*\|\s*(\d+)\s*min', content)
    if m:
        result["actual_time"] = int(m.group(1))
    
    # Calculate accuracy
    if "pred_iter_low" in result and "actual_iter" in result:
        if result["pred_iter_low"] <= result["actual_iter"] <= result["pred_iter_high"]:
            result["iter_accurate"] = True
        else:
            result["iter_accurate"] = False
    
    if "pred_time_low" in result and "actual_time" in result:
        if result["pred_time_low"] <= result["actual_time"] <= result["pred_time_high"]:
            result["time_accurate"] = True
        else:
            result["time_accurate"] = False
    
    return result

def main():
    project_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    pred_dir = os.path.join(project_dir, "predictions")
    
    if not os.path.isdir(pred_dir):
        print("No predictions/ directory found.")
        sys.exit(1)
    
    results = []
    for f in sorted(os.listdir(pred_dir)):
        if f.endswith(".md") and not f.endswith("_redo.md"):
            r = parse_prediction(os.path.join(pred_dir, f))
            if "actual_iter" in r:
                results.append(r)
    
    if not results:
        print("No completed retrospections found.")
        return
    
    iter_acc = sum(1 for r in results if r.get("iter_accurate", False))
    time_acc = sum(1 for r in results if r.get("time_accurate", False))
    total = len(results)
    
    print(f"Calibration pool: {total} samples")
    print(f"Iteration accuracy: {iter_acc}/{total} ({iter_acc/total*100:.0f}%)")
    print(f"Time accuracy:      {time_acc}/{total} ({time_acc/total*100:.0f}%)")
    print()
    
    # Show per-task breakdown
    for r in results:
        fname = os.path.basename(r["file"]).replace(".md", "")
        iter_status = "✅" if r.get("iter_accurate") else "❌"
        time_status = "✅" if r.get("time_accurate") else "❌"
        print(f"  {fname}")
        print(f"    iter: {iter_status} (pred {r.get('pred_iter_low','?')}-{r.get('pred_iter_high','?')}, actual {r.get('actual_iter','?')})")
        print(f"    time: {time_status} (pred {r.get('pred_time_low','?')}-{r.get('pred_time_high','?')}min, actual {r.get('actual_time','?')}min)")

if __name__ == "__main__":
    main()
