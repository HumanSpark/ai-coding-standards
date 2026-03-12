# HumanSpark Workflow Checklist

**For:** Alastair McDermott (the human)
**Companion to:** humanspark-engineering-standards-v1.md (master, with evidence and rationale)
**AI instructions:** humanspark-ai-instructions.md (paste into CLAUDE.md or .claude/rules/)

This checklist captures what YOU do - the decisions, habits, and discipline that no AI instruction file can enforce. Print it. Pin it. Scan it before starting work each day.

---

## Before Starting a New Project

- [ ] **Check for existing infrastructure.** Does an API, catalogue, or index already exist for what you're about to build? Check before writing discovery code. (Rule 1.1)
- [ ] **Write the CLAUDE.md first.** Use the Stage 4 template from the master standards. Fill in design philosophy, build commands, test commands, architecture, and security boundaries BEFORE writing any code. (Rule 2.1)
- [ ] **Write the design philosophy section.** Define "keep strict" vs "free to adapt" boundaries. This is the single most important section - it tells the AI how to think about quality for this project. (Template Section)
- [ ] **Create .gitignore.** Include `__pycache__/`, `*.pyc`, `.coverage`, `*.db`, `venv/`, `.env`, `output/`, `.claude/`. Do this in the first commit. (Rule 2.4)
- [ ] **Set up test fixtures.** Create fixture data immediately. Never use real personal data, not even temporarily. (Rule 2.5)
- [ ] **Set vi config.** Add `set expandtab tabstop=4 shiftwidth=4` to `.vimrc` if not already present. (Rule 4.7)

---

## Before Writing Each Feature

- [ ] **Commit the plan first.** Write the implementation plan as a markdown file and commit it before writing any code. (Rule 3.4)
- [ ] **Decide the testing tier.** Is this Tier 1 (security/protocol - tests first), Tier 2 (feature - tests alongside), or Tier 3 (legacy gap-fill - tests after)? Make the decision explicitly, don't default to "I'll add tests later." (Rule 6.6)
- [ ] **Run the "first code review" checkpoint.** Before sending a prompt to Claude Code, ask: "What would I correct on the first code review?" Then put those corrections into the prompt. Front-load: error handling patterns, CLI structure, logging approach, file paths, naming conventions. (Rule 7.2)
- [ ] **Check file size before adding features.** Is the target file approaching 300 lines? If so, extract before adding more. (Rule 4.5)

---

## Before Each Prompt to Claude Code

- [ ] **Apply the "first code review" filter.** What will be wrong with the output? Tell Claude Code up front.
- [ ] **Specify the testing tier.** Tell Claude Code whether this is Tier 1 (write tests first), Tier 2 (tests in the same commit), or Tier 3 (gap-fill).
- [ ] **Include security context.** If the feature handles external data, user input, or auth, tell Claude Code to write the sanitisation layer first and security tests before feature tests.

---

## After Each Feature / Fix Batch

- [ ] **Update CLAUDE.md.** Add a numbered entry to the evolution history. Update test count. Add new files to the key files table. Add any new gotchas. (Rule 7.4)
- [ ] **Update README project map.** If directory structure changed, update the ASCII tree. (Rule 2.6)
- [ ] **Check for TODOs.** Run `grep -rn "TODO:" src/` and verify nothing was left unfinished by Claude Code. (Rule 4.8)
- [ ] **Track test count.** Did it go up? If it went down, something was removed - investigate. (Rule 6.1)

---

## When Extracting Values to Config

- [ ] **Grep the entire codebase.** Search for every reference to the value being extracted. Update all references in the same commit. Don't discover missed references 22 minutes later. (Rule 3.5)

---

## When Deploying / Transferring Files

- [ ] **Specify machine and user.** Always note which machine and which user when writing commands. (Rule 9.1)
- [ ] **Address file ownership.** After `scp` or any cross-user file transfer, check and fix `chown` if needed. (Rule 9.2)
- [ ] **Chain commands with &&.** Prevents partial execution if an earlier command fails. (Rule 4.6)

---

## Weekly / Periodic Reviews

- [ ] **Check CLAUDE.md staleness.** Does the architecture section still match reality? Are the test counts current? Are there gotchas you discovered but didn't write down?
- [ ] **Review design philosophy boundaries.** Have you discovered a new "keep strict" or "free to adapt" boundary? Update if so. (Rule 7.4)
- [ ] **Check for files over 300 lines.** Run `find src/ -name "*.py" -exec wc -l {} + | sort -rn | head -20` and look for extraction candidates. (Rule 4.5)

---

## Principles to Internalise

These aren't checkboxes - they're habits.

**Detection before correction.** When something breaks, the first commit exposes the problem. The second commit fixes it. (Rule 1.2)

**The thinking is the work.** Architecture decisions and requirements matter more than typing speed. A good plan is worth more than fast code. (Rule 1.5)

**Security boundaries are constraints.** Document what the system CANNOT do. The SafetyValve pattern - whitelist of allowed actions, read-only files declared up front - is the default. (Rule 1.4)

**The lethal trifecta.** Never combine unrestricted data access + untrusted content + autonomous action in one component. Delegated automation with human confirmation is the model. (Rule 5.5)

**Prompts are code.** System prompts, CLAUDE.md, rules files - they get versioned, tested, and reviewed with the same discipline as Python. (Rule 1.3)

**72% of failures are code, not prompts.** Prompt rules alone cannot fix the majority of issues. Code-level enforcement is the primary defence. (Rule 5.4)
