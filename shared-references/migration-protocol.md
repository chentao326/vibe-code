# Migration Protocol（schema 演进哲学）

被 `vibe-migrate`（未来）和所有子 skill 引用。

---

## 哲学

- **MINOR bump**（如 1.0 → 1.1）：仅新增字段。老 state 用 default 值兜底
- **MAJOR bump**（如 1.x → 2.0）：删字段 / 重命名 / 改语义。老 state 必须跑 migrate
- **不允许跳版**：必须按顺序跑每步迁移，每步幂等
- **失败停在原地**：迁移到第 N 步失败 → schema_version 仍是 N-1

---

## 迁移文件约定

文件名：`<from>-to-<to>.md`（如 `1.0-to-1.1.md`）

每份必含 4 段：
1. **WHAT changed** — 字段层 diff
2. **WHY** — 为什么这个改动
3. **HOW** — AI 执行步骤
4. **Manual fallback** — 手改 `.vibe-state.json` 的最小指令

---

## 给开发者：新增一个迁移

1. 想清楚 MINOR 还是 MAJOR
2. 改 `vibe-init/SKILL.md` 的 `schema_version` 硬编码
3. 改 `migrations/registry.md` 的 `LATEST_SCHEMA` 标记位 + 版本链表
4. 新建 `migrations/<old>-to-<new>.md`
5. CHANGELOG 标 `BREAKING`（major）或 `MINOR`
