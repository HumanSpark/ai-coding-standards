# CLAUDE.md as Code

CLAUDE.md is an LLM-facing document, not a human reference. Humans read
README.md. Every token in CLAUDE.md is loaded into every conversation, costs
money, and dilutes attention. Treat it like code: budget tokens, review growth.

**Token budgets:** Small projects < 2,000 tokens, medium < 4,000, large < 6,000.
Add `<!-- ~NNNN tokens — budget: NNNN -->` at the top so growth is visible.

**Three tiers of context:**
1. **Always loaded** (`CLAUDE.md` + `.claude/rules/*.md`): Design philosophy,
   architecture, build/run, testing, security, active gotchas, key files
   (top 10-15). Use rules files to split instructions that would push
   CLAUDE.md past its token budget.
2. **On demand** (skills, `docs/*.md`): Detailed patterns, module contracts,
   reference gotchas. Loaded when working in the relevant area.
3. **Archival** (`docs/HISTORY.md`, git log): Evolution history, completed
   phases. Never auto-loaded.

**What moves out when CLAUDE.md grows:**
- Standalone instruction sets (deployment rules, formatting rules) ->
  `.claude/rules/*.md` (still always-loaded, but keeps CLAUDE.md focused).
- "How It Evolved" past ~5 entries -> `docs/HISTORY.md`, keep 3-line summary.
- Reference gotchas (edge cases for specific subsystems) -> `docs/REFERENCE-GOTCHAS.md`.
- Exhaustive key files tables (20+ files) -> keep top 10-15, full list in README.md.
- Deduplicate across sections - gotchas that restate security boundaries or key
  patterns should be consolidated into the most authoritative section.

**Four edit types:**
- **Phase completion:** Append to "How It Evolved" (or `docs/HISTORY.md` if
  overflowing), update test count, add key files if top-15 worthy.
- **Architectural correction:** Update key flow and component descriptions.
- **Gotcha addition:** Add to "Things to Watch Out For" if it affects everyday
  development. Subsystem-specific gotchas go in `docs/REFERENCE-GOTCHAS.md`.
- **Philosophy refinement:** Update "keep strict" / "free to adapt".
