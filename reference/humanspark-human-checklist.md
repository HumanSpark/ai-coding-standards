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

- [ ] **Commit the plan first.** Write the implementation plan as a markdown file and commit it before writing any code. (Rule 3.3)
- [ ] **Is this R&D?** If the outcome is genuinely uncertain - trying an untested approach, comparing alternatives, benchmarking feasibility - prefix commits with `[R&D]`. If it's routine work with known techniques, don't. (Rule 3.5)
- [ ] **Decide the testing tier.** Is this Tier 1 (security/protocol - tests first), Tier 2 (feature - tests alongside), or Tier 3 (legacy gap-fill - tests after)? Make the decision explicitly, don't default to "I'll add tests later." (Rule 6.6)
- [ ] **Run the "first code review" checkpoint.** Before sending a prompt to Claude Code, ask: "What would I correct on the first code review?" Then put those corrections into the prompt. Front-load: error handling patterns, CLI structure, logging approach, file paths, naming conventions. (Rule 7.2)
- [ ] **Check file size before adding features.** Is the target file approaching 300 lines? If so, extract before adding more. (Rule 4.5)
- [ ] **Scope the task tightly.** Tell Claude Code to fix exactly what's specified - no opportunistic refactoring of adjacent code. (Rule 13.3)

---

## Before Each Prompt to Claude Code

- [ ] **Apply the "first code review" filter.** What will be wrong with the output? Tell Claude Code up front.
- [ ] **Specify the testing tier.** Tell Claude Code whether this is Tier 1 (write tests first), Tier 2 (tests in the same commit), or Tier 3 (gap-fill).
- [ ] **Include security context.** If the feature handles external data, user input, or auth, tell Claude Code to write the sanitisation layer first and security tests before feature tests.
- [ ] **Error hints.** If the feature raises exceptions, remind Claude Code that every raise site needs a `hint` argument (HintedError pattern). The hint should tell a non-technical user what to check or do next.
- [ ] **Type hints.** Remind Claude Code to include return types and parameter types on all public functions. `from __future__ import annotations` at the top of every file.

---

## After Each Feature / Fix Batch

- [ ] **Update CLAUDE.md.** Add a numbered entry to the evolution history. Update test count. Add new files to the key files table. Add any new gotchas. (Rule 7.4)
- [ ] **Update README project map.** If directory structure changed, update the ASCII tree. (Rule 2.6)
- [ ] **Check for TODOs.** Run `grep -rn "TODO:" src/` and verify nothing was left unfinished by Claude Code. (Rule 4.8)
- [ ] **Track test count.** Did it go up? If it went down, something was removed - investigate. (Rule 6.1)

---

## When Extracting Values to Config

- [ ] **Grep the entire codebase.** Search for every reference to the value being extracted. Update all references in the same commit. Don't discover missed references 22 minutes later. (Rule 3.4)

---

## When Creating a New Module

- [ ] **Does this need modular structure?** More than 3 source files with
  distinct responsibilities? Re-explained context to CC more than twice?
  If no, flat layout is fine. (Rule 12.5)
- [ ] **What role does this module play?** Client, processor, storage, output,
  or entrypoint? If you can't pick one, the module is doing too much. (Rule 12.6)
- [ ] **If it's a processor - does it have any I/O?** Processors must be pure:
  dataclasses in, dataclasses out. No network, no filesystem, no database.
  If it needs I/O, it's a client or storage module. (Rules 12.6, 12.7)
- [ ] **Create the module README first.** Copy from `docs/MODULE-README-TEMPLATE.md`.
  Fill in purpose (including what it does NOT do), public interface, dependencies,
  known issues, testing. Commit this before the implementation. (Rules 12.1, 3.3)
- [ ] **Define types in models.py.** What data structures flow in and out?
  Add frozen dataclasses before writing the implementation. If the processor
  enriches data, define a new output type. (Rules 12.3, 12.7)
- [ ] **Add config section if needed.** New tuneable values go in config.py as a
  frozen dataclass. The module receives its section, not the full config. (Rule 12.4)
- [ ] **Write __init__.py with __all__.** Explicit public API. (Rule 12.2)
- [ ] **Add logger.** `logger = logging.getLogger(__name__)` after imports.
  Do not configure logging - entrypoint handles that. (Rule 12.10)
- [ ] **Define exception types** if callers need to handle errors. (Rule 12.8)
- [ ] **Write tests against the public interface.** Not internals. Use fixtures
  for external data. Processor tests should need zero mocks. (Rule 12.6)
- [ ] **Update CLAUDE.md** key files table and architecture section. (Rule 7.4)
- [ ] **Add Makefile target** if missing: `make test-module MOD=name`.

## When Wrapping a New External Service

- [ ] **One client per service.** Even if it's 40 lines. (Rule 12.9)
- [ ] **Capture a real response fixture.** `curl -sL -o tests/fixtures/{service}_{scenario}.{ext} "URL"` (Rule 12.9)
- [ ] **Client returns frozen dataclasses, not raw responses.** Callers never
  see requests.Response, BeautifulSoup, or JSON dicts. (Rule 12.9)
- [ ] **Wrap library exceptions.** `requests.RequestException` becomes
  `ServiceNameError`. Include the resource ID in the message. (Rule 12.8)

## When Refactoring Toward Modules (Migration)

- [ ] **Identify the seams.** List distinct responsibilities in the current code.
  Classify each as client, processor, storage, or output. Do this on paper
  first, not in code.
- [ ] **Extract models.py first.** Find every data structure flowing between
  responsibilities. This is the highest-value single change. (Rule 12.3)
- [ ] **One module per session.** Pick the module with fewest dependencies on
  other parts. Extract it fully (README, __init__.py, core.py, tests) before
  starting the next.
- [ ] **Extract processors before clients.** Processors have no I/O, so they're
  easier to extract cleanly. Once processors are out, the remaining code is
  mostly I/O and wiring.
- [ ] **Add config.py after 2-3 modules.** The configuration pattern becomes
  clear once you've extracted a few modules. (Rule 12.4)
- [ ] **Verify the pipeline is readable in one place.** After extraction, the
  entrypoint (cli.py) should show the full pipeline sequence without needing
  to read any module's internals. (Rule 12.7)

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

**Avoid hasty abstractions.** Don't let the AI build generic factories or deep inheritance for a single use case. Wait for three duplications before abstracting. Composition over inheritance, always. (Rules 13.1, 13.2)
