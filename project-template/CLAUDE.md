# {Project Name}
<!-- ~NNNN tokens — budget: {2000 small | 4000 medium | 6000 large} -->
<!-- This file is for LLMs. Humans read README.md. -->
<!-- Personal preferences go in CLAUDE.local.md (gitignored). -->

{One sentence: what it is, who it's for, where it runs.}

## Design Philosophy

{What does "good" look like for this project? Define the quality standard in terms the AI can apply to every decision.}

**Keep strict:** {Non-negotiable constraints - security, data formats, API contracts}

**Free to adapt:** {Areas where any approach that meets the quality bar is acceptable}

## How It Evolved

{Numbered entries. When this section exceeds ~5 entries, move older phases to docs/HISTORY.md and keep a summary here.}

1. **{Phase/Feature Name} ({date}):** {What was built, key design decisions, test count. Reference design doc if one exists.}

## Build & Run

```bash
{Primary build/install command}
{Primary run command}
{Common flags or modes}
```

## Testing

```bash
{Test command with approximate count}
{Any separate test suites (e.g. prompt reliability)}
```

## Architecture

{ASCII component diagram if multi-component}

Key flow: **{step -> step -> step}**

{Brief description of data flow or processing pipeline}

**Module contracts:** Each module's `README.md` describes its purpose, public
interface, dependencies, and known issues. See `docs/MODULE-README-TEMPLATE.md`
for the format.

**Shared types:** `src/projectname/models.py` defines the data structures that
flow between modules. `src/projectname/config.py` defines typed configuration.

## Key Files

| File | What it does |
|------|-------------|
| {file} | {one-line description} |
| docs/MODULE-README-TEMPLATE.md | Template for module contract READMEs |
| src/{projectname}/models.py | Shared data structures (frozen dataclasses) |
| src/{projectname}/config.py | Typed configuration with from_env() |

## Security Boundaries

- {What the system CANNOT do}
- {Read-only data sources}
- {Rate/length limits}
- {Where secrets live}

## Key Patterns

- {Non-obvious implementation detail}
- {Edge case handling}
- {Integration gotcha}

## Things to Watch Out For

- {Convention that's easy to break}
- {Format/encoding rule}
- {Dependency quirk}

## Git Conventions

- Conventional commits: feat/fix/docs/refactor/test/chore/ux
- NEVER include Co-Authored-By in commit messages
- Work on main only
