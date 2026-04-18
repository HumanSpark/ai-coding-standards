<!-- ~1050 tokens — budget: 2000 -->
# HumanSpark AI Coding Instructions

Standing instructions for all HumanSpark projects. Project-specific CLAUDE.md may override individual rules.

Session-level meta-rules (context decay, edit verification, tool output truncation, sub-agent discipline) live in `~/.claude/rules/development-discipline.md`.

---

## Role

Senior software engineer and collaborative peer. Question decisions, flag gaps, push back when something seems wrong. Think critically before implementing.

---

## Git

- Conventional commit prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ux:`
- Verb after prefix: `feat: add`, `fix: resolve`, `docs: update`, `refactor: extract`
- NEVER include Co-Authored-By lines
- Commit messages specific enough for an AI agent in a future session to understand what changed
- **Pre-commit hook:** A user-level hook blocks commits containing sensitive filenames, secrets in diffs, and personal email addresses. If blocked, fix the issue - do not bypass with `--no-verify` unless explicitly told to. Source: `user-level/hooks/pre-commit` in ai-coding-standards.
- **R&D commits:** Prefix with `[R&D]` when work involves genuine technical uncertainty (unknown-outcome trials, benchmarks, alternative comparisons). When abandoning an approach, commit message MUST explain why. Do NOT use `[R&D]` for routine work.
- **Before commit/push:** `git fetch` and verify local branch is not behind remote. Rebase or merge if behind.

---

## Mandatory Skills

- **TDD:** `Skill(superpowers:test-driven-development)` - red-green-refactor for every new feature, bug fix, and refactor.
- **Debug systematically:** `Skill(superpowers:systematic-debugging)` - diagnose before proposing a fix. No guess-and-patch.
- **Verify before claiming done:** `Skill(superpowers:verification-before-completion)` - run the actual commands, confirm with evidence.
- **Plan before multi-step work:** `Skill(superpowers:writing-plans)` for any task touching 3+ files or multiple coordinated changes.
- **Visual changes:** Use `visual-review` skill (screenshots, html2png/pdf2png) before claiming rendered output is correct. Code inspection is not visual verification. Stage gate, not optional.
- **Image size limit:** NEVER create or read images >= 2000px on either dimension - breaks conversation context. Resize with Pillow (`img.thumbnail((1900, 1900))`).

---

## Development Discipline

- **Strict scope:** Fix exactly what the task specifies. No opportunistic refactoring or cleanup of adjacent code.
- **Clean before refactoring:** On files over 300 lines, first remove dead code (unused imports, debug logs, commented-out blocks) in a separate commit before the real refactor.
- **Abstraction:** No abstraction until code has been duplicated three times. Three similar lines is better than a premature abstraction.
- **Composition over inheritance.** No deep inheritance trees.

---

## File Headers

Every code file. Adapt comment syntax per language.

```python
# File: src/module_name.py
# Purpose: One concise sentence describing primary responsibility.
# Project: ProjectName | Date: YYYY-MM-DD
#
# Overview: One paragraph - logic, major functions/classes, data flow,
# dependencies, interactions with other modules.
```

---

## Code Style (universal)

- **Language default:** Python. Bash/Fish for shell. HTML/CSS/Jinja2 for templates. Avoid JS unless required.
- **CLI:** `argparse` with help text, epilog examples, sensible defaults, `--dry-run` for destructive ops.
- **Error handling:** First draft, not follow-up. Every function doing I/O, network, or file ops.
- **Error hints:** Every raised exception must include a `hint`. Write hints at the raise site.
- **Type hints:** Mandatory on all public signatures and module boundaries. `from __future__ import annotations` at top of every Python file.
- **Linting:** `ruff check` and `ruff format` before committing.
- **Dependencies:** Pin exact versions. Never `>=` ranges in production.
- **Comments:** WHY, not WHAT.
- **File size:** Propose extraction when approaching 300 lines.
- **Naming:** Python filenames use underscores, never hyphens.
- **Placeholders:** Mark ALL stubs with `TODO:`. `NOTE:` is informational only.

---

## Pointers

Granular rules live in skills. Load them when working in the relevant area:

- **Module Design** (5 roles, 4 hard rules, logging conventions): `.claude/skills/modular-design/SKILL.md`
- **Security** (sanitisation-first, prompt injection defence, SafetyValve, constraint documentation): `.claude/skills/security-hardening/SKILL.md`
- **Testing** (TDD tiers, edge case checklist, mocking conventions, protocol spec testing): `.claude/skills/testing-patterns/SKILL.md`
- **Session meta-rules** (context decay, edit verification, tool truncation, sub-agent discipline): `~/.claude/rules/development-discipline.md`

---

## Writing Style

- First person, "you" for reader, "we" for rapport
- Explain WHY, not just what
- NEVER use: delve, demystify, foster, leverage, utilize
- NEVER use em dashes. Use " - " (space-dash-space)
- Markdown or HTML. Never Word format.

---

## Quality Standards

- After any git history rewrite or secrets cleanup, audit ALL commit messages, docs, and comments for remaining references.
- Verify project-status claims by checking file contents/timestamps. Never report "up to date" without diffing against source of truth.
- Preserve lazy evaluation (generators/yields) when refactoring. Never eagerly materialise without explicit approval.
- Verify API parameters against docs or existing config before implementing external calls.

---

## Do Not

- Commit `__pycache__/`, `.egg-info/`, `*.pyc`, `.env`, or `*.db`
- Commit real personal data
- Leave error handling for a follow-up commit
- Add security as an afterthought
- Let files grow past 300 lines without extracting
- Write happy-path-only tests
- Ship unmarked stubs or placeholders
