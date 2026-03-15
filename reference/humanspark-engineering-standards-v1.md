# HumanSpark Engineering Standards

**Version:** 1.0
**Date:** 12 March 2026
**Author:** Alastair McDermott
**Derived from:** Git archaeology across 7 repositories (960+ commits), CLAUDE.md evolution analysis (52+ edits across 6 projects), and architectural review sessions.

This is a living document. It captures how I actually work, not how I aspire to work. Every rule here exists because something went wrong without it, or because a pattern proved its value across multiple projects.

---

## 1. First Principles

These are the foundational rules that everything else derives from. They came from experience, not theory.

### 1.1 Check for existing infrastructure before building new

Before writing any discovery, indexing, or data-gathering code, ask: "Does a catalogue, API, or index already exist for this?" The Forgejo API returns every repo in one call. The eTenders RSS feed provides structured data without scraping. Simple HTTP requests work before reaching for Playwright. The tendency to build from scratch is strong - resist it.

### 1.2 Detection before correction

Understand failure modes before attempting automated fixes. When something breaks, the first commit should expose and report the problem. The second commit fixes it. This applies to code, infrastructure, and processes equally. The tenderhelper DPS parsing issue was discovered this way - the detection pass revealed that DPS pages have a different HTML structure before any fix was attempted.

### 1.3 Prompts and instructions are code

System prompts, CLAUDE.md files, AGENTS.md files, and rules files are engineering artefacts. They get version-controlled, tested where possible, reviewed, and maintained with the same discipline as Python files. The spark project's `core.txt` was modified 46 times - the same churn rate as the main application code. Treat them accordingly.

### 1.4 Security boundaries are constraints, not features

Document what the system CANNOT do, not just what it can. "FreeAgentClient has NO send/delete methods" is more useful to an AI agent than a list of methods it does have. The SafetyValve pattern - whitelist of allowed actions, explicit rate/length limits, read-only files declared up front - should be the default for any component that handles external data or user input.

### 1.5 The thinking is the work

Coding speed was never the bottleneck. Requirements, architecture decisions, and understanding the problem space are where the real time goes. Optimising the typing is a smaller concern than getting the design right. A well-crafted implementation plan is worth more than a fast but misdirected sprint of code.

---

## 2. Project Setup

### 2.1 Every project gets a CLAUDE.md from commit one

Do not start with a 5-line stub. Use the template in Section 8. A Stage 4 CLAUDE.md (design philosophy, evolution history, build commands, test commands, architecture overview, security boundaries, gotchas) from the start prevents the retroactive "add sections after discovering you needed them" pattern seen across all projects. The design philosophy section tells Claude Code *how to think about quality* for this specific project. The evolution history gives it full project context without reading git log.

### 2.2 Standard directory structure for Python projects

```
project-name/
  src/projectname/        # Source (src layout for packages)
  tests/                  # pytest tests
  docs/                   # Design specs, plans, architecture
  scripts/                # Standalone utilities
  config/                 # YAML/TOML configuration
  (root files)            # CLAUDE.md, README.md, pyproject.toml, .gitignore
```

For simpler single-purpose tools (like tenderhelper), a flat layout is acceptable:

```
project-name/
  module1.py
  module2.py
  tests/
  docs/
  config.yaml
  CLAUDE.md
```

### 2.3 Python filenames use underscores, never hyphens

Any Python file that might be imported must use underscores. Hyphens in Python filenames cause `ModuleNotFoundError` because Python interprets `-` as a minus operator. This applies to all `.py` files without exception. Shell scripts and non-Python files can use hyphens.

### 2.4 .gitignore from the first commit

Include at minimum: `__pycache__/`, `*.pyc`, `.coverage`, `*.db`, `venv/`, `.env`, `output/`. Also gitignore personal Claude Code files that shouldn't be shared: `CLAUDE.local.md`, `.claude/settings.local.json`, `.claude/agent-memory-local/`. Note: `.claude/settings.json`, `.claude/skills/`, `.claude/agents/`, and `.claude/rules/` ARE committed - they're team-shared project config. The ragbuilder project had to retroactively remove committed `__pycache__` and `egg-info` files. SessionPilot had the same issue. Don't repeat this.

### 2.5 Never commit real or personal data

Use fixtures from the first commit. The clearmail project required two separate commits to remove hardcoded personal data from the codebase. Build fixture data early and use it in both tests and development. Store fixtures in `tests/fixtures/` or `test_fixtures/`.

### 2.6 README.md includes an ASCII project map

The CLAUDE.md key files table handles AI onboarding. For human onboarding, the README.md must include an ASCII project map showing the hierarchical file/folder structure with brief descriptions. This is maintained by Claude Code as part of phase completion updates.

```
project-name/
├── src/projectname/
│   ├── main.py          - Entry point, listener loop
│   ├── config.py         - Constants and configuration loading
│   └── utils/
│       └── sanitizer.py  - Input sanitisation for external data
├── tests/                - pytest test suite
│   ├── test_main.py      - Listener and message processing tests
│   └── fixtures/         - Test data (never real/personal data)
├── docs/                 - Design specs and implementation plans
├── scripts/              - Standalone utilities and cron wrappers
├── CLAUDE.md             - AI coding context (see Section 8)
└── README.md             - Human-readable project documentation
```

Exclude auto-generated directories (`__pycache__`, `node_modules`, `venv`, `.git`). Update the map when the project structure changes significantly - not on every file addition, but when directories are added or reorganised.

---

## 3. Git Conventions

### 3.1 Use conventional commit prefixes

Every commit message starts with a type prefix. This was used consistently in the most successful projects (clearmail, ragbuilder, sessionpilot) and inconsistently in others. Formalise it:

- `feat:` - new feature or capability
- `fix:` - bug fix
- `docs:` - documentation only
- `refactor:` - code restructuring without behaviour change
- `test:` - adding or fixing tests
- `chore:` - maintenance (deps, config, CI)
- `ux:` - user experience improvements

Start with a verb after the prefix: `feat: add`, `fix: resolve`, `docs: update`, `refactor: extract`.

### 3.2 No Co-Authored-By lines

This is a personal preference that has been present in every single CLAUDE.md since the very first commit across all projects. It's the most consistent instruction across the entire codebase.

### 3.3 Work on main only

No feature branches for single-developer projects. This was explicitly stated in the spark CLAUDE.md: "This is a single-developer project with no CI gates or code review, so branches just create merge debt."

### 3.4 Commit the plan before the code

