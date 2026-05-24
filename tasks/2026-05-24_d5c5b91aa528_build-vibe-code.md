# 构建 vibe-code 项目 v1.0.0

**创建日期**: 2026-05-24
**状态**: completed

---

## 目标

基于 cheat-on-content 的方法论，从零构建 vibe-code——一个面向 vibe coding 开发者的可校准评估系统。

## 上下文

- 参考项目：cheat-on-content（XBuilderLAB），已在本地 `/Users/chentao/Applications/cheat-on-content/cheat-on-content/`
- 目标：将"打分→盲预测→复盘→进化"的内容创作闭环移植到软件工程领域
- 输出：38 个文件、3674 行，涵盖 7 个 skill、7 份协议、6 份模板、3 个 adapter、2 个 hook

## 具体需求

1. 写工程设计文档（DESIGN.md，1166行）：需求分析→领域建模→架构设计→组件契约→实施路线
2. 写总协议 SKILL.md：路由表 + 三条原则 + Agent 兼容说明
3. 写 7 份共享协议（blind-prediction / bump-validation / observation-lifecycle / task-assessment-anatomy / state-management / cadence / migration）
4. 写 6 份脚手架模板（rubric / task / prediction / retro / benchmark / status）
5. 写 7 个子 skill（vibe-init / vibe-assess / vibe-retro / vibe-bump / vibe-status / vibe-learn-from / vibe-recommend）
6. 写 3 个数据采集 adapter（git-stats / lint-collector / time-tracker）
7. 写 2 个 hook（prediction-immutability / session-start）
8. 写 README / CHANGELOG / install.sh / uninstall.sh / .gitignore
9. 写 v0 starter rubric
10. 写 accuracy-curve.py 工具

## 验收标准

- 所有文件可被 AI agent 正确读取和执行
- install.sh 能正常安装到 Codex/Claude Code
- 目录结构符合 DESIGN.md 规格
- 在本项目上自举运行（vibe-init → task → assess → retro）

## 约束

- 保持与 cheat-on-content 一致的三条不可妥协原则
- 所有 skill 格式兼容 Codex + Claude Code
- Markdown 为主，Shell/Python 为辅

## 相关资源

- cheat-on-content: /Users/chentao/Applications/cheat-on-content/cheat-on-content/
- 设计文档: DESIGN.md
