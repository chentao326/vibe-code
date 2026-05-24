---
name: vibe-bump
description: 升级评估模型（rubric）。校准池 ≥5 个样本后可提议调整维度权重、增减维度。强制 5 步流程 + 跨模型审核。触发词："升级模型"/"bump rubric"/"调整维度"/"更新公式"。
argument-hint: --propose "<新公式描述>"
allowed-tools: Bash(*), Read, Write, Edit, Glob, Grep, Task, mcp__llm-chat__chat
---

# vibe-bump — 升级评估模型

严格遵守 [bump-validation-protocol.md](../../shared-references/bump-validation-protocol.md)。

---

## Overview

```
Phase 0: 前置门槛检查
Phase 1: 写出新公式完整方程
Phase 2: 校准池全量重打分（强制 blind sub-agent）
Phase 3: 计算排序一致性
Phase 4: 跨模型独立审核
Phase 5: 落地 + cleanup
```

---

## Constants

- **THRESHOLD = 0.8** — 排序一致性阈值（4/5），刚性不可改
- **CROSS_MODEL_AUDIT = true** — 默认开启跨模型审核
- **MIN_SAMPLES_FOR_BUMP = 5** — 首次 bump 最低门槛

---

## Workflow

### Phase 0: 前置门槛检查

| 检查项 | 失败处理 |
|---|---|
| calibration_samples ≥ 5？ | 不满足 → 说明原因 + 拒绝（除非强反例如 ≥3x 偏差，标 judgment-driven） |
| 有 ≥1 个新样本自上次 bump？ | 不满足 → 拒绝 |
| in_progress_assessment == null？ | 不满足 → 拒绝 |
| 有清晰偏差方向？ | 询问用户为什么现在 bump |

通过 → 进入 Phase 1。

### Phase 1: 写出新公式完整方程

用户描述要改什么 → AI 帮助写出完整的方程。

示例：
```
v0: composite = (CS×1.0 + CX×1.0 + AM×1.0 + TE×1.0 + AQ×1.0) / 5 × 2.0
v1: composite = (CS×1.5 + CX×1.0 + AM×1.0 + TE×1.5 + AQ×1.0) / 6 × 2.0
```

**不允许**只说"CS 权重提高"——必须完整方程。

### Phase 2: 校准池全量重打分

校准池 = 所有 `predictions/*.md` 有完整复盘段的文件。

**强制走 blind sub-agent**（不接受 self-scored fallback）：
1. 对每个校准样本，Task tool spawn sub-agent
2. sub-agent 只读 task 原文件 + 新公式 rubric.md
3. sub-agent 输出新的 N 维分
4. 用新公式重新计算 composite

**sub-agent 禁读**：所有 prediction 文件、retro 段、state 文件——只读 task 原文和新 rubric。

### Phase 3: 计算排序一致性

对新 composite 排序 vs 实际"效率"排序：

效率定义：`1 / (耗时_min × 迭代次数 × (bug数 + 1))`

- 计算 Spearman rank correlation
- 检查 pairwise 顺序是否颠倒
- 满足 ≥4/5 样本排序一致 → 通过

### Phase 4: 跨模型独立审核

打包以下发给外部 LLM：
- 旧公式 + 新公式
- 校准池数据（每样本：维度分、新旧 composite、实际耗时/轮次/bug）
- Step 3 排序对照表

外部 LLM 判定：**PASS** / **REJECT** + ≥100 字理由。

本地 + 外部都通过 → Step 5。

### Phase 5: 落地 + cleanup

1. 更新 `rubric.md` 顶部版本 + 公式
2. 写入"升级 Memo"段（触发原因/证据/新公式/局限）
3. 删除被吸收为维度或被推翻的观察（observation-lifecycle.md）
4. 未解决观察 → 迁移到"待验证假设"
5. 所有校准样本 prediction 文件底部追加 `**Re-scored under v1 on YYYY-MM-DD**: composite=X.XX → Y.YY`
6. 更新 state: `rubric_version` += 1, `last_bump_at` = now, `calibration_samples_at_last_bump` = current

---

## Bump 被拒处理

| 失败位置 | 处理 |
|---|---|
| Step 3 排序不一致 | 候选公式回退。**不允许**放宽 THRESHOLD |
| Step 4 外部 REJECT | 记录外部理由到 rubric.md |
| Step 4 双方冲突 | 视为 REJECT |
