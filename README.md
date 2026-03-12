# HumanSpark Engineering Standards

Evidence-based coding standards derived from 960+ commits across 7 repositories.

## What's Here

```
humanspark-standards/
├── setup.sh                     - Deploy to user + project level
├── CLAUDE.md                    - This repo's own AI context
├── README.md                    - This file
├── .gitignore
│
├── user-level/
│   └── CLAUDE.md                - Universal AI instructions (-> ~/.claude/CLAUDE.md)
│
├── project-template/
│   ├── CLAUDE.md                - Project context template (Stage 4)
│   ├── HANDOFF.md               - Session handoff template
│   ├── .mcp.json                - Forgejo MCP server config
│   └── .claude/
│       ├── settings.json        - Hooks (py_compile on Python edits)
│       ├── skills/
│       │   ├── testing-patterns/SKILL.md
│       │   ├── security-hardening/SKILL.md
│       │   ├── prompt-engineering/SKILL.md
│       │   └── agent-memory/SKILL.md
│       └── agents/
│           └── code-reviewer.md
│
└── reference/
    ├── humanspark-engineering-standards-v1.md   - Master doc (full rules + evidence)
    └── humanspark-human-checklist.md            - Human workflow checklist
```

## How It Works

Three layers, two audiences:

**User-level** (`~/.claude/CLAUDE.md`) loads on every Claude Code session, every project. Contains universal rules: commit conventions, file headers, code style, testing discipline, security principles, writing style.

**Project-level** (`CLAUDE.md` + `.claude/`) contains what's unique to each project: design philosophy, evolution history, architecture, key files, security boundaries, gotchas. Plus hooks for automated quality gates, skills for domain knowledge, MCP for external tool integration, and HANDOFF.md for session continuity.

**Reference docs** are for the human. The master standards document has full evidence and rationale for every rule. The checklist is the pin-on-the-wall actionable version.

## Quick Start

### Deploy user-level instructions (once per machine)

```bash
./setup.sh
```

### Initialise a new or existing project

```bash
./setup.sh ~/projects/my-project
```

Won't overwrite existing files - only creates what's missing.

### Forgejo MCP Setup

Add to `~/.env.shared`:

```
FORGEJO_URL=https://your-forgejo-instance.com
FORGEJO_TOKEN=your_token_here
```

Install the binary:

```bash
go install github.com/raohwork/forgejo-mcp@latest
```

Or download from: https://github.com/raohwork/forgejo-mcp/releases

## What Each Component Does

### User-Level: `~/.claude/CLAUDE.md`
Universal AI instructions (143 lines). Covers: role, git conventions, file headers, code style, placeholders, security, testing, project structure, CLAUDE.md maintenance, writing style, and a "do not" list.

### Project Template: `CLAUDE.md`
Stage 4 template with: design philosophy (strict vs free-to-adapt), evolution history (append-only changelog), build/run commands, testing, architecture, key files, security boundaries, key patterns, gotchas, git conventions.

### Project Template: `HANDOFF.md`
Session continuity for multi-session work. Five fields: current task, last action, next action, key files, context. Updated after every completed subtask. Read first when resuming work.

### Project Template: `.claude/settings.json`
PostToolUse hook that runs `python -m py_compile` after every Python file edit. Catches syntax errors (including tab/space mixing) before deployment.

### Project Template: `.mcp.json`
Forgejo/Gitea MCP server in stdio mode. Gives Claude Code native access to repos, issues, milestones, PRs, wiki pages, and releases.

### Skills

**testing-patterns:** Three-tier discipline (TDD / alongside / gap-fill), edge case checklist, pytest conventions, mocking patterns.

**security-hardening:** SafetyValve pattern, sanitise-first approach, prompt injection defence, the lethal trifecta, constraint documentation.

**prompt-engineering:** System prompt conventions, `.format()` template rules, boundary markers, context poisoning prevention, prompt reliability testing.

**agent-memory:** Pre-emptive state serialisation, HANDOFF.md bookmark pattern, selective context loading, entity file decomposition. For any project with long-running agents or multi-session work.

### Agents

**code-reviewer:** Lightweight checklist with three severity levels (blocking / warning / note). Designed for solo-developer Python projects.

## Updating

Edit source files here, then re-run `./setup.sh` to redeploy user-level config. Project-level files are only created if missing. To force-update:

```bash
rm ~/project/.claude/skills/testing-patterns/SKILL.md && ./setup.sh ~/project
```

## Pushing to Forgejo

```bash
cd humanspark-standards && git init && git add -A && git commit -m "feat: initial commit - engineering standards v1"
git remote add origin https://your-forgejo-instance.com/your-user/humanspark-standards.git && git push -u origin main
```
