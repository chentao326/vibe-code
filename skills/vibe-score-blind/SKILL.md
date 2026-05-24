---
name: vibe-score-blind
description: INTERNAL sub-agent for blind 5-dim rubric scoring. NOT user-facing — called via Task tool by vibe-assess/vibe-bump. Receives ONLY task_path + rubric_path. Hard refuses .vibe-state.json, predictions/*, retros/*. Outputs strict JSON: 5 dims × {score 0-5, confidence, reason}.
allowed-tools: Read, Glob, Grep
argument-hint: <task-path> <rubric-path>
---

# vibe-score-blind — Channel B (blind scorer sub-agent)

> ⚠️ 子 agent，非用户 skill。只能由 vibe-assess / vibe-bump 通过 Task tool spawn。

## Why this exists

主 AI 看过 git log、执行结果、历史复盘。inline 打分 = 被污染。Channel B 用全新 context——只看 task + rubric.md。

## Inputs（白名单）

| 必填 | 说明 |
|---|---|
| `<task-path>` | tasks/<id>.md 全文 |
| `<rubric-path>` | rubric.md 当前公式 |

仅此两个文件可读。

## 禁读（hard list）

| 路径 | refusal_code |
|---|---|
| `.vibe-state.json` | `blocked_contaminated_input` |
| `predictions/*.md` | `blocked_contaminated_input` |
| `retros/*/` | `blocked_contaminated_input` |
| `codebase-profile.md` | `blocked_profile` |
| 含"实际/耗时/完成/diff/lint/bug"的文件 | `blocked_contaminated_input` |

## Output（严格 JSON）

```json
{
  "dimensions": {
    "CS": {"score":4,"confidence":"high","reason":"文件路径和期望行为都写了"},
    "CX": {"score":2,"confidence":"high","reason":"仅涉及auth模块"},
    "AM": {"score":1,"confidence":"high","reason":"信息完整"},
    "TE": {"score":4,"confidence":"medium","reason":"有测试但验收标准偏主观"},
    "AQ": {"score":5,"confidence":"high","reason":"代码修复AI强项"}
  },
  "composite": 6.4,
  "input_status": {"rubric_read":true,"task_read":true,"any_other_file_read":false},
  "self_check": {"saw_execution_data":false,"any_contamination_signal":false},
  "refusal": null
}
```

## 主 AI 调用契约

Task prompt 仅含：
```
Spawn blind assessor sub-agent.
Input: task_path=<path>, rubric_path=rubric.md
Task: 按 rubric.md 打分。返回严格 JSON。不要读 state/predictions/retros。不要询问用户。
```

调用前自检：grep -Ei '实际|耗时|完成|diff|lint|bug|过去|上次'
