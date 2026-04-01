# HumanSpark Engineering Standards

A git-managed system of coding standards, AI instructions, project templates, and reference documents for all HumanSpark projects.

**This repo contains three different CLAUDE.md files - don't confuse them:**
- **`/CLAUDE.md`** (this file) - Context for working on this standards repo itself
- **`user-level/CLAUDE.md`** - Universal AI instructions, deployed to `~/.claude/CLAUDE.md` for all projects
- **`project-template/CLAUDE.md`** - Stage 4 template copied into new projects via `setup.sh`

## Design Philosophy

This system captures how we actually work, not how we aspire to work. Every rule is traceable to evidence from real projects.

**Keep strict:** Evidence derivation (no aspirational rules), three-layer separation (human checklist / AI instructions / master reference), never overwrite existing project files during setup.

**Free to adapt:** Skill content, agent checklists, hook configurations - all can be modified per-project as patterns evolve.

## How It Evolved

1. **Genesis (2026-03-12):** Derived from git archaeology across 7 repos (960+ commits), CLAUDE.md evolution analysis (52+ edits across 6 projects), and analysis of Luna/OpenClaw memory architecture and Hay/Kelder prompting patterns.
2. **Modular Design Patterns (2026-03-13):** Added Section 12 (Rules 12.1-12.10) covering module structure, standard roles, data flow pipeline, error handling, client conventions, and logging. New skill, templates (MODULE-README-TEMPLATE, models.py, config.py), three checklist sections. Thinned user-level Security/Testing sections (~215 tokens saved per session). Evidence: 9 repos, 1000+ commits.
3. **CLAUDE.md Token Discipline (2026-03-14):** Added Rule 7.6 - token budgets and three-tier progressive disclosure (always-loaded / on-demand / archival). Updated user-level section, project template, and reference doc. Evidence: cross-project audit found 3 of 7 projects over budget, with evolution history and reference gotchas as the primary growth vectors.
4. **Claude Code Configuration Patterns (2026-03-15):** Added Rules 7.7 (agent authoring with 14 frontmatter fields), 7.8 (settings precedence and permission patterns). New template files: `.claude/rules/deployment.md`, `.gitignore` (with CLAUDE.local.md). Expanded settings.json with scoped permissions and deny rules. Updated Rule 7.6 to include `.claude/rules/` in Tier 1 context. Fixed Rule 2.4 to distinguish committed vs gitignored Claude Code files. Evidence: comparative analysis of shanraisshan/claude-code-best-practice.
5. **Development Discipline & Code Quality (2026-03-16):** Added Development section to user-level instructions with four mandatory disciplines: TDD (red-green-refactor via superpowers skill), systematic debugging, verification-before-completion, and planning for multi-step work. Added Code Style rules: type hints, ruff linting, dependency pinning, mandatory error hints (HintedError base class). Updated models.py template with HintedError, modular-design skill with hint-at-raise-site pattern, settings.json with ruff permissions.
6. **ccloop Planning Workflow (2026-03-16):** Added project-intake skill (structured interview with scope-aware triage, five phases, two-kind "I don't know" handling) and workplan-generation skill (spec validation, five specificity rules, stage gates, HANDOFF seeding). New SPEC-TEMPLATE.md as contract between skills. Updated setup.sh to deploy template and `docs/plans/` directory. Evidence: SparkCore Phase 2 (17 tasks, 195 tests, 53 minutes, 6 human commands) proved specific task descriptions are the key differentiator for autonomous execution quality.
7. **Stage Gate Completion Fix (2026-03-17):** Cleaned workplan-generation skill stage gate instruction block to remove checkbox syntax that polluted grep-based task counting. Added checkpoint tracking rule (CC marks tasks `- [x]` as completed). Coordinated with ccloop v4.4.0 which tightened completion detection to exact "WORKPLAN COMPLETE" sentinel with unchecked-task verification. Evidence: SparkCore Phase 3 loop stopped prematurely at Stage 1 gate when CC output "Stage 1 tasks complete".
8. **AI-Specific Design Constraints (2026-03-18):** Added Section 13 to reference doc (Rules 13.1-13.3) covering Avoid Hasty Abstractions, Composition Over Inheritance, and Strict Scope with dual Rule/AI-Rationale format. Tightened user-level CLAUDE.md: added three rules to existing sections (Code Style, Module Design, Development), removed code examples and redundant text to stay token-neutral. Evidence: observed LLM over-engineering, context window degradation from deep inheritance, scope creep from "clean up" instructions.
9. **Remove Branching Restrictions (2026-03-18):** Removed all main-only and no-feature-branches directives from user-level CLAUDE.md, project template, and reference doc (old Rule 3.3). Renumbered Section 3 subsections and updated cross-references in human checklist. Coding assistants now decide branching strategy per-situation rather than following a blanket restriction.
10. **Retire commitreader Repo (2026-03-18):** R&D evidence report (12 repos, 1332 commits) kept locally as `docs/rd-evidence-report.md` (gitignored). Deleted commitreader repo - it was a redundant copy of project-template/ with no source code.
11. **Visual Review Skill (2026-03-21):** Added visual-review skill to project template. Playwright-based screenshot and visual inspection for frontend changes. Includes contact sheet compositing, before/after comparison, SSL handling, and design evaluation dimensions.
12. **Tool Discipline & Setup Overhaul (2026-04-01):** Added five Development rules to user-level CLAUDE.md: clean before refactoring, guard against context decay, verify edits applied, assume tool output is truncated, sub-agents for independent work only. Extracted "CLAUDE.md as Code" section to `user-level/rules/claude-md-discipline.md` to offset token growth. Rewrote setup.sh: sync is now the default (creates missing + updates stale template-managed files), auto-discovers all projects when no target given, `--init` for new projects only. Eliminated the old --update/--sync split. Evidence: analysis of Claude Code's actual tool behaviour; found 11/13 projects running stale skills after template updates because --update never refreshed existing files.
13. **Quality Standards & Remote Sync (2026-04-01):** Added Quality Standards section to user-level CLAUDE.md with five rules: post-rewrite secret auditing, status verification against source of truth, lazy evaluation preservation, API parameter verification, and remote sync check before commit/push. Added PreToolUse hook to project-template settings.json that runs `git fetch` and warns if behind remote before any `git commit` or `git push`. Evidence: observed Claude reporting repos as up-to-date without fetching, and pushing without checking for upstream changes.

