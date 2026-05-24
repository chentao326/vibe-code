# 为 uninstall.sh 编写测试

**创建日期**: 2026-05-24
**状态**: pending

---

## 目标

为 uninstall.sh 编写测试脚本，覆盖卸载逻辑和边界情况。

## 上下文

- uninstall.sh 负责从 ~/.codex/skills、~/.claude/skills、~/.cursor/skills 移除 vibe-code skill 符号链接
- 当前零测试——rm -rf 路径的错误可能导致误删
- 已有测试模式参考 tests/test-install.sh 和 tests/test-git-stats.sh

## 具体需求

1. 测试脚本可独立运行（不依赖实际安装状态）
2. 用临时目录模拟 skill 安装环境
3. 测试 symlink 文件被正确检测和移除
4. 测试实际目录（copy mode 安装的）也被移除
5. 测试不存在的目录不报错
6. 测试 SKILLS 数组包含所有 13 个 skill + vibe-code
7. 测试非 vibe-code 的 symlink 不被误删
8. 测试脚本的 SKILLS 数组与 install.sh 一致

## 验收标准

- 新建 tests/test-uninstall.sh
- 使用临时目录 mock，不触碰 ~/.codex 等真实路径
- ≥8 个测试用例全部通过
- 测试无副作用
