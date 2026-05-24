# 为 lint-collector 编写测试 — 预估日志

**Task ID**: h0i1j2
**Title**: 为 lint-collector 适配器编写测试
**Rubric**: v0 | **综合分**: 6.8 (CS=5 CX=1 AM=2 TE=4 AQ=5)
**Confidence**: 🟡 | **Calibration Samples**: 4
**BlindScored By**: sub-agent | **Disagreement**: none
**User Override**: auto-confirmed

---

## 预估 v1

| 指标 | 预估 |
|---|---|
| 对话轮次 | 3-5 |
| 耗时 | 5-10min |
| Bug 风险 | 🟡 中（PATH mock + command -v 行为有坑） |
| 满意度 | 8/10 |
| 一轮过 | 45% |

**关键假设**:
1. `command -v` 在 PATH override 下的行为稳定
2. lint-collector 的 `npx eslint --format json` 在 mock 场景可能因无 npx 而fallback
3. 三路检测的优先级顺序正确（eslint > ruff > golangci-lint）

---

## 复盘

**实际**: 4 轮 / ~5min / 2 bug | 全部指标 ✅

| 指标 | 预估 | 实际 |
|---|---|---|
| 轮次 | 3-5 | 4 |
| 耗时 | 5-10min | ~5min |
| Bug | 🟡 中 | 2（PATH 隔离 + lint-collector JSON 格式错误） |
| 满意度 | 8/10 | 9/10 |

- 测试暴露了 lint-collector 的真实 bug：tool=none 时 `LINT_OUTPUT=""` 导致 `"output": ` 无值，JSON 非法。修了 1 行。
- 第 2 个 bug 是测试自身：PATH="$EMPTY_BIN" 太干净导致 mkdir 找不到。补充 /bin:/usr/bin。
- CX=1 连续第 4 个全中：该模式的预估精度已稳定。

**Re-scored under v1 on 2026-05-24**: composite recalculated with CX×1.5 + TE×1.5 formula.
