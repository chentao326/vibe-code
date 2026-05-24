# 为 lint-collector 适配器编写测试

**创建日期**: 2026-05-24
**状态**: pending

---

## 目标

为 adapters/lint-collector/collect.sh 编写测试，验证其三路 lint 工具检测逻辑。

## 上下文

- lint-collector 检测 package.json → eslint、pyproject.toml → ruff、golangci-lint 命令
- 当前零测试——三路检测逻辑未经验证
- 适配器通过 mock lint 工具来测试：创建假的 package.json/pyproject.toml 和假的 lint 命令

## 具体需求

1. 测试 eslint 路径：存在 package.json + npx 可用时选择 eslint
2. 测试 ruff 路径：不存在 package.json 但存在 pyproject.toml + ruff 可用时选择 ruff
3. 测试 golangci-lint 路径：无前两者但 golangci-lint 可用时选择
4. 测试无可检测工具时输出 tool=none
5. 测试缺少 task-id 时报错
6. 测试输出 JSON 合法性
7. 测试所有路径都生成合法的 lint-report.json

## 验收标准

- 新建 tests/test-lint-collector.sh
- 使用 PATH override mock lint 工具
- ≥7 个测试用例全部通过
