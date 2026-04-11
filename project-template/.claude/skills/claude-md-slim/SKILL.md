---
name: claude-md-slim
description: Shrink a bloated CLAUDE.md by extracting knowledge-dump content into load-on-demand files and rewriting the always-loaded file as a thin routing layer. Use when the user says "CLAUDE.md is too big", "clean up CLAUDE.md", "slim CLAUDE.md", "reduce CLAUDE.md tokens", or when a CLAUDE.md clearly exceeds its token budget (>2k small / >4k medium / >6k large). Complementary to claude-md-improver which handles the opposite problem (sparse files that need additions).
allowed-tools: Read, Glob, Grep, Bash, Edit, Write
---

# claude-md-slim

Shrink a bloated CLAUDE.md by moving content into load-on-demand files and rewriting the always-loaded file as a **thin routing layer**.

This skill solves the *overfed* CLAUDE.md problem: the file has grown into a knowledge dump, every section costs tokens on every turn, and most of it isn't needed for most tasks. The companion skill `claude-md-improver` handles the opposite problem (sparse files that need additions) — don't use this skill for that.

## Core mental model

**CLAUDE.md is a routing layer, not a knowledge dump.** It should answer two questions and nothing else:

1. *What kind of assistant am I on this project?* (identity, non-negotiable rules, design philosophy)
2. *Where should I look next?* (routing table pointing to docs, skills, code locations)

Everything else is load-on-demand. If a section only matters when doing one specific class of task, it doesn't belong in the always-loaded file.

**The litmus test for every paragraph:** *would removing this only hurt one task type?* If yes, it belongs in a subsystem doc, a skill, or `docs/HISTORY.md`, not CLAUDE.md.

## Token budgets

From `claude-md-discipline`:

- Small projects: **< 2,000 tokens**
- Medium projects: **< 4,000 tokens**
- Large projects: **< 6,000 tokens**

Aggressive routing-layer targets (preferred when there are rich load-on-demand docs available):

- Small: ~800 - 1,500 tokens
- Medium: ~1,500 - 2,500 tokens
- Large: ~2,000 - 3,500 tokens

Rough token estimate: `word_count × 1.4` or `byte_count / 4`. `wc -w <file>` is fine for a working estimate.

## Workflow

### Phase 1: Measure

```bash
wc -l -w -c CLAUDE.md
```

Multiply words by ~1.4 for a rough token count. If the file is under budget for its project size (small/medium/large), tell the user the size and ask whether they want to slim further or stop.

**Also find sibling files** that are always-loaded alongside CLAUDE.md:

```bash
find . -name "CLAUDE.md" -o -name "CLAUDE.local.md" 2>/dev/null
find . -type d -name ".claude" -exec ls {}/rules/ 2>/dev/null \;
```

Rules files in `.claude/rules/*.md` are also always-loaded — they count against your working memory budget too.

### Phase 2: Scan for existing load-on-demand homes

**This is the most important phase and the easiest to skip.** Before planning any new files, discover what docs already exist that could absorb moving content:

```bash
ls docs/ 2>/dev/null
ls .claude/skills/ 2>/dev/null
find docs -name "*.md" -type f | head -30
```

For each likely candidate (`docs/CANVAS-REFERENCE.md`, `docs/REFERENCE-GOTCHAS.md`, `docs/ARCHITECTURE.md`, `docs/HISTORY.md`, `docs/<subsystem>.md`), **read its contents** to understand what it already covers. A section of CLAUDE.md that looks like it needs a new home may already have one.

*Why this matters:* In the sparkforge cleanup that grounds this skill, the first plan was to create a new `docs/REFERENCE-GOTCHAS.md` to hold subsystem edge cases. Reading the existing `CANVAS-REFERENCE.md` revealed it already covered ~90% of those same gotchas — creating the new file would have duplicated content and made maintenance worse. The correct move was to just *delete* the duplicates from CLAUDE.md and point at the existing doc.

**Rule:** Prefer existing docs over creating new ones. Only create a new file when no existing home can absorb the content.

### Phase 3: Classify every section

Walk CLAUDE.md top to bottom. For each section (heading or bullet group), decide which bucket it belongs to:

**Stays in CLAUDE.md:**

- **Identity:** project name, one-paragraph description, design philosophy, values, quality bar
- **Non-negotiable rules:** "never do X", "always do Y", behavioural constraints that apply on every turn regardless of task (e.g. "always use `./venv/bin/python3`", "never read images ≥ 2000px")
- **Routing:** capability index, module map, "where should I look next" table, key flow diagram if small
- **Build/test essentials:** the 2-5 commands someone runs most often, plus pointers to `--help` or README for the rest
- **Security boundaries:** gitignored paths, credential locations, what the system can and cannot do — especially the "cannot" side (defensive posture constraints)
- **Recent phases:** last 3-5 evolution entries as a "what's happening now" signal. Full log moves out.

**Moves out (subsystem / reference / workflow):**

- **Subsystem-specific gotchas:** CSS quirks, templating edge cases, library-specific behaviour — go to existing `docs/CANVAS-REFERENCE.md` / `docs/REFERENCE-GOTCHAS.md` or equivalent
- **Workflow-specific procedures:** "after running X, always do Y classification pass" — goes to a skill or docs/workflows/
- **Reference data:** lists of layout types, theme enumerations, CSS class catalogues — go to subsystem docs
- **Long examples:** code samples that aren't constantly needed — subsystem docs
- **Subsystem architecture detail:** how overflow detection works internally, why a particular algorithm — subsystem docs

**Moves out (historical):**

