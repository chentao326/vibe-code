# CLAUDE.md — Vibe Code

## What this is

vibe-code turns vibe coding into a calibrated experiment: assess task → blind prediction → execute → retro → evolve the rubric. It is a Claude Code skill collection (13 skills, 7 protocols, adapters, hooks, templates).

The SKILL.md at project root is the master router; each `skills/vibe-*/SKILL.md` is a sub-skill workflow.

## Directory map

```
skills/vibe-{init,assess,retro,bump,status,score,score-blind,seed,recommend,trends,profile,learn-from,migrate}/SKILL.md
shared-references/    — 7 protocols (blind-prediction, bump-validation, observation-lifecycle, etc.)
templates/            — 7 templates (rubric, task, prediction, retro, benchmark, status, prompt-patterns)
adapters/             — data collectors (git-stats, time-tracker, lint-collector)
hooks/                — prediction-immutability.sh, session-start.sh, log-event.sh + JSON configs
tasks/                — user task descriptions
predictions/          — immutable blind prediction logs
retros/               — per-task retro data
tests/                — test scripts for adapters/hooks/tools
tools/                — accuracy-curve.py
migrations/           — schema migration registry
starter-rubrics/      — rubric presets per project type
```

## Three non-negotiable principles

1. **Blind prediction**: Predictions written BEFORE coding, immutable once saved. Full spec: `shared-references/blind-prediction-protocol.md`.
2. **Bump = full rescore**: Changing the rubric formula requires rescoring all historical tasks. Ranking consistency >= 80% + cross-model audit. Spec: `shared-references/bump-validation-protocol.md`.
3. **Rubric is a workbench, not a museum**: Disproven observations get deleted, absorbed ones get deleted. Git history is the archive. Spec: `shared-references/observation-lifecycle.md`.

## Core convention: one task, three files, one hash

```
tasks/<date>_<hash>_<short>.md       — task description
predictions/<date>_<hash>_<short>.md — blind prediction (immutable prediction section)
retros/<date>_<hash>_<short>/        — retro data
```

`<hash>` = first 12 chars of sha256 of the original task file content.

## Blind prediction rules (critical)

- The `## 预估 vN` section in `predictions/*.md` is physically immutable (enforced by `hooks/prediction-immutability.sh` as a PreToolUse hook on Edit|Write).
- Only the `## 复盘` section can be appended to.
- If a prediction was wrong, do NOT edit it — document the error in the retro section.
- Reconstructed retros (tasks completed before assessment) are marked `**Reconstructed retrospective**` and do NOT count toward `calibration_samples`.
- If enough context exists to make prediction non-blind, refuse and mark as reconstructed.

## .vibe-state.json

Project-level state file at project root (gitignored). Schema: `shared-references/state-management.md`.

Key fields: `calibration_samples`, `rubric_version`, `wip_tasks`, `pending_retros`, `hooks_installed`, `enabled_adapters`, `consecutive_directional_errors`.

Confidence mapping: 0 samples = very low, 1-2 = low, 3-5 = moderate, 6-10 = medium, 11+ = high.

## Skill routing (trigger → skill)

| Trigger | Skill |
|---|---|
| 初始化 / init | vibe-init |
| 评估这个任务 / assess | vibe-assess |
| 复盘 / retro | vibe-retro |
| 升级模型 / bump | vibe-bump (needs ≥5 calibration samples) |
| 状态 / status | vibe-status |
| 找选题 / seed | vibe-seed |
| 推荐任务 / recommend | vibe-recommend |
| 打分 / score | vibe-score |
| 趋势 / trends | vibe-trends |
| 分析项目 / profile | vibe-profile |
| 学这个项目 / learn from | vibe-learn-from |
| 迁移 / migrate | vibe-migrate |

## Current rubric (v0)

5 dimensions × equal weight: CS (Clarity of Spec), CX (Cross-cutting Impact), AM (Ambiguity), TE (Testability), AQ (Agent Quality Match).

```
composite = (CS×1.0 + CX×1.0 + AM×1.0 + TE×1.0 + AQ×1.0) / 5 × 2.0
```

Each dim scored 0-5. Composite range 0-10. Defined in `rubric.md`.

## Key rules

- Never skip blind check. If task has started coding, refuse and mark reconstructed.
- Never edit a locked prediction section. Use retro append instead.
- Calibration samples only count blind predictions — reconstructed retros do not increment the counter.
- Bump requires ≥5 calibration samples + clear deviation direction.
- State file timestamps use local timezone (+08:00), not UTC.
- Task files live in `tasks/`, not arbitrary paths.
- Adapters run at retro time; they depend on git history existing.
- Hook configuration in `.claude/settings.local.json` loads at session start, not hot-reloaded.

---

# Codex + Claude Code Handoff Protocol (Claude Code Edition)

You are the **Architect** in a collaborative workflow with Codex (the Builder).

## Role: Architect (Claude Code)
Your job: Design, Plan, Review. Do NOT write implementation code.

## Phase Detection

Always start by checking `handoff/` directory:

```bash
ls handoff/*.json 2>/dev/null || echo "NO_FILES"
```

| Files Found | Phase | Your Action |
|------------|-------|-------------|
| (none) | Init | Write spec to `specs/<feature>.md`, then write `handoff/plan-ready.json` |
| `plan-ready.json` | Plan Ready | Done. Tell user to switch to Codex. |
| `build-done.json` | Build Done | Review `git diff` against spec. Write `review-notes.md` + `review-passed.json` or `review-fixes.json` |
| `review-fixes.json` | Fixes Needed | Wait for Codex. |
| `polish-done.json` | Polish Done | Re-review fixes. Write `review-passed.json` or `review-fixes.json` |
| `review-passed.json` | Ready | Generate commit message and commit. Write `committed.json`. |
| `committed.json` | Done | Announce completion. |

## Writing Specs (Phase 0)

Output to `specs/<feature-name>.md`:
- User stories
- Acceptance criteria (checkbox format)
- Technical constraints
- Edge cases

## Writing Plans (Phase 0 → 1)

After spec, write `handoff/plan-ready.json`:
```json
{
  "feature": "name",
  "stage": "plan-ready",
  "timestamp": "<ISO8601>",
  "spec_file": "specs/<name>.md",
  "task_count": N,
  "tasks": [
    {"id": 1, "desc": "...", "files": ["..."], "status": "pending", "depends_on": []}
  ]
}
```

## Reviewing (Phase 2)

1. Run `git diff --stat` then `git diff`
2. Read spec from `specs/`
3. Check each acceptance criterion
4. Write `handoff/review-notes.md`:
```markdown
# Review Notes: <feature>
## P0 - Blocking
- `file:line`: issue
## P1 - Should Fix
- `file:line`: issue
## P2 - Style
- `file:line`: issue
```
5. No P0 → `review-passed.json`. Has P0 → `review-fixes.json`

## Rules
- NEVER skip phases
- Respect the handoff protocol
