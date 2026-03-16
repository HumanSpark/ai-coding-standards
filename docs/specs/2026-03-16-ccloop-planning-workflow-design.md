# ccloop Planning Workflow - Design Spec

**Date:** 2026-03-16
**Project:** ai-coding-standards + ccloop (cross-repo)
**Status:** Approved

## Goal

Standardise the path from "I have an idea" to "ccloop run" into two
repeatable skills and a spec format that bridges them. The bottleneck in
ccloop v4 is not execution (SparkCore proved that works) but planning -
writing the spec, producing the WORKPLAN, seeding the HANDOFF. This cuts
planning time from hours of ad hoc conversation to ~25 minutes of structured
decision-making.

## Scope

**In:**
- project-intake skill (structured interview, produces spec)
- workplan-generation skill (consumes spec, produces WORKPLAN.md + HANDOFF.md)
- SPEC-TEMPLATE.md (contract between the two skills)
- setup.sh changes to deploy the template and `docs/plans/` directory
- README.md and CLAUDE.md updates for documentation
- ccloop-side changes documented but not implemented here

Note: both setup.sh (this repo) and ccloop init (separate repo) create
`docs/plans/`. This is intentional belt-and-suspenders - the directory
exists from project birth via setup.sh, and ccloop init ensures it for
projects that weren't initialised with the latest standards.

**Out:**
- Changes to ccloop bash script (separate repo, separate work)
- Espanso snippets (ccloop repo)
- Changes to existing skills (modular-design, testing-patterns)
- Automated testing (these are SKILL.md files, validated manually)

## Decisions Made

1. **Sequential phases, flexible within each** for intake interview - CC runs
   phases in order (goal, scope, decisions, constraints, review) but adapts
   within each phase to what the human volunteers. Balances reliability with
   conversational naturalness. [CC default, vs strict sequential] - strict
   sequential felt robotic; fully flexible risks missing things.

2. **Scope-aware triage at start of intake** - three tiers (small/medium/large)
   determine interview depth. Small compresses Phases 3-4 to one question
   each. Medium runs Phases 1-2 fully, compresses Phase 3 to genuine decision
   points, skips Phase 4 if CLAUDE.md covers conventions. Large gets full
   treatment.

3. **Two kinds of "I don't know" in Phase 3** - "No preference, you pick"
   results in CC choosing a default documented as `[CC default, vs {runner-up}]`
   in Decisions Made. "I haven't thought about this" goes into Open Questions
   as a blocker. CC distinguishes by asking: "Do you want me to pick something
   reasonable here, or is this something you need to think through?"

4. **No auto-commit in either skill** - both skills offer to commit after
   saving output. Human confirms. Prevents premature "this is decided" signals
   for specs that need sleeping on.

5. **Acceptance criteria use plain bullets in spec, checkboxes in WORKPLAN** -
   the spec says what done looks like; the workplan says what to do. Different
   documents, different formats. Reinforces the boundary.

6. **Spec versioning via git, not in-document** - edits between intake and
   workplan generation show up in `git diff`. No revision tracking in the
   document itself.

7. **Workplan skill validates spec before generating** - fails fast if required
   sections are missing or Open Questions has unresolved items. Empty Open
   Questions section = passing state. Missing section = failing state.

8. **Graceful degradation for skill dependencies** - workplan skill references
   modular-design for task classification and testing-patterns for tier
   assignment. If either skill is absent, CC skips that classification and
   notes it was skipped. Keeps the skill useful across projects at different
   maturity levels.

9. **Stage gates at interface boundaries** - placed after infrastructure/models,
   after core logic, after integration, and after any task that introduces an
   external dependency or changes an interface other tasks consume. Scaling
   guidance: small features (under 8 tasks) get one gate at the end; medium
   features (8-15 tasks) get two gates (after foundation, after core logic);
   large features (15+ tasks) get three or more (after models/infra, after
   core logic, after integration). These ranges are advisory - CC uses
   judgement based on where interface boundaries actually fall in the
   specific workplan.

10. **Constraints seeded into HANDOFF.md** - top 3-5 feature-specific
    constraints from the spec are included in the HANDOFF seed. ccloop reads
    HANDOFF.md every iteration but doesn't re-read the spec, so constraints
    need to be where CC sees them. The workplan skill writes a fresh
    HANDOFF.md (replacing any existing content), since it's setting up for a
    new execution phase. Any in-progress session state in an existing
    HANDOFF.md is superseded by the new workplan.

11. **Feature-specific constraints only in spec** - project-wide constraints
    live in CLAUDE.md. The spec's Constraints section does not repeat them.
    Intake Phase 4 cross-references CLAUDE.md to enforce this.

12. **Internal/external dependency split in spec template** - internal deps
    (files/modules in the repo) get read during workplan grounding. External
    deps (APIs, packages, services) may need setup tasks in the workplan.
    The template distinguishes them.

## Constraints

- Spec format is frozen once published. Both skills depend on it. Changing a
  section name means updating both skills.
- WORKPLAN.md format must match ccloop v4.2.0 expectations: `- [ ]` checkboxes,
  HANDOFF.md ending with `[/HANDOFF]` sentinel. The existing HANDOFF.md
  template does not include the sentinel - the workplan skill appends it
  when seeding HANDOFF.md, not the template.
- Stage gates interact with ccloop stuck detection (3 no-commit iterations =
  stop). This is correct behaviour. Do not work around it.
- Skills live in `project-template/` and are deployed by setup.sh. They must
  work for both mature repos and brand-new projects.
- CC must not introduce terminology that conflicts with existing codebase terms.
  Grounding reads catch this; the intake skill reinforces it as explicit
  behaviour.

## Prior Art