Implementation plans are committed as standalone markdown files before any code is written. This is a strong pattern across all projects - the largest commits in ragbuilder, clearmail, sessionpilot, and tenderhelper are all implementation plan documents. Commit the plan, then implement against it.

### 3.5 When extracting values to config, grep the entire codebase

The clearmail config.py was edited three times in rapid succession (1, 22, and 29 minute gaps) after extracting hardcoded values. Each edit caught references that the previous one missed. When moving values to config, search the entire codebase for all references and update them in the same commit.

---

## 4. Code Style

### 4.1 Comment blocks on every file

Every script and code file starts with a standardised header block. Reasoning comments throughout the code explain the *why*, not the *what*. Do not write comments that explain the obvious.

Header format (Python example - adapt comment syntax per language):

```python
# File: src/module_name.py
# Purpose: One concise sentence describing primary responsibility.
# Project: ProjectName | Date: YYYY-MM-DD
#
# Overview: One paragraph describing logic, major functions/classes,
# data flow, dependencies, and interactions with other modules.
```

The `File:` line uses the relative path from project root, confirming location in the project structure. The `Overview:` paragraph is especially important for AI-assisted development - it gives Claude Code immediate context about what the file does without reading every line.

### 4.2 Python is the default language

Python for application code, Bash/Fish for shell scripts, HTML/CSS/Jinja2 for templates. JavaScript is used but being reduced in favour of Python. When choosing between languages for a new component, default to Python unless there's a specific reason not to.

### 4.3 argparse for CLI interfaces

All command-line tools use `argparse` with: comprehensive help text, usage examples in the epilog, sensible defaults, and `--dry-run` where destructive operations are involved. The tenderhelper and git_archaeology scripts both follow this pattern.

### 4.4 Comprehensive error handling from the first pass

The spark project's fix commits show a pattern of adding error handling after initial implementation. Write error handling in the first draft, not as a follow-up commit. Every function that does I/O, network calls, or file operations should have explicit error handling from the start.

### 4.5 Extract at 300 lines

When a single file crosses approximately 300 lines, stop adding features and extract. The spark project's `context_builder.py` reached 3,100 lines with 4,736 additions and 3,345 deletions before being decomposed into AlertBuilder, DataFormatter, MessageProcessor, and StrategicContextBuilder. The refactor was three of the largest commits in the repo. Extract early.

### 4.6 Chain commands with &&

When giving setup or deployment instructions, chain multiple commands on one line with `&&` rather than listing them separately. This prevents partial execution if an earlier command fails.

### 4.7 vi/vim configuration

Set `expandtab`, `tabstop=4`, and `shiftwidth=4` to prevent tab/space mixing. This avoids `TabError: inconsistent use of tabs and spaces in indentation` when editing files that were created with spaces.

### 4.8 Mark all placeholders with TODO

When scaffolding code or generating Phase 1 implementations, use `TODO:` comments to flag every placeholder, stub, incomplete implementation, or mock data. This creates a greppable paper trail for incomplete AI-generated work. Without this, scaffold code can silently ship as if it were real implementation.

```python
# TODO: Replace with actual API call - currently returns mock data
def get_user_profile(user_id):
    return {"name": "STUB_USER", "email": "stub@example.com"}
```

Run `grep -rn "TODO:" src/` before any release to verify nothing was left unfinished. Clearly distinguish between `TODO:` (needs doing) and `NOTE:` (informational context for future developers).

---

## 5. Security Standards

These rules apply to any component that handles user input, external data, or authentication. They are derived from the security patterns in spark (SafetyValve, input sanitisation, prompt injection defence) and ragbuilder (14-point security hardening).

### 5.1 Security tests before feature tests

For any component handling external data, write security tests before feature tests. The spark project had P0 security fixes (dashboard cookie auth, VCALENDAR escaping, sanitisation) committed as follow-up patches. The ragbuilder security hardening was a 14-point remediation. Both should have been first-pass, not afterthoughts.

### 5.2 Build a sanitisation layer first

Before processing any external data (API responses, user input, file uploads, email headers, calendar events), write the sanitisation layer. Spark's `input_sanitizer.py` and `SafetyValve` exist because prompt injection through calendar event titles and invoice descriptions was a real attack surface. The sanitiser should exist before the feature that consumes the data.

### 5.3 Document security boundaries explicitly

In every CLAUDE.md, include a section listing what the system cannot do. Follow the patterns established in spark and ragbuilder:

- Which files are read-only
- Which APIs are read-only (no send/delete/update methods)
- Rate limits and length limits
- What's in the allowed-files whitelist and what's excluded
- Where secrets live and what's never committed

### 5.4 Defence in depth, not prompt rules alone

The spark transcript audit found that 72% of failures were code and architecture problems, not prompt rule violations. Prompt rules alone cannot fix the majority of issues. Code-level enforcement (sanitisation, validation, whitelisting) is the primary defence. Prompt rules are a secondary layer.

### 5.5 The lethal trifecta

Never combine unrestricted data access + untrusted content + autonomous action in the same component. Delegated automation (Level 2) is the preferred autonomy model - the system proposes actions, the human confirms. Spark's pending confirmation pattern (30-second auto-fire with undo window) is a good example.

---

## 6. Testing

### 6.1 Test count is a tracked metric

Every CLAUDE.md update includes the current test count. The spark project tracked this from 876 to 2,012 tests across 52 CLAUDE.md edits. A test count that decreases unexpectedly is a regression signal.

### 6.2 Prompt reliability testing

For any project that uses LLM calls, maintain a dedicated prompt reliability test suite that hits the real API. Spark's `test_prompt_reliability.py` grew from 14 to 33 scenarios. These tests are separate from unit tests and run against live models to catch prompt compliance regressions.

### 6.3 Test mocking patterns

Tests mock external services (LLM APIs, IMAP, CalDAV, FreeAgent) via `unittest.mock.patch`. Never hit real external APIs in unit tests. Document the mocking pattern in CLAUDE.md so Claude Code maintains consistency.

### 6.4 When working with protocol standards, write spec-compliance tests

The clearmail project had multiple fixes for RFC 2822 date parsing and message-ID formatting. When implementing protocol standards (RFC, HTTP, API specs), write tests against the spec itself, not just against sample data. Sample data may not cover edge cases that the spec defines.

### 6.5 Explicit edge case directives

AI coding assistants default to happy-path tests unless explicitly told otherwise. Every test suite must include cases for these categories where applicable:

