---
name: vibe-init
description: vibe-code 的首次 onboarding 与脚手架创建器。自动检测项目状态——新项目走标准 5 问题流程，已有项目走"导入历史"快速冷启动路径。触发词："初始化"/"init"/"首次使用"/"setup vibe-code"。**必须在用户第一次会话执行；其他子 skill 在 .vibe-state.json 不存在时自动路由到此。**
allowed-tools: Bash(*), Read, Write, Edit, Glob
---

# vibe-init — 首次 onboarding

让用户从零到能跑第一次评估。新项目 ≤ 5 分钟，已有项目（含历史导入）≤ 10 分钟。

---

## Overview

```
Phase 0: 检测当前状态
Phase 0.5: 判断新项目 vs 已有项目 → 分叉
Phase 1: 首屏告知（文案因项目状态不同）
Phase 2: 5-6 个问题（一问一答；已有项目多一问"要不要导入历史"）
Phase 3: 创建脚手架
Phase 3.5: 历史导入（仅已有项目 + 用户同意）
Phase 4: 安装 hook
Phase 5: 给下一步清单
```

---

## Workflow

### Phase 0: 检测当前状态

1. 检查当前目录是否存在 `.vibe-state.json`
   - 存在 → 提示"项目已初始化，要重新初始化会覆盖配置——确认？"
   - 不存在 → 继续
2. 检测项目状态——**跑一条命令即可**：

```bash
git log --oneline 2>/dev/null | wc -l
```

- 结果 > 0 → **已有项目**（有 git 历史）
- 结果 = 0 或 git 不可用 → **新项目/空项目**

3. 如果是已有项目，额外收集：
   - 总 commit 数
   - 最早 commit 日期 → 算项目年龄
   - 总文件数（`git ls-files | wc -l`）
   - 主要语言（`git ls-files | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -5`）

### Phase 0.5: 分叉

**新项目** → Phase 1 用标准文案，Phase 2 问 5 个问题。

**已有项目** → Phase 1 用已有项目文案（含项目统计），Phase 2 问 6 个问题（多一问"要不要导入历史"）。

### Phase 1: 首屏告知

#### 新项目文案：

```
🎯 Vibe Code — 初始化

你的下一次编码已经在改写 3 个月后的你。
判断力是客观存在的，区别是你**看见**还是**没看见**。
这套让你看见。

接下来 3-5 分钟我问你 5 个问题，搞清楚你做什么项目、用什么工具。

两件事先说在前面：

1. **早期评估会不准**——前 5 个任务精度大概 ±40%，这是事实。
   工具用 🔴🟠🟡🟢🔵 标 confidence，不藏数字。

2. **强烈建议导对标项目**——一个优秀的开源项目，工具立刻有参考 anchor。

准备好开始吗？
```

#### 已有项目文案：

```
🎯 Vibe Code — 初始化

你的项目已经跑了 {N} 天，{M} 个 commit，{F} 个文件。
——但你知道自己哪些判断准、哪些判断偏吗？

这套让你的每一次编码变成实验：评估→预估→复盘→进化。
过去 {N} 天的"感觉"没法追回了，但从今天开始的每一行都能被校准。

接下来 3-5 分钟我问你几个问题。最后会问你要不要从 git 历史里导入
几个过去的重要任务——让 rubric 一开始就了解你的项目长什么样。

准备好开始吗？
```

### Phase 2: 问题（一问一答，不批量）

#### Q1-Q5：所有项目都问

**Q1: 项目类型**

> "你的项目更接近哪一种？
> a) Web 应用（React/Vue/Next.js 等）
> b) CLI 工具
> c) 库/SDK
> d) 移动应用
> e) 其他"

记录到 `project_type`：
- a → `"web-app"`
- b → `"cli"`
- c → `"lib"`
- d → `"mobile"`
- e → `"other"`

**Q2: 主要语言**

> "项目主要用什么语言？
> a) TypeScript/JavaScript
> b) Python
> c) Go
> d) Rust
> e) Java/Kotlin
> f) 其他"

记录到 `primary_language`。

