# State Management（状态文件读写约定）

被所有子 skill 引用。`.vibe-state.json` 是各子 skill 共享上下文的**单一来源**。

---

## 文件位置

```
<user-project>/.vibe-state.json
```

每个项目独立状态。

---

## 完整 schema

```json
{
  "schema_version": "1.1",
  "skill_version": "1.0.0",

  "rubric_version": "v0",
  "project_type": "web-app",
  "primary_language": "typescript",

  "calibration_samples": 0,
  "calibration_samples_at_last_bump": 0,

  "total_tasks_assessed": 0,
  "total_tasks_completed": 0,
  "total_tasks_abandoned": 0,

  "historical_imports": 0,

  "project_age_days": null,
  "total_commits_at_init": null,

  "data_collection": "auto",
  "enabled_adapters": ["git-stats"],

  "hooks_installed": false,

  "last_bump_at": null,
  "last_bump_self_audited": false,
  "last_retro_at": null,
  "last_assessment_self_scored": false,

  "wip_tasks": [],
  "pending_retros": [],

  "consecutive_directional_errors": [],

  "in_progress_assessment": null,

  "handoff_mode": "self-handoff",
  "handoff_phase": "init",
  "handoff_feature": null,
  "last_handoff_signal_at": null,

  "initialized_at": "2026-05-24T15:00:00+08:00"
}
```

---

## 字段说明

| 字段 | 类型 | 写入者 | 说明 |
|---|---|---|---|
| `schema_version` | string | vibe-init/migrate | "1.0" |
| `rubric_version` | string | vibe-init/bump | 当前评估公式版本 |
| `project_type` | string | vibe-init | web-app/cli/lib/mobile/other |
| `primary_language` | string | vibe-init | 主要编程语言 |
| `calibration_samples` | int | vibe-retro | 有真正盲预估+复盘的任务数。**历史导入不计入此字段** |
| `historical_imports` | int | vibe-init | 从 git 历史导入的 reconstructed 任务数（仅已有项目）。参考价值，不进校准池 |
| `project_age_days` | int\|null | vibe-init | 项目从首次 commit 到今天的天数。仅已有项目填充 |
| `total_commits_at_init` | int\|null | vibe-init | 初始化时的总 commit 数。仅已有项目填充 |
| `data_collection` | string | vibe-init | auto/manual |
| `enabled_adapters` | string[] | vibe-init | 启用的 adapter 列表 |
| `wip_tasks` | object[] | vibe-assess/retro | 进行中的任务 |
| `pending_retros` | string[] | vibe-assess/retro | 待复盘的任务 ID |
| `in_progress_assessment` | object\|null | vibe-assess/retro | 当前评估中的任务 |
| `handoff_mode` | string | vibe-init | claude-handoff / self-handoff / none |
| `handoff_phase` | string | handoff skills + vibe-retro | 当前 handoff 阶段 |
| `handoff_feature` | string\|null | handoff skills | 当前 feature 名称 |
| `last_handoff_signal_at` | string\|null | handoff skills | 最后一次信号写入时间 |

---

## 写入规则

**每个字段只有一个唯一写入者**——防止状态语义破碎。

| 字段 | 唯一写入者 |
|---|---|
| `calibration_samples` | vibe-retro（仅当非 reconstructed 时 +1） |
| `historical_imports` | vibe-init（Phase 3.5 历史导入时） |
| `project_age_days` | vibe-init（初始化时一次性） |
| `total_commits_at_init` | vibe-init（初始化时一次性） |

---

## 与 git 的关系

- `.vibe-state.json` **应该**被纳入 git（项目配置 + 累计指标快照）
- `.vibe-cache/` **不**纳入 git（设备本地状态）