- **Empty and missing:** empty strings, None/null, missing keys, empty lists/dicts
- **Boundary strings:** very long strings (10k+ chars), single character, whitespace-only
- **Unicode and encoding:** non-ASCII characters, emoji, Arabic/Chinese text, mixed scripts
- **Numeric boundaries:** zero, negative, very large (sys.maxsize), very small, float infinity, NaN
- **Type mismatches:** string where int expected, list where dict expected, None where object expected

This is a checklist, not a suggestion. When writing a test file, mentally walk through this list for each function under test and include the categories that are relevant. The spark SafetyValve allowed semicolons and ampersands through because the edge case tests didn't cover special characters in content fields.

### 6.6 Three-tier testing discipline

The commit history across all projects shows features committed first and tests following - classic test-after development. But the data also shows that the areas where tests were written first had noticeably fewer fix commits. This maps to three tiers based on risk:

**Tier 1 - Tests first (TDD):** Security boundaries, protocol/spec compliance, data sanitisation, API contracts. These are the areas where fix commits clustered hardest across spark and clearmail. Writing the test first forces you to define the contract before the implementation. The spark prompt reliability suite was designed up front (14 scenarios, grew to 33) and prompt-related fix rates dropped after it existed.

**Tier 2 - Tests alongside:** Feature code where the behaviour is clear but the implementation is exploratory. Write the test in the same commit as the feature, not in a follow-up. The git archaeology rapid-correction data shows that features committed without tests in the same commit are significantly more likely to have a fix commit within 30 minutes.

**Tier 3 - Tests after (gap-fill):** Only acceptable as a one-time catch-up for legacy or inherited code. The clearmail SDET audit ("fill coverage gaps, fix time-bombs, consolidate fixtures") was a necessary retrospective pass. It should be the last time this pattern occurs on a project - once the gap is filled, all new code follows Tier 1 or Tier 2.

---

## 7. AI-Assisted Development Workflow

### 7.1 CLAUDE.md is the primary context file

CLAUDE.md is read by Claude Code at session start. It must contain everything the AI agent needs to work effectively: what the project does, how to build and test it, where key files are, what the security boundaries are, and what gotchas exist. See the template in Section 8.

### 7.2 The "first code review" checkpoint

Before sending a prompt to Claude Code, ask: "What would I correct on the first code review?" Then put those corrections into the prompt. This is the difference between 70% and 90% accuracy on the first pass. Specific areas to front-load: error handling patterns, CLI argument structure, logging approach, file paths, and naming conventions.

### 7.3 Scope rules files per area

For larger projects, maintain separate rules files for different areas of the codebase. Each file contains only the conventions and constraints relevant to that area. This prevents loading irrelevant context and keeps each rules file focused. Have Claude Code report which rules it used so you can refine them.

### 7.4 Update CLAUDE.md after every significant change

The four types of CLAUDE.md edits observed across all projects:

- **Phase completion:** Add a numbered entry to the evolution history (or to `docs/HISTORY.md` if the section exceeds ~5 entries - see Rule 7.6), update test count, add new files to key files table if they're top-15 worthy.
- **Architectural correction:** Update the key flow diagram, architecture description, or component relationships when the structure changes.
- **Gotcha addition:** Add to "Things to Watch Out For" if it affects everyday development. Subsystem-specific edge cases go in `docs/REFERENCE-GOTCHAS.md` instead. Consolidate with Security Boundaries or Key Patterns if there's overlap.
- **Philosophy refinement:** Update the design philosophy section when you discover a new "keep strict" or "free to adapt" boundary. This is rare but high-value - it shapes every subsequent AI decision.

### 7.5 Commit messages are context for the next session

Write commit messages as if Claude Code will read them to understand what happened. The conventional commit prefix makes this searchable. A message like `fix: resolve RFC 2822 date parsing for timezone-aware headers` is useful context. A message like `fix stuff` is not.

### 7.6 CLAUDE.md token budgets and progressive disclosure

CLAUDE.md is the LLM's "hot path" context - loaded into every conversation, costing money and diluting attention on every single interaction. Treat it like a performance-critical code path: measure, budget, and extract when it grows.

**Token budgets:** Small projects (< 5 source files) should stay under 2,000 tokens. Medium projects (5-20 files) under 4,000 tokens. Large projects (20+ files) under 6,000 tokens. Add a `<!-- ~NNNN tokens — budget: NNNN -->` comment at the top of CLAUDE.md so growth is visible and reviewable.

**Three tiers of LLM context:**

1. **Tier 1 - Always loaded** (`CLAUDE.md` + `.claude/rules/*.md`): Design philosophy, architecture overview, build/run, testing, security boundaries, active gotchas, key files (top 10-15). Rules files auto-load alongside CLAUDE.md - use them to split instruction sets that would push CLAUDE.md past its token budget (deployment constraints, environment rules, formatting rules). This is what prevents mistakes in the current session.
2. **Tier 2 - Loaded on demand** (`.claude/skills/`, `docs/*.md`): Detailed patterns, module contracts, reference gotchas, implementation guides. Loaded when working in the relevant area.
3. **Tier 3 - Archival** (`docs/HISTORY.md`, `docs/CHANGELOG.md`, git log): Evolution history, old design decisions, completed phase details. Never auto-loaded. Git log is the authoritative source.

**What stays in CLAUDE.md (Tier 1):** Project identity, design philosophy (strict/flexible), build and run commands, test commands with count, architecture (key flow, not every file), security boundaries, active gotchas (things that WILL bite you in normal development, not things that once bit you), git conventions.

**What moves out when the file grows:** Standalone instruction sets (deployment rules, environment constraints, formatting rules) move to `.claude/rules/*.md` - these stay always-loaded but keep CLAUDE.md focused on project identity. "How It Evolved" past ~5 entries moves to `docs/HISTORY.md`, replaced with a 3-line summary. Reference gotchas (edge cases for specific subsystems) move to `docs/REFERENCE-GOTCHAS.md`. Exhaustive key files tables (20+ entries) get trimmed to the top 10-15, with the full list in README.md.

**Techniques for trimming:**

