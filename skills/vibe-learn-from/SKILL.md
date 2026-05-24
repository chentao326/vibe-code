---
name: vibe-learn-from
description: 从优秀开源项目反向提取代码质量标准，写入 benchmark.md 作为你的 rubric 调整参考。触发词："学这个项目"/"对标"/"learn from"/"分析这个仓库"。
argument-hint: <github-url> | <local-path>
allowed-tools: Bash(*), Read, Write, Edit, Glob, Grep, WebFetch
---

# vibe-learn-from — 对标项目学习

从优秀开源项目提取代码质量标准，写入 `benchmark.md`。

---

## Workflow

### Phase 1: 获取项目

- GitHub URL → clone 到临时目录或直接通过 GitHub API 分析
- 本地路径 → 直接分析

### Phase 2: 分析代码质量特征

逐项分析并记录：

**目录结构规律**：
- 模块如何组织？
- 测试文件放哪里？
- 配置文件管理方式？

**测试覆盖模式**：
- 测试文件命名（`*.test.ts` / `*_test.py` / `test_*.go`）？
- 测试覆盖率风格（单元/集成/E2E 比例）？
- Mock/Fixture 管理方式？

**命名规范**：
- 函数/变量命名风格？
- 文件命名约定？
- 类型/接口命名？

**错误处理模式**：
- 如何处理错误？（throw / Result type / error return）
- 边界情况处理方式？
- 日志/监控方式？

**API 设计风格**：
- 函数签名偏好（参数数量/类型/返回值）？
- 模块间接口设计？
- 配置 vs 约定？

### Phase 3: 写入 benchmark.md

```
# 对标项目参考

**项目**: react
**仓库**: https://github.com/facebook/react
**导入日期**: 2026-05-24

## 代码质量特征

### 目录结构规律
- packages/ 下每个包独立

### 测试覆盖模式
- __tests__/ 目录 + *-test.js 文件

...
```

### Phase 4: 关联到 rubric

分析完后提示：

```
✅ 对标分析完成。

你当前的 rubric 是 v0 等权起步。以下 feature 可能值得在你的 rubric 里增加权重或细化：

- 测试覆盖：对标项目有严格的测试规范，建议关注 TE 维度
- 错误处理：对标项目的错误边界设计值得学习，当前 rubric 无对应维度

建议：跑 5 个任务后，对比你的数据和对标标准，再决定是否 bump。
```
