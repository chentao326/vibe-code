## 复盘

**复盘时间**: {{timestamp}}
**数据来源**: {{data_source}}

### 实际数据

| 指标 | 预估 | 实际 | 偏差 |
|---|---|---|---|
| 对话轮次 | {{pred_iter}} | {{actual_iter}} | {{iter_deviation}} |
| 耗时 | {{pred_time}} | {{actual_time}} | {{time_deviation}} |
| 文件改动 | — | {{files_changed}} files, +{{ins}}/-{{del}} | — |
| Lint 新增 | — | {{lint_errors}} errors, {{lint_warnings}} warnings | — |
| 测试通过率 | — | {{test_pass_rate}} | — |

### Bug 情况

{{bug_summary}}

### 哪些预估被验证 / 推翻

**被验证 ✅**:
{{verified}}

**被推翻 ❌**:
{{overturned}}

### 需要写进 rubric.md 的新观察

{{new_observations}}

### 主观复盘

<!-- 自由文本：这次哪里顺、哪里卡、学到了什么 -->
{{notes}}