- **Deduplicate across sections.** Gotchas often restate security boundaries or key patterns verbatim. When the same fact appears in multiple sections, keep it in the most authoritative one and remove the copies. This is consistently the easiest win - in practice, 30-50% of gotchas are duplicates of content already in Security Boundaries or Key Patterns.
- **Split active from reference gotchas.** Active gotchas affect everyday development (format rules, delimiter conventions, deployment hooks). Reference gotchas are edge cases you only hit when working on specific subsystems. Active stays in CLAUDE.md; reference moves to `docs/REFERENCE-GOTCHAS.md`.
- **Use standard filenames** for progressive disclosure so the LLM can find them without being told: `docs/HISTORY.md` (evolution), `docs/REFERENCE-GOTCHAS.md` (subsystem gotchas), `docs/REFERENCE-PATTERNS.md` (detailed implementation patterns), `docs/CANVAS-REFERENCE.md` or `docs/{SUBSYSTEM}-REFERENCE.md` (domain-specific reference).

**Evidence:** The spark project's CLAUDE.md reached ~10,700 tokens - 67% was evolution history (~4,600 tokens for 39 phases) and reference gotchas (~2,600 tokens of subsystem-specific edge cases). Cross-project audit found 3 of 7 projects over budget. After applying these techniques, all three dropped to within budget while preserving all information in progressive disclosure files.

### 7.7 Authoring agents and subagents

Agents live in `.claude/agents/<name>.md`. They use YAML frontmatter for configuration and markdown body for instructions. Feature-specific agents with preloaded skills consistently outperform general-purpose agents - give each agent a narrow job and the knowledge it needs to do it.

