# 修复并加固 vibe-code 项目

**创建日期**: 2026-05-24
**状态**: completed

---

## 目标

对 vibe-code 项目做第一轮查漏补缺：修复关键 bug、补全缺失实现、建立测试覆盖、加固安全边界。

## 上下文

- 项目刚完成 v1.0.0 初始构建，从未经过实际使用验证
- 首次自举运行（vibe-init → seed → execute → retro）
- 范围：adapters / hooks / install.sh / tests

## 具体需求

1. 修复 adapters/git-stats/collect.sh 的 JSON 生成 bug（3 个子问题：重定向、子 shell、awk 匹配）
2. 实现 adapters/time-tracker/collect.sh（从 README stub → 可执行的两阶段脚本）
3. 给 4 个核心模块写测试（git-stats / time-tracker / prediction-immutability / accuracy-curve）
4. install.sh 扩展平台支持 + uninstall.sh 同步更新
5. 加固 hooks/prediction-immutability.sh（从 grep → hunk 级 diff 解析）

## 验收标准

- git-stats collect.sh 输出合法 JSON 且 insertions/deletions > 0
- time-tracker collect.sh 正确记录 start/end 时间戳并计算 duration
- 所有测试通过（最终 31/31）
- install.sh --dry-run / --list / --help / --cursor 正常工作
- prediction-immutability hook 正确拦截预估段修改 + 放行复盘段编辑 + v1/v2 通配

## 约束

- 兼容 macOS BSD 工具链（date、awk、grep）
- 不用 jq 做硬依赖（fallback 到 echo "[]"）
