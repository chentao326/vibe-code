---
name: vibe-code
description: 把 vibe coding 变成可校准实验——评估任务 → 盲预估 → 编码执行 → 复盘对账 → 进化评估模型。适用任何用 AI 编码助手（Codex/Claude Code/Cursor）进行开发的程序员。**首次使用必须先跑 vibe-init。**
argument-hint: [task-path] [— mode: cold-start|calibration]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill, Task, WebFetch, mcp__llm-chat__chat
---

# Vibe Code — 把 vibe coding 变成可校准实验

> 🎯 **方法论通用，当前内置 web 开发的默认评估维度**
>
> **方法论**（5 阶段闭环）：适用于任何能被拆分为"任务→执行→复盘"的编码工作流。
>
> **当前内置 rubric**：5 个维度（CS/CX/AM/TE/AQ），适合 web/app 开发场景。
>
> 新项目走标准流程；已有项目自动检测 git 历史 + 提供导入路径加速冷启动。

把 vibe coding 变成可校准预测循环：**评估任务 → 盲预估 → 编码执行 → 复盘对账 → 进化评估模型**。

本文件是**总协议 + 路由器**。具体每个阶段的工作流在 `skills/vibe-*/SKILL.md` 各子 skill 里。

---

## 路由表（触发词 → 子 skill）

### 核心闭环

| 用户说 | 调用 | 前置条件 |
|---|---|---|
| "初始化" / "init" / "首次使用" / "setup vibe-code" | `vibe-init` | 无（这是入口） |
| "评估这个任务" / "assess" / "预估一下" | `vibe-assess` | 已 init + task 文件存在 |
| "复盘" / "retro" / "对账" / "这个任务做完了" | `vibe-retro` | prediction 文件存在 + 任务已完成 |
| "升级模型" / "bump rubric" / "调整维度" / "更新公式" | `vibe-bump` | 已 init + 校准池 ≥5 |

### 辅助功能

| 用户说 | 调用 | 前置条件 |
|---|---|---|
| "状态" / "看板" / "status" | `vibe-status` | 已 init |
| "推荐任务" / "下一步做什么" / "优先级" | `vibe-recommend` | 已 init + 有 tasks |
| "打分这篇" / "score this" / "先打个分看看" | `vibe-score` | 已 init + task 文件存在 |
| "找选题" / "我不知道做什么" / "seed" | `vibe-seed` | 已 init |
| "趋势" / "有什么新动向" / "trends" | `vibe-trends` | 已 init |
| "分析项目" / "代码库画像" / "profile" | `vibe-profile` | 已 init |
| "学这个项目" / "对标" / "learn from" | `vibe-learn-from` | 已 init |
| "迁移" / "migrate" / "升级 schema" | `vibe-migrate` | 已 init + schema 版本过期 |

---

## 三条不可妥协原则

1. **盲预估**：预估必须在编码前写完，一旦落盘不可修改。完整规范：[shared-references/blind-prediction-protocol.md](shared-references/blind-prediction-protocol.md)。

2. **升级 = 全量重打**：改公式必须所有历史任务重打分，排序一致性 ≥80% + 跨模型审核才放行。[shared-references/bump-validation-protocol.md](shared-references/bump-validation-protocol.md)。

3. **rubric 是工作台，不是博物馆**：被推翻的观察删，被吸收的也删。git history 才是档案。[shared-references/observation-lifecycle.md](shared-references/observation-lifecycle.md)。

---

## 项目结构

```
vibe-code/
├── SKILL.md                           # ✅ 总协议 + 路由器
├── README.md                          # ✅ 项目说明 + 使用指南
├── DESIGN.md                          # ✅ 工程设计文档
├── CHANGELOG.md                       # ✅ 版本日志
├── install.sh / uninstall.sh          # ✅ 安装/卸载
│
├── skills/（13 个子 skill）
│   ├── vibe-init/SKILL.md             # ✅ 入口 — onboarding（自动检测新/已有项目）
│   ├── vibe-assess/SKILL.md           # ✅ 核心 — 任务评估 + 盲预估
│   ├── vibe-retro/SKILL.md            # ✅ 核心 — 复盘对账
│   ├── vibe-bump/SKILL.md             # ✅ 升级评估模型
│   ├── vibe-status/SKILL.md           # ✅ 状态看板
│   ├── vibe-score/SKILL.md            # ✅ 轻量打分（控制台，不落盘）
│   ├── vibe-score-blind/SKILL.md      # ✅ Channel B 隔离盲打分（子 agent）
│   ├── vibe-seed/SKILL.md             # ✅ 找选题（从代码库扫描）
│   ├── vibe-recommend/SKILL.md        # ✅ 任务推荐
│   ├── vibe-trends/SKILL.md           # ✅ 趋势扫描（安全/依赖/动态）
│   ├── vibe-profile/SKILL.md          # ✅ 代码库画像
│   ├── vibe-learn-from/SKILL.md       # ✅ 对标学习
│   └── vibe-migrate/SKILL.md          # ✅ Schema 迁移
│
├── shared-references/（9 份协议）
│   ├── blind-prediction-protocol.md   # ✅ 原则 #1
│   ├── bump-validation-protocol.md    # ✅ 原则 #2
│   ├── observation-lifecycle.md       # ✅ 原则 #3
│   ├── task-assessment-anatomy.md     # ✅ 评估日志组件结构
│   ├── state-management.md            # ✅ .vibe-state.json 读写约定
│   ├── cadence-protocol.md            # ✅ 节奏协议（WIP 警戒）
│   ├── migration-protocol.md          # ✅ schema 演进哲学
│   ├── candidate-schema.md            # ✅ 候选任务统一 schema
│   └── data-source-routing.md         # ✅ 数据源路由
│
├── templates/（7 份模板）
│   ├── rubric.template.md             # ✅ 评估公式骨架
│   ├── task.template.md               # ✅ 任务描述模板
│   ├── prediction.template.md         # ✅ 预估日志模板
│   ├── retro.template.md              # ✅ 复盘日志模板
│   ├── benchmark.template.md          # ✅ 对标参考模板
│   ├── status.template.md             # ✅ 状态看板模板
│   └── prompt-patterns.template.md    # ✅ 任务描述 pattern 沉淀
│
├── adapters/（3 个采集器）
├── hooks/（5 个 hook 文件）
├── migrations/ / tools/ / starter-rubrics/
└── docs/ / examples/（待）
```

✅ = 已完成

---

## 给开发者：扩展本 skill

- 新增项目类型默认维度 → 加 `starter-rubrics/<type>.md`
- 新增数据采集源 → 加 `adapters/<name>/`
- 修改原则 → 改 `shared-references/<protocol>.md`
- 修改路由 → 改本文件"路由表"段
- 子 skill 内部细节 → 直接改对应 `skills/vibe-*/SKILL.md`

完整工程文档见 [DESIGN.md](DESIGN.md)。