**Frontmatter fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `name` | string | Identifier (lowercase, hyphens). Required. |
| `description` | string | When to invoke. Use `"PROACTIVELY"` for auto-trigger. Required. |
| `tools` | string | Comma-separated allowlist of permitted tools. Omit to inherit all parent tools. Supports `Agent(agent_type)` to restrict spawnable subagents. |
| `disallowedTools` | string | Tools to deny, overriding inherited permissions. |
| `model` | string | `haiku`, `sonnet`, `opus`, or `inherit` (default). Match model to task complexity. |
| `maxTurns` | number | Cap iteration cycles before the agent stops. |
| `permissionMode` | string | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`. |
| `skills` | list | Skill names to preload into agent context at startup. |
| `mcpServers` | list | MCP servers available to this agent (names or inline configs). |
| `hooks` | object | Lifecycle event handlers scoped to this agent (`PreToolUse`, `PostToolUse`, `Stop`). |
| `memory` | string | Persistence scope: `user` (cross-project), `project` (team-shared), `local` (personal, gitignored). |
| `isolation` | string | Set to `"worktree"` to run in a temporary git worktree with auto-cleanup. |
| `background` | boolean | Set `true` to always run as a background task. |

**Key patterns:**

- **Least privilege tools.** Enumerate specific tools rather than inheriting everything. A code reviewer doesn't need Write or Bash.
- **Preload skills over general instructions.** `skills: ["testing-patterns"]` injects domain knowledge at startup rather than hoping the agent discovers it.
- **Use `plan` permission mode for research agents.** Prevents accidental modifications during exploration.
- **Memory scoping.** Use `local` for ephemeral context, `project` for team-shared knowledge (version controlled), `user` for cross-project continuity.

**Evidence:** The code-reviewer agent uses only `name` and `description`, which is appropriate for its narrow scope. More complex agents (data pipeline builders, deployment coordinators) benefit from explicit tool restrictions, model selection, and skill preloading to stay focused.

### 7.8 Settings and permission configuration

Claude Code settings follow a 5-level precedence hierarchy. Higher levels override lower:

1. **Managed settings** (organisation-enforced, cannot be overridden)
2. **Command-line arguments** (single-session overrides)
3. **`.claude/settings.local.json`** (personal project settings, gitignored)
4. **`.claude/settings.json`** (team-shared, committed)
5. **`~/.claude/settings.json`** (user global defaults)

**Critical rule: deny always wins.** Deny rules have absolute safety precedence and supersede all allow/ask rules regardless of hierarchy level. Array settings (allow, deny) concatenate and deduplicate across scopes.

**Permission pattern syntax:**

| Pattern | What it matches |
|---------|----------------|
| `Read` | All file reads |
| `Edit(src/**)` | Edits to any file under src/ |
| `Bash(python -m pytest *)` | pytest with any arguments |
| `Bash(git status*)` | git status and variants |
| `Read(**/.env)` | .env files at any depth |
| `Read(**/secrets/**)` | Anything under any secrets/ directory |
| `WebFetch(domain:example.com)` | Web fetches to a specific domain |
| `mcp__server__tool` | Specific MCP server tool |

**Default deny rules** (in the project template): `.env` files, secrets directories, credentials files, `curl`/`wget` (prevent exfiltration), `rm -rf` (prevent destructive operations).

**Default allow rules** target safe, high-frequency operations: reading files, editing source/test/docs, running tests, git status/diff/log/add/commit/push. This means Claude Code can work fluidly on code without constant permission prompts, while dangerous operations still require human approval.

**Evidence:** Derived from comparative analysis of permission patterns across Claude Code community best practices. The deny-first approach for network egress and destructive operations aligns with Rule 1.4 (security boundaries as constraints).

---

## 8. CLAUDE.md Template

This template provides a Stage 4 starting point - the maturity level that the spark project reached after 52 iterations. Fill in project-specific content at project creation. The design philosophy section is the most important to get right early - it shapes how Claude Code makes every subsequent decision. The evolution history starts with entry 1 and grows append-only. Remove sections that genuinely don't apply, but keep security and gotchas sections even if empty - their presence is a prompt to fill them in.

```markdown
# {Project Name}
<!-- ~NNNN tokens — budget: {2000 small | 4000 medium | 6000 large} -->
<!-- This file is for LLMs. Humans read README.md. -->

{One sentence: what it is, who it's for, where it runs.}

## Design Philosophy

{What does "good" look like for this project? Define the quality standard in terms the AI can apply to every decision.}

**Keep strict:** {Non-negotiable constraints - brand, security, data formats, API contracts}

**Free to adapt:** {Areas where any approach that meets the quality bar is acceptable - layout, naming, specific implementation patterns}

## How It Evolved

{Numbered entries. When this section exceeds ~5 entries, move older phases to docs/HISTORY.md and keep a summary here.}

1. **{Phase/Feature Name} ({date}):** {What was built, key design decisions, test count. Reference design doc if one exists.}

## Build & Run

\`\`\`bash
{Primary build/install command}
{Primary run command}
{Common flags or modes}
\`\`\`

## Testing

\`\`\`bash
{Test command with approximate count}
{Any separate test suites (e.g. prompt reliability)}
\`\`\`

## Architecture

{ASCII component diagram if multi-component}

Key flow: **{step -> step -> step}**

{Brief description of data flow or processing pipeline}

## Key Files

| File | What it does |
|------|-------------|
| {file} | {one-line description} |

## Security Boundaries

- {What the system CANNOT do}
- {Read-only data sources}
- {Rate/length limits}
- {Where secrets live}

## Key Patterns

- {Non-obvious implementation detail}
- {Edge case handling}
- {Integration gotcha}

## Things to Watch Out For

- {Convention that's easy to break}
- {Format/encoding rule}
- {Dependency quirk}

## Git Conventions

- Conventional commits: feat/fix/docs/refactor/test/chore/ux
- NEVER include Co-Authored-By in commit messages
- Work on main only
```

---

## 9. Infrastructure Conventions

### 9.1 Machine and user context

Always specify machine and user when writing commands or documentation. If your infrastructure has multiple machines with distinct roles (e.g. a development machine and a deployment VPS), or multiple users on the same machine (e.g. an admin user and a service/runtime user), make this explicit in commands and docs. Ambiguity about *where* a command runs is a common source of deployment errors.

Document the transfer direction between machines if they can't reach each other symmetrically (e.g. if the VPS cannot SSH back to the development machine).

### 9.2 File ownership after transfers

Always address `chown` after transferring files between users or machines. Files transferred via `scp` inherit the receiving user's ownership, but files created by one user and needed by another require explicit ownership changes.

### 9.3 Environment files

Shared secrets and API tokens live in `~/.env.shared`. Project-specific secrets live in `.env` within the project directory (never committed). The `load_env_file()` pattern (parse KEY=VALUE, handle quotes and comments, zero dependencies) is the standard approach.

---

## 10. Document and Content Standards

### 10.1 Writing style

First person, addressing the reader as "you", using "we" to build rapport. Explain why something is important or valuable, not just what to do. No hype or exaggeration - acknowledge challenges, offer solutions.

### 10.2 Word avoidance list

Never use: delve, demystify, foster, leverage, utilize. Use instead: examine, encourage, use. Never use em dashes. Use " - " (space-dash-space) instead.

### 10.3 Preferred document formats

Markdown or HTML, never Word format. For structured reports, markdown. For anything that needs to render visually, HTML. For production documents with print requirements, the Pandoc + WeasyPrint pipeline.

---

## 11. Agent Memory Patterns

These patterns apply to any long-running AI agent or any workflow that spans multiple Claude Code sessions. They were derived from analysis of the OpenClaw seven-layer memory architecture and validated against the patterns that naturally emerged in our own work (the "How It Evolved" changelog, the ChatSync handoff documents, and the entity-file approach used in tenderhelper).

### 11.1 Pre-emptive state serialisation

Do not wait for context to be lost before saving state. When approaching session limits, context window pressure, or natural break points, proactively dump structured state to persistent files *before* the information disappears. This is the highest-impact single technique for maintaining continuity.

For Claude Code sessions: before ending a session, create or update HANDOFF.md with the current state of work. Do not rely on memory or the next session's ability to reconstruct context from git log alone.

For long-running agents: detect approaching context limits and trigger a structured save protocol that captures commitments, decisions, status changes, file locations, and lessons learned. This should be mandatory and automatic, not discretionary.

### 11.2 Structured resume points (HANDOFF.md)

HANDOFF.md is a surgical resume point - not memory, not context, a bookmark. It contains exactly five fields:

- **Current Task:** what you're working on right now
- **Last Action:** what was just completed
- **Next Action:** what should happen next
- **Key Files:** where the important artefacts are
- **Context:** anything else needed to resume effectively

Update HANDOFF.md after every completed subtask, not just at session end. When resuming work, read HANDOFF.md first. It should take under 10 seconds to know exactly where to pick up.

This pattern emerged independently in this project (the ChatSync summaries) and in the OpenClaw architecture (where it was the single biggest operational improvement). The value is not in the format but in the discipline of continuous updates.

### 11.3 Selective context loading

Do not load all project knowledge into every session. Decompose knowledge into small, typed files (entity files, per-area rules, per-domain skills) and load only what's relevant to the current task.

This is the principle behind the `.claude/skills/` pattern: testing rules only load when testing is relevant, security patterns only load when security work is happening. The same principle applies to any agent's knowledge base - one massive memory file that gets loaded every time wastes context window on irrelevant information.

For agent projects: decompose knowledge into entity files under 3KB each, organised by type (people, companies, products, systems, protocols). Load by relevance, not by default.

### 11.4 When to apply these patterns

Not every project needs agent memory patterns. They apply when:

- Work regularly spans multiple Claude Code sessions
- A long-running agent maintains state across context window compactions
- Multiple AI agents or instances need to share knowledge
- A project is complex enough that resuming work requires significant context reconstruction

For single-session tasks or small projects, the "How It Evolved" section in CLAUDE.md provides sufficient continuity without the overhead of HANDOFF.md or entity files.

---

## 12. Modular Design

These patterns address the problem of re-explaining context to AI coding
assistants. When Claude Code needs verbal context to understand a module's
purpose, boundaries, or contracts, the code is missing structural
documentation. The fix is not better prompting - it's building projects where
the structure itself carries the context.

Rules 12.1-12.5 define the structural patterns. Rules 12.6-12.10 define
opinionated conventions for where specific types of code live and how data
flows between them. The conventions are derived from patterns observed across
tenderhelper (flat layout, 6 pipeline modules), SessionPilot (src/ package
layout, 6 subsystems), the slide pipeline, and the book PDF pipeline.

The evidence basis for structural patterns (12.1-12.5) is diagnostic - observed
CC re-prompting patterns and refactoring history. The evidence basis for
conventions (12.6-12.10) is architectural - recurring decisions made
consistently across 9 repositories. Both should be revisited as the modular
pattern is applied to more projects.


### 12.1 Modules with distinct responsibilities get a README.md

When a directory contains code with a distinct responsibility (scraping,
scoring, notification, rendering), it gets a README.md describing five things:
purpose (including what it does NOT do), public interface (function signatures
with types), dependencies (internal, external, I/O), known issues, and testing
instructions.

The module README replaces verbal context-setting in CC prompts. Instead of
explaining what a module does at the start of each session, you point CC at the
README and tests. The contract is in the code, not in your head.

The boundary statement ("does NOT do X") is as important as the purpose
statement. It prevents responsibility creep and catches design violations
early - if you find yourself writing "also handles scoring" in the scraper
README, that's the signal to split.

Update the README in the same commit as any interface change. A README that
doesn't match __init__.py is worse than no README at all.

A useful heuristic: if Claude Code needs to read more than 5-6 files to understand a task, the module boundaries are too loose. Tighten them until each task is self-contained within one module plus shared types.

A template is deployed by setup.sh to `docs/MODULE-README-TEMPLATE.md` in
each project.


### 12.2 Public interfaces via __init__.py

Python packages expose their public API through `__init__.py` with an explicit
`__all__` list. Other modules import from the package, never from internal
files.

```python
# scraper/__init__.py
from .core import scrape_tenders, scrape_tender_detail

__all__ = ["scrape_tenders", "scrape_tender_detail"]
```

This matters for two audiences. For CC, reading __init__.py instantly reveals
the module's complete public API - five lines instead of reading 200 lines of
implementation. For the developer, it means internal files (core.py, helpers.py,
parsers.py) can be refactored, split, or reorganised without changing any
imports elsewhere in the project.

This rule applies to modules that are packages (directories with __init__.py).
Single-file modules in flat layouts don't need this pattern.


### 12.3 Shared typed models in models.py

Data structures that flow between modules are defined as frozen dataclasses in
a shared location (typically `src/projectname/models.py` or `models.py` in
flat layouts). This was the pattern used in tenderhelper (TenderNotification,
TenderDetail as the contract between email_reader, tender_fetcher,
relevance_scorer, and digest_writer).

```python
@dataclass(frozen=True)
class Tender:
    reference: str
    title: str
    description: str
    published: datetime
```

Frozen (immutable) dataclasses create clear data direction: Module A produces a
Tender, Module B consumes it. Nobody mutates shared state. CC can reason about
one module's logic without worrying about another module changing data
underneath it.

**The validation boundary:** Pydantic models are for parsing untrusted external
input - API responses, config files, user input. They live at the point of
entry, in the module that receives the data (e.g. the client module that calls
an external API). Once validated, data is converted to a frozen dataclass
before being passed to other modules. The two layers must not be mixed:

- Pydantic at the edge (parsing, validation)
- Frozen dataclasses inside (inter-module communication)
- A module that receives API data validates into Pydantic, then converts to a
  frozen dataclass before passing onward

If models.py approaches 300 lines, apply the same extraction rule as any other
file (Rule 4.5) - split into a `models/` package with per-domain files.

A starter template is deployed by setup.sh to `src/models.py`.


### 12.4 Typed configuration in config.py

All tuneable values live in one file, structured as frozen dataclasses. Each
module gets its own config section. A top-level AppConfig composes them and
provides a `from_env()` or `from_yaml()` classmethod that reads from
environment variables (per Rule 9.3) or YAML config files with sensible
defaults.

```python
@dataclass(frozen=True)
class ScraperConfig:
    base_url: str = "https://www.etenders.gov.ie"
    request_timeout: int = 30

@dataclass(frozen=True)
class AppConfig:
    scraper: ScraperConfig = field(default_factory=ScraperConfig)

    @classmethod
    def from_env(cls) -> "AppConfig":
        return cls(
            scraper=ScraperConfig(
                request_timeout=int(os.getenv("SCRAPER_TIMEOUT", "30")),
            ),
        )
```

Modules receive their specific config section (`ScraperConfig`), never the full
`AppConfig` and never raw environment variables or YAML reads. This makes
modules independently testable - pass a config object in the test, not a live
environment.

A starter template is deployed by setup.sh to `src/config.py`.


### 12.5 When to apply modular structure

Not every project needs full modularisation. The trigger is re-explaining
context to CC - that's the signal that the project has outgrown script-level
organisation.

**Apply when:**
- More than 3 source files with distinct responsibilities
- You've re-explained context to CC more than twice
- Files are approaching the 300-line extraction threshold (Rule 4.5)
- You expect to maintain the project beyond 6 months

**Don't apply when:**
- Single-purpose script under 200 lines
- One-off automation you won't maintain
- Exploratory spike (spike first as a single script, modularise when the
  approach is validated)

For spikes: write the spike, validate the approach, then migrate into modular
structure before building on top of it. The spike is research. The module is
the deliverable.


### 12.6 Standard module roles

Every project has recurring types of code. These conventions define where each
type lives, eliminating the micro-decisions that burn CC tokens and cause
inconsistency across projects.

The roles below map to files (flat layout) or package directories (src/ layout).
Not every project needs all roles - create them as needed, but when you do
create them, put them in the standard location.

| Role | Flat layout | Package layout | Responsibility |
|------|-------------|----------------|----------------|
| **Client** | `{service}_client.py` | `clients/{service}.py` | Wraps a single external service (HTTP API, database, message queue). Handles connection, auth, retries, timeouts. Returns Pydantic models at the validation boundary, which callers convert to frozen dataclasses. |
| **Storage** | `db.py` | `storage/` or `db.py` | Application state persistence - SQLite, file I/O for state. External data file ingestion (CSV imports, data dumps) is a client role. Accepts and returns frozen dataclasses. Owns the schema and migrations. One storage module per project unless there are genuinely separate data stores. |
| **Processor** | `{concern}.py` | `{concern}/` | Pure business logic - scoring, detection, transformation, parsing. No I/O, no network calls, no database access. Takes dataclasses in, returns dataclasses out. The most testable layer. |
| **Output** | `{output_type}_writer.py` | `output/` or `{output_type}/` | Generates deliverables - markdown digests, HTML reports, notifications, UI updates. Consumes processed dataclasses. |
| **Entrypoint** | `{project_name}.py` or `cli.py` | `cli.py` or `main.py` | Thin orchestrator. Wires modules together, handles arg parsing, configures logging. No business logic. This is the only file that imports from multiple modules. |
| **Models** | `models.py` | `models.py` | Shared frozen dataclasses (Rule 12.3). |
| **Config** | `config.py` | `config.py` | Typed configuration (Rule 12.4). |

**Evidence:** Tenderhelper naturally evolved into exactly this structure:
`email_reader.py` (client), `tender_fetcher.py` (client), `relevance_scorer.py`
(processor), `db.py` (storage), `digest_writer.py` (output),
`tender_scanner.py` (entrypoint), `models.py`, `config.yaml`. SessionPilot
follows the same logical roles in a package layout: `stt/` (client),
`detection/` (processor), `agenda/` (processor), `ui/` (output).

**The critical constraint:** Processors have no I/O. They take dataclasses in
and return dataclasses out. This is what makes them trivially testable and easy
for CC to reason about in isolation. If a processor needs data from an external
source, the entrypoint fetches it via a client and passes it in.


### 12.7 The data flow pipeline

Data flows through the system in one direction, with explicit type transitions
at each boundary. This is the canonical path:

```
External source
    ↓
Client module (HTTP, IMAP, filesystem)
    ↓ raw response
Pydantic validation (in the client module)
    ↓ validated Pydantic model
Convert to frozen dataclass
    ↓ frozen dataclass (enters the internal system)
Processor module(s) (scoring, detection, transformation)
    ↓ enriched/transformed frozen dataclass
Output module (digest, notification, UI) or Storage module (SQLite, file)
```

**Key rules:**

1. **Pydantic lives at the edge.** Client modules validate external data into
   Pydantic models, then convert to frozen dataclasses before returning to
   callers. No other module imports Pydantic.

2. **Processors are pure.** They receive frozen dataclasses and return frozen
   dataclasses. No network calls, no file I/O, no database access. If a
   processor's test needs a mock, something is in the wrong layer.

3. **The entrypoint owns the pipeline.** The sequence of "fetch via client,
   process, store/output" is expressed in the entrypoint (cli.py), not buried
   inside modules. This makes the full pipeline readable in one place.

4. **New dataclass types for enriched data.** When a processor adds information
   (e.g. a relevance score), it returns a new dataclass type that wraps or
   extends the input type. The tenderhelper pattern: `TenderNotification` →
   `TenderDetail` → `ScoredTender`. Each stage has its own type.

**Evidence:** Tenderhelper's pipeline follows this exactly: email_reader
(client) → tender_fetcher (client) → relevance_scorer (processor) → db
(storage) → digest_writer (output), with models.py defining the types at
each transition. SessionPilot follows the same pattern: STT client → transcript
buffer → phrase detector/tangent tracker (processors) → UI overlay (output).


### 12.8 Error handling at module boundaries

Modules define their own exception types for errors that callers need to
handle. These are thin, specific, and defined at the top of the module's
main file or in a shared `exceptions.py`.

```python
class TenderFetchError(Exception):
    """Raised when a tender detail page cannot be fetched or parsed."""
    pass

class DPSPageError(TenderFetchError):
    """Raised for DPS pages that have a different HTML structure."""
    pass
```

**Convention:**

1. **Modules raise, the entrypoint catches.** Processing modules raise
   specific exceptions. The CLI entrypoint catches them and decides what to
   do (log and continue, abort, retry). Modules never catch their own
   exceptions to silently continue - that hides failures.

2. **External service errors are wrapped.** Client modules catch
   `requests.RequestException`, `sqlite3.Error`, etc. and re-raise as
   project-specific exceptions. This prevents implementation details
   (which HTTP library you use) from leaking into the rest of the system.

3. **Processors never raise I/O errors.** Since processors have no I/O
   (Rule 12.6), they only raise ValueError, TypeError, or domain-specific
   exceptions. If a processor test needs to handle ConnectionError, something
   is in the wrong layer.

4. **Always include context in exceptions.** Pass the resource ID, URL, or
   input that caused the failure. `TenderFetchError(f"Failed to parse
   {resource_id}: {e}")` not just `TenderFetchError(str(e))`.

**Evidence:** Tenderhelper's DPS parsing issue was discovered because the
fetcher raised a clear error on the different page structure rather than
silently returning partial data. This follows Rule 1.2 (detection before
correction) applied at the module level.


### 12.9 External service clients

Every external service (HTTP API, database, email, filesystem for data
ingestion) gets its own client module. Client modules are the only place in the
system that performs I/O to external services.

**Convention:**

1. **One client per service.** `tender_fetcher.py` talks to eTenders.
   `email_reader.py` talks to notmuch. Even if the implementation is 40 lines,
   it gets its own file. This makes it replaceable and independently testable.

2. **Clients accept config, not raw credentials.** Pass a typed config section
   (Rule 12.4), not API keys or URLs as string parameters.

3. **Clients return validated data.** The client is responsible for parsing the
   raw response (HTML, JSON, IMAP) and returning structured data. Callers
   never see raw HTTP responses or BeautifulSoup objects.

4. **Clients handle retries and timeouts.** Retry logic, backoff, and timeout
   configuration live in the client, not in the caller. Use config values
   (Rule 12.4) for retry counts and timeout durations.

5. **Tests use saved response fixtures.** Save real responses (HTML pages, JSON
   payloads) to `tests/fixtures/` and load them in tests. The client's parsing
   logic is tested against real data without making network calls. Capture
   fixtures from the live service with a one-liner curl/wget and commit them.

6. **Fixture naming:** `{service}_{scenario}.{ext}` - e.g.
   `etenders_cft_standard.html`, `etenders_cft_dps.html`,
   `assemblyai_transcript_short.json`. The scenario name should describe what
   makes this fixture interesting for testing.

**Evidence:** Tenderhelper's `tender_fetcher.py` follows this exactly - it
takes a resource ID, fetches the HTML, parses with BeautifulSoup, and returns a
`TenderDetail` dataclass. The test uses a saved HTML fixture. The DPS parsing
failure was caught because the fixture for a DPS page exposed the structural
difference.


### 12.10 Logging conventions

Logging follows a single convention across all projects. The goal is readable
logs that CC can interpret when debugging, without modules fighting over
logging configuration.

**Convention:**

1. **Every module gets a logger.** First line after imports:
   `logger = logging.getLogger(__name__)`. This creates loggers named after
   the module path (e.g. `projectname.scraper.core`), which makes filtering
   trivial.

2. **The entrypoint configures logging.** `logging.basicConfig()` is called
   exactly once, in `cli.py` or `main.py`. Modules never call
   `basicConfig()`, `setLevel()`, or add handlers. They just use their
   `logger` instance.

3. **Log level meanings:**
   - `DEBUG` - internal state useful during development (parsed field values,
     score calculations, config loaded)
   - `INFO` - pipeline progress (started fetching, scored N tenders,
     wrote digest)
   - `WARNING` - recoverable problems (timeout on one tender, skipped
     unparseable field, retrying)
   - `ERROR` - failures that affect output (couldn't fetch tender,
     database write failed)

4. **Include identifiers in log messages.** Always include the resource ID,
   URL, or other identifier that makes the log message actionable:
   `logger.warning("Timeout fetching tender %s, retrying", resource_id)` not
   `logger.warning("Timeout, retrying")`.

5. **No print statements in modules.** Use `logger.info()` for progress
   messages and `logger.debug()` for diagnostic output. The only acceptable
   `print()` calls are in the entrypoint for user-facing output (e.g.
   `--dry-run` mode showing results to stdout).

**Evidence:** This matches stdlib logging best practices and the pattern used
across projects. The convention of logger-per-module with entrypoint-only
configuration is standard Python and prevents the configuration conflicts
that occur when modules each set up their own logging.

---

## Appendix A: Rules Derivation

Each rule in this document traces back to specific evidence. This appendix maps rules to their origin for future review and challenge.

| Rule | Evidence Source |
|------|---------------|
| Check for existing infrastructure | Forgejo API vs filesystem walker (this session) |
| Detection before correction | Tenderhelper DPS parsing |
| Prompts are code | spark core.txt: 46 changes, same churn as app code |
| Security boundaries as constraints | spark SafetyValve, ragbuilder hardening |
| CLAUDE.md from commit one | 6 projects all started with stubs, grew retroactively |
| Evolution history (append-only changelog) | spark CLAUDE.md: 38 numbered phases giving full project context |
| Design philosophy (strict vs free-to-adapt) | humansparkforge CLAUDE.md: only project that told AI how to think about quality |
| Python filenames use underscores | repo-discovery.py import failure (this session) |
| Never commit personal data | clearmail: 2 commits removing hardcoded data |
| Conventional commits | clearmail/ragbuilder (consistent) vs tenderhelper (inconsistent) |
| Commit plans before code | Largest commits across all repos are implementation plans |
| Grep entire codebase on config extraction | clearmail config.py: 3 rapid corrections |
| Extract at 300 lines | spark context_builder.py: 3,100 lines before decomposition |
| Security tests before features | spark P0/P1 security fixes as follow-up commits |
| Sanitisation layer first | spark input_sanitizer.py, SafetyValve pattern |
| 72% of failures are code, not prompts | spark transcript audit (62% reliability) |
| Test count as tracked metric | 52 CLAUDE.md edits all updating test count |
| RFC spec tests, not sample tests | clearmail: multiple RFC 2822 date parsing fixes |
| Tab/space mixing prevention | repod.py TabError on deployment server (this session) |
| The "first code review" checkpoint | Scott Hay LinkedIn analysis (this session) |
| Formalised file header format | AI Coding Standards doc (Alastair, 2025) - concrete format vs vague description |
| TODO/stub marking convention | AI Coding Standards doc - greppable paper trail for incomplete AI work |
| Edge case testing checklist | AI Coding Standards doc + spark SafetyValve semicolon/ampersand bug |
| README ASCII project map | AI Coding Standards doc - human onboarding complement to CLAUDE.md key files table |
| Three-tier testing discipline | All repos: feat-then-test commit pattern + spark prompt suite (test-first, fewer fixes) + clearmail SDET audit (gap-fill) |
| Pre-emptive state serialisation | Luna/OpenClaw seven-layer analysis: 90% context loss reduced to <5% |
| HANDOFF.md structured resume points | Luna/OpenClaw analysis + ChatSync pattern emergent in this project |
| Selective context loading | Luna entity file decomposition + .claude/skills/ progressive disclosure pattern |
| Module READMEs as contracts (12.1) | CC re-prompting analysis: verbal context needed per session correlated with missing structural docs. |
| Public interfaces via __init__.py (12.2) | CC token analysis: reading 5-line __init__.py vs 200-line implementation. Refactoring safety from import indirection. |
| Shared typed models (12.3) | tenderhelper models.py (TenderNotification/TenderDetail as inter-module contract). CC reasoning: frozen dataclasses prevent cross-module mutation confusion. Pydantic-at-boundaries from tenderhelper API parsing vs internal data flow. |
| Typed configuration (12.4) | Extends Rule 9.3 (env files). SessionPilot config system (YAML with per-subsystem sections). CC readability: typed signatures vs dict access. Testability: config injection vs env variable mocking. |
| When to apply modular structure (12.5) | Counter-pattern to over-engineering. Trigger is "re-explained context to CC more than twice." Flat layout remains valid per Rule 2.2 for smaller projects. |
| Standard module roles (12.6) | tenderhelper pipeline: email_reader (client), tender_fetcher (client), relevance_scorer (processor), db (storage), digest_writer (output), tender_scanner (entrypoint). SessionPilot: stt/ (client), detection/ (processor), agenda/ (processor), ui/ (output). Same logical roles in both flat and package layouts across 9 repos. |
| Data flow pipeline (12.7) | tenderhelper: TenderNotification → TenderDetail → ScoredTender type chain. SessionPilot: audio → transcript → classification → alert. Pydantic-at-edge derived from tenderhelper's HTML parsing (external) vs inter-module frozen dataclasses (internal). |
| Error handling at module boundaries (12.8) | tenderhelper DPS parsing: clear error on structural difference rather than silent partial data. Aligns with Rule 1.2 (detection before correction). spark project: P0 fixes from swallowed errors in context_builder.py. |
| External service clients (12.9) | tenderhelper tender_fetcher.py: one service, one file, fixture-tested. SessionPilot stt/: AssemblyAI wrapped with config injection. Fixture naming from tenderhelper test_fixtures/ directory. |
| Logging conventions (12.10) | stdlib logging best practices. Consistent across projects where applied. Module-level logger + entrypoint-only config prevents the handler duplication seen in spark early development. |
| CLAUDE.md token budgets (7.6) | spark CLAUDE.md: ~10,700 tokens, 67% was evolution history (39 phases) and reference gotchas. Refactored to ~1,200 tokens with progressive disclosure. Cross-project analysis: 3 of 7 projects over budget. |
| Agent authoring patterns (7.7) | code-reviewer agent: narrow scope, minimal frontmatter. Comparative analysis of shanraisshan/claude-code-best-practice: 14 frontmatter fields documented, feature-specific agents with preloaded skills pattern. |
| Rules directory for instruction splitting (7.6) | shanraisshan/claude-code-best-practice: `.claude/rules/` auto-loads alongside CLAUDE.md, complementing token discipline by splitting always-loaded instructions without bloating CLAUDE.md. |
| Settings and permission patterns (7.8) | shanraisshan/claude-code-best-practice: 5-level settings hierarchy, deny-always-wins rule, wildcard permission syntax. Aligns with Rule 1.4 (security as constraints). |
