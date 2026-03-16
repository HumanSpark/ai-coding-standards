# ccloop Planning Workflow - Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create two skills (project-intake, workplan-generation) and a spec template that standardise the planning workflow from idea to ccloop execution.

**Architecture:** Three new files in `project-template/` (two SKILL.md skills and one SPEC-TEMPLATE.md), plus deployment changes to setup.sh and documentation updates. The spec template is the contract between skills - intake produces it, workplan consumes it.

**Tech Stack:** Markdown (SKILL.md files), Bash (setup.sh modifications)

**Spec:** `docs/specs/2026-03-16-ccloop-planning-workflow-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `project-template/docs/SPEC-TEMPLATE.md` | Create | Contract format between intake and workplan skills |
| `project-template/.claude/skills/project-intake/SKILL.md` | Create | Structured interview skill producing spec documents |
| `project-template/.claude/skills/workplan-generation/SKILL.md` | Create | Converts specs into ccloop-compatible WORKPLAN.md + HANDOFF.md |
| `setup.sh` | Modify | Deploy SPEC-TEMPLATE.md and `docs/plans/.gitkeep` in init + update modes |
| `README.md` | Modify | Add new files to project tree and skills descriptions |
| `CLAUDE.md` | Modify | Add new files to key files table, update evolution history |

---

## Chunk 1: Template and Intake Skill

### Task 1: Create SPEC-TEMPLATE.md

**Files:**
- Create: `project-template/docs/SPEC-TEMPLATE.md`

- [ ] **Step 1: Create the spec template**

Write to `project-template/docs/SPEC-TEMPLATE.md`:

```markdown
# {Feature Name} - Spec

**Date:** {YYYY-MM-DD}
**Project:** {project name}

## Goal

{What and why. One paragraph.}

## Scope