- **"How It Evolved" past ~5 entries:** to `docs/HISTORY.md`. Keep only the last 3-5 phases inline.

**Deletes entirely (no destination):**

- **Duplicates of global CLAUDE.md or rules files.** Check `~/.claude/CLAUDE.md` and any `.claude/rules/*.md` - if the global version is authoritative, delete the project-level copy.
- **Obvious / self-evident instructions** ("break down large tasks", "avoid pasting full files into chat")
- **Flag lists that duplicate `--help`.** Point at `--help`, keep only the 2-3 flags with non-obvious usage notes.
- **"Key Files" tables that duplicate "Key modules" lists** (or vice versa)
- **Content rediscoverable from code, tests, or git log**

### Phase 4: Present the plan for approval

Before touching any files, show the user:

1. **Current size vs. budget:** "CLAUDE.md is at ~X,XXX tokens, budget for a <size> project is Y,YYY."
2. **What will move where:** a tight bullet list of moves. For each move: *this section → this destination*, with a one-line reason.
3. **What will be deleted:** sections dropped entirely, with a one-line reason each.
4. **New files (if any) to be created:** justify each one against Phase 2's "prefer existing docs" rule.
5. **Target size after cleanup:** rough estimate.

Ask for approval. Let the user override individual moves ("keep that inline, it bites every session").

### Phase 5: Execute the moves

In order:

1. **Create archive files first** (e.g. `docs/HISTORY.md`) using `Write`, with full verbatim content so nothing is lost.
2. **Append to existing docs** using `Edit` when content needs to move into an existing file.
3. **Rewrite CLAUDE.md last** using `Write` - it's a full rewrite of a mostly-replaced file, and Write is cleaner than many small Edits for this.
4. **Do not alter rules files** (`~/.claude/rules/*.md`, `.claude/rules/*.md`) unless the user asked — they belong to separate concerns.

### Phase 6: Verify and report

```bash
wc -l -w -c CLAUDE.md
```

Report before/after metrics to the user:

- Line count: N → M
- Word count: N → M
- Estimated tokens: ~N → ~M (% reduction)
- Files created / modified
- Any sections flagged for follow-up (e.g. "a few CSS gotchas aren't yet in CANVAS-REFERENCE.md — worth migrating in a follow-up")

## The thin CLAUDE.md template

A good slimmed CLAUDE.md looks roughly like this:

```markdown
# <Project> - Project Instructions

<!-- ~X,XXX tokens — budget: Y,YYY -->
<!-- LLM-facing routing layer. Humans read README.md. -->

<One paragraph: what this project is, in one sentence plus context>

## Non-negotiable rules

- <Rule that applies on every turn, with reason if non-obvious>
- <Rule>
- <Rule>

## Design philosophy

<Short: quality bar, guiding principles, what's strict vs. flexible>

## Where to look next

| Task | Where |
|---|---|
| <Subsystem detail> | `docs/<SUBSYSTEM>.md` |
| <Workflow> | `docs/<workflow>.md` or skill name |
| <Historical context> | `docs/HISTORY.md` |
| <Full CLI flags> | `<tool> --help` |

## Pipeline / architecture in one glance

<Key flow in one line or small ASCII diagram. Module index as a bullet list - one line per module, routing only, no deep explanation.>

## Build basics

<2-5 most-used commands. Pointer to README for setup, --help for full flag list.>

## Security boundaries

<Credential locations, gitignored paths, defensive constraints.>

## Testing

<Run command, test count, coverage floor, any non-obvious test config.>

## Recent phases

<Last 3-5 evolution entries as short bullets. Full log in docs/HISTORY.md.>
```

Not every project needs every section. Drop the ones that aren't load-bearing.

## When to push back

Don't slim a CLAUDE.md if:

- **It's already under budget** for its project size. Tell the user the current size and ask what they want to optimise for (token cost? attention? currency?).
- **It's sparse, not bloated.** Route the user to `claude-md-improver` instead — that skill adds missing sections, this skill removes bloat.
- **The user wants to delete content without preservation.** Always move content to a load-on-demand file. Deleting load-bearing knowledge is not a cleanup, it's a regression.

## Worked example (sparkforge)

The first real run of this skill shrank `~/sparkforge/CLAUDE.md`:

- **Before:** 277 lines / ~14,120 tokens (2.3× over the 6,000-token budget for a large project)
- **After:** 105 lines / ~1,800 tokens (well under the 2,500 aggressive target for large projects with good load-on-demand docs)
- **Reduction:** ~87%, zero information loss

Moves that mattered:

1. **Evolution log (33 entries) → `docs/HISTORY.md`** (new file). Biggest single win - history sections grow monotonically and belong in an archive.
2. **"Key Files" table → deleted** as a duplicate of the "Key modules" bullet list right above it.
3. **~15 subsystem-specific gotchas → deleted** because `docs/CANVAS-REFERENCE.md` already covered them. This is the "prefer existing docs" lesson - the original plan was to create a new `REFERENCE-GOTCHAS.md`, but reading the existing canvas reference showed it already had ~90% of the content.
4. **Full `--flag` list → replaced with pointer to `--help`** plus the 3-4 flags with non-obvious usage.
5. **Git conventions and session-management bullets → deleted** because they duplicated `~/.claude/CLAUDE.md` (global) or stated obvious defaults.
6. **"How It Evolved" ordering bug** (entry 31 appeared after 33 in the source) was fixed when moving to `HISTORY.md` - numeric order restored.

The thing that didn't ship: a new `REFERENCE-GOTCHAS.md`. Don't create new files when existing ones can absorb the content.
