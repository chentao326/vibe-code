---
name: vibe-score
description: 给任务描述快速打分——只在控制台输出，不写文件，不预测。是 vibe-assess 之前的轻量探索动作，适合快速 triage 多个任务。触发词："打分这篇"/"score this"/"先打个分看看"/"这个任务几分"。
argument-hint: <task-path>
allowed-tools: Bash(*), Read, Glob
---

# vibe-score — 轻量打分

只输出到控制台，不写 prediction 文件，不预估，不落盘。

## 与 vibe-assess 的区别

| | vibe-score | vibe-assess |
|---|---|---|
| 落盘 | ❌ | ✅ predictions/*.md |
| 预估 | ❌ | ✅ 耗时/轮次/bug |
| 盲打分 | ❌ inline | ✅ blind sub-agent |
| 用途 | 快速 triage、比较 | 正式评估、进校准循环 |

## Workflow

### Phase 1: 读 task + rubric
读 `tasks/<id>.md` 和 `rubric.md`。

### Phase 2: 打分
按当前公式打 5 维分 + 综合分。

### Phase 3: 输出
```
📊 快速打分: <标题>
| CS | 4 | 需求清晰 |
| CX | 2 | 影响面小 |
| AM | 1 | 信息完整 |
| TE | 3 | 可验证 |
| AQ | 5 | AI 强项 |
综合分: 6.0 / 10
💡 正式评估请用 "评估这个任务" ——走盲打分+预估。
```
不写文件，不更新 state。