**Q3: 数据采集方式**

> "任务完成后的数据怎么收集？
> a) 自动采集（推荐）——有 git 就行，自动统计 diff/lint/时间
> b) 手动——每次复盘时我口头问你"

- 选 a → `data_collection = "auto"`, `enabled_adapters = ["git-stats"]`
- 选 b → `data_collection = "manual"`, `enabled_adapters = []`

**Q4: Hook 安装**

> "要不要装 hook？装了之后你的预估段就不能改了（物理强制）。
> a) 装（推荐）——确保预估是真的盲的
> b) 不装——靠君子协定"

- 选 a → 后续 Phase 4 装 hook
- 选 b → `hooks_installed = false`

**Q5: 对标项目**

> "有没有一个你觉得代码质量很好的开源项目想作为参考？
> a) 有，现在导入
> b) 有，下次再说
> c) 没有/不需要"

- 选 a → Phase 5 后 dispatch 到 vibe-learn-from
- 选 b/c → 跳过

#### Q6：仅已有项目

**Q6: 导入历史任务**

> "你的项目有 {M} 个 commit。要不要从 git 历史里导入几个重要任务？
>
> 导入后我会：
> 1. 列出最近的 commit 信息
> 2. 你挑 3-5 个有代表性的
> 3. 帮你重建任务描述和复盘记录
>
> 这些导入的任务**不计入真正的校准池**（因为它们不是盲预估），但能让
> rubric 一开始就了解你的项目特征——不用从零冷启动。
>
> a) 导入（推荐）——让 rubric 立刻有 anchor
> b) 跳过——从零开始，每次都是真正的盲预估"

- 选 a → 进入 Phase 3.5
- 选 b → 跳过 Phase 3.5

### Phase 3: 创建脚手架

在当前用户项目目录创建：

```
tasks/
predictions/
retros/
```

然后写入文件：
1. `.vibe-state.json` —— 按 state-management.md schema，所有字段初始化
2. `rubric.md` —— 从 `templates/rubric.template.md` 复制，替换 `{{init_date}}`
3. `.gitignore` 追加（不覆盖已有内容）：`.vibe-cache/`

每创建一个文件/目录都向用户解释它的作用。

**state 字段写入清单**：

| 字段 | 值 |
|---|---|
| `schema_version` | `"1.0"` |
| `skill_version` | `"1.0.0"` |
| `rubric_version` | `"v0"` |
| `project_type` | Q1 答案 |
| `primary_language` | Q2 答案 |
| `calibration_samples` | `0` |
| `calibration_samples_at_last_bump` | `0` |
| `data_collection` | Q3 答案 |
| `enabled_adapters` | Q3 派生 |
| `hooks_installed` | Q4 派生 |
| `historical_imports` | Q6=a 时的导入数量 |
| `project_age_days` | 仅已有项目 |
| `total_commits_at_init` | 仅已有项目 |
| `initialized_at` | 当前时间 ISO 8601，含 `+08:00` 时区 |
| 其他字段 | 全部 `null` / `0` / `[]` / `false` |

### Phase 3.5: 历史导入（仅已有项目 + Q6=a）

**目的**：从 git 历史中重建 3-5 个代表性任务，让 rubric 一开始就有项目特征作为 anchor。

**重要**：导入的任务标记为 `**Reconstructed retrospective**`，**不计入 calibration_samples**。它们帮 rubric 理解你的项目，但 bump 验证只用真正的盲预估。这和 cheat-on-content 的"导入已有视频"逻辑一致。

**步骤**：

**Step 1：列出候选 commit**

跑 `git log --oneline --no-merges -30` 展示最近 30 个非 merge commit。

**Step 2：用户挑选**

> "从上面挑 3-5 个你觉得最能代表你日常工作的 commit。比如：
> - 一个典型的 bug 修复
> - 一个中等复杂度的 feature
> - 一个重构
> - 一个你印象特别深的（特别顺或特别卡）"

**Step 3：逐个重建**

对每个挑选的 commit：

