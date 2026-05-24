# Vibe Code — 工程设计文档

> 版本：v0.1.0-draft
> 状态：设计阶段
> 基于：[cheat-on-content](https://github.com/XBuilderLAB/cheat-on-content) 方法论移植

---

## 目录

1. [需求分析](#1-需求分析)
2. [领域建模](#2-领域建模)
3. [系统边界](#3-系统边界)
4. [核心闭环](#4-核心闭环)
5. [总体架构](#5-总体架构)
6. [数据模型](#6-数据模型)
7. [组件设计](#7-组件设计)
8. [协议设计](#8-协议设计)
9. [Adapter 设计](#9-adapter-设计)
10. [Hook 设计](#10-hook-设计)
11. [实施路线图](#11-实施路线图)
12. [风险与局限](#12-风险与局限)
13. [附录：与 cheat-on-content 的差异对照](#13-附录)

---

## 1. 需求分析

### 1.1 用户画像

**主要用户**：使用 AI 编码助手（Codex / Claude Code / Cursor / Copilot 等）进行"vibe coding"的开发者。

**特征**：
- 通过自然语言描述需求，由 AI 生成代码
- 开发节奏快（分钟到小时级别的迭代）
- 单次会话聚焦一个或多个任务
- 对 AI 输出质量有感知但缺乏量化标准
- 想知道自己是否在进步，但缺乏衡量工具

### 1.2 核心痛点（按优先级）

| 优先级 | 痛点 | 现状 | 目标 |
|---|---|---|---|
| P0 | **预估失准** | 不知道一个任务要几轮对话、花多少时间 | 任务前写预估，任务后对账，逐步校准 |
| P1 | **不知道自己进步了没** | 感觉 prompt 能力在提升但无法验证 | 量化追踪 prompt 质量、效率、成功率 |
| P2 | **质量波动无归因** | AI 输出好坏没有系统性归因 | 复盘时关联任务特征到输出质量 |
| P3 | **任务优先级靠直觉** | 不知道先做哪个任务性价比最高 | 基于历史数据推荐任务顺序 |

### 1.3 功能需求

- **FR1**: 任务评估——在编码前对任务难度、风险、清晰度打分
- **FR2**: 盲预估——在执行前写下耗时、迭代次数等预测（不可事后修改）
- **FR3**: 自动数据采集——从 git、lint、终端历史等自动收集执行结果
- **FR4**: 复盘对账——对比预估 vs 实际，分析偏差原因
- **FR5**: 模型进化——累计足够样本后自动提议调整评估维度权重
- **FR6**: 状态看板——随时查看 WIP、待复盘、准确率趋势
- **FR7**: 对标学习——从优秀开源项目反向提取代码质量标准

### 1.4 非功能需求

- **NFR1**: 零配置起步——首次使用 5 分钟内完成初始化
- **NFR2**: 不打断工作流——数据采集自动化，不需要手动记录
- **NFR3**: Agent 原生——所有功能通过 AI Agent 的自然语言指令触发
- **NFR4**: 数据不可篡改——预估段一旦写入不可修改（hook 强制）
- **NFR5**: 渐进信心——样本少时诚实标注低信心，不假装精确

---

## 2. 领域建模

### 2.1 核心实体

```
┌──────────────┐     1:N     ┌──────────────┐
│   Project    │────────────▶│    Task      │
│  (用户项目)   │             │  (编码任务)   │
└──────────────┘             └──────┬───────┘
                                    │ 1:1
                           ┌────────▼───────┐
                           │  Assessment    │
                           │  (任务评估)     │
                           │  + Prediction  │
                           │  (盲预估)      │
                           └──────┬───────┘
                                  │ 1:1
                           ┌──────▼───────┐
                           │   Session     │
                           │  (执行会话)    │
                           └──────┬───────┘
                                  │ 1:1
                           ┌──────▼───────┐
                           │  Retrospective│
                           │  (复盘记录)    │
                           └──────────────┘

┌──────────────┐             ┌──────────────┐
│    Rubric    │◀────evolves─│  Calibration │
│  (评估模型)   │             │    Pool      │
│              │             │  (校准池)     │
└──────────────┘             └──────────────┘
```

### 2.2 实体定义

**Project（用户项目）**
- 一个 git 仓库 = 一个 vibe-code 项目
- 状态存储在 `.vibe-state.json`
- 可含多个 Task

**Task（编码任务）**
- 一次完整的编码意图单元
- 粒度：一次对话会话中完成的一个连贯目标
- 示例："修复登录页面的 token 刷新逻辑"、"给用户表加软删除字段"
- 包含：任务描述文件、评估文件、预测文件、复盘文件

**Assessment（任务评估）**
- 在编码执行前，AI 基于 task 描述 + 当前 rubric 打分
- N 个维度各 0-5 分
- 综合分由当前公式计算
- 包含 Blinded Score（由隔离 sub-agent 打分，防污染）

**Prediction（盲预估）**
- 在执行前写下的定量预测
- 一旦写完不可修改（由 hook 强制）
- 包含：预计耗时、预计对话轮次、bug 风险等级、综合信心等级

**Session（执行会话）**
- 实际的 AI 编码执行
- 由 Adapter 自动采集客观数据
- 包含：实际耗时、实际对话轮次、git diff 统计、lint 结果、测试结果

**Retrospective（复盘）**
- 在 Session 完成后追加到 Prediction 文件
- 对比预估 vs 实际
- 分析偏差原因
- 产出观察记录 → 可能触发 Rubric 升级

**Rubric（评估模型）**
- 包含 N 个维度 + 权重 + 综合分公式
- 版本化（v0, v1, v2...）
- 随校准池数据积累而进化
- 升级必须走 bump 流程（全量重打 + 一致性验证 + cross-model 审核）

**Calibration Pool（校准池）**
- 所有有完整复盘数据的 Task
- 用于 bump 时验证新公式是否比旧公式更准确

### 2.3 状态机

```
                    ┌─────────┐
                    │  None   │ (任务未创建)
                    └────┬────┘
                         │ 用户描述任务
                    ┌────▼────┐
                    │ Drafted │ (任务描述已写)
                    └────┬────┘
                         │ vibe-assess
                    ┌────▼────┐
                    │ Assessed│ (已评估+盲预估)
                    └────┬────┘
                         │ 开始编码
                    ┌────▼────┐
                    │ Running │ (执行中)
                    └────┬────┘
                         │ 编码完成
                    ┌────▼────┐
                    │  Done   │ (待复盘)
                    └────┬────┘
                         │ vibe-retro
                    ┌────▼────┐
                    │Retroed  │ (已复盘 → 进校准池)
                    └─────────┘

特殊状态：
  - Abandoned: 任务被放弃（不计入校准池，但保留记录）
  - Blocked: 任务被外部阻塞（暂停，不计时）
```

---

## 3. 系统边界

### 3.1 系统做什么

```
┌─────────────────────────────────────────────────┐
│                  Vibe Code                       │
│                                                  │
│  ✅ 评估任务难度/风险/清晰度                       │
│  ✅ 写预估（耗时/轮次/bug风险）                    │
│  ✅ 自动采集执行数据（git/lint/时间）               │
│  ✅ 复盘对账（预估 vs 实际）                       │
│  ✅ 进化评估模型（bump rubric）                    │
│  ✅ 状态看板（WIP/准确率/待复盘）                   │
│  ✅ 对标学习（从优秀代码反向提取标准）              │
│                                                  │
└─────────────────────────────────────────────────┘
```

### 3.2 系统不做什么

```
┌─────────────────────────────────────────────────┐
│              明确不做                               │
│                                                  │
│  ❌ 不替代项目管理工具（Jira/Linear/Notion）        │
│  ❌ 不自动分配任务优先级（只推荐，不决定）           │
│  ❌ 不管理代码本身（那是 git 的事）                 │
│  ❌ 不监控运行时系统（那是 APM 的事）               │
│  ❌ 不替代 code review（那是同事的事）              │
│  ❌ 不替你写 prompt（那是你自己的核心能力）          │
│                                                  │
└─────────────────────────────────────────────────┘
```

### 3.3 外部依赖

| 外部系统 | 用途 | 必需？ |
|---|---|---|
| Git | 代码变更统计、diff 分析 | 是 |
| AI Agent (Codex/Claude Code) | 运行 skill 指令 | 是 |
| Lint 工具 (ESLint/ruff/etc.) | 代码质量数据采集 | 推荐 |
| 测试框架 | 测试通过率数据 | 推荐 |
| Shell history / session log | 时间统计 | 可选（有 adapter） |
| GitHub API | 对标项目分析 | 可选 |

---

## 4. 核心闭环

### 4.1 闭环流程

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│  ① Assess                 ② Predict                 │
│  ┌──────────┐            ┌──────────┐               │
│  │ 读 task  │───────────▶│ 写预估   │               │
│  │ N 维打分 │            │ 耗时/轮次│               │
│  │ 综合分   │            │ bug风险  │               │
│  └──────────┘            │ 信心等级 │               │
│                           └────┬─────┘               │
│                                │                     │
│  ⑤ Evolve                     │ ③ Execute           │
│  ┌──────────┐            ┌────▼─────┐               │
│  │ bump?    │◀───────────│ 实际编码  │               │
│  │ 调整权重 │            │ 数据采集  │               │
│  │ 加减维度 │            └────┬─────┘               │
│  └──────────┘                 │                     │
│        ▲                      │                     │
│        │                 ┌────▼─────┐               │
│        └─────────────────│ 对比预估  │               │
│          校准池数据驱动    │ vs 实际   │               │
│                          │ 偏差分析  │               │
│                          │ 写观察    │               │
│                          └──────────┘               │
│                          ④ Retrospect               │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### 4.2 闭环频率

| 事件 | 频率 | 说明 |
|---|---|---|
| Assess + Predict | 每个任务开始前 | 必须在编码前完成 |
| Execute | 每个任务 | 可能跨多个对话会话 |
| Retrospect | 每个任务完成后 | 事件驱动，非时间驱动 |
| Evolve (bump) | 每 5-10 个任务 | 有足够校准样本后触发 |

---

## 5. 总体架构

### 5.1 分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    用户交互层                                 │
│  "评估这个任务" / "预估一下" / "复盘" / "状态" / "升级模型"   │
│  自然语言触发 → SKILL.md 路由器 dispatch                      │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                    工作流层（Skills）                         │
│  vibe-init  vibe-assess  vibe-retro  vibe-bump             │
│  vibe-status  vibe-learn-from  vibe-recommend              │
│  每个 skill 是一个独立的 SKILL.md，含工作流指令               │
└─────────────────────────┬───────────────────────────────────┘
                          │ 引用
┌─────────────────────────▼───────────────────────────────────┐
│                    协议层（Shared References）               │
│  blind-prediction-protocol  bump-validation-protocol        │
│  task-assessment-anatomy  state-management                  │
│  observation-lifecycle  cadence-protocol                    │
│  跨 skill 共享的规范、约定、数据格式定义                       │
└─────────────────────────┬───────────────────────────────────┘
                          │ 读写
┌─────────────────────────▼───────────────────────────────────┐
│                    数据层（用户项目文件）                      │
│  .vibe-state.json  rubric.md  tasks/*.md                   │
│  predictions/*.md  retros/*/  calibration-pool/             │
└─────────────────────────────────────────────────────────────┘

横向切面：
  ├── hooks/（harness 强制层 — 拦截修改预测段、SessionStart 自动报告）
  ├── adapters/（外部数据采集 — git-stats、lint-collector、time-tracker）
  ├── templates/（脚手架模板 — 写入用户项目的文件骨架）
  └── migrations/（状态文件 schema 版本演进）
```

### 5.2 目录结构

```
vibe-code/
│
├── SKILL.md                       # 总协议 + 路由器（Agent 入口文件）
├── README.md                      # 项目说明 + 安装指南
├── CHANGELOG.md                   # 版本演进日志
├── DESIGN.md                      # 本文件：工程设计文档
├── install.sh                     # 安装脚本（symlink/copy 到 agent skill 目录）
├── uninstall.sh                   # 卸载脚本
│
├── skills/                        # 工作流层（7 个子 skill）
│   ├── vibe-init/                 # [P0] 入口 — onboarding + 脚手架创建
│   │   └── SKILL.md
│   ├── vibe-assess/               # [P0] 核心 — 任务评估 + 盲预估 + 写 prediction
│   │   └── SKILL.md
│   ├── vibe-retro/                # [P0] 核心 — 复盘对账
│   │   └── SKILL.md
│   ├── vibe-bump/                 # [P1] — 升级评估模型（rubric 进化）
│   │   └── SKILL.md
│   ├── vibe-status/               # [P1] — 状态看板
│   │   └── SKILL.md
│   ├── vibe-learn-from/           # [P2] — 对标项目学习
│   │   └── SKILL.md
│   └── vibe-recommend/            # [P2] — 任务优先级推荐
│       └── SKILL.md
│
├── shared-references/             # 协议层（跨 skill 共享规范）
│   ├── blind-prediction-protocol.md    # 原则 #1：盲预估协议
│   ├── bump-validation-protocol.md     # 原则 #2：升级验证协议
│   ├── observation-lifecycle.md        # 原则 #3：观察生命周期
│   ├── task-assessment-anatomy.md      # 评估日志的 N 组件结构
│   ├── state-management.md             # .vibe-state.json 读写约定
│   ├── cadence-protocol.md             # 节奏协议（WIP 警戒 + 复盘提醒）
│   └── migration-protocol.md           # schema 演进哲学
│
├── templates/                     # 脚手架模板（写入用户项目的文件骨架）
│   ├── rubric.template.md              # 评估公式骨架
│   ├── task.template.md                # 任务描述模板
│   ├── prediction.template.md          # 预估日志模板
│   ├── retro.template.md               # 复盘日志模板
│   ├── benchmark.template.md           # 对标项目参考模板
│   └── status.template.md              # 状态看板模板
│
├── adapters/                      # 数据采集适配器
│   ├── git-stats/                 # Git 统计（diff 行数、文件数、commit 数）
│   │   ├── README.md
│   │   └── collect.sh
│   ├── lint-collector/            # Lint 结果采集
│   │   ├── README.md
│   │   └── collect.sh
│   └── time-tracker/              # 会话时间追踪
│       ├── README.md
│       └── track.sh
│
├── hooks/                         # Harness 强制层
│   ├── prediction-immutability.sh      # 拦截 prediction 文件修改
│   └── session-start.sh                # SessionStart 自动状态报告
│
├── migrations/                    # Schema 版本演进
│   ├── registry.md                     # LATEST_SCHEMA 标记 + 版本链表
│   └── 1.0-to-1.1.md                   # 未来迁移文件
│
├── tools/                         # 独立分析工具
│   └── accuracy-curve.py               # 预估准确率收敛曲线
│
└── starter-rubrics/               # 先验评估公式
    └── vibe-coding-default.md          # v0 等权起步公式
```

### 5.3 组件依赖图

```
                    ┌──────────┐
                    │vibe-init │ (入口，无依赖)
                    └────┬─────┘
                         │ 创建 state + rubric + 目录结构
          ┌──────────────┼──────────────┐
          │              │              │
    ┌─────▼─────┐ ┌─────▼─────┐ ┌─────▼─────┐
    │vibe-assess│ │vibe-status│ │vibe-learn │
    │           │ │           │ │ -from     │
    └─────┬─────┘ └───────────┘ └───────────┘
          │ 写 prediction
          │
    ┌─────▼─────┐
    │vibe-retro │ (依赖 prediction 文件 + adapter 数据)
    └─────┬─────┘
          │ 写入复盘 + 观察
          │
    ┌─────▼─────┐
    │vibe-bump  │ (依赖 ≥5 个 calibration samples)
    └─────┬─────┘
          │ 更新 rubric
          │
    ┌─────▼─────┐
    │ vibe-     │
    │ recommend │ (依赖 calibration pool + rubric)
    └───────────┘
```

---

## 6. 数据模型

### 6.1 状态文件：`.vibe-state.json`

```json
{
  "schema_version": "1.0",
  "skill_version": "1.0.0",

  "rubric_version": "v0",
  "project_type": "web-app",
  "primary_language": "typescript",

  "calibration_samples": 0,
  "calibration_samples_at_last_bump": 0,

  "total_tasks_assessed": 0,
  "total_tasks_completed": 0,
  "total_tasks_abandoned": 0,

  "data_collection": "auto",
  "enabled_adapters": ["git-stats", "lint-collector"],

  "hooks_installed": false,

  "last_bump_at": null,
  "last_bump_self_audited": false,
  "last_retro_at": null,
  "last_assessment_self_scored": false,

  "wip_tasks": [],
  "pending_retros": [],

  "consecutive_directional_errors": [],

  "in_progress_assessment": null,

  "initialized_at": "2026-05-24T15:00:00+08:00"
}
```

**字段说明**：

| 字段 | 类型 | 写入者 | 说明 |
|---|---|---|---|
| `schema_version` | string | vibe-init/migrate | 状态文件 schema 版本 |
| `rubric_version` | string | vibe-init/bump | 当前评估公式版本 |
| `project_type` | string | vibe-init | 项目类型（web/cli/lib/mobile/...） |
| `primary_language` | string | vibe-init | 主要编程语言 |
| `calibration_samples` | int | vibe-retro | 有完整复盘数据的任务数 |
| `data_collection` | string | vibe-init | 数据采集模式（auto/manual） |
| `enabled_adapters` | string[] | vibe-init | 启用的数据采集适配器 |
| `wip_tasks` | object[] | vibe-assess/retro | 进行中的任务列表 |
| `pending_retros` | string[] | vibe-assess | 待复盘的任务 ID 列表 |
| `consecutive_directional_errors` | object[] | vibe-retro | 连续同向偏差追踪 |
| `in_progress_assessment` | object\|null | vibe-assess/retro | 当前 in-progress 评估 |

### 6.2 评估公式文件：`rubric.md`

```markdown
# Vibe Code Rubric

**当前版本**: v0
**最后更新**: 2026-05-24
**校准样本数**: 0

---

## v0 综合分公式（等权起步）

composite = (CS×1.0 + CX×1.0 + AM×1.0 + TE×1.0 + AQ×1.0) / 5 × 2.0

每个维度 0-5 整数分。综合分范围 0-10。

---

## 5 个维度

### CS — Clarity of Spec（需求清晰度）
*任务描述有多清晰、具体、可执行？*

- **0** — "帮我改个bug"（完全无法执行）
- **3** — 描述了问题现象和期望结果，但缺少具体文件/行号
- **5** — 精确到文件路径+函数名+期望行为+验收标准

### CX — Cross-cutting Impact（改动影响面）
*这个任务涉及多少模块/文件/系统？*

- **0** — 单文件，纯函数，无外部依赖
- **3** — 同模块内 3-5 个文件
- **5** — 跨 5+ 模块，涉及数据库 schema + API + 前端

### AM — Ambiguity（隐性知识占比）
*多少信息在脑子里没写进任务描述？*

- **0** — 所有信息已写在 task 描述中
- **3** — 需要一些业务背景知识，但可推断
- **5** — 大量业务逻辑和设计决策只在用户脑子里

### TE — Testability（可验证性）
*多容易判断"做对了"？*

- **0** — 结果纯主观，无法自动验证
- **3** — 有明确的验收标准但无自动测试
- **5** — 有完整的自动化测试覆盖 + 编译检查

### AQ — Agent Quality Match（AI 匹配度）
*这个任务是否适合 AI 执行？*

- **0** — 需要 AI 工具链不支持的能力（如 GUI 操作）
- **3** — AI 能做但需要多轮澄清
- **5** — AI 原生强项：代码生成、重构、bug 修复

---

## 待验证观察

（空——随复盘积累）

## 被推翻假设

（空）

## 升级 Memo

（空——bump 后追加）

## 规律沉淀区

（空——≥2 样本支持的规律）
```

### 6.3 预测日志文件：`predictions/<task-id>.md`

```markdown
# <任务标题> — 预估日志

**Task ID**: <sha256:12>
**Title**: <任务完整标题>
**Rubric Version**: v0
**预估时间**: 2026-05-24T15:00:00+08:00
**Task Path**: tasks/2026-05-24_<id>_<short>.md
**Task Hash**: <sha256:12 of task content at assess time>
**Calibration Samples (at assess time)**: 3
**Confidence**: 🟡 偏低 (±40%，可作为参考)
**Scored By**: claude
**BlindScored By**: subagent-v1
**BlindScore Disagreement**: <inline JSON>
**User Override**: none
**预估时数据状态**: blind（未开始编码）

---

## 任务快照

（待 vibe-assess 填写：任务描述摘要 + 上下文概要）

---

## 维度评分

| 维度 | 分数 | 信心 | 理由 |
|---|---|---|---|
| CS | 4 | high | 指定了文件路径和期望行为 |
| CX | 2 | high | 仅涉及 auth 模块 3 个文件 |
| AM | 1 | high | 所有业务逻辑已在描述中 |
| TE | 4 | medium | 有测试文件可直接验证 |
| AQ | 5 | high | 纯代码重构，AI 强项 |

**综合分**: 6.4 / 10

---

## 预估 v1 ⭐ IMMUTABLE

（以下为盲预估——在编码开始前写下，一旦落盘不可修改）

### 📊 预估指标

| 指标 | 预估值 |
|---|---|
| 预计对话轮次 | 3-5 轮 |
| 预计耗时 | 15-25 分钟 |
| Bug 风险 | 🟡 中（涉及 auth 状态管理） |
| 预期满意度 | 7/10 |

### 🎲 概率分布

| 结果 | 概率 | 含义 |
|---|---|---|
| 一轮过 | 15% | 一次对话完成，无需修正 |
| 正常迭代 | 60% | 3-5 轮，正常修正 |
| 多次返工 | 20% | 6-10 轮，需要重大方向调整 |
| 卡住 | 5% | 超过 10 轮或放弃 |

### 💡 关键假设

- auth token 刷新逻辑现有代码结构足够清晰，AI 能直接定位
- 没有隐藏的跨模块副作用
- 测试覆盖现有 auth 流程，改动后能立即验证

---

## 复盘 ⬜

（待 vibe-retro 追加）
```

### 6.4 复盘数据追加（追加到 prediction 文件末尾）

```markdown
## 复盘

**复盘时间**: 2026-05-24T15:45:00+08:00
**数据来源**: auto（adapter: git-stats + lint-collector + time-tracker）

### 实际数据

| 指标 | 预估 | 实际 | 偏差 |
|---|---|---|---|
| 对话轮次 | 3-5 | 4 | ✅ 命中 |
| 耗时 | 15-25min | 22min | ✅ 命中 |
| 文件改动 | — | 3 files, +45/-12 lines |
| Lint 新增问题 | — | 0 errors, 1 warning |
| 测试通过率 | — | 5/5 passed |

### Bug 情况

- 无新 bug（lint warning 是已有代码的问题，非本次引入）

### 哪些预估被验证 / 推翻

**被验证 ✅**:
- 轮次和耗时在预估范围内
- auth token 刷新逻辑结构清晰，AI 直接定位

**被推翻 ❌**:
- （无）

### 需要写进 rubric.md 的新观察

- CS=4 + AM=1 + AQ=5 → 一次通过率高。初步验证"清晰度高 + 隐性知识少"是效率的核心预测因子
```

---

## 7. 组件设计

### 7.1 vibe-init — 初始化（P0）

**职责**：首次 onboarding + 脚手架创建

**工作流**：

```
Phase 0: 检测当前状态
  ├─ 检查 .vibe-state.json 是否存在
  └─ 存在 → 提示已初始化

Phase 1: 首屏告知
  └─ 输出项目介绍 + 期望管理

Phase 2: 收集信息（5 个问题，一问一答）
  ├─ Q1: 项目类型（web-app / cli / lib / mobile / other）
  ├─ Q2: 主要语言（typescript / python / go / rust / ...）
  ├─ Q3: 数据采集方式（auto 自动 / manual 手动）
  ├─ Q4: 是否安装 hook（auto / ask / skip）
  └─ Q5: 是否有对标项目

Phase 3: 创建脚手架
  ├─ 创建目录: tasks/ predictions/ retros/
  ├─ 写入 .vibe-state.json
  ├─ 从 templates/ 复制 rubric.md
  └─ 写入 .gitignore（排除 .vibe-cache/）

Phase 4: 安装 hook（如 Q4 != skip）
  └─ 写入 hook 配置 + 验证

Phase 5: 给出下一步清单
```

**输入**：无
**输出**：`.vibe-state.json` + `rubric.md` + 目录结构
**前置条件**：无（这是入口）
**后置条件**：所有其他 skill 可用

### 7.2 vibe-assess — 任务评估 + 盲预估（P0）

**职责**：任务前评估 + 写不可修改的预估

**工作流**：

```
Phase 0: Blind check 自检
  └─ 确认用户尚未开始编码（否则拒绝写预估）

Phase 1: 读 task + rubric + state
  ├─ 读 tasks/<id>.md 全文
  ├─ 读 rubric.md 拿当前公式
  ├─ 读 .vibe-state.json 拿 calibration_samples → 派生 confidence
  └─ 计算 task_hash

Phase 2: 委派盲打分（类似 cheat-score-blind）
  ├─ Task tool spawn sub-agent
  ├─ sub-agent 只读 task 文件 + rubric.md
  ├─ sub-agent 输出 N 维打分 + 每维 confidence + 理由
  └─ sub-agent 硬拒绝读 .vibe-state.json / predictions/ / retros/

Phase 2.5: Disagreement detection
  ├─ 主 AI 内心自估一份
  ├─ 比较 sub-agent 输出 vs 自估
  └─ |delta| ≥ 2 → 弹给用户裁定

Phase 3: 写预估指标
  ├─ 预计对话轮次
  ├─ 预计耗时
  ├─ Bug 风险等级
  └─ 概率分布

Phase 4: 写关键假设

Phase 5: 用户 review
  └─ 展示完整预估 → 等用户 "ok" 或挑刺

Phase 6: 落盘
  ├─ 写 predictions/<task-id>.md
  ├─ 更新 state: pending_retros += task-id
  └─ 更新 state: in_progress_assessment = task-id
```

**输入**：`tasks/<id>.md` + `rubric.md` + `.vibe-state.json`
**输出**：`predictions/<task-id>.md`
**前置条件**：已 vibe-init
**后置条件**：task 进入 pending_retros

### 7.3 vibe-retro — 复盘对账（P0）

**职责**：任务完成后收集实际数据 + 对比预估 + 写入观察

**工作流**：

```
Phase 0: 确认任务状态
  └─ 确认用户已完成编码（或放弃）

Phase 1: 读 prediction 文件
  └─ 缓存预估段 hash（后续校验用）

Phase 2: 采集实际数据（调用 adapters）
  ├─ git-stats: 收集 diff 统计（文件数/行数/commit 数）
  ├─ lint-collector: 收集 lint 结果
  ├─ time-tracker: 收集耗时
  └─ 手动: 询问用户主观数据（满意度/对话轮次/实际 bug 数）

Phase 3: 写入复盘段
  ├─ 对比预估 vs 实际
  ├─ 标注哪些被验证 / 推翻
  └─ 写入新观察

Phase 4: 校验 immutability
  └─ 确认预估段 hash 未变 → 否则标 integrity warning

Phase 5: 更新状态
  ├─ calibration_samples += 1
  ├─ pending_retros 移除该 task
  ├─ 检查 bump 触发条件
  └─ 更新 rubric.md 的观察段
```

**输入**：`predictions/<task-id>.md` + adapter 数据
**输出**：追加 `## 复盘` 段 + 可能更新 `rubric.md`
**前置条件**：prediction 文件存在 + 任务已完成

### 7.4 vibe-bump — 升级评估模型（P1）

**职责**：基于校准池数据升级 rubric

**工作流**（5 步强制，不可跳步）：

```
Phase 0: 前置门槛检查
  ├─ calibration_samples ≥ 5？（首次 bump 门槛）
  ├─ 有明确的方向性偏差？
  └─ in_progress_assessment == null？

Step 1: 写出新公式完整方程
Step 2: 校准池全量重打分（强制走盲打分子 agent）
Step 3: 计算排序一致性（THRESHOLD = 80%）
Step 4: 跨模型独立审核（调外部 LLM 验证）
Step 5: 落地 + cleanup（更新 rubric.md，删被推翻/吸收的观察）
```

**输入**：`rubric.md` + 所有 `predictions/*.md` 有复盘的文件
**输出**：更新 `rubric.md`（新版公式）
**前置条件**：校准池 ≥5 + bump 触发条件成立

### 7.5 vibe-status — 状态看板（P1）

**职责**：渲染当前项目状态

**输出内容**：
- 📊 校准进度（calibration_samples / confidence 等级）
- 📝 WIP 任务列表
- ⏰ 待复盘任务
- 📈 预估准确率趋势
- ⚠️ Bump 触发状态
- 🔧 Adapter 健康状态

**特性**：只读，无副作用

### 7.6 vibe-learn-from — 对标学习（P2）

**职责**：从优秀开源项目反向提取代码质量标准

**工作流**：
```
Phase 1: 获取对标项目
  └─ 用户提供 GitHub URL

Phase 2: 分析代码质量特征
  ├─ 目录结构规律
  ├─ 测试覆盖模式
  ├─ 命名规范
  ├─ 错误处理模式
  └─ API 设计风格

Phase 3: 写入 benchmark.md
  └─ 作为你的 rubric 调整参考
```

### 7.7 vibe-recommend — 任务推荐（P2）

**职责**：基于历史数据推荐下一个任务的优先级

**逻辑**：
- 高分（CS+AQ 高）+ 历史快速完成 → 优先推荐
- 低分任务建议拆分或补充信息
- WIP 积压时提醒先完成已有任务

---

## 8. 协议设计

### 8.1 盲预估协议（原则 #1）

继承 cheat-on-content 的 blind-prediction-protocol，适配 vibe coding：

**核心规则**：
- 预估必须在**开始编码之前**写完
- 一旦写入 `predictions/*.md` 的 `## 预估 v1` 段，不可修改
- 只能在文件末尾追加 `## 复盘` 段

**"见过数据"的边界**：

| 信息 | 是否破坏 blind |
|---|---|
| 已经开始了编码 | ✗ 破坏 |
| 已经看了 git diff / lint 结果 | ✗ 破坏 |
| 已经知道了实际耗时 | ✗ 破坏 |
| 类似任务的历史数据 | ○ 不破坏（这是锚点对比的依据） |
| 用户说"这个任务应该很简单" | △ 谨慎（主观偏见，需标注） |

**Immutability 强制**：由 `hooks/prediction-immutability.sh` 在文件系统层拦截。

### 8.2 升级验证协议（原则 #2）

**升级定义**（以下任一触发完整 bump 流程）：
- 维度系数变化（CS×1.0 → ×1.5）
- 维度增减（新增/删除维度）
- 归一化常数变化
- 维度定义颠覆性改写

**完整 5 步流程**（不可跳步）：
1. 写出新公式完整方程
2. 校准池全量重打分（强制走 blind sub-agent）
3. 计算排序一致性（≥80% = 4/5 样本排序一致）
4. 跨模型独立审核（外部 LLM 判定 PASS/REJECT）
5. 落地 + cleanup（更新 rubric.md + 删被推翻观察）

**升级阻尼**：校准池越大，bump 成本越高——这是故意的。频繁 bump = 在追噪声。

### 8.3 观察生命周期协议（原则 #3）

继承 cheat-on-content 的三阶段模型：

```
[新增] → [观察记录] → [跨任务观察] → [规律沉淀] / [被吸收为维度] / [被推翻]
```

**删除规则**：
- 被吸收为维度的观察 → 删
- 被新数据推翻的观察 → 删
- rubric.md 是工作台，不是博物馆——git history 才是档案

---

## 9. Adapter 设计

### 9.1 git-stats

**采集内容**：
- 改动文件列表 + 每个文件的 +/- 行数
- Commit 数量
- 是否涉及特定模块（按目录匹配）

**输出格式**（写到 `retros/<task-id>/git-report.json`）：
```json
{
  "files_changed": 3,
  "insertions": 45,
  "deletions": 12,
  "commits": 1,
  "modules_touched": ["auth"],
  "files": [
    {"path": "src/auth/token.ts", "insertions": 20, "deletions": 5},
    {"path": "src/auth/__tests__/token.test.ts", "insertions": 15, "deletions": 3},
    {"path": "src/types/auth.ts", "insertions": 10, "deletions": 4}
  ]
}
```

**实现**：`git diff --stat HEAD~1..HEAD` 或比较 task 开始前后的 git tree。

**挑战**：如何确定 task 的"开始"commit？方案：vibe-assess 时自动记录当前 HEAD 到 state。

### 9.2 lint-collector

**采集内容**：
- 当前 lint 错误数/警告数
- 与 task 开始前对比的新增问题

**输出格式**（写到 `retros/<task-id>/lint-report.json`）：
```json
{
  "errors": 0,
  "warnings": 1,
  "new_errors": 0,
  "new_warnings": 1,
  "new_issues": [
    {"file": "src/auth/token.ts", "line": 42, "rule": "no-unused-vars", "severity": "warning"}
  ]
}
```

### 9.3 time-tracker

**采集内容**：
- 实际耗时（task 开始到结束的时间差）

**挑战**：vibe coding 可能跨多个对话会话。需要 vibe-assess 和 vibe-retro 分别记录时间戳。

**方案**：不追踪"纯粹的编码时间"，只追踪"从预估到复盘的时间跨度"——这个更诚实，包含了思考和打断。

---

## 10. Hook 设计

### 10.1 prediction-immutability hook

**触发条件**：任何对 `predictions/` 目录下文件的 Edit/Write 操作

**行为**：
- 检查 diff 是否涉及 `## 预估 v1` 与 `## 复盘` 之间的内容
- 命中 → exit 1 阻塞
- `## 复盘` 段的追加 → 放行

**配置**（Claude Code）：
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .vibe-hooks/prediction-immutability.sh"
          }
        ]
      }
    ]
  }
}
```

### 10.2 session-start hook

**触发条件**：每次新对话会话开始

**行为**：
- 读取 `.vibe-state.json`
- 渲染 4-6 行状态摘要：
  - 📝 WIP 任务数
  - ⏰ 待复盘任务数
  - 📈 Calibration 进度
  - ⚠️ 关键提醒

---

## 11. 实施路线图

### 11.1 里程碑

```
Milestone 1: 最小闭环（MVP）
├── vibe-init        ✅
├── vibe-assess      ✅
└── vibe-retro       ✅
→ 能跑通：评估 → 预估 → 复盘 的基础循环

Milestone 2: 自动数据采集
├── git-stats adapter    ✅
├── lint-collector       ✅
└── time-tracker         ✅
→ 复盘时自动获取数据，不需手动填写

Milestone 3: 模型进化
├── vibe-bump            ✅
└── blind sub-agent      ✅
→ 校准池 ≥5 后可升级 rubric

Milestone 4: 运维体验
├── vibe-status          ✅
├── hooks                ✅
└── migrations           ✅
→ 完整的日常使用体验

Milestone 5: 高级功能
├── vibe-learn-from      ✅
└── vibe-recommend       ✅
→ 对标学习 + 智能推荐
```

### 11.2 文件级实施顺序

```
Phase 1 (基础框架):
  1. DESIGN.md                          ← 本文件（已完成）
  2. SKILL.md                           ← 总协议 + 路由器
  3. install.sh                         ← 安装脚本
  4. README.md                          ← 项目说明
  5. shared-references/                 ← 全部 7 份协议文件
  6. templates/                         ← 全部 6 份模板文件
  7. starter-rubrics/                   ← v0 等权公式
  
Phase 2 (核心闭环):
  8. skills/vibe-init/SKILL.md          ← 初始化
  9. skills/vibe-assess/SKILL.md        ← 评估 + 预估
  10. skills/vibe-retro/SKILL.md        ← 复盘

Phase 3 (数据采集):
  11. adapters/git-stats/               ← git 统计
  12. adapters/lint-collector/          ← lint 采集

Phase 4 (模型进化):
  13. skills/vibe-bump/SKILL.md         ← 升级模型
  14. hooks/                            ← 强制层

Phase 5 (体验完善):
  15. skills/vibe-status/SKILL.md       ← 状态看板
  16. migrations/                       ← schema 演进
  17. skills/vibe-learn-from/SKILL.md   ← 对标学习
  18. skills/vibe-recommend/SKILL.md    ← 任务推荐
  19. tools/accuracy-curve.py           ← 准确率曲线
  20. CHANGELOG.md                      ← 版本日志
```

### 11.3 每步的前置依赖

| 步骤 | 依赖 |
|---|---|
| SKILL.md | DESIGN.md |
| shared-references/ | DESIGN.md |
| templates/ | shared-references/（引用了协议中的 schema） |
| vibe-init | templates/（需要模板文件来复制） |
| vibe-assess | vibe-init（需要 state + rubric）+ templates/ |
| vibe-retro | vibe-assess（需要 prediction 文件）+ adapters/ |
| git-stats adapter | 独立（只依赖 git，不依赖其他 skill） |
| vibe-bump | vibe-retro（需要 calibration samples） |
| hooks | vibe-assess（需要理解 prediction 文件格式） |
| vibe-status | vibe-init + vibe-assess + vibe-retro（读 state） |
| vibe-recommend | vibe-bump（需要校准后的 rubric） |

---

## 12. 风险与局限

### 12.1 已知风险

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| **数据采集不完整** | git-stats 只能采到 git 记录的信息，不知道"中间尝试和放弃的代码" | time-tracker 补充时间维度；未来可考虑 IDE session log |
| **任务粒度过大** | 一个 task 可能跨几天、多次会话，预估和实际的对应关系模糊 | vibe-init 时强制约定粒度；建议每个 task ≤1 小时 |
| **主观指标难量化** | "满意度""代码质量"等指标主观性强 | 用可观测的客观指标（lint/test/git）为主，主观指标为辅 |
| **跨模型审核不稳定** | bump 时外部 LLM 的判断可能不一致 | 外部审核只是参考，最终决策权在用户 |
| **校准池冷启动** | 前 5-10 个任务 confidence 低，rubric 基本是猜测 | 诚实标注低 confidence；建议导入对标项目加速 |
| **adapters 脆弱** | lint 工具版本更新可能改变输出格式 | lint-collector 解析 lint 工具的 JSON/机器可读输出，不用人类可读格式 |

### 12.2 已知局限

1. **不追踪"失败的原因"**：如果 AI 生成的代码被拒绝，系统只知道"迭代次数多"，不知道是因为"prompt 写得不好"还是"任务本身就模糊"
2. **只追踪文件级变更**：不追踪"认知负荷"（如理解代码库的时间）
3. **rubric 维度是预定义的**：可能存在未被维度覆盖的重要信号
4. **单用户系统**：不做跨用户对比，不建基准数据库

### 12.3 与 cheat-on-content 的关键差异

| 维度 | cheat-on-content | vibe-code |
|---|---|---|
| **复盘窗口** | T+3d 固定（等数据沉淀） | 事件驱动（任务完成即复盘） |
| **"对标"含义** | 同平台博主 → 学流量规律 | 优秀开源项目 → 学代码质量标准 |
| **"发布"概念** | 有明确的发布时间点 | 无单一"发布"——持续 commit |
| **数据采集** | 手动粘贴 或 Playwright 爬虫 | git + lint 自动采集 |
| **buffer 含义** | 已拍未发的视频 | 已开始未完成的任务（WIP） |
| **rubric 维度** | 情感/社会/钩子/金句...（传播学） | 清晰度/影响面/隐性知识/可验证性（软件工程） |
| **"现象级"对应** | 150w+ 播放 | 一轮过 + 零 bug + 高满意度 |

---

## 13. 附录

### 13.1 术语对照

| 缩写 | 全称 | 含义 |
|---|---|---|
| CS | Clarity of Spec | 需求清晰度 |
| CX | Cross-cutting Impact | 改动影响面 |
| AM | Ambiguity | 隐性知识占比 |
| TE | Testability | 可验证性 |
| AQ | Agent Quality Match | AI 匹配度 |
| WIP | Work In Progress | 进行中的任务 |
| Bump | — | 升级评估模型 |

### 13.2 设计决策记录

| 决策 | 理由 |
|---|---|
| 任务粒度：单次编码会话 | vibe coding 天然以会话为单位；粒度统一便于统计 |
| 复盘窗口：事件驱动（非时间驱动） | 编码任务不像视频有"数据沉淀期"——完成就知道结果 |
| 5 维评分（非 7 维） | cheat-on-content 的 7 维针对传播学。vibe coding 从更少的维度起步，随数据积累再扩展 |
| 不用 T+3d，用"任务完成" | 代码质量不需要等待——lint/test 即时可得 |
| 保留 blind sub-agent 机制 | 防作弊同样重要——主 AI 知道"这个任务其实很简单"会污染评估 |
| 保留 bump 5 步流程 | 升级模型同样需要严格的验证——防自己骗自己 |
| 不做"bucket 预测" | 播放量分 bucket 有意义，代码任务的结果不是"大中小"可以概括的 |

---

> **本文件是 vibe-code 项目的工程设计文档。**
> 下一步：基于本文档开始实施 Phase 1（基础框架），逐个文件落地。
> 每个组件的实现细节在对应的 `skills/<name>/SKILL.md` 中展开。
