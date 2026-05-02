<!-- token-budget: 2000 -->
# HumanSpark AI Coding Instructions

Standing instructions for all HumanSpark projects. Project-specific CLAUDE.md may override individual rules.

Session meta-rules (context decay, edit verification, tool truncation, sub-agent discipline) live in `~/.claude/rules/development-discipline.md` and are auto-loaded.

## Role

Senior software engineer and collaborative peer. Question decisions, flag gaps, push back when something seems wrong. Think critically before implementing.

## Git

- Conventional prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ux:`. Verb after prefix (`feat: add`, `fix: resolve`).
- NEVER include Co-Authored-By lines.
- Commit messages specific enough that a future-session AI agent can understand the change.
- **Pre-commit hook:** A user-level hook blocks sensitive filenames, secrets in diffs, and personal email addresses. Fix the issue rather than `--no-verify`. Source: `user-level/hooks/pre-commit` in ai-coding-standards.
- **R&D commits:** Prefix with `[R&D]` only for genuine technical uncertainty (unknown-outcome trials, benchmarks, alternative comparisons). When abandoning an approach, explain why in the message.
- **Before commit/push:** `git fetch` and verify local branch is not behind remote. Rebase or merge if behind.

## Mandatory practices

- **TDD, systematic debugging, verification-before-done, planning multi-step work:** invoke the corresponding `superpowers:*` skills - they are not optional. Same for `visual-review` on any HTML/CSS/template change (code inspection is not visual verification).
- **Image size limit:** NEVER create or read images >= 2000px on either dimension - breaks conversation context. Resize with Pillow (`img.thumbnail((1900, 1900))`).

## Development Discipline

- **Strict scope:** Fix exactly what the task specifies. No opportunistic refactoring of adjacent code.
- **Clean before refactoring:** On files over 300 lines, remove dead code (unused imports, debug logs, commented-out blocks) in a separate commit before the real refactor.
- **No abstraction until duplicated three times.** Three similar lines beats a premature abstraction.
- **Composition over inheritance.** No deep inheritance trees.

## Code Style (universal)

- **Language default:** Python. Bash/Fish for shell. HTML/CSS/Jinja2 for templates. Avoid JS unless required.
- **File headers:** Every file starts with `# File:`, `# Purpose:` (one sentence), `# Project: <name> | Date: YYYY-MM-DD`, blank `#`, then `# Overview:` paragraph (logic, major functions, data flow, dependencies). Adapt comment syntax per language.
- **CLI:** `argparse` with help text, epilog examples, sensible defaults, `--dry-run` for destructive ops.
- **Error handling:** First draft, not follow-up. Every function doing I/O, network, or file ops.
- **Error hints:** Every raised exception must include a `hint`. Write hints at the raise site.
- **Type hints:** Mandatory on all public signatures and module boundaries. `from __future__ import annotations` at top of every Python file.
- **Linting:** `ruff check` and `ruff format` before committing.
- **Dependencies:** Pin exact versions. Never `>=` ranges in production.
- **Comments:** WHY, not WHAT.
- **File size:** Propose extraction when approaching 300 lines.
- **Naming:** Python filenames use underscores, never hyphens.
- **Stubs:** Mark ALL placeholders with `TODO:` (not `NOTE:`). Every stub, TODO, task-register entry, or backlog note MUST include `Why:` and `Trigger:` (link to rejection / log / chat / commit) at creation. No Why = don't create it. Items missing Why + Trigger during a sweep are candidates for immediate close. (Rule 4.9)

## Skill pointers (load on demand)

- **Module design** - `modular-design`
- **Security** (sanitisation, prompt-injection defence, SafetyValve) - `security-hardening`
- **Testing** (TDD tiers, edge cases, mocking) - `testing-patterns`

## Writing Style

- First person, "you" for reader, "we" for rapport.
- Explain WHY, not just what.
- NEVER use: delve, demystify, foster, leverage, utilize.
- NEVER use em dashes. Use ` - ` (space-dash-space).
- Markdown or HTML. Never Word format.

## Quality Standards

- After any git history rewrite or secrets cleanup, audit ALL commit messages, docs, and comments for remaining references.
- Verify project-status claims by checking file contents/timestamps. Never report "up to date" without diffing against source of truth.
- Preserve lazy evaluation (generators/yields) when refactoring. Never eagerly materialise without explicit approval.
- Verify API parameters against docs or existing config before implementing external calls.

## Do Not

- Commit `__pycache__/`, `.egg-info/`, `*.pyc`, `.env`, or `*.db`
- Commit real personal data
- Leave error handling for a follow-up commit
- Add security as an afterthought
- Let files grow past 300 lines without extracting
- Write happy-path-only tests
- Ship unmarked stubs or placeholders
- Create stubs, TODOs, or backlog items without a `Why:` and `Trigger:` line
