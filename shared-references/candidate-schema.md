# Candidate Schema（候选任务统一 schema）

被 vibe-seed、vibe-recommend、vibe-trends 引用。

所有候选任务（无论来源）使用统一 schema。

## 字段

```json
{
  "id": "seed_todo-rate-limit",
  "title": "auth 模块 rate limit 未处理",
  "source": "todo",
  "source_detail": "src/auth/token.ts:42 TODO: handle rate limit",
  "type": "tech-debt",
  "estimated_complexity": "medium",
  "files_touched": ["src/auth/token.ts"],
  "created_at": "2026-05-24"
}
```

| 字段 | 说明 |
|---|---|
| `id` | 唯一标识，格式: `<source>_<slug>` |
| `title` | 一句话描述 |
| `source` | todo / fixme / untested / churn / dependabot / trend / manual |
| `source_detail` | 来源的具体引用（文件:行号 或 commit SHA） |
| `type` | tech-debt / dependency / testing / refactor / feature / security |
| `estimated_complexity` | simple / medium / complex（粗估，非 rubric 打分） |
| `files_touched` | 预计涉及的文件 |
| `created_at` | 候选生成日期 |

## 候选生命周期

```
[扫描生成] → [用户选中] → [展开为正式task] → [进入 vibe-assess 流程]
                 ↘ [用户跳过] → [标记 skipped，6个月内不重复推荐]
```
