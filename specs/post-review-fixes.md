# 项目审查修复 (Post-Review Fixes)

## 用户故事

- 作为项目维护者，我希望仓库有合法的 MIT LICENSE 文件，与 README 的声明一致
- 作为开发者，我希望 CLAUDE.md 包含项目上下文信息，方便 AI agent 理解本项目
- 作为用户，我希望 Spearman ρ 负相关问题被显式诊断和记录，避免误导
- 作为贡献者，我希望 DESIGN.md 的版本号反映实际项目状态
- 作为用户，我不希望二进制文件膨胀 git 仓库

## 验收标准

### P0 — 阻塞级

- [ ] **AC1**: 仓库根目录存在 `LICENSE` 文件，内容为 MIT 许可证
- [ ] **AC2**: `CLAUDE.md` 恢复项目上下文信息（项目结构、技能路由表、rubric 公式、盲预估规则、状态文件 schema），同时保留 Codex+Claude Code 交接协议作为独立章节或独立文件
- [ ] **AC3**: `rubric.md` 的"待验证观察"段新增一条诊断记录，显式标注 Spearman ρ = −0.893 为负相关，说明可能原因（小样本偏差 vs 公式方向倒置），并提出 v2 升级前需验证的事项

### P1 — 应修复

- [ ] **AC4**: `DESIGN.md` 的版本号更新为 `v1.0.1`，状态更新为 `已发布`
- [ ] **AC5**: `Vibe_Code_Introduction.pptx` 和 `vibe-code-intro.pptx` 从 git 跟踪中移除，加入 `.gitignore`
- [ ] **AC6**: `retros/test-none/` 目录被删除

### P2 — 观察

- [ ] **AC7**: `handoff/` 目录从 git 跟踪中移除（已在 `.gitignore` 中）

## 技术约束

- 不修改任何技能逻辑、hook、adapter 或测试
- 不改变 rubric 公式本身（诊断记录仅文档化，不等同于 bump）
- CLAUDE.md 的交接协议部分保持完整，不丢失信息

## 边界情况

- `retros/test-none/` 如包含有效数据文件，需先确认再删除
- `.pptx` 文件只是从 git 跟踪移除，不删除本地文件
- LICENSE 文件使用标准 MIT 模板，版权年份用 2026，版权人用仓库所有者
