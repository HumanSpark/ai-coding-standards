# AI-Specific Design Constraints - Design Spec

**Date:** 2026-03-18
**Status:** Draft
**Scope:** Small - two files changed, no code

## Goal

Add explicit AI-specific design constraints to the HumanSpark engineering
standards. Human coding best practices and LLM coding best practices diverge
in specific, predictable ways. This change makes that divergence visible to
human readers (reference doc) and enforces tighter guardrails for LLM agents
(user-level CLAUDE.md).

## Scope

**In:**
- New Section 13 in `reference/humanspark-engineering-standards-v1.md`
  (human-facing, AI Rationale format)
- Tightened rules in `user-level/CLAUDE.md` (LLM-facing, three additions
  offset by tightening pass to stay token-neutral)

**Out:**
- Espanso prompts (separate workflow, not repo content)
- CQS as a standalone rule (already covered by module-level separation and
  error handling; no project evidence of CQS violations)
- Project-template changes (these are universal rules, not project-specific)
- New skills or rules files

## Decisions Made

1. Use Approach C: integrate constraints into existing user-level sections
   (not a new standalone section) and tighten wording to stay token-neutral.
   Rationale: the LLM doesn't benefit from knowing a rule is "AI-specific" -
   it just needs sharp rules in the right place.

2. Drop CQS as a standalone constraint. The module design already enforces
   separation at the architecture level (processors are pure, clients handle
   I/O). Strict method-level CQS fights Python's standard library. The "fail
   fast" half is already covered by mandatory error hints. Mention CQS briefly
   in the reference doc section intro as context for module role design.

3. Reference doc uses hybrid format: existing numbered rule convention
   (13.1, 13.2, 13.3) with The Rule / The AI Rationale structure inside each
   rule. This preserves the document's skeleton while highlighting the
   human-vs-AI contrast that makes this section valuable.

4. Fail Fast gets a sentence in the reference doc section intro rather than
   its own rule. Already covered by Section 4.4 (error handling) and
   user-level error hints mandate. The AI-specific angle (LLMs silently
   swallow errors to be "helpful") is worth noting but doesn't need a full
   rule.

5. Three additions to user-level CLAUDE.md, placed in existing sections:
   - Anti-abstraction / Rule of Three → Code Style
   - Composition over inheritance → Module Design (fourth hard rule)
   - Strict scope → Development

## Constraints

- User-level CLAUDE.md token count must stay flat or decrease after changes.
  Currently ~2,000 tokens (~1,450 words). Additions (~60 words) offset by
  tightening pass (~50+ words saved).
- Reference doc follows existing numbered convention (Section 13, Rules
  13.1-13.3).
- All rules must be traceable to evidence or observed AI failure modes, per
  the repo's design philosophy.

## Prior Art

- Existing user-level CLAUDE.md sections: Code Style, Module Design,
  Development
- Reference doc Sections 4 (Code Style), 5 (Security), 12 (Modular Design)
- Claude Code system prompt "Avoid over-engineering" text (not user-controlled,
  cannot be relied on as stable)

## Dependencies

- None. Both target files exist and are stable.

## Acceptance Criteria

1. Reference doc has Section 13 "AI-Specific Design Constraints" with rules
   13.1, 13.2, 13.3 using The Rule / The AI Rationale format.
2. User-level CLAUDE.md has three new/sharpened rules in existing sections.
3. User-level CLAUDE.md word count is <= 1,450 words (current baseline).
4. No duplication between the new rules and existing content in either file.
5. `setup.sh` still deploys cleanly (no structural changes to template files).

## Open Questions

None.

## Deliverable 1: Reference Doc Section 13

New section after Section 12 (Modular Design), before Appendix A.

### Section intro

One paragraph: human and AI coding standards diverge. Some principles that
make humans better (anticipating future needs, opportunistic refactoring)
cause LLMs to hallucinate, waste tokens, bloat context, or introduce scope
creep. These constraints address specific LLM failure modes. Brief mention
of Fail Fast angle (LLMs silently swallow errors) as context, not a rule.

### 13.1 Avoid Hasty Abstractions (Rule of Three)

**The Rule:** Do not build generic, highly abstracted factory classes or
interfaces for a single use case. Wait until code has been duplicated at
least three times before refactoring into a shared abstraction.

**The AI Rationale:** LLMs tend to over-engineer and predict future feature
needs that do not exist. Premature abstraction burns tokens, complicates the
context window, and makes future prompt-driven modifications unnecessarily
difficult.

### 13.2 Composition Over Inheritance

**The Rule:** Build complex objects by combining simple, flat, plug-and-play
functions and classes. Deep OO inheritance trees (e.g.,
`BaseUser -> PaidUser -> AdminUser`) are prohibited.

**The AI Rationale:** Deep inheritance destroys an LLM's context window. It
forces the AI to open and hold multiple files in memory to understand or
modify a single inherited method. Flat, composed code is significantly more
CC-efficient.

### 13.3 Strict Scope (Anti-Boy Scout Rule)

**The Rule:** Fix exactly what is outlined in the HANDOFF.md or the immediate
prompt. Do not opportunistically refactor, reformat, or "clean up" adjacent
code just because you are touching the file.

**The AI Rationale:** Telling an AI agent to "leave the code cleaner than you
found it" results in massive, unrelated diffs. Scope creep is fatal in
AI-assisted development; agents must execute the exact task specified and
nothing more.

## Deliverable 2: User-Level CLAUDE.md Tightening

### Addition 1: Code Style section - new bullet after "File size"

```markdown
- **Abstraction:** Do not abstract until code has been duplicated three times.
  Three similar lines is better than a premature abstraction. Never build
  generic factories or interfaces for a single use case.
```

### Addition 2: Module Design section - fourth hard rule

Update heading from "**Three hard rules:**" to "**Four hard rules:**" and add:

```markdown
4. Composition over inheritance. No deep inheritance trees. Build complex
   behaviour by combining simple, flat functions and classes.
```

### Addition 3: Development section - new bullet

```markdown
- **Strict scope.** Fix exactly what the task specifies. Do not
  opportunistically refactor, reformat, or "clean up" adjacent code while
  working on a task.
```

### Tightening pass

Concrete edits to offset additions (~75 words added, ~85 words saved):

1. **Error hints** (lines 70-80): Remove "The technical detail (exit codes,
   HTTP status, stderr) stays; the hint tells a non-technical user what to
   actually do about it. Write the hint at the raise site where you have the
   most context about what went wrong." Replace with "Write hints at the
   raise site where you have most context." Also remove the 4-line code
   example (lines 75-79) - the rule text is clear without it, and
   `models.py` template already demonstrates the HintedError pattern.
   Saves ~55 words total.

2. **Module Design intro** (lines 99-100): "For projects with 3+ source
   files and distinct responsibilities, apply modular structure. Full
   conventions in..." → "For projects with 3+ source files. Full conventions
   in..." Saves ~5 words.

3. **Placeholders section** (lines 119-129): Remove the 4-line code example
   (the concept is clear without it). Keep the rule text and TODO/NOTE
   distinction. Saves ~25 words.

**Fallback areas** if above falls short:
- Type hints bullet: "Mandatory on all public function signatures, method
  signatures, and module boundaries" → "Mandatory on public signatures and
  module boundaries" (~5 words)
- Linting bullet: drop "Configure in `pyproject.toml`." (~3 words)

Commitment: net word count <= 1,450 (current baseline).
