# {{TASK_TITLE}} — 预估日志

**Task ID**: {{task_id}}
**Title**: {{title}}
**Rubric Version**: v0
**预估时间**: {{timestamp}}
**Task Path**: tasks/{{task_file}}
**Task Hash**: {{task_hash}}
**Calibration Samples (at assess time)**: {{calibration_samples}}
**Confidence**: {{confidence_emoji}} {{confidence_label}} ({{confidence_range}})
**Scored By**: claude
**BlindScored By**: subagent-v1
**BlindScore Disagreement**: {{disagreement_json}}
**User Override**: none
**预估时数据状态**: blind（未开始编码）

---

## 任务快照

{{task_summary}}

---

## 维度评分

| 维度 | 分数 | 信心 | 理由 |
|---|---|---|---|
| CS | {{cs}} | {{cs_confidence}} | {{cs_reason}} |
| CX | {{cx}} | {{cx_confidence}} | {{cx_reason}} |
| AM | {{am}} | {{am_confidence}} | {{am_reason}} |
| TE | {{te}} | {{te_confidence}} | {{te_reason}} |
| AQ | {{aq}} | {{aq_confidence}} | {{aq_reason}} |

**综合分**: {{composite}} / 10

---

## 预估 v1 ⭐ IMMUTABLE

### 📊 预估指标

| 指标 | 预估值 |
|---|---|
| 预计对话轮次 | {{predicted_iterations}} |
| 预计耗时 | {{predicted_time}} |
| Bug 风险 | {{bug_risk}} |
| 预期满意度 | {{predicted_satisfaction}}/10 |

### 🎲 概率分布

| 结果 | 概率 |
|---|---|
| 一轮过 | {{p_one_shot}}% |
| 正常迭代 | {{p_normal}}% |
| 多次返工 | {{p_redo}}% |
| 卡住 | {{p_stuck}}% |

---

## 关键假设

{{assumptions}}

---

## 复盘 ⬜

（待 vibe-retro 追加）
