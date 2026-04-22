# {Feature Name} - Spec

**Date:** {YYYY-MM-DD}
**Project:** {project name}

**Why:** {One sentence on why this exists. What problem is it solving, what
broke, what did a human/customer/stakeholder ask for. Required by Rule 4.9.}

**Trigger:** {Link to the source: rejection email, incident, build log,
chat message, commit, or issue. Required by Rule 4.9. Pre-commit hook
blocks specs missing this line.}

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
