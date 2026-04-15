# Applying Standards to Existing Projects

A step-by-step guide for rolling out HumanSpark engineering standards across
all your existing projects.

---

## What You Get

When you apply standards to a project, it receives these files. Sync mode
(default) creates missing files and updates stale ones. Init mode (`--init`)
additionally creates project-specific files that are never overwritten on
subsequent syncs.

**Synced to every project (created + kept up to date):**

| File | What it does |
|------|-------------|
| `.claude/settings.json` | git fetch before commit/push + py_compile on save |
| `.gitignore` | Python artifacts, env files, personal Claude Code files |
| `.claude/skills/` | 8 skill packs (testing, security, prompts, memory, modular design, intake, workplan, visual review) |
| `.claude/agents/code-reviewer.md` | Code review agent definition |
| `.claude/rules/deployment.md` | Template: always-loaded deployment constraints |
| `.claude/rules/specs.md` | Enforces docs/plans/ as canonical spec location |
| `docs/MODULE-README-TEMPLATE.md` | Template for module contract docs |
| `docs/SPEC-TEMPLATE.md` | Feature spec template (intake to workplan contract) |
| `docs/plans/` | Directory for spec and plan documents |

**Created only with `--init` (never overwritten):**

| File | What it does |
|------|-------------|
| `CLAUDE.md` | Project context template - tells Claude about your project |
| `HANDOFF.md` | Session handoff template for multi-session work |
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

You should see output confirming installation of `~/.claude/CLAUDE.md`,
rules files, and user-level git hooks (deployed to `~/.config/git/hooks/`
via `core.hooksPath`).

This gives Claude your coding style, git conventions, module design rules,
and testing preferences in every project - no per-project setup needed for
the basics. The pre-commit hook applies to all repos automatically.

---

## Step 2: Run Setup on Each Project

For each project you want to fully standardise:

```bash
./setup.sh ~/project-name
```

That's it. The script creates missing files and updates stale template-managed
files (skills, agents, rules, doc templates). It's safe to re-run any time -
project-specific files like CLAUDE.md are never overwritten.

### Run them all at once

```bash
cd ~/ai-coding-standards
./setup.sh
```

With no arguments, setup.sh auto-discovers all projects in the home
directory that have a `.claude/` directory and syncs them all. To opt a
directory out of auto-discovery (e.g. a writing workspace that has its
own `.claude/skills/` but is not a Python project), create an empty
`.claude/.nosync` sentinel file in that directory.

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

- **`.claude/settings.json`** - Has two hooks: a PreToolUse hook that
  runs `git fetch` before commit/push (language-agnostic), and a PostToolUse
  hook that runs py_compile after Python edits. For non-Python projects,
  remove the py_compile hook but keep the git fetch one.

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
git add .claude/ .gitignore CLAUDE.md HANDOFF.md docs/
git add src/models.py src/config.py 2>/dev/null  # only if they exist
git commit -m "chore: add HumanSpark engineering standards"
```

---

## Your Projects at a Glance

All 14 managed projects are synced via `./setup.sh` (auto-discovers
projects with a `.claude/` directory). To verify current state, run:

```bash
./setup.sh --dry-run
```

| Project |
|---------|
| booky |
| ccloop |
| clearmail |
| gdrive-ops |
| migration |
| ragbuilder |
| sessionpilot |
| sparkcore |
| sparkdash |
| sparkforge |
| sparky |
| tenderhelper |
| tidybot |
| workstation-dotfiles |

---

## FAQ

**Will setup.sh break anything?**
No. It syncs template-managed files (skills, agents, rules, doc templates) but
never overwrites project-specific files (CLAUDE.md, HANDOFF.md). Settings.json
and .gitignore are merged additively - existing entries are preserved.

**What if my project isn't Python?**
The skills and CLAUDE.md template are language-agnostic. The only
Python-specific pieces are `.claude/settings.json` (py_compile hook),
`models.py`, and `config.py`. Remove or adapt those for non-Python projects.

**Do I need to fill in CLAUDE.md right away?**
The user-level `~/.claude/CLAUDE.md` already gives Claude your coding style
and conventions. The project-level CLAUDE.md adds project-specific context.
It's most valuable for complex projects - a simple script folder can wait.

**Can I re-run setup.sh later?**
Yes, any time. Running `./setup.sh` with no arguments auto-discovers all
projects and syncs them. New and updated skills, agents, rules, and doc
templates are deployed automatically.

**How do I update skills across all projects?**
Just re-run `./setup.sh`. Sync mode (the default) detects stale
template-managed files and updates them.
