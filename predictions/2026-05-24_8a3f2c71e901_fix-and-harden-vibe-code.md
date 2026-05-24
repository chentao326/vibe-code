# 修复并加固 vibe-code 项目 — 预估日志

**Task ID**: 8a3f2c71e901
**Title**: 修复并加固 vibe-code 项目
**Rubric Version**: v0
**预估时间**: 2026-05-24T17:30:00+08:00（reconstructed — 任务已完成）
**Task Path**: tasks/2026-05-24_8a3f2c71e901_fix-and-harden-vibe-code.md
**Task Hash**: 8a3f2c71e901
**Calibration Samples (at assess time)**: 0
**Confidence**: 🔴 极低（reconstructed — 任务已完成，非盲预测，不计入校准池）
**Scored By**: claude（reconstructed）
**BlindScored By**: main-claude-self（reconstructed — 任务已完成，无法走 blind sub-agent）
**BlindScore Disagreement**: N/A（reconstructed）
**User Override**: none
**预估时数据状态**: **Reconstructed** — 任务已完成，此为重建记录，非盲预测

---

> ⚠️ 本文件是 **reconstructed assessment**，不是真正的盲预测。任务在评估前已完成。不计入校准池。

---

## 任务快照

对 vibe-code v1.0.0 做首轮查漏补缺：修 git-stats JSON bug（3 子问题）、实现 time-tracker、写 31 个测试、扩展 install.sh、加固 prediction-immutability hook。5 个子任务，跨 adapters/hooks/tests/tools 四个模块。

---

## 维度评分（reconstructed）

| 维度 | 分数 | 信心 | 理由 |
|---|---|---|---|
| CS | 5 | high | 任务描述逐条列出 5 个需求 + 验收标准 + 约束，bug 定位精确到文件行号 |
| CX | 3 | high | 跨 4 个模块、5 个文件修改 + 4 个测试文件新建，范围中等 |
| AM | 2 | high | macOS BSD 工具链差异（date/awk/grep）需要额外知识；set -e + pipefail 行为是隐藏陷阱 |
| TE | 5 | high | 所有验收标准可自动化验证：JSON 合法性、测试通过数、CLI flag 输出 |
| AQ | 5 | high | 纯 Bash/Python/Markdown——AI 原生最强领域，无编译依赖 |

**综合分**: (5+3+2+5+5)/5 × 2.0 = **8.0 / 10**

---

## 预估 v1（reconstructed）⭐

> ⚠️ 以下为重建预估，非盲预测。

### 📊 预估指标

| 指标 | 预估值 |
|---|---|
| 预计对话轮次 | 8-15 轮（5 个子任务，每任务 1-4 轮） |
| 预计耗时 | 20-35 分钟 |
| Bug 风险 | 🟡 中（macOS 工具链差异是主要风险点） |
| 预期满意度 | 8/10 |

### 🎲 概率分布

| 结果 | 概率 |
|---|---|
| 一轮过（无返工） | 40% |
| 正常迭代 | 45% |
| 多次返工 | 15% |
| 卡住 | 0% |

---

## 关键假设

- `set -euo pipefail` 下 grep 无匹配会静默退出——测试会暴露这一点（✅ 验证，3 个测试因此失败）
- macOS git shortstat 输出格式可能与 Linux 不同（✅ 验证，`insertion(+)` 带了括号后缀）
- BSD date 的 `-j -f` 和 GNU date 的 `-d` 语法不同——time-tracker 需要兼容两套（✅ 已做双路径 fallback）
- 项目代码结构足够清晰，AI 能直接定位所有需改文件（✅ 验证）

---

## 复盘

**复盘时间**: 2026-05-24
**数据来源**: 手动（用户确认） + 测试结果

### 实际数据

