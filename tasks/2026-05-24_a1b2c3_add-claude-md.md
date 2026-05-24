# 为 vibe-code 项目创建 CLAUDE.md

**创建日期**: 2026-05-24
**状态**: pending

---

## 目标

在项目根目录创建 `CLAUDE.md`，让 Claude Code 在每次 session 启动时自动理解项目约定、目录结构和 skill 体系。

## 上下文

- 项目是一个 Claude Code skill 集合（vibe-code），包含 13 个子 skill + 7 份协议 + adapters/hooks/templates
- 当前没有任何 CLAUDE.md 或项目级指令文件
- 目标读者是 Claude Code（不是人类开发者），内容应精简、结构化、可被 AI 高效解析
- 需要覆盖：项目定位、目录结构、核心约定、skill 体系、关键规则

## 具体需求

1. 写明项目定位：vibe-code 是什么、解决什么问题
2. 描述目录结构（一行一个目录 + 用途，不超过 10 行）
3. 列出 3 条不可妥协原则（从 SKILL.md 提取）
4. 列出所有 skill 及其一句话描述
5. 说明 .vibe-state.json 的作用和 schema 位置
6. 说明盲预估协议的核心规则（predictions/ 文件的预估段不可编辑）
7. 控制在 100 行以内——这是给 AI 读的指令，不是人类文档

## 验收标准

- `CLAUDE.md` 存在于项目根目录
- 文件 ≤ 100 行
- 包含以上 7 项内容
- 不含 emoji（保持与项目风格一致）
- 能被 `cat CLAUDE.md | wc -l` 验证行数

## 约束

- 不重复 README.md 的完整内容——README 是人类文档，CLAUDE.md 是 AI 指令
- 参考 SKILL.md 的第 1-2 部分（路由表和原则），但不要照搬
