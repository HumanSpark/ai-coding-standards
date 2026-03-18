# AI-Specific Design Constraints Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add AI-specific design constraints to the reference doc (human-facing) and tighten the user-level CLAUDE.md (LLM-facing) to stay token-neutral.

**Architecture:** Two documentation files changed. Reference doc gets a new Section 13. User-level CLAUDE.md gets three rule additions offset by a tightening pass. No code, no templates, no skills.

**Tech Stack:** Markdown only.

---

## Task 1: Add Section 13 to reference doc

**Files:**
- Modify: `reference/humanspark-engineering-standards-v1.md:922-924` (insert before Appendix A)

- [ ] **Step 1: Insert Section 13 before Appendix A**

Insert the following between line 922 (`---`) and line 925 (`## Appendix A`). Keep the existing `---` separator, add the new section, then add another `---` before Appendix A.

```markdown
## 13. AI-Specific Design Constraints

Human coding standards and AI coding standards are not always identical. Some principles that make humans better developers - like anticipating future needs, opportunistically refactoring adjacent code, or building abstractions early - will cause an LLM to waste tokens, bloat the context window, or introduce scope creep. Conversely, LLMs are hardwired to be "helpful," which often translates to silently swallowing errors rather than failing fast (addressed by Rule 4.4 and the mandatory error hints in the user-level instructions). The following constraints address the specific, predictable failure modes of LLM-assisted development.

### 13.1 Avoid Hasty Abstractions (Rule of Three)

* **The Rule:** Do not build generic, highly abstracted factory classes or interfaces for a single use case. Wait until code has been duplicated at least three times before refactoring it into a shared abstraction.
* **The AI Rationale:** LLMs tend to over-engineer and predict future feature needs that do not exist. Premature abstraction burns tokens, complicates the context window, and makes future prompt-driven modifications unnecessarily difficult.

### 13.2 Composition Over Inheritance

* **The Rule:** Build complex objects by combining simple, flat, plug-and-play functions and classes. Deep Object-Oriented inheritance trees (e.g., `BaseUser -> PaidUser -> AdminUser`) are prohibited.
* **The AI Rationale:** Deep inheritance destroys an LLM's context window. It forces the AI to open and hold multiple files in memory just to understand or modify a single inherited method. Flat, composed code is significantly more "Claude-Code-efficient." This principle is operationalised in Section 12 (Modular Design) through the five standard module roles, which enforce flat composition at the architectural level.

### 13.3 Strict Scope (Anti-Boy Scout Rule)

* **The Rule:** Fix exactly what is outlined in the HANDOFF.md or the immediate prompt. Do not opportunistically refactor, reformat, or "clean up" adjacent code just because you are touching the file.
* **The AI Rationale:** Telling an AI agent to "leave the code cleaner than you found it" results in massive, unrelated diffs. Scope creep is fatal in AI-assisted development; agents must execute the exact task specified and nothing more.
```

- [ ] **Step 2: Add derivation entries to Appendix A**

Append the following rows to the end of the Appendix A table:

```markdown
| Avoid Hasty Abstractions (13.1) | Observed LLM over-engineering pattern: factory classes and interfaces built for single use cases across multiple projects. |
| Composition Over Inheritance (13.2) | CC context window analysis: deep inheritance requires holding multiple files to understand a single method. Section 12 module roles enforce flat composition. |
| Strict Scope (13.3) | Observed LLM scope creep: "clean up" instructions produce unrelated diffs. HANDOFF.md / prompt boundary enforcement. |
```

- [ ] **Step 3: Verify section numbering**

Run: `grep -n "^## " reference/humanspark-engineering-standards-v1.md`
Expected: Section 13 appears between Section 12 and Appendix A.

- [ ] **Step 4: Commit**

```bash
git add reference/humanspark-engineering-standards-v1.md
git commit -m "docs: add Section 13 AI-Specific Design Constraints to reference doc"
```

---

## Task 2: Tighten user-level CLAUDE.md

**Files:**
- Modify: `user-level/CLAUDE.md`

This task has two parts: tightening (remove words) then additions (add rules). Do tightening first so we can verify word count headroom before adding.

- [ ] **Step 1: Tighten error hints bullet (lines 70-80)**

Replace:

