# Applying Standards to Existing Projects

A step-by-step guide for rolling out HumanSpark engineering standards across
all your existing projects.

---

## What You Get

When you apply standards to a project, it receives these files (nothing is
overwritten if it already exists):

| File | What it does |
|------|-------------|
| `CLAUDE.md` | Project context template - tells Claude about your project |
| `HANDOFF.md` | Session handoff template for multi-session work |
| `.claude/settings.json` | py_compile hook that catches syntax errors on save |
| `.claude/skills/` | 5 skill packs (modular design, testing, security, prompts, memory) |
| `.claude/agents/code-reviewer.md` | Code review agent definition |
| `.mcp.json` | Forgejo MCP server config |
| `docs/MODULE-README-TEMPLATE.md` | Template for module contract docs |
| `src/models.py` | Starter frozen dataclasses (only if `src/` exists) |
| `src/config.py` | Starter typed config (only if `src/` exists) |

---

## Step 1: Deploy User-Level Instructions (One Time)

This installs the universal `~/.claude/CLAUDE.md` that applies to every
project. You only need to do this once.

```bash
cd ~/ai-coding-standards
./setup.sh
```

You should see: `Installed: ~/.claude/CLAUDE.md`

This gives Claude your coding style, git conventions, module design rules,
and testing preferences in every project - no per-project setup needed for
the basics.

---

## Step 2: Run Setup on Each Project

For each project you want to fully standardise:

```bash
./setup.sh ~/project-name
```

That's it. The script creates all the template files listed above. It never
overwrites existing files, so it's safe to run on projects that already have
some of these in place.

### Run them all at once

```bash
cd ~/ai-coding-standards

for project in \
  clearmail gdrive-ops humansparkforge inbox-roulette \
  ragbuilder sessionpilot shared-email sign-making \
  spark tenderhelper workstation-dotfiles; do
  echo ""
  echo "=========================================="
  ./setup.sh ~/$project
done
```

---

## Step 3: Fill In Each Project's CLAUDE.md

This is the important part. The script drops a template `CLAUDE.md` with
placeholders like `{Project Name}` and `{one sentence description}`. For
projects that already have a `CLAUDE.md`, the script skips it - but you
should still check that the existing one covers the key sections.

### The easy way (with Claude)

Open the project in Claude Code and say:

> Read through this project and fill in the CLAUDE.md template with real
> details about how this project works. Keep it factual - only what you
> can verify from the code.

Claude will read your code, figure out the architecture, and fill in the
template. Review what it writes - you know your project better than it does.

### What each section needs

**Remember: CLAUDE.md is for LLMs, not humans.** Humans read README.md.
Every token in CLAUDE.md is loaded into every conversation, so keep it lean.
Target: small projects < 2,000 tokens, medium < 4,000, large < 6,000. Add
`<!-- ~NNNN tokens — budget: NNNN -->` at the top so growth is visible.

**Design Philosophy** - One or two sentences about what "good" looks like
for this project. What are the non-negotiable rules vs. the flexible areas?

**How It Evolved** - A numbered history of major phases. Keep to ~5 entries
max. When it grows past that, move older phases to `docs/HISTORY.md` and
keep a 3-line summary in CLAUDE.md.

**Build & Run** - The exact commands to install dependencies, run the app,
and run tests. Someone (or an AI) should be able to copy-paste these and
have it work.

**Architecture** - For multi-file projects, a quick ASCII diagram or
description of how the pieces fit together. For single-file scripts, skip it.

**Key Files** - A table of the top 10-15 important files. For larger projects,
keep the full list in README.md.

**Security Boundaries** - What the system cannot do. Read-only APIs, rate
limits, where secrets live.

**Things to Watch Out For** - Active gotchas that affect everyday development.
Subsystem-specific edge cases go in `docs/REFERENCE-GOTCHAS.md` instead.
Watch for duplication with Security Boundaries or Key Patterns - if the same
fact appears in multiple sections, keep it in the most authoritative one.

---

## Step 4: Review What Got Deployed

After running setup, check what's new in each project:

```bash
cd ~/project-name
git status
```

You'll see untracked files for everything that was created. Review them
before committing:

- **`.claude/settings.json`** - Check the py_compile hook paths make sense
  for your project layout. If the project isn't Python, you may want to
  adjust or remove this.

- **`.mcp.json`** - Contains Forgejo MCP config. If you don't use Forgejo,
  you can delete this file.

- **`.claude/skills/`** - These are ready to use as-is. Browse them if
  you're curious, but they don't need editing.

- **`HANDOFF.md`** - A template for session continuity. You don't need to
  fill this in now - Claude uses it automatically when sessions get long.

- **`docs/MODULE-README-TEMPLATE.md`** - Reference template. Only relevant
  when you create new modules.

- **`src/models.py` and `src/config.py`** - Starter templates with TODOs.
  Fill these in when you're ready to add typed data structures or config
  to the project. If the project already has its own approach, delete these.

---

## Step 5: Commit the Standards Files

For each project:

```bash
cd ~/project-name
git add .claude/ CLAUDE.md HANDOFF.md .mcp.json docs/
git add src/models.py src/config.py 2>/dev/null  # only if they exist
git commit -m "chore: add HumanSpark engineering standards"
```

---

## Your Projects at a Glance

Current status of your coding projects (identified by having `.git`,
`CLAUDE.md`, or `.claude/`):

| Project | CLAUDE.md | .claude/ | Action needed |
|---------|-----------|----------|---------------|
| claritybot | yes | - | Run setup (adds skills, agents, settings) |
| clearmail | yes | yes | Run setup (fills gaps), review CLAUDE.md |
| gdrive-ops | yes | - | Run setup (adds skills, agents, settings) |
| humansparkforge | yes | yes | Run setup (fills gaps), review CLAUDE.md |
| inbox-roulette | - | - | Run setup (gets everything) |
| ragbuilder | yes | yes | Run setup (fills gaps), review CLAUDE.md |
| sessionpilot | yes | yes | Run setup (fills gaps), review CLAUDE.md |
| shared-email | - | - | Run setup (gets everything) |
| sign-making | - | yes | Run setup (adds CLAUDE.md, skills, etc.) |
| spark | yes | yes | Run setup (fills gaps), review CLAUDE.md |
| tenderhelper | yes | yes | Run setup (fills gaps), review CLAUDE.md |
| workstation-dotfiles | - | yes | Run setup (adds CLAUDE.md, skills, etc.) |

**Legend:** "yes" = already has it, "-" = missing, "fills gaps" = only
creates files that don't already exist.

---

## FAQ

**Will setup.sh break anything?**
No. It never overwrites existing files. If a file already exists, it prints
"skipped" and moves on.

**What if my project isn't Python?**
The skills and CLAUDE.md template are language-agnostic. The only
Python-specific pieces are `.claude/settings.json` (py_compile hook),
`models.py`, and `config.py`. Remove or adapt those for non-Python projects.

**Do I need to fill in CLAUDE.md right away?**
The user-level `~/.claude/CLAUDE.md` already gives Claude your coding style
and conventions. The project-level CLAUDE.md adds project-specific context.
It's most valuable for complex projects - a simple script folder can wait.

**Can I re-run setup.sh later?**
Yes, any time. If new skills or templates are added to `ai-coding-standards`
in the future, re-running setup.sh will deploy only the new files without
touching anything that already exists.

**How do I update skills across all projects?**
If a skill is updated in `ai-coding-standards`, you need to manually copy it
or delete the old version and re-run setup.sh (since it won't overwrite).
A future enhancement could add a `--force-skills` flag for this.
