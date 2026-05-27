---
name: vibe-retro
description: 任务完成后复盘对账——采集实际数据、对比预估 vs 实际、分析偏差原因、写入观察。触发词："复盘"/"retro"/"对账"/"这个任务做完了"。
argument-hint: <task-id> | <prediction-path>
allowed-tools: Bash(*), Read, Write, Edit, Glob, Grep
---

# vibe-retro — 复盘对账

编码完成后的复盘：采集数据 → 对比预估 → 偏差分析 → 写入观察 → 检查 bump 触发。

---

## Overview

```
Phase 0: 确认任务状态
Phase 0.1: Handoff phase detection（融合）
Phase 1: 读 prediction 文件 + 缓存预估段 hash
Phase 2: 采集实际数据（adapters + 用户输入 + handoff 数据）
Phase 3: 对比预估 vs 实际
Phase 4: 写入复盘段
Phase 5: 校验 immutability
Phase 6: 更新 state + rubric.md
```

---

## Workflow

### Phase 0: 确认任务状态

1. 确认用户已完成编码（或放弃）
2. 如放弃 → 标 `status: abandoned`，不计入 calibration_samples，但保留 prediction 文件

### Phase 0.1: Handoff phase detection（融合协议）

根据 [handoff-vibe-bridge.md](../../shared-references/handoff-vibe-bridge.md) 检测当前 handoff 阶段：

```bash
ls handoff/*.json 2>/dev/null || echo "NO_FILES"
```

| handoff 状态 | 处理 |
|---|---|
| `handoff/build-done.json` 存在 | ✅ **自动触发复盘**——无需用户手动确认。读取 `files_changed`、`completed_tasks` 作为数据源 |
| `handoff/` 有其他文件但无 build-done | 正常复盘，标注 `handoff_phase: <当前阶段>` |
| `handoff/` 为空 | 正常复盘，标注 `handoff_phase_unknown: true` |

**如果 build-done.json 存在**：
1. 解析 `files_changed` 列表 → 传给 Phase 2 adapters
2. 解析 `completed_tasks` → 用于偏差分析
3. 复盘完成后更新 `.vibe-state.json` 的 `handoff_phase` 为 `review-ready`


### Phase 1: 读 prediction 文件

1. 根据 task-id 找到 `predictions/<task-id>.md`
2. 缓存 `## 预估 v1` 段 hash（后续校验用）
3. 读预估数据（轮次/耗时/bug风险/满意度/关键假设）

### Phase 2: 采集实际数据

**如果 `state.data_collection = "auto"`**：

运行 adapters：

```
# git-stats: 从 task 开始时的 HEAD 到当前 HEAD 的 diff
cd <user-project>
bash <vibe-code-path>/adapters/git-stats/collect.sh <task-id> <start-commit>

# lint-collector: 当前 lint 状态
bash <vibe-code-path>/adapters/lint-collector/collect.sh <task-id>
```

如果 adapter 输出成功 → 写入 `retros/<task-id>/report.md`

**如果 `state.data_collection = "manual"`**：

询问用户：

```
📊 复盘需要以下数据：

1. 实际对话轮次？（预计 {{pred_iter}}）
2. 实际耗时？（预计 {{pred_time}}）
3. 有 bug 吗？几个？
4. 满意度 1-10？（预计 {{pred_sat}}）
5. 有什么意外情况？
```

### Phase 3: 对比预估 vs 实际

逐项对比：

| 对比项 | 判定 |
|---|---|
| 轮次在预估范围内 | ✅ 命中 |
| 轮次低于预估下限 | ✅ 高估（好于预期） |
| 轮次高于预估上限 | ❌ 低估（差于预期） |
| 耗时同理 | — |
| Bug 风险预估 vs 实际 | — |
| 满意度预估 vs 实际 | — |

**偏差方向**：如果连续 ≥3 次同向偏差 → 标记 `consecutive_directional_errors` + 在状态报告里提示"可能该 bump 了"。

### Phase 4: 写入复盘段

追加到 prediction 文件末尾（不动预估段），格式按 `templates/retro.template.md`。

必须包含：
- 实际数据表（预估 vs 实际 vs 偏差）
- 哪些被验证 ✅
- 哪些被推翻 ❌
- 新观察（带证据，写入 `rubric.md` 观察段）
- 主观复盘笔记

### Phase 5: 校验 immutability

确认预估段 hash 未变：
- 一致 → 通过
- 不一致 → 在复盘段开头追加 `**Integrity warning**: 预估段于复盘时发现已被修改，无法保证盲度。本次复盘不计入校准池`

### Phase 6: 更新状态

1. `state.calibration_samples` += 1
2. `state.pending_retros` 移除该 task-id
3. `state.wip_tasks` 移除该 task
4. `state.total_tasks_completed` += 1
5. `state.in_progress_assessment` = null
6. `state.last_retro_at` = 当前时间

**检查 bump 触发条件**：
- `calibration_samples >= 5` + 有清晰偏差方向？
- → 提示用户："校准池已有 N 个样本，可以考虑 `/vibe-bump` 升级评估模型"

**写入 rubric.md 观察段**：
- 有新观察 → 追加到 `## 待验证观察` 段
- 格式：`### YYYY-MM-DD [任务简称] — [一句话定性]` + 证据数据
- 遵守 observation-lifecycle.md

---

## 与 vibe-assess 的衔接

`vibe-assess` 在落盘时记录的 `task_hash` 和 `start_commit`（如 adapter 支持）是本 skill 的输入。如果 task 文件在评估后被修改过：
- 在复盘段标注 `**Task modified after assessment**`
- hash 不一致不影响复盘——但说明任务描述在预估后有变化

---

## 反模式

- 「跳过数据采集直接写复盘」 → 拒绝。没有实际数据就不是复盘
- 「预估全错能不能删了重写」 → 拒绝。预估段 immutable —— 复盘段里分析为什么全错更有价值
- 「这次太差了不想计入校准池」 → 拒绝。差样本是模型进化最重要的数据——如果 rubric 只见到"好预测"，永远不知道边界在哪
