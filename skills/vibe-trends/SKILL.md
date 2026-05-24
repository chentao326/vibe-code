---
name: vibe-trends
description: 扫描项目相关趋势——依赖安全公告、上游 breaking changes、相关 issues。生成有时效性的任务。触发词："趋势"/"有什么新动向"/"trends"/"扫描依赖"。
allowed-tools: Bash(*), Read, Glob, Grep, WebFetch
---

# vibe-trends — 趋势扫描

## Workflow

### Phase 1: 识别依赖
从 package.json/pyproject.toml/go.mod/Cargo.toml 提取依赖。

### Phase 2: 并行扫描
- `npm audit` / `pip-audit` → 安全漏洞
- 核心依赖的最新版本检查
- GitHub issues（如有 repo URL）

### Phase 3: 输出
```
📡 趋势扫描
🔴 安全: lodash CVE-2026-xxxx → 立即升级
🟡 过期: next 14→15 有 breaking
🟢 机会: tailwindcss v4 新 API
💡 说 "展开 tasks/trend_xxx" 写成正式任务。
```