## Build & Run

```bash
./setup.sh                         # Sync user-level + all projects (auto-discover)
./setup.sh ~/path/to/project       # Sync user-level + one project
./setup.sh --init ~/new-project    # Sync + create project-specific files (CLAUDE.md, HANDOFF.md)
./setup.sh --dry-run               # Preview any of the above without applying
```

## Testing

No automated tests. Validate by running `./setup.sh --init --dry-run /tmp/test-project` and inspecting output.

## Key Files

| File | What it does |
|------|-------------|
| setup.sh | Deployer script - user-level + project initialisation |
| user-level/CLAUDE.md | Universal AI instructions (-> ~/.claude/CLAUDE.md) |
| user-level/rules/claude-md-discipline.md | CLAUDE.md maintenance rules (-> ~/.claude/rules/) |
| project-template/CLAUDE.md | Stage 4 project context template |
| project-template/.gitignore | Template gitignore (includes CLAUDE.local.md) |
| project-template/HANDOFF.md | Session handoff template for multi-session work |
| project-template/.claude/rules/deployment.md | Template: always-loaded project rules |
| project-template/.claude/rules/specs.md | Enforces docs/plans/ as canonical spec location |
| project-template/.claude/settings.json | Permissions + hooks: git fetch before commit/push, py_compile after edits (see Rule 7.8) |
| project-template/.claude/skills/modular-design/SKILL.md | Module boundary patterns and conventions |
| project-template/.claude/skills/project-intake/SKILL.md | Structured interview producing spec documents |
| project-template/.claude/skills/visual-review/SKILL.md | Playwright screenshot and visual review for frontend changes |
| project-template/.claude/skills/workplan-generation/SKILL.md | Spec-to-WORKPLAN converter for ccloop execution |
| project-template/docs/MODULE-README-TEMPLATE.md | Module contract template |
| project-template/docs/SPEC-TEMPLATE.md | Feature spec template (contract between intake and workplan skills) |
| project-template/src/models.py | Starter shared types template |
| project-template/src/config.py | Starter typed config template |
| reference/humanspark-engineering-standards-v1.md | Master doc with evidence (Sections 1-12, Rules 7.7-7.8) |
| reference/humanspark-human-checklist.md | Human workflow checklist |
| docs/rd-evidence-report.md | 12-repo, 1332-commit analysis (gitignored - local only) |

## Git Conventions

- Conventional commits: feat/fix/docs/refactor/test/chore/ux
- NEVER include Co-Authored-By in commit messages
