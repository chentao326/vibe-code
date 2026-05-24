# 修复 prediction-immutability hook 的 PreToolUse 兼容性

**创建日期**: 2026-05-24
**状态**: pending

---

## 目标

根据 task 1 复盘发现，修复 prediction-immutability.sh 使其兼容 Claude Code PreToolUse hook 的实际输入格式。

## 上下文

- Task 1 复盘发现：hook 假设 stdin 传来的是 diff 格式，但 PreToolUse hook 的实际输入是 JSON（含 tool/file/arguments）
- 当前 hook 在 settings.json 中通过 `${CLAUDE_FILE}` `${CLAUDE_TOOL}` 传递文件路径和工具名
- FILE 和 ACTION 参数来自 settings command args，这个路径是正确的
- stdin 内容需要在 diff 格式和 JSON 格式之间做兼容

## 具体需求

1. 保留当前 diff 格式的检测逻辑（向后兼容，test 已验证）
2. 新增 JSON 格式检测：尝试从 stdin JSON 中提取 file 和 new_string/old_string
3. 两种格式下都能正确检测预测段修改
4. 在文件头部注释说明支持的两种输入格式
5. 更新已有测试以覆盖新逻辑

## 验收标准

- tests/test-prediction-immutability.sh 9 个测试继续通过
- 新增 ≥2 个 JSON 输入格式的测试
- 脚本头部注释说明 PreToolUse stdin JSON 格式
