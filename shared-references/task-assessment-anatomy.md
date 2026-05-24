# Task Assessment Anatomy（评估日志解剖）

被 `vibe-assess`、`vibe-retro` 引用。

所有评估都用统一格式——5 个必备组件 + 复盘段。

---

## 5 个必备组件

### 组件 1：File header

```markdown
# <任务标题> — 预估日志

**Task ID**: <sha256:12>
**Title**: <任务完整标题>
**Rubric Version**: v0
**预估时间**: 2026-05-24T15:00:00+08:00
**Task Path**: tasks/<date>_<id>_<short>.md
**Task Hash**: <sha256:12>
**Calibration Samples (at assess time)**: 3
**Confidence**: 🟡 偏低 (±40%)
**Scored By**: claude
**BlindScored By**: subagent-v1
**BlindScore Disagreement**: <JSON>
**User Override**: none
**预估时数据状态**: blind（未开始编码）
```

### 组件 2：任务快照

记录评估时的任务描述摘要 + 关键上下文（涉及模块、依赖、约束）。

### 组件 3：预估 v1 ⭐ IMMUTABLE

核心预测指标：

| 指标 | 说明 |
|---|---|
| 预计对话轮次 | 预计需要几轮对话完成 |
| 预计耗时 | 分钟 |
| Bug 风险 | 🔴高 / 🟡中 / 🟢低 |
| 预期满意度 | 1-10（做完后预计的满意程度） |

+ 概率分布（一轮过/正常迭代/多次返工/卡住的概率，合计 100%）

### 组件 4：关键假设

明确写下这次预估依赖的假设。例如：
- "auth 模块代码结构清晰，AI 能直接定位"
- "没有隐藏的跨模块副作用"

### 组件 5：维度评分表

| 维度 | 分数 | 信心 | 理由 |
|---|---|---|---|
| CS | 4 | high | ... |
| CX | 2 | high | ... |
| AM | 1 | high | ... |
| TE | 4 | medium | ... |
| AQ | 5 | high | ... |

**综合分**: X.X / 10

---

## 复盘段（组件 ∞，仅追加）

```markdown
## 复盘

**复盘时间**: 2026-05-24T15:45:00+08:00
**数据来源**: auto（adapter: git-stats + lint-collector）

### 实际数据

| 指标 | 预估 | 实际 | 偏差 |
|---|---|---|---|
| 对话轮次 | 3-5 | 4 | ✅ |
| 耗时 | 15-25min | 22min | ✅ |
| 文件改动 | — | 3 files, +45/-12 | — |
| Lint 新增 | — | 0 errors, 1 warning | — |

### 哪些预估被验证 / 推翻

**被验证 ✅**:
- ...

**被推翻 ❌**:
- ...

### 需要写进 rubric.md 的新观察
- ...
```

---

## 完整结构

```
file: predictions/<date>_<id>_<short>.md

# 标题 — 预估日志              ← 组件 1: header
（metadata block）

## 任务快照                     ← 组件 2

## 维度评分                     ← 组件 5

## 预估 v1 ⭐ IMMUTABLE         ← 组件 3: 核心预估

## 关键假设                     ← 组件 4

## 复盘                         ← 仅追加，IMMUTABLE 边界
```

## Confidence 派生表

| calibration_samples | confidence | 含义 |
|---|---|---|
| 0 | 🔴 极低 | 纯猜测，纪律训练 |
| 1-2 | 🟠 低 | 方向感优于绝对数字 |
| 3-5 | 🟡 偏低 | 可作为参考 |
| 6-10 | 🟢 中 | 可参与决策 |
| 11-20 | 🟢 较高 | 可信 |
| 21+ | 🔵 高 | 数据驱动 bump |