- `project-template/.claude/skills/modular-design/SKILL.md`: structure for a
  substantial skill with When to Use, structural patterns, checklists, and
  anti-patterns. The two new skills follow the same voice and organisation.
- `project-template/.claude/skills/testing-patterns/SKILL.md`: structure for
  a shorter skill. Shows how frontmatter, tiers, and checklists work together.
- `project-template/.claude/agents/code-reviewer.md`: agent frontmatter format.
  Skills use a slightly different format (name, description, allowed-tools).
- `project-template/HANDOFF.md`: the HANDOFF template that workplan-generation
  seeds. Five fields: current task, last action, next action, key files, context.
- SparkCore Phase 2 build: 17 tasks, 195 tests, 53 minutes, 6 human commands.
  Proved that specific task descriptions (naming files, fixtures, patterns,
  types, criteria) are the key differentiator for autonomous execution quality.

## Dependencies

**Internal:**
- `setup.sh`: deployment mechanism for templates and skills
- `project-template/.claude/skills/modular-design/SKILL.md`: referenced by
  workplan skill for task classification (graceful degradation if absent)
- `project-template/.claude/skills/testing-patterns/SKILL.md`: referenced by
  workplan skill for tier assignment (graceful degradation if absent)
- `project-template/HANDOFF.md`: template for HANDOFF seeding
- `README.md`: project tree and skill descriptions
- `CLAUDE.md`: key files table

**External:**
- ccloop v4.2.0: consumes WORKPLAN.md and HANDOFF.md. No changes needed to
  ccloop for this work. Separate-repo changes (docs/plans/ in ccloop init,
  README update, Espanso snippets) documented here but implemented separately.

## Acceptance Criteria

- Skill file exists at `project-template/.claude/skills/project-intake/SKILL.md`
  with correct YAML frontmatter (name, description, allowed-tools)
- Skill file exists at `project-template/.claude/skills/workplan-generation/SKILL.md`
  with correct YAML frontmatter
- Template exists at `project-template/docs/SPEC-TEMPLATE.md` with all
  sections: Goal, Scope (In/Out), Decisions Made, Constraints, Prior Art,
  Dependencies (Internal/External), Acceptance Criteria, Open Questions
- Intake skill covers all five phases (goal, scope, decisions, constraints,
  review) with scope-aware triage (small/medium/large)
- Intake skill compresses interview depth per triage tier: small compresses
  Phases 3-4 to one question each; medium runs Phases 1-2 fully, compresses
  Phase 3 to genuine decision points, skips Phase 4 if CLAUDE.md has
  non-placeholder content in conventions-relevant sections (Key Patterns,
  Things to Watch Out For, or equivalent); large gets full treatment
- Intake skill handles two kinds of "I don't know" distinctly
- Intake skill marks CC-chosen defaults as `[CC default, vs {alternative}]`
- Intake skill offers to commit but does not auto-commit
- Intake skill reads existing `docs/plans/` specs during grounding
- Intake skill handles missing project context gracefully: if CLAUDE.md is
  absent or contains only template placeholders, CC notes the spec is
  ungrounded, skips cross-referencing steps, and flags in the output that
  grounding reads were unavailable
- Intake skill preserves existing codebase terminology
- Intake skill cross-references CLAUDE.md during Phase 4 to prevent
  duplicating project-wide constraints in the spec
- Workplan skill validates spec completeness before generating
- Workplan skill enforces all five specificity rules:
  1. **File:** every task names the file it creates or modifies
  2. **Fixture:** test tasks name the fixture file to use or create
  3. **Pattern:** tasks that follow an existing pattern name the file to follow
  4. **Type:** tasks that add data structures name the type and its fields
  5. **Criterion:** every task has a verifiable done condition (e.g. "make check
     passes with 20+ new tests")
- Workplan skill flags tasks it cannot make specific as pattern decisions
- Workplan skill includes stage gate template with explicit "do NOT continue"
- Workplan skill places stage gates at interface boundaries
- Workplan skill references modular-design and testing-patterns skills with
  graceful degradation
- Workplan skill reads existing WORKPLAN.md for multi-phase awareness
- Workplan skill seeds HANDOFF.md with constraints from spec
- Workplan output uses `- [ ]` checkbox format compatible with ccloop
- HANDOFF.md output ends with `[/HANDOFF]` sentinel
- `setup.sh` deploys SPEC-TEMPLATE.md alongside MODULE-README-TEMPLATE.md
  in both init and update modes (same create-if-missing, skip-if-exists
  pattern as all other template files)
- `setup.sh` creates `docs/plans/.gitkeep` in both init and update modes
- README.md tree updated with new files (matching existing tree format)
- README.md skills section describes both new skills
- CLAUDE.md key files table updated with new template files

## Open Questions

None. All design decisions resolved during brainstorming.

---

## Appendix: ccloop-Side Changes (separate implementation)

These changes live in the ccloop repo and are not part of this implementation:

- `ccloop init` creates `docs/plans/` directory if it doesn't exist
- ccloop README references the planning workflow
- Espanso snippet `:ccintake` triggers the intake skill
- Espanso snippet `:ccworkplan` triggers WORKPLAN generation

---

## Appendix: Spec Template (for reference)

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
intake when the human had no preference.}

## Constraints
{Feature-specific constraints only. Project-wide constraints live in
CLAUDE.md and don't need repeating here.}
- {non-negotiable rule}

## Prior Art
- {existing module to follow}: {what pattern it demonstrates}

## Dependencies
**Internal:**
- {file/module}: {what it provides}

**External:**
- {package/API/service}: {what it provides, version if relevant}

## Acceptance Criteria
- {specific testable condition}

## Open Questions
{Empty if all questions resolved. Items here are blockers for workplan
generation.}
```
