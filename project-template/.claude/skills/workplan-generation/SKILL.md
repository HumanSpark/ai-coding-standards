---
name: workplan-generation
description: Converts spec documents into ccloop-compatible WORKPLAN.md with specific, file-level tasks. Validates spec completeness, classifies tasks by module role, places stage gates. Use when generating a workplan, planning tasks, or preparing for ccloop execution.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git log*), Bash(git status*), Bash(git diff*), Bash(git add *), Bash(git commit *)
---

# WORKPLAN Generation

Converts a spec document into a ccloop-compatible WORKPLAN.md with specific,
file-level tasks. Seeds HANDOFF.md for execution continuity.

## When to Use

- User mentions "workplan", "WORKPLAN", "generate tasks", "plan tasks",
  "create workplan"
- A spec document exists in `docs/plans/` and is ready for execution planning
- Preparing for a ccloop autonomous execution run

## Input Validation

**Read the spec document first.** Then validate before generating anything:

**Required sections** (must exist):
- Goal (must contain content)
- Scope (must have In and Out with content)
- Decisions Made (must contain content)
- Constraints (must contain content)
- Prior Art (may contain "None" for greenfield features)
- Dependencies (may contain "None" if no dependencies)
- Acceptance Criteria (must contain content)
- Open Questions (see rules below)

**Validation rules:**
- Missing section → stop. Name the missing sections.
- Open Questions section exists and is empty → pass (human considered it,
  nothing unresolved).
- Open Questions section exists with items → stop. "This spec has unresolved
  open questions: {list}. These must be resolved before generating a WORKPLAN."
- Open Questions section missing entirely → stop. "Spec is missing the Open
  Questions section."

## Grounding Reads

After validation passes, read the codebase to make tasks specific:

1. **The spec document** - fully (you already read it for validation)
2. **CLAUDE.md** - fully (architecture, conventions, key files)
3. **Prior Art files named in the spec** - read the actual modules you will
   point tasks at. This is how you learn the pattern to follow.
4. **`models.py` and `config.py`** if they exist - to reference real types
5. **Existing test directory structure** - to name test files correctly
6. **`pyproject.toml` or `requirements.txt`** - to verify any external packages
   referenced in tasks are already dependencies. If a task needs a package that
   isn't listed, either add an explicit "add X to dependencies" sub-task or
   choose an approach using existing dependencies.
7. **Existing `WORKPLAN.md`** if present - for multi-phase awareness. If you
   are generating a Phase 2 workplan after Phase 1 is complete, you need to
   know what was already built so you do not re-specify work or contradict
   completed decisions.

## Five Specificity Rules

These are hard requirements, not guidelines. Every task must satisfy the
rules that apply to it.

1. **Name the file.** "Add `ScoredTender` to `src/sparkcore/models.py`" not
   "add a data model"
2. **Name the fixture.** For tasks involving test data: "Use
   `tests/fixtures/etenders_cft_standard.html`" not "use mock data"
3. **Name the pattern.** "Follow `src/sparkcore/storage/__init__.py` for
   module structure" not "follow conventions"
4. **Name the type.** "Add `ScoredTender` to `models.py` with fields:
   `tender: Tender`, `score: float`, `matched_keywords: list[str]`" not
   "add a data model"
5. **Name the criterion.** Each task gets a verifiable done condition:
   "Parser extracts 5 fields from `tests/fixtures/sample.html` - test
   asserts all five" not "it should work". Aggregate criteria like
   "`make check` passes with 20+ new tests" belong on stage gates.

**Validate every task against these rules before presenting the WORKPLAN.**
If a task is vague, read the codebase to find the specific file, type, or
pattern. If you cannot make a task specific because no Prior Art exists:

```markdown
- [ ] Task N: {description} ⚠️ PATTERN DECISION - no existing Prior Art
  found for {what's missing}. Resolve before execution or accept that CC
  will make a judgement call.
```

## Task Classification

**Module roles:** If the `modular-design` skill exists in the project
(`.claude/skills/modular-design/SKILL.md`), use it to classify each task
by module role: client, processor, storage, output, entrypoint. (Models
and config are shared types, not module roles.) This helps with task
ordering and stage gate placement.

If the modular-design skill is not present, skip role classification and
note: "Task classification by module role skipped - modular-design skill
not deployed to this project."

**Testing tiers:** If the `testing-patterns` skill exists, use it to assign
testing tiers. Tier 1 (tests first) for security and protocol boundaries.
Tier 2 (tests alongside, default) for feature work.

