# Adapter: lint-collector

采集 lint 结果。自动检测项目使用的 lint 工具。

## 支持的 lint 工具

- ESLint（JavaScript/TypeScript）
- Ruff（Python）
- golangci-lint（Go）

## 输出

JSON 写到 `retros/<task-id>/lint-report.json`：

```json
{
  "errors": 0,
  "warnings": 1,
  "tool": "eslint",
  "issues": [
    {"file": "src/auth/token.ts", "line": 42, "rule": "no-unused-vars", "severity": "warning"}
  ]
}
```
