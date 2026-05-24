---
name: vibe-seed
description: 从代码库中找"该做什么"——扫描 TODO/FIXME、测试覆盖缺口、过期依赖、高频 churn 文件。适合已有项目冷启动期选题。触发词："找选题"/"我不知道做什么"/"有什么可以做的"/"seed"。
allowed-tools: Bash(*), Read, Glob, Grep
---

# vibe-seed — 找选题

从代码本身提取候选任务。不依赖已有 tasks/ 目录。

## Workflow

### Phase 1: 多源并行扫描

**源1: TODO/FIXME/HACK**
```bash
grep -rn "TODO\|FIXME\|HACK\|XXX\|WORKAROUND" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" . | head -30
```

**源2: 高频 churn 文件**
```bash
git log --format=format: --name-only | sort | uniq -c | sort -rn | head -15
```

**源3: 测试覆盖缺口**
```bash
find . -name "*.ts" -not -name "*.test.ts" -not -name "*.spec.ts" -not -path "*/node_modules/*" | head -50 | while read f; do
  test="${f%.ts}.test.ts"; [ ! -f "$test" ] && echo "UNTESTED: $f"
done | head -20
```

**源4: 过期依赖**
```bash
npx npm-check-updates 2>/dev/null | head -20 || pip list --outdated 2>/dev/null | head -20
```

**源5: 大文件**
```bash
find . -name "*.ts" -not -path "*/node_modules/*" -exec wc -l {} + | sort -rn | head -10
```

### Phase 2: 分类输出

```
🌱 选题建议

🔧 技术债（N个）— TODO/FIXME
📦 依赖更新（N个）— 过期/不安全
🧪 测试补全（N个）— 无测试覆盖
♻️ 重构候选（N个）— 高churn/大文件

💡 选感兴趣的，说 "展开 tasks/seed_xxx" 帮你写成正式任务。
```

### Phase 3: 展开
用户选候选 → 写成正式 task 文件到 `tasks/<date>_<hash>_<short>.md`。
