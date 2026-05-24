# 为 install.sh 编写测试 — 预估日志

**Task ID**: d4e5f6
**Title**: 为 install.sh 编写测试
**Rubric Version**: v0
**预估时间**: 2026-05-24T19:00:00+08:00
**Task Path**: tasks/2026-05-24_d4e5f6_test-install-sh.md
**Task Hash**: 919ea0dcbdec
**Calibration Samples (at assess time)**: 2
**Confidence**: 🟠 低
**Scored By**: claude（main）
**BlindScored By**: sub-agent（general-purpose, context-isolated）
**BlindScore Disagreement**: none（all dims |Δ| = 0）
**User Override**: none（auto-confirmed）

---

## 任务快照

为 install.sh（142 行，13 skills，5 个 CLI flag）写测试脚本。8 个测试用例覆盖 --list/--help/--dry-run/--copy/默认行为/非法参数/错误处理。纯 Bash，单文件。

---

## 维度评分（blind sub-agent）

| 维度 | 分数 | 信心 | 理由 |
|---|---|---|---|
| CS | 5 | high | 8 个测试用例逐条列出 + 预期行为，明确验收标准 |
| CX | 1 | high | 单文件新建，测试一个已有脚本，无跨模块影响 |
| AM | 2 | medium | 需从已有测试文件推断 helper 模式，install.sh 的 flag 细节需验证 |
| TE | 4 | high | 测试脚本自身是自验证的（pass/fail 计数），验收标准清晰 |
| AQ | 5 | high | Bash 测试生成按枚举用例 + 已有模式——AI 核心强项 |

**综合分**: (5+1+2+4+5)/5 × 2.0 = **6.8 / 10**

---

## 预估 v1 ⭐

> **盲预估 #3** — calibration_samples: 2, confidence: 🟠 低

### 预估指标

| 指标 | 预估值 |
|---|---|
| 预计对话轮次 | 3-5 轮（读 install.sh → 读参考测试 → 写测试 → 运行验证 → 修复） |
| 预计耗时 | 5-10 分钟 |
| Bug 风险 | 🟡 中（--dry-run 输出格式依赖 install.sh 实际实现，flag 解析可能有意料外的行为） |
| 预期满意度 | 8/10 |

### 概率分布

| 结果 | 概率 |
|---|---|
| 一轮过（无返工） | 45% |
| 正常迭代 | 40% |
| 多次返工 | 15% |
| 卡住 | 0% |

---

## 关键假设

1. install.sh 的 --dry-run 输出格式稳定，可做 grep 断言
2. 已有测试的 helper 模式（run_xxx + PASS/FAIL）可直接复用
3. --dry-run 确实不创建任何文件——如果实现有 bug，测试会暴露

---

## 复盘

**复盘时间**: 2026-05-24
**数据来源**: 手动

### 实际数据

| 指标 | 预估 | 实际 | 偏差 |
|---|---|---|---|
| 对话轮次 | 3-5 | 4（读→写→跑→修+重跑） | ✅ 命中 |
| 耗时 | 5-10min | ~5min | ✅ 命中 |
| Bug | 🟡 中 | 1（grep 不含 `--` 导致 `--copy` 被解释为 grep flag） | ✅ 命中 |
| 满意度 | 8/10 | 9/10（20 个测试 > 8 最小需求） | ✅ 超预期 |

### Bug 情况

1. **grep 参数歧义**：`grep -q "$flag"` 中 `$flag` 的值是 `--copy`、`--codex` 等，grep 将 `--` 前缀解释为自身选项。修复：加 `--` 分隔符（`grep -q -- "$flag"`）。1 轮发现 + 修复。

### 哪些被验证 ✅

- **🟡 中风险的判断正确**——确实有 bug，但不严重，1 轮修复。pattern 与 task 1（pipefail + grep）同源：Bash 工具链的 CLI 参数歧义是高频陷阱
- **CX=1 预估精度再次验证**——所有 4 个指标全部命中，CX=1 的任务（tasks 2&3）共 8 个指标全中
- **假设 1 和 2 验证**——install.sh 的 --dry-run 输出格式稳定，参考测试的模式直接复用
- **假设 3 验证**——--dry-run 确实无副作用，输出 "Dry run complete" 确认

### 哪些被推翻 ❌

- **满意度低估**：预估 8/10，实际 9/10。最终输出了 20 个测试用例（远超 8 个的最低要求），覆盖面完整。低估原因：预估时只算了"满足需求"的程度，没算"超预期交付"的满意度增益
- 偏乐观的轮次预估被修正——第 1 个任务低估 25%，第 2-3 个任务全部命中，说明校准方向正确

### 需要写进 rubric.md 的新观察

1. **CX=1 任务连续 2 个全中**：task 2（CLAUDE.md）和 task 3（test-install.sh）都是 CX=1 + 全部指标命中。对比 task 1（CX=3，轮次低估 25%）。**规律**：CX=1 是预估精度的安全区——单文件、无跨模块依赖时，预估误差趋于零。

2. **Bash CLI 参数歧义是 AM 的稳定子项**：pipefail+grep（task 1）和 grep `--` 前缀（task 3）是同根问题——Bash 工具链中，flag 字符串在管道和参数传递中容易被 shell 重新解释。这应该成为 AM 评分的固定检查项：任务涉及 Bash flag 传递时，AM 自动 +1。

3. **测试用例数超预期是 TE 维度未捕获的信号**：TE 只衡量"是否可验证"，但"可验证性强"时（TE=4-5），AI 倾向于产出更多测试用例（20 vs 8）。这可能是一个杠杆效应：高 TE 任务的测试覆盖率天然超过最低要求。

### 主观复盘

这次最有趣的是 grep bug——和 task 1 的 pipefail 问题同一个根因（Bash CLI 参数的隐式行为），两次都命中了。我已经学会在测试里加 `|| true` 和 `--`，但每个新脚本仍然可能踩新坑。这验证了 AM=2 的判断：Bash 的领域知识密度高，需要"踩坑经验"而非纯粹推理。

另一个观察：连续 3 个盲预估都没有重大翻车（偏差方向从低估→全中→全中），说明 v0 等权公式在项目早期就给出了合理的难度排序。虽然 calibration_samples 才 3，但 rubric 的"方向感"已经比 🔴 极低时期好很多。

**Re-scored under v1 on 2026-05-24**: composite recalculated with CX×1.5 + TE×1.5 formula.
