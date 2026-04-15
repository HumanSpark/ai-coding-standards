# Claude Code Settings: Token Efficiency Configuration

Practical configuration for Claude Code that keeps daily usage costs
predictable without degrading output quality. Complements the permission
and precedence rules in `reference/humanspark-engineering-standards-v1.md`
sections 7.7-7.8.

## Why this matters

Every tool call, file read, and reasoning step loaded into a Claude Code
session is paid for in tokens. On Opus 4.6 at high effort, exploratory
churn - the reads, searches, and retries around a simple task - often
costs more than the actual code change. The settings documented here
push cheap work to a cheap model and block categories of reads that
never repay their token cost.

The goal is not "smallest possible context" - it is "smallest context
that does not force Claude into a less capable fallback."

## Settings hierarchy (recap)

Five levels, higher overrides lower (full rules in section 7.8):

1. Managed settings (`/etc/claude-code/managed-settings.json`)
2. CLI flags (`--model`, `--permission-mode`, etc.)
3. `.claude/settings.local.json` (personal, gitignored)
4. `.claude/settings.json` (project, committed)
5. `~/.claude/settings.json` (user global)

Token efficiency settings live at level 5 (global defaults) because
they apply to every session and every project. Per-project overrides
stay at level 4.

## Recommended user-level settings

Place in `~/.claude/settings.json`:

```json
{
  "model": "opusplan",
  "effortLevel": "medium",
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "claude-haiku-4-5-20251001",
    "BASH_MAX_OUTPUT_LENGTH": "50000"
  },
  "claudeMdExcludes": [
    "**/project-template/**",
    "**/archive/**/CLAUDE.md",
    "**/node_modules/**"
  ],
  "permissions": {
    "deny": [
      "Read(**/node_modules/**)",
      "Read(**/dist/**)",
      "Read(**/build/**)",
      "Read(**/__pycache__/**)",
      "Read(**/*.pyc)",
      "Read(**/.venv/**)",
      "Read(**/*.egg-info/**)",
      "Read(**/.mypy_cache/**)",
      "Read(**/.ruff_cache/**)"
    ]
  }
}
```

The `permissions.allow` and hook configuration from the project template
remain untouched; this file only shows the token-efficiency additions.

## Per-setting rationale

### `model: "opusplan"`

`opusplan` is the hybrid mode where Claude Code uses Opus for Plan
Mode (`Shift+Tab` to the plan state) and Sonnet for execution. This
routes the expensive model to the phase where its reasoning produces
compounding returns - plan quality determines how many execution
iterations you need - and lets the cheaper model handle the mechanical
edits and verifications.

A permanent `model: "opus"` setting burns the premium rate on routine
work like "update a test assertion" where Sonnet would produce an
identical diff for a third of the cost. A permanent `model: "sonnet"`
setting saves money but removes Opus's planning advantage on tasks
that genuinely benefit from it.

The alias `opusplan` is the cleanest expression of "use Opus only
when I'm planning, use Sonnet the rest of the time."

### `effortLevel: "medium"`

Controls how many internal reasoning tokens the model allocates before
responding. `"high"` biases toward deeper thought; `"medium"` is the
standard default; `"low"` is suitable for narrow mechanical work.

`"medium"` is the practical daily-driver value. `"high"` is justified
when you are in a plan-first session on a genuinely complex task -
the reasoning cost is amortised across a better plan - but permanent
`"high"` pays for depth on every single turn, including trivial ones.

Override per-session with `/effort high` when a task warrants it.

### `env.CLAUDE_CODE_SUBAGENT_MODEL`

Without this, subagents inherit the main thread's model. Running
Explore, general-purpose, or custom subagents on Opus defeats the
point of delegation - the whole reason to isolate noisy operations
(repo search, log triage, documentation lookups) in a subagent is
that their context can be cheap and disposable.

Pinning to `claude-haiku-4-5-20251001` matches Anthropic's own
built-in Explore subagent, which runs Haiku on read-only tools.

Use the full model ID (not the `haiku` alias) to avoid drift when
Anthropic releases a new Haiku generation.

### `env.BASH_MAX_OUTPUT_LENGTH`

