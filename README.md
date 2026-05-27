<h2 align="center">Vibe Code</h2>

<p align="center">
For developers who use AI coding assistants — a skill that turns every task into a calibrated experiment.
</p>

<p align="center">
你说"这个任务应该很简单"。你说了一百次。<br>
有多少次真的对了？你不知道——因为你从来没记过账。<br>
Vibe Code 帮你记。一个月后，你对任务难度/风险/耗时的判断力有数据支撑。<br>
三个月后，你的 prompt 能力是三个月前的 10 倍。
</p>

<p align="center">
  <strong>简体中文</strong>
  &nbsp;·&nbsp;
  <a href="README_EN.md"><strong>English</strong></a>
</p>

<p align="center">
<a href="CHANGELOG.md"><img src="https://img.shields.io/badge/rubric-v1-success" alt="Rubric v1"></a>
&nbsp;
<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
&nbsp;
<a href="#"><img src="https://img.shields.io/badge/tests-70%2F70-brightgreen" alt="Tests"></a>
&nbsp;
<a href="#"><img src="https://img.shields.io/badge/calibration-6_samples-ff69b4" alt="Calibration"></a>
&nbsp;
<a href="#"><img src="https://img.shields.io/badge/handoff-v1.0-blue" alt="Handoff"></a>
</p>

---

## 它做什么

大多数 AI 编码助手用户活在这样的循环里：

> 写 prompt → AI 生成代码 → 好用/不好用 → 下次继续凭感觉

一个用了 AI 编码半年的人，判断力可能和第一周差不多——因为从来没**复盘**过。

**Vibe Code** 让每一次编码都变成可追溯的实验：

📊 评估任务 → 🎯 盲预估 → 🚀 编码执行 → 📈 复盘对账 → 🧬 进化你的评估模型

这不是效率工具。这是**复利**——每一次不复盘的编码，都在侵蚀你看见自己的能力。

---

## 起源

> 我做了一套内容创作工具，用"盲预测→复盘→进化公式"的闭环，一个月从零到百万粉。
>
> 然后我意识到：这套方法论不限于内容。任何能被拆成"任务→执行→复盘"的工作流都能用。
>
> 于是有了 Vibe Code。我把内容领域的校准引擎移植到软件工程——评估任务难度、预估轮次和耗时、编码完成后对账、评估模型随你的数据进化。
>
> 用了三个月之后，你对"这个任务大概多久"的直觉就不再是直觉——是数据。
>
> —— *从 cheat-on-content 移植而来*

---

---

## v1.1.0 更新（2026-05-27）

本次更新将两套 handoff 协同协议内置到 Vibe Code，并与校准闭环打通：

- **新增** `codex-self-handoff` 和 `codex-claude-handoff` 两个 skill，说"自交接"或"交接"即可启动 6 阶段流程
- **新增** 融合协议 `handoff-vibe-bridge.md`，handoff 阶段自动触发 vibe 校准动作（Spec 前评估、Build 后复盘、Commit 后检查升级）
- **升级** `vibe-assess` / `vibe-retro` / `vibe-status` 三个技能，全部感知 handoff 阶段
- **扩展** 安装脚本，一次安装 13 vibe + 2 handoff = 15 个 skill
- **更新** DESIGN.md → v1.1.0，新增"与 Handoff 协议的集成"完整章节

[查看完整更新日志 →](CHANGELOG.md)


## 它和其他 AI 编码工具的区别

| 其他工具 | Vibe Code |
|---|---|
| 帮你写代码 | 帮你**判断**代码该写成什么样 |
| AI 替你干活 | AI **评估**你的活——执行还是你来 |
| 做完就完了 | 做完只是开始——预估 vs 实际，**偏差入账** |
| 每次对话独立 | 一个**进化的评估模型**——v1 不等于 v0，v2 也不会等于 v1 |

一句话：别的工具帮你"写得多"。这个帮你"判断得准"。

---

## 为什么评估模型会进化

每次任务走完闭环，**偏差分析写入 rubric**。连续 3 次同向偏差，工具主动提示你升级公式。升级公式需要：

- 全量历史任务重打分
- 排序一致性 ≥ 80%
- 跨模型独立审核

**你不是自己在猜——模型替你记住，替你对账，替你进化。**

被数据推翻的观察会删除，被吸收为维度的观察也会删除。rubric 只保留当下最有用的东西。

---

## 内置 Handoff 协议

Vibe Code 不仅仅是校准工具——它内置了两套 **AI 编码协同协议**，让你的编码工作流有纪律、可追溯：

| 协议 | 说明 | 触发词 |
|---|---|---|
| **codex-self-handoff** | Codex 独自走 6 阶段全流程（Spec→Plan→Build→Review→Polish→Commit） | "自交接" / "自己走全流程" |
| **codex-claude-handoff** | Codex + Claude Code 双工具协同（Codex 编码，Claude 设计+审查） | "交接" / "下一阶段" |

**与校准闭环的融合**：handoff 的 6 个阶段为 vibe-code 提供"何时触发"的锚点：

```
handoff: Spec → Plan → Build → Review → Polish → Commit
           │       │       │        │         │        │
vibe:   assess  score    —      retro      —    bump-check
```

详见 [handoff-vibe-bridge.md](shared-references/handoff-vibe-bridge.md)。


## 安装

```bash
git clone https://github.com/chentao326/vibe-code.git
cd vibe-code
bash install.sh        # Claude Codex（默认）
bash install.sh --all  # Codex + Claude Code + Cursor
```

15 个子 skill（13 vibe-code + 2 handoff）以符号链接方式安装到 agent 的 skill 目录。一次安装，所有项目都能用。

**支持的 agent**：Claude Code（默认）· Codex · Cursor

> 冻结版本：`bash install.sh --copy`
>
> 卸载：`bash uninstall.sh`（项目数据不动）

---

## 首次使用

在项目目录里打开 Codex / Claude Code，说：

```
初始化 vibe-code
```

新项目走标准 5 问题 onboarding。已有 git 历史会自动检测并提供历史任务导入。

初始化后直接开始：

```
自交接 — 做一个用户登录功能
```

Codex 会自动走完 6 阶段（Spec→Plan→Build→Review→Polish→Commit），同时在关键节点触发 vibe 校准（评估→编码→复盘）。

---

## 日常使用

```
自交接                → 启动 6 阶段全流程（vibe 校准 + handoff 纪律）
评估这个任务 tasks/xxx.md → 打分 + 盲预估（编码前，落盘不可改）
编码                   → AI 正常干活
复盘                   → 自动感知 build-done，采集 git 数据对账
升级模型                → 进化公式（需 ≥5 校准样本）

状态 / 找选题 / 推荐任务 / 趋势 / 分析项目 / 打分这篇
```

安装 hook 后，每次 session 启动自动显示 WIP + 待复盘 + bump 提醒。完整工作流见 [SKILL.md](SKILL.md)。

---

## 当前状态

| 指标 | 值 |
|---|---|
| Rubric | v1（CX×1.5 + TE×1.5） |
| 校准池 | 6 个盲预估样本 |
| Spearman ρ | −0.893 |
| Handoff | codex-self-handoff + codex-claude-handoff |
| 技能数 | 15（13 vibe + 2 handoff） |
| 测试 | 70/70 通过 |

---

## 许可

MIT。商用、修改、闭源集成——都可以。

---

*Is this over-engineering? So was writing tests. So was code review.*
*The future doesn't reward those who code fastest — it rewards those who judge sharpest.*
