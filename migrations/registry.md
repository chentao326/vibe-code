# Migrations Registry

vibe-code 的 schema 版本演进单一来源。

---

## 当前 schema_version

**`1.0`** — 由 `vibe-init` Phase 3 写入新 state 文件。

```
LATEST_SCHEMA = "1.0"
```

---

## 版本链

| from | to | breaking? | 迁移文件 | 描述 |
|---|---|---|---|---|
| (none) | 1.0 | — | (内置) | 初始 schema |

---

## 给开发者：新增一个迁移

1. 想清楚 MINOR 还是 MAJOR
2. 改 `vibe-init/SKILL.md` 的 `schema_version` 硬编码
3. 改本文件的 `LATEST_SCHEMA` 标记位
4. 本文件"版本链"表追加一行
5. 新建 `migrations/<old>-to-<new>.md`（4 段：WHAT/WHY/HOW/Manual fallback）
6. CHANGELOG 标 `BREAKING`（major）或 `MINOR`
