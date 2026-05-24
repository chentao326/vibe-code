# Vibe Code — 状态看板

**更新时间**: {{timestamp}}
**Rubric 版本**: {{rubric_version}}
**校准进度**: {{calibration_samples}} 样本 | Confidence: {{confidence}}

---

## 📝 WIP（进行中）

{{#each wip_tasks}}
- {{title}} — assessed {{date}}
{{else}}
（无进行中任务）
{{/each}}

## ⏰ 待复盘

{{#each pending_retros}}
- {{id}} — 预估完成于 {{date}}
{{else}}
（无待复盘任务）
{{/each}}

## 📈 效率趋势

总评估: {{total_assessed}} | 已完成: {{total_completed}} | 已放弃: {{total_abandoned}}

准确率: {{accuracy_summary}}

## ⚠️ 提醒

{{alerts}}
