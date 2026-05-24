<h2 align="center">Vibe Code</h2>

<p align="center">
For developers who use AI coding assistants — a skill that turns every task into a calibrated experiment.
</p>

<p align="center">
You say "this task should be easy." You've said it a hundred times.<br>
How many times were you right? You don't know — because you never kept books.<br>
Vibe Code keeps them for you. One month in, your judgment has data behind it.<br>
Three months in, your prompt intuition is 10× sharper than day one.
</p>

<p align="center">
  <a href="README.md"><strong>简体中文</strong></a>
  &nbsp;·&nbsp;
  <strong>English</strong>
</p>

<p align="center">
<a href="CHANGELOG.md"><img src="https://img.shields.io/badge/rubric-v1-success" alt="Rubric v1"></a>
&nbsp;
<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
&nbsp;
<a href="#"><img src="https://img.shields.io/badge/tests-70%2F70-brightgreen" alt="Tests"></a>
&nbsp;
<a href="#"><img src="https://img.shields.io/badge/calibration-6_samples-ff69b4" alt="Calibration"></a>
</p>

---

## What it does

Most AI coding users live in the same loop:

> Prompt → AI generates → works / doesn't → wing it next time

A developer who's used AI coding for six months is barely sharper than someone on day one — because they never **retro'd** a single task.

**Vibe Code** turns every coding session into a traceable experiment:

Assess → Blind-predict → Code → Retro → Evolve your rubric

This isn't productivity theater. It's **compounding** — every task you don't retro is silently eroding your ability to see yourself.

---

## Origin

> I built a content creation toolkit that used "blind-predict → retro → evolve the formula." It took me from zero to 1M followers in a month.
>
> Then I realized: the methodology isn't content-specific. It works for any workflow that can be broken into "task → execute → retro."
>
> So I built Vibe Code. It ports the calibration engine from content creation to software engineering — assess task difficulty, predict rounds and time, settle the books after coding, and let the model evolve with your data.
>
> After three months, your guess about "how long will this take" is no longer a guess. It's data.
>
> — *ported from cheat-on-content*

---

## How it differs from other AI coding tools

| Other tools | Vibe Code |
|---|---|
| Write code for you | **Judge** what good code looks like |
| AI does the work | AI **assesses** the work — you still execute |
| Task done, move on | Task done is the beginning — predicted vs. actual, **deviation logged** |
| Each session is siloed | An **evolving rubric** — v1 ≠ v0, and v2 won't equal v1 |

In a sentence: other tools help you "ship faster." This helps you "judge sharper."

---

## Why the rubric actually evolves

Every completed task feeds its deviation analysis into the rubric. Three same-direction misses in a row, and the tool nudges you to upgrade the scoring formula. Upgrades require:

- Full historical rescore
- Rank consistency ≥ 80%
- Cross-model independent audit

**You're not guessing alone — the model remembers, settles, and evolves for you.**

Observations refuted by data get deleted. Observations absorbed into formal dimensions also get deleted. The rubric only holds what's most useful right now.

---

## Install

```bash
git clone https://github.com/chentao326/vibe-code.git
cd vibe-code
bash install.sh        # Claude Codex (default)
bash install.sh --all  # Codex + Claude Code + Cursor
```

13 sub-skills are symlinked into your agent's skill directory. One install, every project gets it.

**Supported agents**: Claude Code (default) · Codex · Cursor

> Frozen version: `bash install.sh --copy`
>
> Uninstall: `bash uninstall.sh` (your project data is not touched)

---

## First run

In your project directory, open Claude Code / Codex and say:

```
初始化 vibe-code
```

New projects go through a standard 5-question onboarding. Projects with git history are auto-detected and offered historical task import — giving the rubric an anchor from day one.

---

## Daily use

```
评估这个任务 tasks/xxx.md   → score + blind prediction (before coding, locked on save)
code                        → AI does the work
复盘                        → collect git data, predicted vs. actual
升级模型                     → evolve formula (needs ≥5 calibration samples)

status / find topic / recommend / trends / profile / quick score
```

With hooks installed, WIP + pending retros + bump alerts show at every session start. Full workflow: [SKILL.md](SKILL.md).

---

## Current status

| Metric | Value |
|---|---|
| Rubric | v1 (CX×1.5 + TE×1.5) |
| Calibration pool | 6 blind-prediction samples |
| Spearman ρ | −0.893 |
| Tests | 70/70 passing |

---

## License

MIT. Commercial use, modification, closed-source integration — all fine.

---

*Is this over-engineering? So was writing tests. So was code review.*
*The future doesn't reward those who code fastest — it rewards those who judge sharpest.*
