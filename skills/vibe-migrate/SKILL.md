---
name: vibe-migrate
description: 升级 .vibe-state.json 的 schema 版本。git pull 更新 vibe-code 后如 CHANGELOG 标 BREAKING/MINOR 需跑此命令。触发词："迁移"/"migrate"/"升级 schema"。
allowed-tools: Bash(*), Read, Write, Edit, Glob
---

# vibe-migrate — Schema 迁移

## Workflow

### Phase 1: 检测版本
对比 `.vibe-state.json` schema_version vs `migrations/registry.md` LATEST_SCHEMA。

### Phase 2: 确定路径
从版本链找到需要跑的迁移文件。

### Phase 3: 按序执行
每步读迁移文件的 HOW 段 → 执行 → 更新 schema_version。幂等，不跳版。

### Phase 4: 验证
schema_version == LATEST_SCHEMA + state 可解析 + 必填字段齐全。

## 失败处理
- 迁移文件缺失 → 报错提示版本链断裂
- 某步失败 → 停在当前版本，不回滚
- state 损坏 → 备份 + 重 init
