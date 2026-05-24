# Vibe Code

**把 vibe coding 变成可校准的实验。**

你说"这个任务应该很简单"——准过吗？Vibe Code 把每一次 AI 编码变成闭环实验，用数据回答这个问题。

---

## 一句话

```
评估任务 → 盲预估 → 编码执行 → 复盘对账 → 进化你的判断力
```

---

## 安装

```bash
git clone https://github.com/chentao326/vibe-code.git
cd vibe-code
bash install.sh        # Claude Codex（默认）
bash install.sh --all  # Codex + Claude Code + Cursor
```

---

## 快速开始

在项目目录里说 `初始化 vibe-code`，5 个问题完成 onboarding。

然后每次编码走这个循环：

```
① 写 task        tasks/xxx.md
② 评估这个任务     打分 + 盲预估（落盘后不可改）
③ 编码           AI 正常干活
④ 复盘           预估 vs 实际，偏差分析
⑤ 升级模型        攒够 5 个复盘后进化公式（v1 已上线）
```

---

## 当前状态

| 指标 | 值 |
|------|-----|
| Rubric | v1（CX×1.5 + TE×1.5） |
| 校准池 | 6 个盲预估样本 |
| Confidence | 🟢 中 |
| 测试 | 70/70 通过 |
| Spearman ρ | −0.893 |

### Rubric v1 公式

```
composite = (CS×1.0 + CX×1.5 + TE×1.5 + AM×1.0 + AQ×1.0) / 6.0 × 2.0
```

5 个维度：CS（需求清晰度）、CX（改动影响面）、TE（可验证性）、AM（隐性知识）、AQ（AI 匹配度）。

---

## 命令速查

### 核心闭环

| 命令 | 说明 |
|------|------|
| `初始化 vibe-code` | 首次 onboarding |
| `评估这个任务 tasks/xxx.md` | 打分 + 盲预估（编码前） |
| `复盘` | 对账预估 vs 实际 |
| `升级模型` | 进化公式（需 ≥5 校准样本） |

### 辅助

| 命令 | 说明 |
|------|------|
| `状态` | WIP / 校准池 / 准确率 / bump 提醒 |
| `找选题` | 扫描 TODO/测试缺口/依赖过期 |
| `打分这篇 tasks/xxx.md` | 轻量打分（不落盘） |
| `推荐任务` | 下一步优先级 |
| `趋势` | 安全公告 + 依赖更新 |
| `分析项目` | 代码库画像 |
| `学这个项目 <url>` | 对标优质开源项目 |
| `迁移` | 升级 state schema |

---

## 关键概念

| 概念 | 含义 |
|------|------|
| Blind prediction | 编码前写的预估，不可修改 |
| Rubric | 5 维度评估模型，随数据进化 |
| Calibration pool | 所有盲预估+复盘的任务——bump 验证集 |
| Confidence | 如实标注当前模型的可靠程度 |
| Bump | 升级公式——全量重打 + 排序 ≥80% + 跨模型审核 |

---

## 项目结构

```
skills/vibe-*/     — 13 个子 skill
shared-references/ — 7 份协议
adapters/          — 数据采集器（git-stats, time-tracker, lint-collector）
hooks/             — prediction-immutability + session-start
templates/         — 7 份脚手架模板
tests/             — 7 个测试脚本（70 用例）
CLAUDE.md          — AI 项目指令
```

---

## 为什么不是又一个任务管理工具

Jira/Linear 管"做什么"，Vibe Code 管"怎么判断"。前者追踪 deadline，后者追踪判断准确率。一个是给人看的静态配置，一个是给 AI Agent 用的自动进化模型。

---

## 许可

MIT
