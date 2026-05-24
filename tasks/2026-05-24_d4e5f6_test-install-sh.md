# 为 install.sh 编写测试

**创建日期**: 2026-05-24
**状态**: pending

---

## 目标

为 install.sh（142 行）编写测试脚本，覆盖主要功能分支和边界情况。

## 上下文

- install.sh 负责将 13 个 vibe-code skill 安装到 AI 编码工具的 skill 目录
- 支持 --copy（复制）和 --symlink（默认，符号链接）
- 支持 --codex / --claude / --cursor / --all 四种目标
- 支持 --dry-run（仅显示）和 --list（列出 skill）和 --help
- 当前零测试覆盖——若 install.sh 有 bug，用户可能安装失败或装错路径
- 已有测试模式参考：tests/test-git-stats.sh, tests/test-time-tracker.sh 等

## 具体需求

1. 测试 --list 输出包含 13 个 skill 名称
2. 测试 --help 输出包含 Usage 和选项说明
3. 测试 --dry-run --all 不实际创建文件但输出预期内容
4. 测试 --dry-run --codex 只显示 codex target
5. 测试 --dry-run --copy 显示 copy mode
6. 测试默认行为（无参数 = --codex symlink）
7. 测试非法参数被拒绝
8. 测试 SKILL.md 缺失时的错误处理

## 验收标准

- 新建 tests/test-install.sh 文件
- 包含 ≥8 个测试用例
- 全部通过
- 测试不产生副作用（只用 --dry-run 和 --list，不做实际安装）

## 约束

- 使用 --dry-run 避免实际安装到系统目录
- 不依赖 ~/.codex/skills 或 ~/.claude/skills 的实际存在
- 遵循现有测试文件风格（set -euo pipefail, PASS/FAIL 计数, run_xxx helper）
