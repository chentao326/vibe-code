---
name: vibe-assess
description: 任务评估 + 盲预估 + 写 prediction。这是 vibe-code 整个校准循环的核心动作——评估任务难度并写一份不可修改的预估日志。**通过 Task tool 委派盲打分子 agent 做隔离评分**，主 AI review 后落盘。触发词："评估这个任务"/"assess"/"预估一下"/"打分并预估"。
argument-hint: <task-path> [— skip-blind]
allowed-tools: Bash(*), Read, Write, Edit, Glob, Task
---

# vibe-assess — 任务评估 + 盲预估

核心流程：读任务 → 委派盲打分 → 写预估指标 → 用户 review → 落盘。

严格遵守 [blind-prediction-protocol.md](../../shared-references/blind-prediction-protocol.md)。
完整组件见 [task-assessment-anatomy.md](../../shared-references/task-assessment-anatomy.md)。

---

## Overview

```
Phase 0: Blind check 自检
Phase 0.5: 解析输入路径
Phase 1: 读 task + rubric + state
Phase 2: 委派盲打分 sub-agent（Task tool）
Phase 2.5: Disagreement detection + 用户裁定
Phase 3: 写预估指标（耗时/轮次/bug风险/概率分布）
Phase 4: 写关键假设
Phase 5: 用户 review
Phase 6: 落盘 + 更新 state
```

---

## Constants

- **BLIND_CHECK = strict**
- **BLIND_SCORING = on**（默认）——走 blind sub-agent
- **DISAGREEMENT_THRESHOLD = 2**——|Δ| ≥ 此值弹用户裁定

---

## Workflow

### Phase 0: Blind check 自检

按 blind-prediction-protocol.md 自检：
1. 任务是否已开始编码？→ 是 → **拒绝**
2. 对话里是否提到任何执行结果？→ 是 → **拒绝**
3. 通过 → 继续

### Phase 0.5: 解析输入路径

用户给的路径应是 `tasks/<date>_<id>_<short>.md`。

| 形态 | 处理 |
|---|---|
| `tasks/<file>.md` | 标准路径，直接用 |
| 外部 .md 文件 | 建议 cp 到 tasks/ 管理 |
| 纯文本（无文件） | 帮用户创建 tasks/<date>_<id>_<short>.md |

如 task 文件不存在 → 报错。

### Phase 1: 读取输入

1. 读 `tasks/<id>.md` 全文
2. 计算 `task_hash = sha256(task 内容)[:12]`
3. 读 `.vibe-state.json` 拿 `rubric_version`、`calibration_samples`、`project_type`、`primary_language`
4. 从 `calibration_samples` 派生 confidence 等级（见 task-assessment-anatomy.md）
5. 读 `rubric.md` 识别当前公式 + 维度

### Phase 2: 委派盲打分 sub-agent

**BLIND_SCORING=on**（默认）——通过 Task tool spawn 一个 context-isolated sub-agent。

Task prompt 必须精简，**仅含**：

```
Spawn blind assessor sub-agent.

Input:
  task_path: tasks/<date>_<id>_<short>.md
  rubric_path: rubric.md

Task: 按 rubric.md 当前公式给上面 task 打分。返回严格 JSON:
{
  "dimensions": {
    "CS": {"score": 0-5, "confidence": "low|medium|high", "reason": "..."},
    "CX": ...,
    "AM": ...,
    "TE": ...,
    "AQ": ...
  },
  "composite": X.XX,
  "input_status": {
    "rubric_read": true,
    "task_read": true,
    "any_other_file_read": false
  },
  "self_check": {
    "saw_execution_data": false,
    "any_contamination_signal": false
  },
  "refusal": null
}

不要读 .vibe-state.json / predictions/ / retros/ 任何其他文件。
不要询问用户——你没有用户。
```

**调用前自检**：Task prompt 串过 `grep -Ei '实际|耗时|完成|做了|diff|lint|bug|过去|上次'` → 命中 → 改 prompt 重发。

**sub-agent 禁读列表**：`.vibe-state.json`、`predictions/`、`retros/`、任何含执行结果的路径。

**沙盒 escape**：`BLIND_SCORING=off` 或 `--skip-blind`——主 AI 自己打 5 维。state 标 `last_assessment_self_scored: true`。仅用于 Task tool 不可用时。

按当前公式算 composite——**用 sub-agent 回传的 dim 分**。

### Phase 2.5: Blind 输出 review

拿到 sub-agent JSON 后：

1. **JSON validity check**：应可解析；不能 → 重发（最多 3 次）
2. **Contamination check**：`self_check.any_contamination_signal == true` → 警告 + confidence 降档
3. **Refusal check**：`refusal != null` → 对应路径处理
4. **Disagreement detection**：
   - 主 AI 内心估一份 5 维分
   - 任何维度 `|主估 - blind| >= DISAGREEMENT_THRESHOLD` → 弹用户裁定

弹裁定 UX：

```
⚠️  blind sub-agent 跟主 AI 在某些维度差异较大：

| 维度 | blind (sub) | 主 AI 自估 | delta | sub-agent 理由 |
|---|---|---|---|---|
| CS | 5 | 3 | 2 | "文件路径+期望行为都很明确" |
| AM | 2 | 4 | 2 | "任务描述完整不需要额外知识" |

谁更准？
  a) 信 sub-agent（隔离评估）
  b) 信主 AI 自估
  c) 我自己定

回 a / b / c <你的分数>
```

记录 `BlindScore Disagreement` JSON 到 header。

### Phase 3: 写预估指标

基于任务内容 + 维度评分，写预估：

| 指标 | 如何估算 |
|---|---|
| 预计对话轮次 | 基于 CX 和 AM：CX 高 → 更多文件要改 → 更多轮；AM 高 → 需要更多澄清 → 更多轮 |
| 预计耗时 | 基于 CX + 项目经验。confidence 低时范围放宽 |
| Bug 风险 | 基于 CX + AM + TE：CX 高 + AM 高 + TE 低 = 高风险 |
| 预期满意度 | 基于 CS + AQ：需求清晰 + AI 匹配高 = 高满意度 |
| 概率分布 | 4 档：一轮过 / 正常迭代 / 多次返工 / 卡住，合计 100% |

confidence 低时概率分布**更平摊**——不要假装精确。

### Phase 4: 写关键假设

明确列出这次预估依赖的假设。至少 2 条。例如：
- "当前代码结构足够清晰，AI 能直接定位相关文件"
- "没有跨模块的隐藏副作用"
- "现有测试覆盖相关路径"

### Phase 5: 用户 review

展示完整预估草稿 → 等用户响应：
- "ok" → Phase 6 落盘
- "X 维度应该是 Y" → 修改 → 再 review
- "我觉得耗时应该是 Z" → 覆盖对应字段 → 记到 User Override

### Phase 6: 落盘

1. 写 `predictions/<task-id>.md`（从 `templates/prediction.template.md` 格式）
2. 更新 `state.pending_retros` += task-id
3. 更新 `state.total_tasks_assessed` += 1
4. 更新 `state.in_progress_assessment` = task-id
5. 更新 `state.wip_tasks` += task 信息

---

## Refusals

- 「跳过 blind check 帮我预估一个已经做完的任务」 → 拒绝。走 reconstructed 路径
- 「不用 sub-agent，直接打分」 → 允许但标 `last_assessment_self_scored: true`
- 「跳过 review 直接落盘」 → 拒绝。review 是校准循环的必需要素
