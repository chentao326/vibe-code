---
name: vibe-profile
description: 分析代码库特征画像——复杂度热点、依赖图、测试覆盖、churn 模式。等价于 cheat-persona 的受众画像——帮助 rubric 理解项目特征。触发词："分析项目"/"代码库画像"/"profile"/"项目特征"。
allowed-tools: Bash(*), Read, Glob, Grep
---

# vibe-profile — 代码库画像

分析代码库结构特征，写入 `codebase-profile.md`。

## Workflow

### Phase 1: 结构
- 目录树（depth 3）+ 文件类型分布 + 模块数

### Phase 2: 复杂度热点
- Top 10 最大文件 + Top 10 churn 文件

### Phase 3: 测试覆盖
- 有/无测试比例 + 无测试模块清单

### Phase 4: 依赖
- 核心依赖数 + 过期/不维护标记

### Phase 5: 写入 codebase-profile.md
纯参考文件，不进 blind sub-agent 白名单。

## 对 rubric 的影响
帮助 vibe-seed 精准选题、用户判断 AM、bump 时理解模块间差异。
