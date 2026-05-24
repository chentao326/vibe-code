# Adapter: time-tracker

追踪任务墙钟耗时。分两阶段调用：

```bash
# vibe-assess 时记录开始时间
bash adapters/time-tracker/collect.sh start <task-id>

# vibe-retro 时记录结束时间，计算差值
bash adapters/time-tracker/collect.sh report <task-id>
```

## 输出

JSON 写到 `retros/<task-id>/time-report.json`：

```json
{
  "started_at": "2026-05-24T15:00:00+00:00",
  "completed_at": "2026-05-24T15:22:00+00:00",
  "duration_minutes": 22
}
```

## 局限

- 追踪的是"墙钟时间"（wall-clock time），不是纯编码时间
- 包含了思考和打断——但这更诚实
- 如果 `start` 没被调用过，`report` 会输出 duration_minutes: null 而非报错
