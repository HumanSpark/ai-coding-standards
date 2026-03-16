---
name: project-intake
description: Structured interview for capturing feature specs. Covers goal, scope, design decisions, constraints. Produces standard spec documents in docs/plans/. Use when planning a new feature, brainstorming, creating a project spec, or running an intake interview.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git log*), Bash(git status*), Bash(git diff*), Bash(git add *), Bash(git commit *)
---

# Project Intake

Structured interview skill for capturing feature specs. Produces a standard
spec document that the workplan-generation skill consumes.

## When to Use

- Planning a new feature or project
- User mentions "plan", "brainstorm", "new feature", "new project", "intake",
  "interview", "spec"
- Starting work that needs design decisions captured before execution
- Preparing input for ccloop autonomous execution

## Triage First

Before any interview phase, assess scope:

> "Is this a small change (one module, clear approach), a medium feature
> (clear module, some design choices), or a larger feature (new module or
> subsystem, significant design choices needed)?"

This determines interview depth:

| Tier | Phase 1-2 | Phase 3 | Phase 4 |
|------|-----------|---------|---------|
| **Small** | Full | One question each | One question each |
| **Medium** | Full | Genuine decision points only | Skip if CLAUDE.md has non-placeholder content in Key Patterns / Things to Watch Out For |
| **Large** | Full | Full treatment | Full treatment |

Do not run a 20-minute interview for a 30-minute fix.

## Grounding Reads (Token-Budgeted)

Before asking questions, ground yourself in the project. Budget your reads:

1. **CLAUDE.md** - read fully (always-loaded context, small by design)
2. **`git log --oneline -20`** - skim for recent patterns and conventions
3. **`docs/plans/`** - scan existing specs for contradictions or overlap with
   the new feature. Surface relevant specs: "I see the auth spec from March 10
   already locked in JWT tokens - does this feature interact with that?"
4. **Specific files** you will reference during questions - NOT the whole tree

**If project context is missing** (no CLAUDE.md, or CLAUDE.md contains only
template placeholders, no `docs/plans/` directory): note what is missing,
proceed without cross-referencing, and flag in the output that grounding
reads were unavailable. This is normal for new projects.

## Phase 1: Goal and Context

What are you building, why, where does it live, what exists already?

Grounded by the reads above. If existing specs in `docs/plans/` are relevant,
surface them and ask about interactions.

Key questions:
- What problem does this solve?
- Which project/repo does this live in?
- What exists already that this builds on or replaces?

## Phase 2: Scope

Minimum viable version, what is explicitly excluded.

Key questions:
- What is the smallest version that delivers value?
- What is explicitly NOT included? (forces boundary thinking)

**Acceptance criteria get their own moment.** After scope is clear, ask
specifically: "What does done look like? Give me specific, testable
conditions." Push for specificity - "it works" is not an acceptance criterion.

## Phase 3: Design Decisions

Technology choices, rejected alternatives, patterns to follow (Prior Art),
interfaces, data structures, external services, known gotchas.

This is the highest-value phase. Every decision captured here is one CC
does not guess at during autonomous execution.

Key areas to cover:
- Technology and library choices
- Rejected alternatives and why
- Patterns to follow (point at existing code: "follow the same pattern as X")
- Interfaces and data structures
- External services and their constraints
- Known gotchas or edge cases

### Two Kinds of "I Don't Know"

When the human is unsure, distinguish between two cases by asking:

> "Do you want me to pick something reasonable here, or is this something
> you need to think through?"

**"No preference, you pick":** Choose a sensible default. Document in
Decisions Made as:

```
3. Use SQLite for local cache [CC default, vs Redis] - lightweight, no
   server dependency, sufficient for single-user access pattern
```

The `[CC default, vs {runner-up}]` marker makes CC choices visually distinct
during Phase 5 review. Always name the alternative CC chose against.

**"I haven't thought about this":** Add to Open Questions as a blocker.
Explain why it matters:

```
## Open Questions
- Storage backend choice: SQLite vs Redis vs filesystem. Affects
  concurrency model and deployment requirements. Must resolve before
  workplan generation.
```

## Phase 4: Constraints

What must NOT happen. Conventions to follow. Dependencies on other systems.

**Feature-specific only.** Cross-reference CLAUDE.md to avoid duplicating
project-wide constraints. If CLAUDE.md already says "never hit real APIs
in unit tests," do not repeat it in the spec. Only capture constraints
unique to this feature.

Key questions:
- What must this feature NOT do?
- Are there external system dependencies with rate limits or access controls?
- Are there conventions from other modules this must follow?

## Phase 5: Review and Output

Assemble the spec using the template from `docs/SPEC-TEMPLATE.md`.

1. Present the complete spec to the human for review
2. Iterate on feedback - especially review `[CC default]` entries
3. Save to `docs/plans/{date}-{feature-name}.md`
4. **Do not auto-commit.** Offer:

> "Spec saved to `docs/plans/{date}-{feature-name}.md`. Want me to commit
> it now, or leave it uncommitted for review?"

If the human confirms, commit with: `docs: add {feature-name} spec`

## Key Behaviours

- **One question at a time.** Do not overwhelm with multiple questions.
- **Push back on vagueness.** "What do you mean by 'it should handle errors'?"
- **Capture early information.** If the human volunteers Phase 3 info during
  Phase 1, note it and confirm during Phase 3 rather than re-asking.
- **Preserve existing terminology.** Do not introduce new terms when the
  codebase already has established names. If the project calls them
  "processors," do not start calling them "handlers" in the spec.
- **Scale to scope.** A small-tier interview should feel like a quick chat,
  not a bureaucratic form.
- **Open Questions are blockers.** Make this explicit to the human when
  adding items.

## Anti-Patterns

- Do NOT skip triage and run full interview for every request
- Do NOT repeat project-wide constraints from CLAUDE.md in the spec
- Do NOT auto-commit the spec - always offer and wait for confirmation
- Do NOT accept "it should work" as an acceptance criterion
- Do NOT invent terminology that conflicts with the existing codebase
- Do NOT slurp the entire codebase during grounding - read targeted files
- Do NOT combine multiple questions in one message
