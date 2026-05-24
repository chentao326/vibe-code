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

## 安装

```bash
git clone https://github.com/chentao326/vibe-code.git
cd vibe-code
bash install.sh        # Claude Codex（默认）
bash install.sh --all  # Codex + Claude Code + Cursor
```

13 个子 skill 以符号链接方式安装到 agent 的 skill 目录。一次安装，所有项目都能用。

**支持的 agent**：Claude Code（默认）· Codex · Cursor

> 冻结版本：`bash install.sh --copy`
>
> 卸载：`bash uninstall.sh`（项目数据不动）

---

## 首次使用

在项目目录里打开 Claude Code / Codex，说：

```
初始化 vibe-code
```

新项目走标准 5 问题 onboarding。已有 git 历史的项目会自动检测到，并提供历史任务导入——让评估模型一开始就有项目特征作为 anchor。

---

## 日常使用

```
评估这个任务 tasks/xxx.md   → 打分 + 盲预估（编码前，落盘不可改）
编码                         → AI 正常干活
复盘                         → 采集 git 数据，预估 vs 实际对账
升级模型                      → 进化公式（需 ≥5 校准样本）

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
| 测试 | 70/70 通过 |

---

## 许可

MIT。商用、修改、闭源集成——都可以。

---

*Is this over-engineering? So was writing tests. So was code review.*
*The future doesn't reward those who code fastest — it rewards those who judge sharpest.*
