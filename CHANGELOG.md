# Changelog

## [Unreleased]

## [1.1.0] — 2026-05-27

### Added
- **codex-claude-handoff skill**：Codex + Claude Code 6 阶段协同协议（Spec→Plan→Build→Review→Polish→Commit）
- **codex-self-handoff skill**：Codex 独自走 6 阶段全流程，在 Architect/Builder 模式间自动切换
- **handoff-vibe-bridge.md**：融合协议——定义 handoff 阶段与 vibe 校准动作的映射、冲突规则、数据流
- **handoff 文档**：AGENTS.md、QUICKSTART.md、WALKTHROUGH.md
- `.vibe-state.json` 新增 handoff 字段：`handoff_mode`、`handoff_phase`、`handoff_feature`、`last_handoff_signal_at`（schema v1.0 → v1.1）
- README 新增"内置 Handoff 协议"章节（中英文）

### Changed
- **vibe-assess**：新增 Phase 0.1 handoff 阶段检测——plan-ready.json 或 build-done.json 存在时拒绝评估，防止盲度破坏
- **vibe-retro**：新增 Phase 0.1 自动感知 build-done.json，无需用户手动确认即可启动复盘
- **vibe-status**：新增 handoff 阶段看板，同步显示 6 阶段状态 + vibe 校准数据
- **install.sh**：从安装 13 个技能扩展为 15 个（13 vibe + 2 handoff）
- **state-management.md**：文档化 handoff 字段及写入规则
- **DESIGN.md**：v1.0.1 → v1.1.0，新增 §11 "与 Handoff 协议的集成"
- **AGENTS.md**：handoff 协议段改为引用本地 skill 文件，首次纳入版本管理

### Fixed
- DESIGN.md 子章节编号未同步（#12.x / #13.x / #14.x）
- vibe-status 重复 `---` 分隔线
- state-management.md 表格缺少结尾 `|`

## [1.0.0] — 2026-05-24

### Added
- 完整初始版本：7 个子 skill + 7 份协议文件 + 6 份模板 + 3 个 adapter + 2 个 hook
- 5 维评估模型（CS/CX/AM/TE/AQ），v0 等权起步
- 盲预估 + 复盘对账闭环
- 对标项目学习功能
- 任务优先级推荐功能
- Codex + Claude Code 双 agent 安装支持

---

## [1.0.0] — 2026-05-24

### Added
- 首次发布
- 基于 [cheat-on-content](https://github.com/XBuilderLAB/cheat-on-content) 方法论移植
- 完整工程设计文档（DESIGN.md）
