# {Project Name}

{One sentence: what it is, who it's for, where it runs.}

## Design Philosophy

{What does "good" look like for this project? Define the quality standard in terms the AI can apply to every decision.}

**Keep strict:** {Non-negotiable constraints - security, data formats, API contracts}

**Free to adapt:** {Areas where any approach that meets the quality bar is acceptable}

## How It Evolved

{Numbered chronological entries. Add new entries, never edit old ones.}

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

## Key Files

| File | What it does |
|------|-------------|
| {file} | {one-line description} |

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

- Conventional commits: feat/fix/docs/refactor/test/chore
- NEVER include Co-Authored-By in commit messages
- Work on main only
