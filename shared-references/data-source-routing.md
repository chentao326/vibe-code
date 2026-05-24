# Data Source Routing（数据源路由）

被 vibe-retro、vibe-seed、vibe-trends 引用。

定义不同数据采集场景下 adapter 的选择逻辑。

## 复盘数据源

| 场景 | adapter | 输出 |
|---|---|---|
| 代码变更统计 | git-stats | retros/<id>/git-report.json |
| 代码质量 | lint-collector | retros/<id>/lint-report.json |
| 耗时 | time-tracker | retros/<id>/time-report.json |

## 选题数据源

| 场景 | 来源 |
|---|---|
| 技术债 | grep TODO/FIXME/HACK |
| 测试缺口 | 源码 vs 测试文件对比 |
| 重构候选 | git log churn + 大文件 |
| 依赖更新 | npm-check-updates / pip list --outdated |

## 趋势数据源

| 场景 | 来源 |
|---|---|
| 安全漏洞 | npm audit / pip-audit |
| Breaking changes | 核心依赖的 CHANGELOG / release notes |
| 社区动态 | GitHub issues（如有 repo URL） |

## Adapter 失败处理

| 症状 | 处理 |
|---|---|
| adapter 未安装 | 跳过该数据源，在输出标注数据不完整 |
| adapter 执行失败 | 重试 1 次，仍失败 → 跳过 + 建议手动采集 |
| 输出格式异常 | 跳过解析，保留原始输出到 debug 目录 |
