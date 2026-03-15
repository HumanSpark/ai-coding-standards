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

## Build & Run

```bash
./setup.sh                    # Deploy user-level ~/.claude/CLAUDE.md
./setup.sh ~/path/to/project  # Initialise project-level config
```

## Testing

No automated tests. Validate by running `./setup.sh /tmp/test-project` and inspecting output.

## Key Files

| File | What it does |
|------|-------------|
| setup.sh | Deployer script - user-level + project initialisation |
| user-level/CLAUDE.md | Universal AI instructions (-> ~/.claude/CLAUDE.md) |
| project-template/CLAUDE.md | Stage 4 project context template |
| project-template/.gitignore | Template gitignore (includes CLAUDE.local.md) |
| project-template/HANDOFF.md | Session handoff template for multi-session work |
| project-template/.claude/rules/deployment.md | Template: always-loaded project rules |
| project-template/.claude/settings.json | Permissions + py_compile hook (see Rule 7.8 for precedence) |
| project-template/.mcp.json | Forgejo MCP server config |
| project-template/.claude/skills/modular-design/SKILL.md | Module boundary patterns and conventions |
| project-template/docs/MODULE-README-TEMPLATE.md | Module contract template |
| project-template/src/models.py | Starter shared types template |
| project-template/src/config.py | Starter typed config template |
| reference/humanspark-engineering-standards-v1.md | Master doc with evidence (Sections 1-12, Rules 7.7-7.8) |
| reference/humanspark-human-checklist.md | Human workflow checklist |

## Git Conventions

- Conventional commits: feat/fix/docs/refactor/test/chore/ux
- NEVER include Co-Authored-By in commit messages
- Work on main only
