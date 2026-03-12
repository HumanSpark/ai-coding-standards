# HumanSpark Engineering Standards

A git-managed system of coding standards, AI instructions, project templates, and reference documents for all HumanSpark projects.

## Design Philosophy

This system captures how we actually work, not how we aspire to work. Every rule is traceable to evidence from real projects.

**Keep strict:** Evidence derivation (no aspirational rules), three-layer separation (human checklist / AI instructions / master reference), never overwrite existing project files during setup.

**Free to adapt:** Skill content, agent checklists, hook configurations - all can be modified per-project as patterns evolve.

## How It Evolved

1. **Genesis (2026-03-12):** Derived from git archaeology across 7 repos (960+ commits), CLAUDE.md evolution analysis (52+ edits across 6 projects), and analysis of Luna/OpenClaw memory architecture and Hay/Kelder prompting patterns.

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
| project-template/HANDOFF.md | Session handoff template for multi-session work |
| project-template/.claude/settings.json | py_compile hook on Python edits |
| project-template/.mcp.json | Forgejo MCP server config |
| reference/humanspark-engineering-standards-v1.md | Master doc with evidence |
| reference/humanspark-human-checklist.md | Human workflow checklist |

## Git Conventions

- Conventional commits: feat/fix/docs/refactor/test/chore
- NEVER include Co-Authored-By in commit messages
- Work on main only