```markdown
- **Error hints are mandatory.** Every raised exception must include a `hint` -
  a human-friendly suggestion of what to check or do next. The technical detail
  (exit codes, HTTP status, stderr) stays; the hint tells a non-technical user
  what to actually do about it. Write the hint at the raise site where you have
  the most context about what went wrong.
  ```python
  raise ServiceError(
      "gws returned exit code 1 (stderr: 'token expired')",
      hint="Try running 'gws auth login' to refresh your Google credentials"
  )
  ```
```

With:

```markdown
- **Error hints are mandatory.** Every raised exception must include a `hint` -
  a human-friendly suggestion of what to check or do next. Write hints at the
  raise site where you have most context.
```

- [ ] **Step 2: Tighten Module Design intro (lines 99-100)**

Replace:

```markdown
For projects with 3+ source files and distinct responsibilities, apply modular
structure. Full conventions in `.claude/skills/modular-design/SKILL.md`.
```

With:

```markdown
For projects with 3+ source files. Full conventions in
`.claude/skills/modular-design/SKILL.md`.
```

- [ ] **Step 3: Tighten Placeholders section (lines 119-129)**

Replace:

```markdown
Mark ALL stubs, incomplete implementations, and mock data with `TODO:` comments. Mandatory.

```python
# TODO: Replace with actual API call - currently returns mock data
def get_user_profile(user_id):
    return {"name": "STUB_USER", "email": "stub@example.com"}
```

Distinguish `TODO:` (needs doing) from `NOTE:` (informational).
```

With:

```markdown
Mark ALL stubs, incomplete implementations, and mock data with `TODO:` comments.
Mandatory. Distinguish `TODO:` (needs doing) from `NOTE:` (informational).
```

- [ ] **Step 4: Verify word count after tightening**

Run: `wc -w user-level/CLAUDE.md`
Expected: below 1,370 words (original 1,447 minus ~85 saved), giving headroom for additions.

- [ ] **Step 5: Add abstraction rule to Code Style (after "File size" bullet, line 90)**

Insert after the "File size" bullet:

```markdown
- **Abstraction:** Do not abstract until code has been duplicated three times.
  Three similar lines is better than a premature abstraction. Never build
  generic factories or interfaces for a single use case.
```

- [ ] **Step 6: Add composition rule to Module Design (after rule 3, line 112)**

Change heading from `**Three hard rules:**` to `**Four hard rules:**` and add after rule 3:

```markdown
4. Composition over inheritance. No deep inheritance trees. Build complex
   behaviour by combining simple, flat functions and classes.
```

- [ ] **Step 7: Add strict scope rule to Development section (after "Plan before multi-step work" bullet, line 61)**

Insert as the last bullet in the Development section:

```markdown
- **Strict scope.** Fix exactly what the task specifies. Do not
  opportunistically refactor, reformat, or "clean up" adjacent code while
  working on a task.
```

- [ ] **Step 8: Verify final word count**

Run: `wc -w user-level/CLAUDE.md`
Expected: <= 1,450 words. If over, apply fallback tightening from spec (type hints bullet, linting bullet).

- [ ] **Step 9: Commit**

```bash
git add user-level/CLAUDE.md
git commit -m "docs: tighten user-level CLAUDE.md with AI design constraint rules"
```

---

## Task 3: Deploy and verify

**Files:**
- No files modified - verification only

- [ ] **Step 1: Deploy user-level CLAUDE.md**

Run: `./setup.sh`
Expected: "Installed: ~/.claude/CLAUDE.md"

- [ ] **Step 2: Verify deployed file matches source**

Run: `diff user-level/CLAUDE.md ~/.claude/CLAUDE.md`
Expected: no output (files are identical)

- [ ] **Step 3: Verify setup.sh still works for project init**

Run: `./setup.sh --dry-run /tmp/test-project`
Expected: lists files that would be created, no errors.

---

## Task 4: Update repo CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Add evolution history entry**

Append entry 8 to the "How It Evolved" section:

```markdown
8. **AI-Specific Design Constraints (2026-03-18):** Added Section 13 to reference doc (Rules 13.1-13.3) covering Avoid Hasty Abstractions, Composition Over Inheritance, and Strict Scope with dual Rule/AI-Rationale format. Tightened user-level CLAUDE.md: added three rules to existing sections (Code Style, Module Design, Development), removed code examples and redundant text to stay token-neutral. Evidence: observed LLM over-engineering, context window degradation from deep inheritance, scope creep from "clean up" instructions.
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add AI design constraints evolution entry to CLAUDE.md"
```
