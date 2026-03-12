# HumanSpark Engineering Standards

**Version:** 1.0 (Draft)
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

Include at minimum: `__pycache__/`, `*.pyc`, `.coverage`, `*.db`, `venv/`, `.env`, `output/`, `.claude/`. The ragbuilder project had to retroactively remove committed `__pycache__` and `egg-info` files. SessionPilot had the same issue. Don't repeat this.

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
# Project: ProjectName | Date: 2026-03-12
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

- **Phase completion:** Add a numbered entry to the evolution history, update test count, add new files to the key files table. Do this after every feature or fix batch. Never edit old entries - the history is append-only.
- **Architectural correction:** Update the key flow diagram, architecture description, or component relationships when the structure changes.
- **Gotcha addition:** When something bites you in production or testing, add it to the gotchas section immediately.
- **Philosophy refinement:** Update the design philosophy section when you discover a new "keep strict" or "free to adapt" boundary. This is rare but high-value - it shapes every subsequent AI decision.

### 7.5 Commit messages are context for the next session

Write commit messages as if Claude Code will read them to understand what happened. The conventional commit prefix makes this searchable. A message like `fix: resolve RFC 2822 date parsing for timezone-aware headers` is useful context. A message like `fix stuff` is not.

---

## 8. CLAUDE.md Template

This template provides a Stage 4 starting point - the maturity level that the spark project reached after 52 iterations. Fill in project-specific content at project creation. The design philosophy section is the most important to get right early - it shapes how Claude Code makes every subsequent decision. The evolution history starts with entry 1 and grows append-only. Remove sections that genuinely don't apply, but keep security and gotchas sections even if empty - their presence is a prompt to fill them in.

```markdown
# {Project Name}

{One sentence: what it is, who it's for, where it runs.}

## Design Philosophy

{What does "good" look like for this project? Define the quality standard in terms the AI can apply to every decision.}

**Keep strict:** {Non-negotiable constraints - brand, security, data formats, API contracts}

**Free to adapt:** {Areas where any approach that meets the quality bar is acceptable - layout, naming, specific implementation patterns}

## How It Evolved

{Numbered chronological entries. Add new entries, never edit old ones. This gives Claude Code full project context without reading git log.}

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

- Conventional commits: feat/fix/docs/refactor/test/chore
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
