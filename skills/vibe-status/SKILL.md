---
name: vibe-status
description: 状态看板——渲染当前项目状态（校准进度/WIP/待复盘/准确率趋势/bump 触发状态）。只读，无副作用。触发词："状态"/"看板"/"status"/"我现在该做什么"。
allowed-tools: Bash(*), Read, Glob
---

# vibe-status — 状态看板

只读，无副作用。任何时候都可以调用。

---

## 工作流

### Phase 1: 读取 state + handoff 阶段

1. 读 `.vibe-state.json` 所有字段
2. 检测 handoff 阶段：
```bash
ls handoff/*.json 2>/dev/null || echo "NO_FILES"
```
3. 将 handoff 阶段与 vibe 校准数据合并渲染

### Phase 2: 渲染看板

输出格式：

```
📊 Vibe Code — 状态看板

Rubric: v0 | 校准池: 5 samples | Confidence: 🟡 偏低

---

📝 WIP（进行中）
  • tasks/fix-auth.md — assessed 2026-05-24

⏰ 待复盘（共 2 个）
  • predictions/fix-auth.md — overdue（完成于 2026-05-22）
  • predictions/add-cache.md — ready

📈 统计
  总评估: 8 | 已完成: 5 | 已放弃: 1 | 准确率趋势: ↗ 上升

⚠️ 提醒
  • 校准池 5 个样本，可以考虑 bump 升级模型
  • 2 个任务待复盘，建议先复盘再评估新任务
```

---

## Handoff 状态（融合协议）

根据 [handoff-vibe-bridge.md](../../shared-references/handoff-vibe-bridge.md) 同步显示 handoff 阶段。

### 检测命令

```bash
ls handoff/*.json 2>/dev/null || echo "NO_FILES"
```

### 阶段展示

| 信号文件 | 展示 |
|---|---|
| (无) | 🔵 Init — "等待写 spec" |
| `plan-ready.json` | 🟡 Plan Ready — "等待编码" |
| `build-done.json` | 🟢 Build Done — "等待 review / 可以复盘" |
| `review-fixes.json` | 🟠 Fixes Needed — "等待修复" |
| `polish-done.json` | 🟡 Polish Done — "等待重审" |
| `review-passed.json` | 🟢 Review Passed — "等待提交" |
| `committed.json` | ✅ Done — "已完成" |

### 看板展示格式

```
## 🔄 Handoff 状态
  模式: codex-self-handoff
  阶段: build-done → 等待 review
  Feature: post-review-fixes

## 📊 Vibe 校准
  Rubric: v1 | 校准池: 6 | Confidence: 🟢 中
  （后续跟现有 vibe 看板内容）
```


## 自动检测项

| 检测 | 条件 | 提醒 |
|---|---|---|
| Bump 建议 | calibration_samples ≥5 + 未 bump 过 | "可以考虑升级模型" |
| 复盘积压 | pending_retros ≥3 | "建议先复盘再评估新任务" |
| 偏差警告 | consecutive_directional_errors ≥3 | "连续3次同向偏差，rubric可能系统性不准" |
| 自评分警告 | last_assessment_self_scored == true | "上次评估没有走 blind sub-agent" |
| WIP 积压 | wip_tasks ≥5 | "建议先完成已有任务" |
| Rubric 健康 | rubric.md 行数 >500 | "rubric.md 可能需要清理" |

---

## 信心等级展示

| calibration_samples | 展示 |
|---|---|
| 0 | 🔴 极低 — "占星级别，纯纪律训练" |
| 1-2 | 🟠 低 — "方向感优于绝对数字" |
| 3-5 | 🟡 偏低 — "可作为参考之一" |
| 6-10 | 🟢 中 — "可参与决策" |
| 11+ | 🔵 高 — "值得信赖" |