Default truncates shell output around 30,000 characters. When a test
suite or log dump exceeds that, Claude either re-runs the command
(more tokens) or works from partial output (more errors, then more
tokens). 50,000 is a practical ceiling that fits most full test
runs without re-invocation.

For specific log-heavy sessions, override with an even higher value
via `.claude/settings.local.json`.

### `claudeMdExcludes`

Every `CLAUDE.md` file in or under the working directory is loaded
at session start. In monorepos or template-containing repos, stray
`CLAUDE.md` files from other teams, archived projects, or template
placeholders silently add tokens that compete for attention with
the instructions you actually want loaded.

Exclude anything that is not your current project's live context.
`project-template/**` is specific to the ai-coding-standards repo
(its Stage 4 template is a placeholder with `{foo}` variables).
`archive/**/CLAUDE.md` and `node_modules/**` are broadly useful.

### `permissions.deny` (build artefacts)

The template deny list covers secrets and destructive operations.
Build artefacts are the other category worth blocking - not because
they are dangerous, but because they are expensive to read and
almost never add signal. A single `Read(node_modules/react/cjs/...)`
can burn 30k tokens on a file the model has already seen during
training.

Denies are additive: user-level denies apply to every project on top
of whatever the project-level settings.json defines.

## Project-level additions

`project-template/.claude/settings.json` carries the same six build-artefact
deny rules so that new projects inherit them, and `setup.sh`'s additive
merge propagates them to existing managed projects on next sync.

Project-level settings also carry the hook configuration (git fetch
before commit/push, py_compile after Python edits) - those belong with
the project because they enforce project-specific quality gates.

Model, effort, subagent env, and claudeMdExcludes are user-level concerns
and do not appear in `project-template/.claude/settings.json`.

## When to tune

- **Switch to permanent `model: "sonnet"`** if you rarely use Plan Mode.
  You lose the Opus-in-planning benefit but save on even the planning
  model.
- **Raise `effortLevel` to `"high"`** for a session tackling architecture
  work or debugging where reasoning depth is the bottleneck. Revert
  afterwards.
- **Narrow `BASH_MAX_OUTPUT_LENGTH`** if your environment runs small
  test suites and you want to catch runaway output faster.
- **Add more `claudeMdExcludes` entries** when you adopt a new monorepo
  layout that places sibling `CLAUDE.md` files near your working directory.

## Pitfalls

- **`MAX_THINKING_TOKENS` alone does nothing on 4.6 models.** Adaptive
  thinking overrides a fixed cap unless you also set
  `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`. Use `effortLevel` instead.
- **`.claudeignore` is not a supported exclusion mechanism.** Use
  `permissions.deny` for hard exclusions. `.claudeignore` is unreliable
  and does not replace permission rules.
- **`respectGitignore` affects `@` file suggestions only.** It is not
  a broad read blocker.
- **Subagents do not inherit parent skills.** Any `skills:` in a
  subagent frontmatter loads the full skill content into that subagent's
  context. Do not attach skills to reader subagents.
- **Deploying settings across machines requires your own sync step.**
  `~/.claude/settings.json` is not version-controlled by Claude Code
  itself. Use dotfiles or a setup script.

## Deployment

The HumanSpark standards deploy this configuration via two repositories:

- **`ai-coding-standards`** - the project-level additions (`project-template/
  .claude/settings.json` build-artefact denies) cascade to all managed
  projects via `setup.sh`'s additive merge.
- **A personal dotfiles repository** (not in this repo) - the user-level
  `~/.claude/settings.json` with model/effort/env/claudeMdExcludes.

Teams adopting these standards should replicate the user-level block in
their own dotfiles or provisioning tooling. The project-level pieces
come "for free" via `setup.sh`.

## Evidence

- Anthropic Claude Code docs on model selection, adaptive thinking, and
  settings precedence (code.claude.com/docs).
- `/context` command output in live HumanSpark sessions showing Opus-high
  as the main model with unset subagent override, plus user-level
  CLAUDE.md running over its token budget.
- Cross-project audit finding that build-artefact reads accounted for
  a disproportionate share of exploratory token spend on three projects.

See `CLAUDE.md` evolution entry 16 for the specific change set and
rationale applied to this repository.
