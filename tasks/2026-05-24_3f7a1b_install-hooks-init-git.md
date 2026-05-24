# Git 初始化 + 安装 hook

**创建日期**: 2026-05-24
**状态**: pending

---

## 目标

为 vibe-code 项目做首次 git commit，并安装 prediction-immutability hook，使项目进入可追溯 + 预估段不可篡改的状态。

## 上下文

- 项目当前有 0 个 git commit，所有文件都是 untracked
- adapters/git-stats 依赖 git 历史采集数据——没有 commit 就无法工作
- hooks/prediction-immutability.sh 已写好并通过测试，但未安装
- hooks/session-start.sh 已存在但未安装
- .gitignore 当前只有 3 行（.vibe-cache/ + *.pyc + __pycache__/），需要补充

## 具体需求

1. 检查并完善 `.gitignore`：补充 `.DS_Store`、`retros/*/`（复盘数据是运行时产物）、`.vibe-state.json`（本地状态不入库）等
2. 确认所有文件均为项目源文件（无密钥、无凭证）
3. `git add` 所有源文件，跳过 .gitignore 中的项
4. 做首次 commit，message 遵循项目规范
5. 安装 hooks/prediction-immutability.sh 到 `.claude/hooks/`（或 Codex 等价目录）
6. 安装 hooks/session-start.sh
7. 更新 `.vibe-state.json` 中 `hooks_installed: true`
8. 验证 hook 生效：尝试编辑 predictions/ 下任意文件的预估段，确认被拦截

## 验收标准

- `git log --oneline` 输出 1 个 commit
- `git ls-files` 包含所有源文件，不含 `.vibe-state.json`
- `hooks_installed` 在 state 中为 `true`
- prediction-immutability hook 能拦截预估段编辑
- git-stats adapter 能正常采集数据（`bash adapters/git-stats/collect.sh test HEAD` 输出合法 JSON）

## 约束

- 不提交 `.vibe-cache/`、`.DS_Store`、`retros/*/` 等运行时产物
- 不提交任何含密钥/凭证的文件
- hook 安装路径兼容 macOS