If the testing-patterns skill is not present, default all tasks to Tier 2
and note: "Testing tier assignment skipped - testing-patterns skill not
deployed. All tasks default to Tier 2 (tests alongside)."

## Stage Gates

Stage gates are explicit tasks that block autonomous progress until a human
reviews and marks them complete.

**Template:**
```markdown
- [ ] Task N: STAGE GATE - {specific criteria}. Human review required.
  Do NOT continue to Stage {next}.
```

The "Do NOT continue" text serves dual purpose: it is visible to the human
during review, and it is an instruction to CC during execution. CC must not
proceed past a STAGE GATE task until it is checked off.

**Placement rules:**
- After infrastructure/models are created (types that other tasks depend on)
- After core business logic is implemented
- After integration/wiring between modules
- After any task that introduces an external dependency
- After any task that changes an interface other tasks consume

**Scaling guidance (advisory):**
- Small features (under 8 tasks): one gate at the end
- Medium features (8-15 tasks): two gates (after foundation, after core logic)
- Large features (15+ tasks): three or more (after models/infra, after core
  logic, after integration)

CC uses judgement based on where interface boundaries actually fall.

## Output: WORKPLAN.md

Generate `WORKPLAN.md` at the project root with this structure:

```markdown
# WORKPLAN - {Feature Name}

**Spec:** `docs/plans/{date}-{feature-name}.md`
**Generated:** {YYYY-MM-DD}

**CC: Never mark a STAGE GATE task as `- [x]`. Leave stage gates as `- [ ]`.
Report gate criteria status in HANDOFF.md and stop working. Only the human
marks stage gates complete.**

## Stage 1: {Stage Name}

- [ ] Task 1: {specific task description}
- [ ] Task 2: {specific task description}
- [ ] Task N: STAGE GATE - {criteria}. Human review required. Do NOT continue to Stage 2.

## Stage 2: {Stage Name}

- [ ] Task N+1: {specific task description}
...
```

**Format constraints (ccloop compatibility):**
- Task checkboxes MUST use `- [ ]` format exactly
- Tasks must be specific enough to execute without reading the spec

## Output: HANDOFF.md

Write a fresh `HANDOFF.md` at the project root (replacing any existing
content, including any "Usage Notes" section from the template). This is
intentional - the seeded HANDOFF is execution state, not a template. The
"Decisions to preserve" field is a deliberate extension of the standard
HANDOFF format for workplan-seeded contexts.

```markdown
# HANDOFF.md

Session handoff for multi-session work. Read this FIRST when resuming.
Updated after every completed subtask - not just at session end.

**Last updated:** {YYYY-MM-DD HH:MM}

## Current Task

Begin WORKPLAN Stage 1.

## Last Action

WORKPLAN generated from spec: `docs/plans/{date}-{feature-name}.md`

## Next Action

{First task from WORKPLAN, copied verbatim}

## Key Files

- `WORKPLAN.md` - task list for this feature
- `docs/plans/{date}-{feature-name}.md` - spec with design decisions
{Additional key files from the spec's Dependencies section}

## Context

**Feature-specific constraints (from spec):**
{Top 3-5 constraints from the spec's Constraints section, copied verbatim.
These must be visible every iteration because ccloop reads HANDOFF.md
but does not re-read the spec.}

**Decisions to preserve:**
{Top 3-5 decisions from the spec that are most likely to be forgotten or
contradicted during execution}

## Check State

Not yet run.

[/HANDOFF]
```

The `[/HANDOFF]` sentinel at the end is required by ccloop.

## Commit Behaviour

**Do not auto-commit.** After saving both files, offer:

> "WORKPLAN.md and HANDOFF.md saved. Want me to commit now, or leave
> uncommitted for review?"

If the human confirms, commit with: `docs: add {feature-name} workplan and seed HANDOFF`

## Anti-Patterns

- Do NOT generate a WORKPLAN from a spec with unresolved Open Questions
- Do NOT write vague tasks - every task must pass the five specificity rules
- Do NOT auto-commit - always offer and wait for confirmation
- Do NOT skip reading Prior Art files named in the spec
- Do NOT ignore existing WORKPLAN.md in multi-phase scenarios
- Do NOT place stage gates arbitrarily - place them at interface boundaries
- Do NOT reference skills that are not deployed to the project
- Do NOT seed HANDOFF.md with project-wide constraints already in CLAUDE.md
- Do NOT let tasks use terminology that differs from the existing codebase
