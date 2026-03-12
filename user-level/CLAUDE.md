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
- Commit to `main` only. No feature branches.

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

## Code Style

- **Language:** Python default. Bash/Fish for shell. HTML/CSS/Jinja2 for templates. Avoid JS unless required.
- **CLI:** `argparse` with help text, epilog examples, sensible defaults, `--dry-run` for destructive ops.
- **Error handling:** First draft, not follow-up. Every function doing I/O, network, or file ops.
- **Comments:** WHY, not WHAT. Reasoning for non-obvious decisions. Never state the obvious.
- **File size:** Propose extraction when approaching 300 lines. Do not keep adding features past this.
- **Naming:** Python filenames use underscores, never hyphens. All `.py` files, no exceptions.
- **Commands:** Chain with `&&` on one line.
- **Config extraction:** When moving hardcoded values to config, `grep -rn` the entire codebase for all references and update them in the same commit.

---

## Placeholders

Mark ALL stubs, incomplete implementations, and mock data with `TODO:` comments. Mandatory.

```python
# TODO: Replace with actual API call - currently returns mock data
def get_user_profile(user_id):
    return {"name": "STUB_USER", "email": "stub@example.com"}
```

Distinguish `TODO:` (needs doing) from `NOTE:` (informational).

---

## Security

- **Sanitisation first:** Write the sanitisation layer before the feature that consumes external data.
- **Security tests before feature tests** for anything handling external data, user input, or auth.
- **Document constraints, not capabilities:** What the system CANNOT do - read-only APIs, disallowed operations, rate/length limits.
- **Prompt injection:** Boundary markers (`--- BEGIN/END DATA ---`) around untrusted data. XML tags for RAG document delimiters.
- **Defence in depth:** Code-level enforcement is the primary defence. Prompt rules are secondary. Never rely on prompts alone.
- **Never combine** unrestricted data access + untrusted content + autonomous action in one component.

---

## Testing

- **Test counts:** Always include current count when updating CLAUDE.md.
- **Tiers** (user will specify):
  - **Tier 1 - tests first:** Security, protocol compliance, sanitisation, API contracts.
  - **Tier 2 - tests alongside:** Feature code. Tests in the same commit. Default tier.
  - **Tier 3 - gap-fill:** Legacy catch-up only. User must explicitly request.
- **Edge cases** (walk this checklist per function):
  - Empty/missing: empty strings, None, missing keys, empty collections
  - Boundary strings: 10k+ chars, single char, whitespace-only
  - Unicode: emoji, Arabic, Chinese, mixed scripts
  - Numeric: zero, negative, sys.maxsize, float infinity, NaN
  - Type mismatches: wrong types for parameters
- **Mocking:** `unittest.mock.patch` for all external services. Never hit real APIs in unit tests.
- **Protocol specs:** Test against the spec, not just sample data.
- **Prompt reliability:** Separate test suite hitting real API for projects using LLM calls.

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

---

## CLAUDE.md Maintenance

Four edit types:

- **Phase completion:** Append numbered entry to "How It Evolved" (never edit old entries), update test count, add new files to key files table.
- **Architectural correction:** Update key flow diagram and component descriptions.
- **Gotcha addition:** Add to "Things to Watch Out For" when something bites.
- **Philosophy refinement:** Update "keep strict" / "free to adapt" in design philosophy.

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
- Create feature branches
- Add security as an afterthought
- Let files grow past 300 lines without extracting
- Write happy-path-only tests
- Ship unmarked stubs or placeholders
