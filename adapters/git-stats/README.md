# Adapter: git-stats

自动采集 git 变更统计数据。

## 输出

JSON 写到 `retros/<task-id>/git-report.json`：

```json
{
  "files_changed": 3,
  "insertions": 45,
  "deletions": 12,
  "commits": 1,
  "modules_touched": ["auth"],
  "files": [
    {"path": "src/auth/token.ts", "insertions": 20, "deletions": 5}
  ]
}
```

## 依赖

- git（项目本身）

## 局限

- 只能看到 commit 之间的差异，看不到中间试错过程
- 需要 vibe-assess 时记录 start_commit（当前 HEAD）