| 指标 | 预估 | 实际 | 偏差 |
|---|---|---|---|
| 对话轮次 | 8-15 | ~10 轮工具调用 | ✅ 命中 |
| 耗时 | 20-35min | ~25min（从 Phase 0 到全量测试通过） | ✅ 命中 |
| Bug | 🟡 中风险 | 1 个 bug（awk `(+)` 后缀不匹配） | ✅ 命中 |
| 测试首次通过率 | — | 18/31 首次通过，3 个因 pipefail 失败 | — |
| 满意度 | 8/10 | 8/10 | ✅ 命中 |

### Bug 情况

1. **git-stats awk 匹配 bug**：`git diff --shortstat` 在 macOS 上输出 `1 insertion(+)`，字段带 `(+)` 后缀，awk 精确匹配 `== "insertion"` 失败，导致 insertions/deletions 始终为 0。测试暴露了这个问题，改用 `~ /^insertion/` 正则修复。

2. **pipefail + grep 静默退出**：3 个测试文件中 `set -euo pipefail` 下 `bash cmd | grep -q ...` 在 cmd 返回非零时，pipefail 导致整个管道返回非零，`if` 条件判为 false。修复方式：抽取 output 再 grep，或加 `|| true`。

### 哪些被验证 ✅

- **macOS 兼容性确实是主要风险**——awk 和 pipefail 两个问题都在测试中暴露，验证了 🟡 中风险的判断
- **验收标准的可测试性**——JSON 合法性、测试通过数、CLI flag 输出全部可自动化验证，TE=5 是正确的
- **AI 在 Bash/Markdown 领域的高匹配度**——AQ=5 的判断被验证：所有修复都是模式匹配级别的改动，无架构理解障碍
- **项目结构清晰**——5 个子任务的文件定位没有任何歧义

### 哪些被推翻 ❌

- （无——reconstructed 预估基于事后知识，天然准确。但下一轮的真正盲预估才是真正的检验）

### 需要写进 rubric.md 的新观察

1. **测试驱动的 bug 发现效率极高**：awk 匹配 bug 在首次测试运行中被立即发现——如果不是测试的自动化验证，这个 bug 可能在生产中静默存在很久。**假设**：TE（可测试性）维度在软件工程领域应该比内容领域权重更高——软件 bug 的代价是功能失效，不只是评分不准。

2. **pipefail 行为的领域知识**：`set -euo pipefail` 下 grep 无匹配导致脚本退出——这是 Bash 编程的常见陷阱，但 AI 第一次写测试时仍然踩了。**假设**：AM（环境模糊度）对 AI 的制约在 shell 脚本领域比在应用代码领域更大——shell 的隐式行为更多，需要更多"经验"而非"推理"。

3. **reconstructed vs blind 的差异可见**：本次是 reconstructed，预估全中。对比第一个 reconstructed 任务（构建 vibe-code）也是全中。**这反向验证了盲预估的必要性**——如果所有预估都是事后写，accuracy 100% 但毫无信息量。真正的信号只能从盲预估中提取。

4. **CX=3 的实际拆解**：跨 4 个模块但只有 5 个文件修改——CX 的"范围"定义可能需要区分"文件数"和"模块数"。当前任务文件数少但模块跨度大，实际执行中模块跨度的影响小于预期（因为每个模块的改动都很局部）。

### 主观复盘

最顺利的部分是测试发现 bug 的闭环——写完测试、运行、发现 awk 和 pipefail 问题、修复、再运行、全绿。这个循环本身证明了 TE 维度的价值：可自动化验证的验收标准让 bug 无处藏身。

意料之外的是 pipefail 陷阱——我在写测试时想过"grep 找不到会怎样"，但因为 `set -e` 的行为在管道中不明显，第一版测试仍然踩了。这提醒我：shell 脚本的"隐式行为"需要用更防御性的方式处理，不能假定 AI 能推理出所有边界情况。

最大的教训：**重构代码后立刻跑测试**——哪怕改动看起来"显然正确"。awk 正则改动的修复只用了 30 秒，但如果没有测试，可能永远不知道旧代码在 macOS 上完全不工作。
