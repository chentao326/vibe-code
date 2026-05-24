# Vibe Code

**Turn vibe coding into a calibrated experiment.**

You tell your AI "this should be easy" — how often are you right? Vibe Code answers that question with data by turning every AI coding session into a closed-loop experiment.

---

## One-liner

```
Assess → Blind-predict → Code → Retro → Evolve your judgment
```

---

## Install

```bash
git clone https://github.com/chentao326/vibe-code.git
cd vibe-code
bash install.sh        # Claude Codex (default)
bash install.sh --all  # Codex + Claude Code + Cursor
```

---

## Quick Start

In your project directory, say `初始化 vibe-code` (init vibe-code). Five questions and you're set up.

Then follow this loop for every task:

```
1. Write task     tasks/xxx.md
2. Assess         Score + blind prediction (locked on save)
3. Code           AI does the work
4. Retro          Predicted vs. actual, deviation analysis
5. Bump           Evolve the formula after 5+ retro samples
```

---

## Current Status

| Metric | Value |
|--------|-------|
| Rubric | v1 (CX×1.5 + TE×1.5) |
| Calibration pool | 6 blind-prediction samples |
| Confidence | 🟢 Medium |
| Tests | 70/70 passing |
| Spearman ρ | −0.893 |

### Rubric v1 Formula

```
composite = (CS×1.0 + CX×1.5 + TE×1.5 + AM×1.0 + AQ×1.0) / 6.0 × 2.0
```

Five dimensions: CS (Clarity of Spec), CX (Cross-cutting Impact), TE (Testability), AM (Ambiguity), AQ (Agent Quality Match).

---

## Command Reference

### Core Loop

| Command | Description |
|---------|-------------|
| `初始化 vibe-code` | First-time onboarding |
| `评估这个任务 tasks/xxx.md` | Score + blind prediction (before coding) |
| `复盘` | Compare prediction vs. actual |
| `升级模型` | Evolve formula (needs ≥5 calibration samples) |

### Auxiliary

| Command | Description |
|---------|-------------|
| `状态` | Dashboard: WIP / pool / accuracy / bump alerts |
| `找选题` | Scan codebase for TODOs, test gaps, stale deps |
| `打分这篇 tasks/xxx.md` | Quick score (console only, no file written) |
| `推荐任务` | Priority recommendations |
| `趋势` | Security advisories + dependency updates |
| `分析项目` | Codebase profile (hotspots, coverage, deps) |
| `学这个项目 <url>` | Learn from a reference open-source project |
| `迁移` | Upgrade state schema |

---

## Key Concepts

| Concept | Meaning |
|---------|---------|
| Blind prediction | Prediction written before coding, physically immutable |
| Rubric | 5-dimension evaluation model that evolves with data |
| Calibration pool | All blind-predicted + retro'd tasks — the bump validation set |
| Confidence | Current model reliability, honestly labeled |
| Bump | Formula upgrade — full rescore + rank consistency ≥80% + cross-model audit |

---

## Project Structure

```
skills/vibe-*/     — 13 sub-skills
shared-references/ — 7 protocol docs
adapters/          — Data collectors (git-stats, time-tracker, lint-collector)
hooks/             — prediction-immutability + session-start
templates/         — 7 scaffold templates
tests/             — 7 test scripts (70 cases)
CLAUDE.md          — AI project instructions
```

---

## Why not another project management tool

Jira and Linear track *what* to do. Vibe Code tracks *how you judge*. One manages deadlines; the other manages judgment accuracy. One is static configuration for humans; the other is a self-evolving model for AI agents.

---

## License

MIT
