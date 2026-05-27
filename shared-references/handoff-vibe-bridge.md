# Handoff–Vibe Bridge Protocol（融合协议）

定义 handoff 协议的 6 阶段状态机与 vibe-code 校准闭环之间的桥接规则。
本文件是 vibe-code 主 SKILL.md 和 codex-claude-handoff/codex-self-handoff SKILL.md 的共同引用。

---

## 设计理念

handoff 提供 **"何时做什么"**（阶段纪律），vibe-code 提供 **"做得怎么样"**（校准指标）。
两者不互相替代，而是分层协作：

```
handoff: Spec → Plan → Build → Review → Polish → Commit
           │       │       │        │         │        │
vibe:   assess  score    —      retro      —    bump-check
```

---

## Phase → Vibe 动作映射表

| Handoff 阶段 | 触发 vibe 动作 | 触发条件 | 输出 |
|---|---|---|---|
| **Init / Spec** | `vibe-assess` | 用户确认 spec 范围后、写 spec 前 | `predictions/<id>.md` 落盘 |
| **Plan** | `vibe-score`（可选） | plan-ready.json 写入前，对子任务快速打分 | 控制台输出（不落盘） |
| **Build** | — | — | — |
| **Build Done** | `vibe-retro` | build-done.json 存在 + prediction 文件存在 | `predictions/<id>.md` 追加复盘段；`calibration_samples` +1 |
| **Review / Polish** | — | — | — |
| **Commit** | `vibe-bump` 条件检查 | committed.json 存在 + `calibration_samples >= 5` + 偏差方向明显 | 提示用户考虑升级 |

---

## 信号文件触发约定

### 自动检测优先级

vibe 技能在启动时应按以下顺序检测 handoff 状态：

```
1. 检查 handoff/committed.json    → 已完成，无需操作
2. 检查 handoff/build-done.json   → 触发 vibe-retro
3. 检查 handoff/plan-ready.json   → 已过评估窗口，拒绝 vibe-assess
4. 检查 handoff/ 是否有任何文件  → 有则读取阶段
5. handoff/ 为空                  → 可以评估，提示走 handoff Spec
```

### vibe-assess 自检规则

- `handoff/plan-ready.json` 已存在 → **拒绝写 prediction**（spec 和 plan 已完成，评估已不盲）
- `handoff/` 目录为空 → 允许，评估完成后提示："可以开始写 spec 了，说'交接'启动 handoff"
- `handoff/build-done.json` 已存在 → **拒绝**（编码已执行，数据已泄露）

### vibe-retro 自检规则

- `handoff/build-done.json` 存在 → **自动启动复盘**（无需用户手动触发）
- `handoff/build-done.json` 不存在但用户说"做完了" → 正常复盘，但标注 `handoff_phase_unknown: true`
- 读取 `build-done.json` 中的 `files_changed` 和 `completed_tasks` 作为复盘数据源

---

## 状态文件联合同步

`.vibe-state.json` 新增字段：

```json
{
  "handoff_mode": "claude-handoff | self-handoff | none",
  "handoff_phase": "init | plan-ready | build-done | review-fixes | polish-done | review-passed | committed",
  "handoff_feature": "当前 feature 名称",
  "last_handoff_signal_at": "ISO8601"
}
```

**同步规则**：

- handoff 写信号文件时，同步更新 `.vibe-state.json` 的 `handoff_phase`
- vibe 技能读取 `handoff_phase` 判断当前阶段，无需每次都跑 `check_phase.py`
- 如果 `.vibe-state.json` 与实际 handoff/ 目录不一致 → 以 handoff/ 目录为准，更新 state

---

## 冲突规则

当 handoff 协议和 vibe-code 协议出现冲突时，按以下优先级：

1. **盲预估不可破坏**（最高优先级）：如果编码已开始或已完成，vibe-assess 必须拒绝
2. **阶段不可跳过**：handoff 的 6 阶段顺序不可变，vibe 动作不能绕过 handoff 阶段
3. **复盘必须执行**：build-done 后必须触发 vibe-retro，不能因为"还在 review"就跳过
4. **校准数据完整性**：review-fixes 后的 polish-done 不触发第二次 retro（只复盘第一次 build-done）

---

## 数据流

```
user spec
  │
  ├─→ vibe-assess: 读 spec → 盲打分 → prediction.md
  │
  └─→ handoff Plan: 拆任务 → plan-ready.json
        │
        └─→ handoff Build: 编码 → build-done.json
              │
              ├─→ vibe-retro: 读 prediction + build-done
              │     ├─ 采集实际数据（adapters）
              │     ├─ 对比预估 vs 实际
              │     ├─ 追加复盘段到 prediction.md
              │     └─ 更新 calibration_samples + 检查 bump 触发
              │
              └─→ handoff Review → Commit → committed.json
```

---

## vibe-status 增强

`vibe-status` 看板应显示：

```
## Handoff 状态
- 模式: codex-self-handoff
- 当前阶段: build-done → 等待 review
- 当前 feature: post-review-fixes

## Vibe 校准
- 校准池: 6 个样本
- 待复盘: 0
- WIP: 0
- 下次可 bump: ✅（6 ≥ 5，建议检查偏差方向）
```

---

## 安装时的项目初始化

新项目使用 vibe-code + handoff 时，`vibe-init` 自动执行：

```bash
mkdir -p specs handoff tasks predictions retros
echo 'handoff/' >> .gitignore
```

---

## 反模式

- 「先编码再回头补评估和复盘」 → 拒绝。盲度已破坏，走 reconstructed 路径
- 「跳过 spec 直接 build，但还想 vibe-assess」 → 拒绝。没有 spec 的评估缺乏锚点
- 「handoff review-fixes 后再 retro 一次」 → 拒绝。只复盘首次 build-done
- 「用 vibe 但不走 handoff」 → 允许但降级为 manual 模式