**In:** {what's included}

**Out:** {what's explicitly excluded}

## Decisions Made

1. {Decision} - {rationale}
2. {Decision} - {rationale}

{Entries marked [CC default, vs {alternative}] were chosen by CC during
intake when the human had no preference. Review these carefully - they
are reasonable defaults, not human decisions.}

## Constraints

{Feature-specific constraints only. Project-wide constraints live in
CLAUDE.md and don't need repeating here. The top 3-5 items from this
section will be seeded into HANDOFF.md by the workplan skill.}

- {non-negotiable rule}

## Prior Art

- {existing module/file to follow}: {what pattern it demonstrates}

## Dependencies

**Internal:**
- {file/module in this repo}: {what it provides}

**External:**
- {package/API/service}: {what it provides, version if relevant}

## Acceptance Criteria

- {specific testable condition}
- {another testable condition}

## Open Questions

{Empty if all questions resolved during intake. Items listed here are
blockers - workplan generation will not proceed until they are resolved.}
```

- [ ] **Step 2: Verify template has all required sections**

Check against spec acceptance criteria (line 160-162): Goal, Scope (In/Out),
Decisions Made, Constraints, Prior Art, Dependencies (Internal/External),
Acceptance Criteria, Open Questions. Verify `[CC default, vs {alternative}]`
marker is documented. Verify feature-specific-only note in Constraints. Verify
Internal/External split in Dependencies.

- [ ] **Step 3: Commit**

```bash
git add project-template/docs/SPEC-TEMPLATE.md
git commit -m "feat: add spec template for ccloop planning workflow"
```

---

### Task 2: Create project-intake skill

**Files:**
- Create: `project-template/.claude/skills/project-intake/SKILL.md`
- Reference: `project-template/.claude/skills/modular-design/SKILL.md` (structure pattern)
- Reference: `project-template/docs/SPEC-TEMPLATE.md` (output format)
- Reference: `docs/specs/2026-03-16-ccloop-planning-workflow-design.md` (spec, Decisions 1-4, 11)

This is the largest single file. Follow the voice and organisation of
`modular-design/SKILL.md`: frontmatter, When to Use, core content with
clear headings, key behaviours, anti-patterns.

- [ ] **Step 1: Create skill directory**

```bash
mkdir -p project-template/.claude/skills/project-intake
```

- [ ] **Step 2: Write the skill file**

Write to `project-template/.claude/skills/project-intake/SKILL.md`:

````markdown
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
````

- [ ] **Step 3: Verify against acceptance criteria**

Check the skill against spec acceptance criteria (lines 156-180):
- Correct YAML frontmatter (name, description, allowed-tools)
- Five phases present (goal, scope, decisions, constraints, review)
- Scope-aware triage with three tiers and compression rules
- Two kinds of "I don't know" handled distinctly
- `[CC default, vs {alternative}]` marker documented
- Offers to commit, does not auto-commit
- Grounding reads include `docs/plans/`
- Graceful handling of missing project context
- Terminology preservation in Key Behaviours
- CLAUDE.md cross-reference in Phase 4

- [ ] **Step 4: Commit**

```bash
git add project-template/.claude/skills/project-intake/SKILL.md
git commit -m "feat: add project-intake skill for structured feature interviews"
```

---

## Chunk 2: Workplan Generation Skill

### Task 3: Create workplan-generation skill

**Files:**
- Create: `project-template/.claude/skills/workplan-generation/SKILL.md`
- Reference: `project-template/.claude/skills/modular-design/SKILL.md` (structure pattern)
- Reference: `project-template/.claude/skills/testing-patterns/SKILL.md` (testing tiers)
- Reference: `project-template/HANDOFF.md` (seeding template)
- Reference: `docs/specs/2026-03-16-ccloop-planning-workflow-design.md` (spec, Decisions 7-12)

- [ ] **Step 1: Create skill directory**

```bash
mkdir -p project-template/.claude/skills/workplan-generation
```

- [ ] **Step 2: Write the skill file**

Write to `project-template/.claude/skills/workplan-generation/SKILL.md`:

````markdown
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
6. **Existing `WORKPLAN.md`** if present - for multi-phase awareness. If you
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
````

- [ ] **Step 3: Verify against acceptance criteria**

Check the skill against spec acceptance criteria (lines 181-197):
- Correct YAML frontmatter (name, description, allowed-tools)
- Validates spec completeness before generating
- Five specificity rules defined and enforced
- Flags tasks that cannot be made specific (⚠️ PATTERN DECISION)
- Stage gate template with "do NOT continue"
- Stage gates placed at interface boundaries with scaling guidance
- References modular-design and testing-patterns with graceful degradation
- Reads existing WORKPLAN.md for multi-phase awareness
- Seeds HANDOFF.md with constraints from spec
- Output uses `- [ ]` checkbox format
- HANDOFF.md ends with `[/HANDOFF]` sentinel
- Offers to commit, does not auto-commit

- [ ] **Step 4: Commit**

```bash
git add project-template/.claude/skills/workplan-generation/SKILL.md
git commit -m "feat: add workplan-generation skill for ccloop-compatible task planning"
```

---

## Chunk 3: Deployment, Documentation, and Validation

### Task 4: Modify setup.sh

**Files:**
- Modify: `setup.sh:406-419` (init mode docs deployment)
- Modify: `setup.sh:212-291` (update mode - add docs template deployment)

- [ ] **Step 1: Run baseline dry-run to see current behaviour**

```bash
./setup.sh --dry-run /tmp/test-planning-workflow
```

Note: `/tmp/test-planning-workflow` should not exist yet. Create it first:
```bash
mkdir -p /tmp/test-planning-workflow
```

Record what files are currently deployed to docs/.

- [ ] **Step 2: Add docs/plans/.gitkeep creation to init mode**

In setup.sh, after the `mkdir -p "$TARGET/docs"` line (around line 408),
add creation of the plans subdirectory and .gitkeep:

```bash
# Create docs/plans/ directory for spec documents
if ! $DRY_RUN; then
    mkdir -p "$TARGET/docs/plans"
fi
if [ ! -f "$TARGET/docs/plans/.gitkeep" ]; then
    if $DRY_RUN; then
        echo "   Would create: docs/plans/.gitkeep"
    else
        touch "$TARGET/docs/plans/.gitkeep"
        echo "   Created: docs/plans/.gitkeep"
    fi
else
    echo "   Exists:  docs/plans/.gitkeep (skipped)"
fi
```

- [ ] **Step 3: Add SPEC-TEMPLATE.md deployment to init mode**

After the MODULE-README-TEMPLATE.md copy block (around line 419), add the
same pattern for SPEC-TEMPLATE.md:

```bash
if [ ! -f "$TARGET/docs/SPEC-TEMPLATE.md" ]; then
    if $DRY_RUN; then
        echo "   Would create: docs/SPEC-TEMPLATE.md"
    else
        cp "$SCRIPT_DIR/project-template/docs/SPEC-TEMPLATE.md" "$TARGET/docs/SPEC-TEMPLATE.md"
        echo "   Created: docs/SPEC-TEMPLATE.md"
    fi
else
    echo "   Exists:  docs/SPEC-TEMPLATE.md (skipped)"
fi
```

- [ ] **Step 4: Add docs template deployment to update mode**

In the update mode section, insert after the agents loop closing `done`
(line 288) and before the final echo messages (line 290). This is inside
the `if $UPDATE_MODE` block. Add deployment for both `docs/plans/.gitkeep`
and `SPEC-TEMPLATE.md`:

```bash
# Create docs/plans/ directory and templates
if ! $DRY_RUN; then
    mkdir -p "$TARGET/docs/plans"
fi
if [ ! -f "$TARGET/docs/plans/.gitkeep" ]; then
    if $DRY_RUN; then
        echo "   Would create: docs/plans/.gitkeep"
    else
        touch "$TARGET/docs/plans/.gitkeep"
        echo "   Created: docs/plans/.gitkeep"
    fi
fi

# Deploy docs templates (create-if-missing)
for doc_template in MODULE-README-TEMPLATE.md SPEC-TEMPLATE.md; do
    if [ ! -f "$TARGET/docs/$doc_template" ]; then
        if [ -f "$SCRIPT_DIR/project-template/docs/$doc_template" ]; then
            if $DRY_RUN; then
                echo "   Would create: docs/$doc_template"
            else
                cp "$SCRIPT_DIR/project-template/docs/$doc_template" "$TARGET/docs/$doc_template"
                echo "   Created: docs/$doc_template"
            fi
        fi
    fi
done
```

Note: update mode currently has no docs template deployment. This loop
handles both MODULE-README-TEMPLATE.md and SPEC-TEMPLATE.md with
create-if-missing semantics. Adding MODULE-README-TEMPLATE.md to update
mode is a minor enhancement beyond spec scope but follows naturally from
the loop pattern.

- [ ] **Step 5: Verify with dry-run**

```bash
./setup.sh --dry-run /tmp/test-planning-workflow
```

Expected output should include:
- `Would create: docs/plans/.gitkeep`
- `Would create: docs/SPEC-TEMPLATE.md`

Also test update mode:
```bash
./setup.sh --update --dry-run /tmp/test-planning-workflow
```

- [ ] **Step 6: Run actual deployment and verify**

```bash
rm -rf /tmp/test-planning-workflow && mkdir -p /tmp/test-planning-workflow
./setup.sh /tmp/test-planning-workflow
```

Verify:
```bash
ls /tmp/test-planning-workflow/docs/plans/.gitkeep
ls /tmp/test-planning-workflow/docs/SPEC-TEMPLATE.md
ls /tmp/test-planning-workflow/.claude/skills/project-intake/SKILL.md
ls /tmp/test-planning-workflow/.claude/skills/workplan-generation/SKILL.md
```

All four files should exist. The two skills come free from the existing
skill deployment loop - no setup.sh changes needed for them.

- [ ] **Step 7: Commit**

```bash
git add setup.sh
git commit -m "feat: deploy SPEC-TEMPLATE.md and docs/plans/ in setup.sh init and update modes"
```

---

### Task 5: Update README.md

**Files:**
- Modify: `README.md:7-43` (project tree)
- Modify: `README.md:109-122` (skills descriptions)

- [ ] **Step 1: Update the project tree**

The existing tree shows skill directories without filenames (e.g.,
`testing-patterns/SKILL.md`). Match the existing format exactly. Add:

Under `project-template/docs/`: change the existing `└──` on
MODULE-README-TEMPLATE.md to `├──` (it is no longer the last child),
then add SPEC-TEMPLATE.md as the new last entry with `└──`:
```
│   │   ├── MODULE-README-TEMPLATE.md  - Module contract template
│   │   └── SPEC-TEMPLATE.md           - Feature spec template (intake → workplan)
```

Under `project-template/.claude/skills/`: add the two new entries before
or after the existing skills. Adjust `└──`/`├──` connectors so the last
skill in the list uses `└──` and all others use `├──`:
```
│       │   ├── project-intake/SKILL.md
│       │   ├── workplan-generation/SKILL.md
```

- [ ] **Step 2: Add skill descriptions**

After the existing skills descriptions (around line 118), add:

```markdown
**project-intake:** Structured interview for capturing feature specs. Five phases (goal, scope, decisions, constraints, review) with scope-aware triage. Produces standard spec documents in `docs/plans/`.

**workplan-generation:** Converts spec documents into ccloop-compatible WORKPLAN.md with specific, file-level tasks. Validates spec completeness, classifies tasks by module role, places stage gates at interface boundaries. Seeds HANDOFF.md with constraints.
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add planning workflow skills to README tree and descriptions"
```

---

### Task 6: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md` (key files table, evolution history)

- [ ] **Step 1: Add new files to key files table**

Add three entries to the key files table:

```markdown
| project-template/docs/SPEC-TEMPLATE.md | Feature spec template (contract between intake and workplan skills) |
| project-template/.claude/skills/project-intake/SKILL.md | Structured interview producing spec documents |
| project-template/.claude/skills/workplan-generation/SKILL.md | Spec-to-WORKPLAN converter for ccloop execution |
```

- [ ] **Step 2: Add evolution history entry**

Add entry 6 to the "How It Evolved" section:

```markdown
6. **ccloop Planning Workflow (2026-03-16):** Added project-intake skill (structured interview with scope-aware triage, five phases, two-kind "I don't know" handling) and workplan-generation skill (spec validation, five specificity rules, stage gates, HANDOFF seeding). New SPEC-TEMPLATE.md as contract between skills. Updated setup.sh to deploy template and `docs/plans/` directory. Evidence: SparkCore Phase 2 (17 tasks, 195 tests, 53 minutes, 6 human commands) proved specific task descriptions are the key differentiator for autonomous execution quality.
```

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md key files and evolution history for planning workflow"
```

---

### Task 7: Final Validation

- [ ] **Step 1: Run full deployment test**

```bash
rm -rf /tmp/test-planning-final && mkdir -p /tmp/test-planning-final
./setup.sh /tmp/test-planning-final
```

- [ ] **Step 2: Verify all new files deployed**

```bash
# Template
test -f /tmp/test-planning-final/docs/SPEC-TEMPLATE.md && echo "PASS: SPEC-TEMPLATE.md" || echo "FAIL"
test -f /tmp/test-planning-final/docs/plans/.gitkeep && echo "PASS: docs/plans/.gitkeep" || echo "FAIL"

# Skills
test -f /tmp/test-planning-final/.claude/skills/project-intake/SKILL.md && echo "PASS: project-intake" || echo "FAIL"
test -f /tmp/test-planning-final/.claude/skills/workplan-generation/SKILL.md && echo "PASS: workplan-generation" || echo "FAIL"

# Existing files still deployed
test -f /tmp/test-planning-final/.claude/skills/modular-design/SKILL.md && echo "PASS: modular-design" || echo "FAIL"
test -f /tmp/test-planning-final/.claude/skills/testing-patterns/SKILL.md && echo "PASS: testing-patterns" || echo "FAIL"
test -f /tmp/test-planning-final/docs/MODULE-README-TEMPLATE.md && echo "PASS: MODULE-README-TEMPLATE" || echo "FAIL"
```

All should print PASS.

- [ ] **Step 3: Verify update mode creates missing new files**

Create a project without the new files to test the meaningful update path:
```bash
rm -rf /tmp/test-update && mkdir -p /tmp/test-update/.claude/skills /tmp/test-update/docs
touch /tmp/test-update/.claude/settings.json
echo '{}' > /tmp/test-update/.claude/settings.json
./setup.sh --update /tmp/test-update
```

Verify the new files were created:
```bash
test -f /tmp/test-update/docs/plans/.gitkeep && echo "PASS: plans/.gitkeep via update" || echo "FAIL"
test -f /tmp/test-update/docs/SPEC-TEMPLATE.md && echo "PASS: SPEC-TEMPLATE via update" || echo "FAIL"
```

Clean up: `rm -rf /tmp/test-update`

- [ ] **Step 4: Verify update mode skips existing files**

```bash
./setup.sh --update --dry-run /tmp/test-planning-final
```

Should show "Exists" or "No new" for all files (since they were just created
by the init test).

- [ ] **Step 5: Verify idempotency - re-running init skips existing files**

```bash
./setup.sh --dry-run /tmp/test-planning-final
```

All new files should show "Exists: ... (skipped)".

- [ ] **Step 6: Verify README.md and CLAUDE.md documentation updates**

```bash
# README: new entries in tree
grep -c "SPEC-TEMPLATE" README.md && echo "PASS: SPEC-TEMPLATE in README tree" || echo "FAIL"
grep -c "project-intake" README.md && echo "PASS: project-intake in README" || echo "FAIL"
grep -c "workplan-generation" README.md && echo "PASS: workplan-generation in README" || echo "FAIL"

# CLAUDE.md: key files table entries
grep -c "SPEC-TEMPLATE" CLAUDE.md && echo "PASS: SPEC-TEMPLATE in CLAUDE.md" || echo "FAIL"
grep -c "project-intake" CLAUDE.md && echo "PASS: project-intake in CLAUDE.md" || echo "FAIL"
grep -c "workplan-generation" CLAUDE.md && echo "PASS: workplan-generation in CLAUDE.md" || echo "FAIL"

# CLAUDE.md: evolution history entry 6
grep -c "ccloop Planning Workflow" CLAUDE.md && echo "PASS: evolution entry in CLAUDE.md" || echo "FAIL"
```

- [ ] **Step 7: Verify skill frontmatter is valid YAML**

```bash
head -5 project-template/.claude/skills/project-intake/SKILL.md
head -5 project-template/.claude/skills/workplan-generation/SKILL.md
```

Both should show `---` delimiters with name, description, allowed-tools.

- [ ] **Step 8: Spot-check spec template sections**

```bash
grep "^## " project-template/docs/SPEC-TEMPLATE.md
```

Expected output:
```
## Goal
## Scope
## Decisions Made
## Constraints
## Prior Art
## Dependencies
## Acceptance Criteria
## Open Questions
```

- [ ] **Step 9: Clean up test directory**

```bash
rm -rf /tmp/test-planning-final /tmp/test-planning-workflow
```
