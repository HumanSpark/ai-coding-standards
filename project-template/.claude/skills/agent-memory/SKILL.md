---
name: agent-memory
description: Patterns for AI agent memory persistence across sessions and context limits. Use when building long-running agents, implementing state serialisation, managing context windows, or working with HANDOFF.md for session continuity.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Agent Memory Patterns

## When to Use
- Building a long-running AI agent that persists across sessions
- Work spanning multiple Claude Code sessions on the same task
- Designing state management for agents with context window limits
- User mentions "memory", "handoff", "resume", "context loss", "state"
- Implementing knowledge bases or entity files for agent consumption

## Pattern 1: Pre-Emptive State Serialisation

Do not wait for context to be lost. Proactively save structured state to persistent files BEFORE session limits or context pressure hits.

### For Claude Code sessions
Before ending a session, update HANDOFF.md:

```markdown
## Current Task
Implementing the scoring module for tenderhelper

## Last Action
Completed keyword scoring with word-boundary regex for short terms

## Next Action
Add CPV code matching and write tests for both scoring methods

## Key Files
- relevance_scorer.py - main module being built
- tests/test_relevance_scorer.py - 12 tests passing
- config.yaml - keyword lists and CPV codes

## Context
- Decision: using \b word boundaries for terms <= 3 chars to avoid false positives
- Tried simple substring matching first, too many false positives on "AI"
- CPV codes need exact prefix matching, not substring

## Check State
All 12 tests passing.
```

### For long-running agents
Implement a mandatory pre-compaction save protocol that captures:
1. Commitments made (promises to user)
2. Decisions agreed on (and reasoning)
3. Project/task status changes
4. File locations for new artefacts
5. Lessons learned / mistakes to avoid
6. People/entity context updates
7. Ideas flagged for future exploration

This runs EVERY time context pressure is detected. Not optional.

## Pattern 2: Structured Resume Points (HANDOFF.md)

HANDOFF.md is a bookmark, not a memory dump. Six fields only:

| Field | Purpose | Example |
|-------|---------|---------|
| Current Task | What you're doing now | "Implementing email parser" |
| Last Action | What just finished | "Completed IMAP connection with retry logic" |
| Next Action | Immediate next step | "Add message body extraction with charset handling" |
| Key Files | Active artefacts | "email_parser.py, tests/test_parser.py" |
| Context | Decisions, dead ends, blockers | "Chose imaplib over imapclient for zero deps" |
| Check State | Last verification result | "Not yet run." or "All 45 tests passing" |

Update after every completed subtask. Resuming should take under 10 seconds of reading.

## Pattern 3: Selective Context Loading

Do not load all project knowledge into every session. Decompose into small, typed files:

### Entity file structure
```
knowledge/
  people/
    client_name.md      - role, relationship, key context (< 3KB)
  companies/
    company_name.md     - products, status, history (< 3KB)
  systems/
    infrastructure.md   - architecture, credentials, APIs (< 3KB)
  protocols/
    operational.md      - procedures, quality standards (< 3KB)
```

### Loading rules
- Load ONLY files relevant to the current task
- Never load the entire knowledge base into context
- Use file naming to make relevance obvious
- Keep each file under 3KB

This is the same principle behind `.claude/skills/` - domain knowledge loads only when relevant.

## Pattern 4: Append-Only History

For project-level continuity, the "How It Evolved" section in CLAUDE.md serves as a lightweight memory layer:

```markdown
## How It Evolved
1. **Core Pipeline (2026-03-01):** Built ingest -> score -> store. 45 tests.
2. **DPS Support (2026-03-05):** Added DPS tender parsing. Different HTML structure.
3. **Email Integration (2026-03-08):** Replaced notmuch with ClearMail reader.
```

Rules: numbered entries, never edit old entries, include date and test count. This gives any AI agent reading CLAUDE.md full project context without reconstructing it from git log.

## When NOT to Use These Patterns

- Single-session tasks that complete in one sitting
- Small projects where CLAUDE.md provides sufficient context
- Situations where git log and commit messages give enough continuity

Add HANDOFF.md when you find yourself spending more than 2 minutes re-establishing context at the start of a session. That's the signal.

## Anti-Patterns

- Do NOT create one massive memory file that loads every session
- Do NOT store raw conversation transcripts as "memory" (summarise first)
- Do NOT rely on the AI's built-in context management for critical state
- Do NOT treat HANDOFF.md as a diary - keep it to the six fields