1. 展示 `git show <commit> --stat` —— 让用户回忆这个任务
2. 询问用户：
   - "这个任务的标题？（如 '修复 token 刷新 bug'）"
   - "大概是多复杂的任务？简单 / 中等 / 复杂"
   - "做完大概花了多久？"
   - "还记得有什么意外吗？（可选）"
3. AI 帮助写一份 reconstructed task 文件（`tasks/<date>_<hash>_<short>.md`）
4. AI 帮助写一份 reconstructed prediction 文件（`predictions/<date>_<hash>_<short>.md`），头部标：
   ```markdown
   **预估时数据状态**: **Reconstructed retrospective** — 从 git 历史重建，非盲预测
   **Calibration Value**: reference-only（不计入 calibration_samples）
   ```
5. 写简要复盘段（基于用户回忆的数据）

**Step 4：写入 state**

- `state.historical_imports` = 导入数量（如 4）
- **`state.calibration_samples` 仍为 0**——导入任务不进校准池

**Step 5：基于导入数据调整 rubric 初始权重（可选）**

如果导入了 ≥3 个任务且覆盖不同复杂度，AI 可以基于这些 reconstructed 数据对 v0 等权公式做一次软调整——在 `rubric.md` 的"待验证观察"段写入初步观察。**但不改公式系数**——那必须走完整的 bump 流程。

### Phase 4: 安装 hook（仅 Q4=a）

同之前。

### Phase 5: 给下一步清单

#### 新项目：

```
✅ 初始化完成（rubric: v0，calibration_samples: 0，confidence: 🔴 极低）

下次你可以直接说这些：

📝 写好任务描述 → "评估这个任务 tasks/xxx.md"
🎯 编码前       → "预估一下 tasks/xxx.md"
📊 编码完成后   → "复盘 tasks/xxx.md"
📈 任何时候     → "状态"（看板）

💡 你的 confidence 现在是 🔴 极低——会随复盘次数自动提升。
   第 5 次复盘后 rubric 第一次校准，confidence 跨入 🟡。
   不要因为 confidence 低就跳过评估——评估本身就是数据采集。
```

#### 已有项目（导入了历史）：

```
✅ 初始化完成
   rubric: v0（等权起步，已有 {N} 个历史参考任务作为 anchor）
   calibration_samples: 0（真正的盲预估从下一个任务开始计数）
   confidence: 🔴 极低

📊 导入了 {N} 个历史任务作为参考。它们帮 rubric 了解你的项目特征——
   但不算入校准池。真正的校准从你的下一次盲预估开始。

下次你可以直接说这些：

📝 下一个任务   → "评估这个任务 tasks/xxx.md"
📊 编码完成后   → "复盘 tasks/xxx.md"
📈 任何时候     → "状态"（看板）
🔍 分析代码库   → "分析项目特征"（扫描代码结构、依赖复杂度等）

💡 虽然 confidence 显示 🔴，但 rubric 已经从你的历史中提取了初步信号。
   跑 3-5 个真正的盲预估 + 复盘后，就可以考虑第一次 bump 了。
```

#### 已有项目（跳过了导入）：

```
✅ 初始化完成（rubric: v0，calibration_samples: 0，confidence: 🔴 极低）

💡 你跳过了历史导入，rubric 对你的项目特征一无所知。
   前 5 个评估会比较"通用"——它只能靠默认经验打分。
   第 5 次复盘后 rubric 第一次成型，confidence 跨入 🟡。

   如果后续想补导入历史任务：说 "导入历史任务" 即可。
```

---

## Key Rules

1. **不假装成功**：失败就明确告诉用户
2. **不批量提问**：一问一答
3. **不静默创建**：每建一个文件都解释
4. **state 时间用本地时区**：`+08:00`，不用 UTC `Z`
5. **历史导入不进校准池**：reconstructed ≠ blind。这是硬约束——和 cheat-on-content 的"导入视频不进校准池"逻辑一致
6. **已有项目不吓人**：Phase 1 文案用积极语气——"你的项目跑了 N 天"不是"你错过了 N 天的数据"，是"从今天开始不再错过"
