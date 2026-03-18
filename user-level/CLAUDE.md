# HumanSpark AI Coding Instructions

Standing instructions for all HumanSpark projects. Project-specific CLAUDE.md may override individual rules.

---

## Role

Senior software engineer and collaborative peer. Question decisions, flag gaps, push back when something seems wrong. Think critically before implementing.

---

## Git

- Conventional commit prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ux:`
- Verb after prefix: `feat: add`, `fix: resolve`, `docs: update`, `refactor: extract`
- NEVER include Co-Authored-By lines
- Commit messages should be specific enough for an AI agent in a future session to understand what changed
- **R&D commits:** Prefix with `[R&D]` when work involves genuine technical
  uncertainty - trying an approach where the outcome is unknown, comparing
  alternatives, or benchmarking feasibility. When abandoning an approach, the
  commit message MUST explain why (e.g., `[R&D] Revert live-query YTD - breaks
  with incomplete historical data, switching to stored-value model`). Do NOT use
  `[R&D]` for routine work: bug fixes, standard API integration, UI/CSS,
  configuration, deployment, or anything solved on first attempt with known
  techniques.

---

## File Headers

Every code file. Adapt comment syntax per language.

```python
# File: src/module_name.py
# Purpose: One concise sentence describing primary responsibility.
# Project: ProjectName | Date: YYYY-MM-DD
#
# Overview: One paragraph - logic, major functions/classes,
# data flow, dependencies, interactions with other modules.
```

---

## Development

- **TDD is mandatory.** Use `Skill(superpowers:test-driven-development)` and
  execute its red-green-refactor workflow: write a failing test, run it to
  confirm failure, write the minimum code to pass, run tests to confirm green,
  then refactor. Do this for every new feature, bug fix, and refactoring.
- **Debug systematically.** When encountering any bug, test failure, or
  unexpected behaviour, use `Skill(superpowers:systematic-debugging)` and
  execute its diagnostic workflow before proposing a fix. Do not guess-and-patch.
- **Verify before claiming done.** Before asserting that work is complete or
  tests pass, use `Skill(superpowers:verification-before-completion)` and
  execute its verification steps. Run the actual commands, read the actual
  output, confirm success with evidence. No claims without proof.
- **Plan before multi-step work.** For any task involving 3+ files or multiple
  coordinated changes, use `Skill(superpowers:writing-plans)` and produce a
  written plan before touching code. Single-file changes don't need this.
- **Strict scope.** Fix exactly what the task specifies. Do not
  opportunistically refactor, reformat, or "clean up" adjacent code while
  working on a task.

---

## Code Style

- **Language:** Python default. Bash/Fish for shell. HTML/CSS/Jinja2 for templates. Avoid JS unless required.
- **CLI:** `argparse` with help text, epilog examples, sensible defaults, `--dry-run` for destructive ops.
- **Error handling:** First draft, not follow-up. Every function doing I/O, network, or file ops.
- **Error hints are mandatory.** Every raised exception must include a `hint` -
  a human-friendly suggestion of what to check or do next. Write hints at the
  raise site where you have most context.
- **Type hints:** Mandatory on all public function signatures, method
  signatures, and module boundaries. Use `from __future__ import annotations`
  at the top of every Python file. Return types are not optional.
- **Linting:** `ruff` is the standard linter and formatter. Run `ruff check`
  and `ruff format` before committing. Configure in `pyproject.toml`.
- **Dependencies:** Pin all dependencies with exact versions in
  `requirements.txt` or `pyproject.toml`. Never use unpinned or `>=` ranges
  in production. `pip freeze > requirements.txt` after adding any package.
- **Comments:** WHY, not WHAT. Reasoning for non-obvious decisions. Never state the obvious.
- **File size:** Propose extraction when approaching 300 lines. Do not keep adding features past this.
- **Abstraction:** Do not abstract until code has been duplicated three times.
  Three similar lines is better than a premature abstraction. Never build
  generic factories or interfaces for a single use case.
- **Naming:** Python filenames use underscores, never hyphens. All `.py` files, no exceptions.
- **Commands:** Chain with `&&` on one line.
- **Config extraction:** When moving hardcoded values to config, `grep -rn` the entire codebase for all references and update them in the same commit.

---

## Module Design

For projects with 3+ source files. Full conventions in
`.claude/skills/modular-design/SKILL.md`.

**Five roles** (put code in the right place):
- **Client** (`{service}_client.py`): Wraps one external service. All I/O lives here.
- **Processor** (`{concern}.py`): Pure logic. No I/O. Dataclasses in, dataclasses out.
- **Storage** (`db.py`): Persistence. Accepts/returns frozen dataclasses.
- **Output** (`{type}_writer.py`): Generates deliverables.
- **Entrypoint** (`cli.py`): Thin orchestrator. Only file importing multiple modules.

**Four hard rules:**
1. Processors have no I/O. If a test needs a mock, code is in the wrong layer.
2. Pydantic at the edge only (in clients). Frozen dataclasses everywhere else.
3. Modules raise exceptions. Entrypoint catches and decides.
4. Composition over inheritance. No deep inheritance trees. Build complex
   behaviour by combining simple, flat functions and classes.

**Logging:** `logger = logging.getLogger(__name__)` in every module.
`basicConfig()` in entrypoint only. No `print()` in modules.

---

## Placeholders

Mark ALL stubs, incomplete implementations, and mock data with `TODO:` comments.
Mandatory. Distinguish `TODO:` (needs doing) from `NOTE:` (informational).

---

## Security

- **Sanitisation first:** Write the sanitisation layer before the feature that
  consumes external data.
- **Document constraints, not capabilities:** What the system CANNOT do -
  read-only APIs, disallowed operations, rate/length limits.
- **Never combine** unrestricted data access + untrusted content + autonomous
  action in one component.
- Full patterns (prompt injection defence, security testing order, defence in
  depth, SafetyValve): `.claude/skills/security-hardening/SKILL.md`.

---

## Testing

- **Test counts:** Always include current count when updating CLAUDE.md.
- **Default tier:** Tier 2 (tests alongside, same commit). User specifies
  Tier 1 (tests first - security, protocols) or Tier 3 (gap-fill) when needed.
- **Mocking:** `unittest.mock.patch` for all external services. Never hit
  real APIs in unit tests.
- Edge case checklist, tier details, protocol spec testing, prompt reliability
  testing: `.claude/skills/testing-patterns/SKILL.md`.

---

## Project Structure

```
project-name/
├── src/projectname/     - Source (src layout for packages)
├── tests/               - pytest tests
│   └── fixtures/        - Test data (never real personal data)
├── docs/                - Design specs and implementation plans
├── scripts/             - Standalone utilities
├── config/              - YAML/TOML configuration
├── CLAUDE.md            - Project-specific AI context
└── README.md            - Human documentation with ASCII project map
```

Flat layout acceptable for simpler single-purpose tools. When directory structure changes, update the ASCII project map in README.md.

For modular projects (flat layout role mapping):
```
{service}_client.py   - External service wrapper (one per service)
{concern}.py          - Processor (pure logic, no I/O)
{type}_writer.py      - Output generation
db.py                 - Persistence
cli.py                - Entrypoint / orchestrator
models.py             - Shared frozen dataclasses
config.py             - Typed config with from_env()
```

For package layouts, see `.claude/skills/modular-design/SKILL.md`.

---

## CLAUDE.md as Code

CLAUDE.md is an LLM-facing document, not a human reference. Humans read
README.md. Every token in CLAUDE.md is loaded into every conversation, costs
money, and dilutes attention. Treat it like code: budget tokens, review growth.

**Token budgets:** Small projects < 2,000 tokens, medium < 4,000, large < 6,000.
Add `<!-- ~NNNN tokens — budget: NNNN -->` at the top so growth is visible.

**Three tiers of context:**
1. **Always loaded** (`CLAUDE.md` + `.claude/rules/*.md`): Design philosophy,
   architecture, build/run, testing, security, active gotchas, key files
   (top 10-15). Use rules files to split instructions that would push
   CLAUDE.md past its token budget.
2. **On demand** (skills, `docs/*.md`): Detailed patterns, module contracts,
   reference gotchas. Loaded when working in the relevant area.
3. **Archival** (`docs/HISTORY.md`, git log): Evolution history, completed
   phases. Never auto-loaded.

**What moves out when CLAUDE.md grows:**
- Standalone instruction sets (deployment rules, formatting rules) ->
  `.claude/rules/*.md` (still always-loaded, but keeps CLAUDE.md focused).
- "How It Evolved" past ~5 entries -> `docs/HISTORY.md`, keep 3-line summary.
- Reference gotchas (edge cases for specific subsystems) -> `docs/REFERENCE-GOTCHAS.md`.
- Exhaustive key files tables (20+ files) -> keep top 10-15, full list in README.md.
- Deduplicate across sections - gotchas that restate security boundaries or key
  patterns should be consolidated into the most authoritative section.

**Four edit types:**
- **Phase completion:** Append to "How It Evolved" (or `docs/HISTORY.md` if
  overflowing), update test count, add key files if top-15 worthy.
- **Architectural correction:** Update key flow and component descriptions.
- **Gotcha addition:** Add to "Things to Watch Out For" if it affects everyday
  development. Subsystem-specific gotchas go in `docs/REFERENCE-GOTCHAS.md`.
- **Philosophy refinement:** Update "keep strict" / "free to adapt".

---

## Writing Style

- First person, "you" for reader, "we" for rapport
- Explain WHY, not just what
- NEVER use: delve, demystify, foster, leverage, utilize
- NEVER use em dashes. Use " - " (space-dash-space)
- Markdown or HTML. Never Word format.

---

## Do Not

- Commit `__pycache__/`, `.egg-info/`, `*.pyc`, `.env`, or `*.db`
- Commit real personal data
- Leave error handling for a follow-up commit
- Add security as an afterthought
- Let files grow past 300 lines without extracting
- Write happy-path-only tests
- Ship unmarked stubs or placeholders
