---
name: vibe-recommend
description: 基于校准池数据和当前 WIP 状态推荐下一步任务的优先级。触发词："推荐任务"/"下一步做什么"/"优先级"。
allowed-tools: Bash(*), Read, Glob
---

# vibe-recommend — 任务优先级推荐

读 tasks/ 目录 + state + rubric → 推荐任务顺序。

---

## Workflow

### Phase 1: 读状态

读 `.vibe-state.json` → WIP 数量、calibration_samples。

### Phase 2: 读候选任务

Glob `tasks/*.md`，排除已在 WIP 的任务。

### Phase 3: 排序推荐

推荐逻辑：

1. **排除**：已在 WIP 的任务
2. **排序**：按综合分降序（如有评估数据），否则按文件名
3. **分组**：
   - 第 1 个（稳分）：CS + AQ 高，CX 低（需求清晰 + AI 匹配好 + 改动小 = 快速完成）
   - 第 2 个（实验性）：能验证某个待验证假设的任务

### Phase 4: 输出

```
🎯 推荐任务

稳分（建议优先）:
  • tasks/fix-typo.md — CS=5, AQ=5, CX=1 → 预计 1-2 轮，5-10min

实验性（验证假设）:
  • tasks/refactor-db.md — CX=4, AM=3 → 适合验证"高 CX 任务是否系统性被低估"

⚠️ 提醒：当前 WIP=3（偏高），建议先完成已有任务。
```
