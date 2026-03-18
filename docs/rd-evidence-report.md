# R&D Tax Credit Evidence Report
## Git Commit History Analysis - HumanSpark Projects
### Generated: 2026-03-15

**Scope:** 12 active repositories on local workstation (commitreader excluded - no commits yet)
**Period covered:** 2025-04-13 to 2026-03-15
**Total commits analysed:** 1,332

---

## Table of Contents

1. [Spark (Agent-Spark)](#1-spark-agent-spark)
2. [ClearMail](#2-clearmail)
3. [RAGBuilder](#3-ragbuilder)
4. [HumanSparkForge](#4-humansparkforge)
5. [SessionPilot](#5-sessionpilot)
6. [ClarityBot](#6-claritybot)
7. [TenderHelper](#7-tenderhelper)
8. [Workstation Dotfiles](#8-workstation-dotfiles)
9. [AI Coding Standards](#9-ai-coding-standards)
10. [Shared Email](#10-shared-email)
11. [Inbox Roulette](#11-inbox-roulette)
12. [GDrive Ops](#12-gdrive-ops)
13. [Cross-Project Summary](#13-cross-project-summary)

---

## 1. Spark (Agent-Spark)

**Repository:** alastair/agent-spark
**Description:** AI-powered personal assistant with LLM-driven conversation, calendar management, project management, email integration, and scheduled operations via RocketChat.

| Metric | Value |
|--------|-------|
| First commit | 2026-02-10 |
| Most recent commit | 2026-03-15 |
| Total commits | 402 |
| Test files | 261 |
| Peak test count | 2,043 |
| Monthly: Feb 2026 | 215 commits |
| Monthly: Mar 2026 | 187 commits |

### Phase/Iteration Timeline

| Date | Phase/Milestone |
|------|----------------|
| 2026-02-10 | Initial commit; CalDAV calendar creation (Phase 1) |
| 2026-02-11 | "How Spark fails" documentation added |
| 2026-02-12 | Three-category booking rules; LLM adapter refactoring; pre-computed slot availability |
| 2026-02-13 | Project management Phase 1; LLM prompt reliability test harness (14 scenarios) |
| 2026-02-14 | spark-pm build complete: all 21 phases, QA and hardening finished |
| 2026-02-15 | Tensorix model catalog; prompt reliability across 6 models; FreeAgent OAuth 2.0 |
| 2026-02-16 | Security red team; prompt injection guardrails; SafetyValve hardening |
| 2026-02-18 | 10-bug system audit fix; invoice ops; race condition fix |
| 2026-02-20 | 11 transcript issues fixed: prompt hardening, reply sanitizer |
| 2026-02-21 | VPS migration design |
| 2026-02-22 | VPS hardening design |
| 2026-02-26 | VPS hardening script deployed |
| 2026-02-28 | Night-owl time gate (code-level replacement for LLM-based rule) |
| 2026-03-01 | Labs experiments tracking |
| 2026-03-03 | Three-tier model architecture; switch to Gemini Flash with Sonnet escalation |
| 2026-03-05 | Transcript audit (62% reliability); re-audit reaches 97.7%; prompt harness 23->33 scenarios |
| 2026-03-06 | Dashboard redesign: 4 iterations, sci-fi command center aesthetic |
| 2026-03-08 | ClearMail integration (Phase 36) |
| 2026-03-09 | Architecture security audit; P0/P1 security fixes; major refactoring |
| 2026-03-10 | Log hygiene (Phase 38); Jinja2 dashboard migration (42-51% file reductions) |
| 2026-03-11 | Legacy EmailReader removed; ClearMail-only backend |
| 2026-03-12 | Transcript bug fixes (Phase 39); 2,008 tests |
| 2026-03-14 | Interaction memory; journal system; CLAUDE.md token discipline |

### Key Experimental Evidence Commits

#### Failed/Abandoned Approaches

**2026-02-12 - DeepSeek V3.1 ignored override preamble**
```
Remove weekends from hard blocks in scheduling prompt (DeepSeek V3.1
ignored the override preamble)
```
*Evidence of model-specific behavioural uncertainty requiring empirical investigation.*

**2026-02-12 - LLM action language failure**
```
Add action language rule (LLM was saying "I'll reschedule that"
without generating the file_op)
```
*LLM produced natural language responses instead of structured operations - required prompt engineering to resolve.*

**2026-02-12 - Haiku hallucination: time calculations**
```
Pre-compute time-until for events (Haiku was hallucinating "starts in
15 minutes" when 60 minutes away)
```
*Model incapable of reliable temporal arithmetic - required architectural shift to pre-computation.*

**2026-02-12 - Haiku hallucination: slot computation**
```
Add pre-computed free-slot availability (Instead of making the LLM
compute gaps - error-prone with Haiku)
```
*Fundamental uncertainty about LLM capability for calendar gap calculation.*

**2026-02-11 - Haiku calendar hallucination**
```
Add calendar event deletion (Previously Haiku hallucinated by creating
"CANCELLED:" events)
```
*Model invented non-existent conventions rather than using delete operations.*

**2026-02-11 - Prompt rule ordering sensitivity**
```
Move late-night tomorrow rule to top of prompt (Haiku was ignoring the
rule when buried mid-prompt)
```
*Discovered positional sensitivity in prompt rule processing - required empirical testing of rule placement.*

**2026-02-15 - Multi-model reliability comparison**
```
Add Tensorix model catalog and prompt reliability test results across 6 models
deepseek-chat-v3.1: 100%, llama-4-maverick: 97%, gpt-oss-20b: 97%,
deepseek-v3.2: 90%, qwen3-235b: 88%, deepseek-r1-0528: 71%
```
*Systematic experimental comparison across 6 models showing wide reliability variance (71-100%).*

**2026-02-15 - Invoice sync anti-hallucination**
```
Fix invoice sync: date filter, pagination, replace mode,
anti-hallucination guardrails
```
*LLM hallucination in financial data context required defensive architecture.*

**2026-02-28 - Night-owl LLM misfiring**
```
Implement code-level night-owl time gate (Eliminates LLM misfiring at 23:xx)
```
*LLM rule-following unreliable for time-based logic - replaced with deterministic code.*

**2026-03-03 - Model architecture pivot**
```
Switch operational model to Gemini Flash, add Sonnet escalation config
```
*Three-tier model architecture replacing single-model approach after reliability testing.*

**2026-03-05 - Transcript audit revealing systemic failures (62% reliability)**
```
Add comprehensive transcript audit report (62% reliability)
72% of failures are code+architecture, not prompt rules
```
*Major finding: majority of LLM failures were architectural, not prompt-level. Required fundamental rethinking of approach.*

**2026-03-05 - Re-audit after fixes (62% -> 97.7%)**
```
Re-audit prompt reliability: 62% -> 97.7%, fix 5 test harness issues
```
*Systematic experimental cycle: measure, diagnose, fix, re-measure.*

**2026-03-05 - Fabricated data in LLM responses**
```
Expand prompt reliability harness: 23 -> 33 scenarios
New scenarios from transcript audit failures: fabricated deadlines,
wrong contact association, model info disclosure, negation comprehension...
```
*LLM fabricating deadlines and misassociating contacts - required empirical discovery and specific countermeasures.*

**2026-03-09 - God function extraction**
```
refactor: P1-2 extract MessageProcessor class from process_message()
17-param god function replaced with MessageProcessor class. main.py
reduced from 1872 to 865 lines.
```
*Architectural refactoring driven by empirical finding that monolithic design was causing failures.*

**2026-03-09 - Security fixes from red team**
```
fix: P0 security fixes - dashboard cookie auth, VCALENDAR escaping,
ClearMail sanitization
P0-1: Replace query-string token auth with HTTP-only session cookie
```
*Security vulnerabilities discovered through adversarial testing, not anticipated.*

**2026-03-11 - Silent production failures**
```
fix: allow semicolons and ampersands in SafetyValve content
Fixes 3 silent production failures (Mar 4, Mar 9 x2) where Spark told
the user activity was logged but SafetyValve silently dropped the op.
```
*Safety system inadvertently blocking legitimate operations - discovered empirically in production.*

#### Technical Uncertainty References

- **Prompt injection defence:** 7 commits addressing injection vectors via calendar events, data boundaries, section markers
- **Hallucination countermeasures:** 5 commits addressing fabricated data, temporal hallucinations, context poisoning
- **Model reliability variance:** Systematic testing across 6 models (71-100% reliability range)
- **Prompt positional sensitivity:** Rules ignored when buried mid-prompt (Haiku)
- **Race conditions:** FileLock for quiet mode, TOCTOU in pending operations
- **Graceful degradation:** ClearMailReader, email summary, dashboard sections

### Test Suite Growth

| Date | Test Count | Milestone |
|------|-----------|-----------|
| 2026-02-14 | 239 | Initial QA (100 edge case tests) |
| ~2026-02-14 | 370 | Performance tests, docstrings |
| ~2026-02-15 | 433 | Invoice, reliability harness |
| ~2026-02-16 | 800 | Security hardening tests |
| ~2026-03-05 | 1,316 | Post-transcript audit |
| 2026-03-09 | 1,591 | Architecture refactoring |
| 2026-03-10 | 1,901 | Jinja2 migration |
| 2026-03-12 | 2,008 | Phase 39 |
| 2026-03-14 | 2,043 | Interaction memory |

---

## 2. ClearMail

**Repository:** alastair/clearmail
**Description:** Rules-based and LLM-based email triage system with thread analysis, closing detection, known-sender classification tiers, and automated IMAP actions.

| Metric | Value |
|--------|-------|
| First commit | 2026-03-07 |
| Most recent commit | 2026-03-15 |
| Total commits | 235 |
| Test files | 148 |
| Monthly: Mar 2026 | 235 commits |

### Phase/Iteration Timeline

| Date | Phase/Milestone |
|------|----------------|
| 2026-03-06 | Initial classifier with known-sender rules, calendar detection, LLM classification |
| 2026-03-07 | Phase 3.5: Thread state management, confidence thresholds, risk age gates |
| 2026-03-07 | Verify.py QA system: processing stats, error rate checks, anomaly detection |
| 2026-03-07 | Closing message detection (Rule 4a) with validation against 624 real messages |
| 2026-03-08 | Phase 2: Reply composer with LLM draft generation |
| 2026-03-08 | Phase 4: Spark briefing integration via ClearMailReader |
| 2026-03-08 | Edge case testing: 45 tests across 5 risk categories |
| 2026-03-09 | Phase 5: Tech debt elimination (14 tasks) |
| 2026-03-09 | SDET audit: 1,096->1,126 tests, 85%->87% coverage |
| 2026-03-11 | Phase 2 integration |
| 2026-03-12 | Phase 7: Telemetry and alerting |
| 2026-03-13 | Phase 8: Production polish design |
| 2026-03-14 | Phase 8: Batch classification, exception narrowing, hardening |

### Key Experimental Evidence Commits

#### Failed/Abandoned Approaches

**2026-03-07 - RFC 2822 date sorting bug (wrong message selection)**
```
Fix RFC 2822 date sorting in thread message ordering
String-sorting RFC 2822 dates sorted by day-of-week name alphabetically
("Mon" < "Wed") instead of chronologically. This caused
_latest_inbound_message_id to pick the wrong message - e.g. Jan 21
instead of Jan 26 because "Wed" > "Mon". Now parses dates to ISO
format before sorting.
```
*Non-obvious date format edge case causing silent data corruption.*

**2026-03-07 - Wrong message returned from thread**
```
Fix notmuch fallback returning wrong message headers from thread
When querying notmuch for a specific message ID, it returns the entire
thread. _find_headers() was returning the first message's headers
(often an outbound message) instead of the target message.
```
*Undocumented notmuch API behaviour causing incorrect classification.*

**2026-03-07 - Body preview showing wrong message**
```
Fix body preview showing wrong message from thread
Same bug as the headers fix: notmuch returns the entire thread even
when queried for a single message ID.
```
*Systematic discovery of the same root cause across multiple code paths.*

**2026-03-07 - Closing detection incorrectly triggering reply_now**
```
feat: add Rule 4a closing message detection to thread analyser
...short closing replies (thanks, sounds good, OK, etc.) after an
outbound message are classified as done_archive, waiting_on_them, or
review instead of incorrectly triggering reply_now.
```
*Classification system producing false positives on polite closings - required new heuristic layer.*

**2026-03-07 - Closing detection validation against real data**
```
fix: improve closing detection with name stripping, OOO category, and
expanded phrases
Validated full pipeline against 624 real messages: 10 pure_close
(100% precision), 5 OOO, 15 ball_in_court (all correct actions)
```
*Empirical validation against production dataset demonstrating precision measurement.*

**2026-03-08 - Notmuch query returning all 34k messages**
```
fix: use folder:INBOX instead of tag:inbox for triage query
notmuch adds tag:inbox to every imported message and never removes it,
so tag:inbox matched all 34k messages across every folder.
folder:INBOX (case-sensitive) reflects actual IMAP state. Also fixed
get_notmuch_messages() to recursively parse notmuch's nested JSON
thread structure - the shallow parser missed reply messages at depth
3+, silently dropping ~18k messages.
```
*Two compounding bugs: wrong query semantics (34k vs actual inbox) AND shallow JSON parsing silently dropping ~18k messages.*

**2026-03-08 - Dual-use sender detection**
```
feat: generic broadcast detection via List-Unsubscribe header
Replace per-sender dual_use flag with automatic broadcast detection.
Any known sender who normally needs_reply (client, contact, internal)
but has a List-Unsubscribe header is now routed to Reading as a
newsletter.
```
*Manual per-sender configuration insufficient - required automated heuristic approach.*

**2026-03-12 - Granular source tracking replacing generic labels**
```
feat: granular source values at each classification pipeline exit point
Replace generic "rule" and "thread" source values with specific
identifiers: known_sender:tier1..4, calendar_invite,
thread_consistency
```
*Generic classification insufficient for telemetry - required tracing each decision path individually.*

#### Technical Uncertainty References

- **Confidence thresholds:** Archive confidence, closing confidence, contact age gates - all tuned against real data
- **Error rates:** verify.py system with processing stats, anomaly detection (24h vs 30-day distribution comparison)
- **False positives:** Closing detection precision measured at 100% against 624 messages; request language checked first
- **Classification pipeline:** 20+ commits tracing the evolution from simple rules to multi-layer classification with LLM fallback
- **Token limits:** Thread analysis max tokens tuned from 500 to 800; batch body truncation to prevent overruns
- **Edge cases:** 5 dedicated risk categories, boundary tests for confidence thresholds

### Test Suite Growth

| Date | Test Count | Milestone |
|------|-----------|-----------|
| 2026-03-08 | 472 | Code review fixes |
| 2026-03-08 | 645 | Post code-review refactoring |
| 2026-03-08 | 783 | Edge case suite |
| 2026-03-09 | 1,096 | Phase 5 refactoring complete |
| 2026-03-09 | 1,126 | SDET audit |
| 2026-03-14 | ~1,200+ | Phase 8 batch classification |

---

## 3. RAGBuilder

**Repository:** alastair/ragbuilder
**Description:** Retrieval-Augmented Generation system with multi-source ingestion, vector storage, LLM-powered chat, and web UI.

| Metric | Value |
|--------|-------|
| First commit | 2026-02-25 |
| Most recent commit | 2026-03-15 |
| Total commits | 227 |
| Test files | 102 |
| Monthly: Feb 2026 | 33 commits |
| Monthly: Mar 2026 | 194 commits |

### Phase/Iteration Timeline

| Date | Phase/Milestone |
|------|----------------|
| 2026-02-25 | Design document; initial RAG pipeline with embedding + retrieval |
| 2026-02-25 | End-to-end smoke test |
| 2026-02-26 | WordPress WXR import; ProviderConfig for multi-provider support |
| 2026-03-06 | Stage 1: FastAPI migration replacing Streamlit; 210 tests |
| 2026-03-06 | Strategic improvements: 3-wave plan (16 tasks) |
| 2026-03-06 | Multi-source ingestion design |
| 2026-03-07 | Stage 4a: Foundation + features (chat redesign, conversations, settings) |
| 2026-03-12 | UX overhaul: document browser, chat upgrade, visual migration |
| 2026-03-13 | Phase 1: Document browser + design system |
| 2026-03-14 | Phase 2: Generation quality + chat upgrade |
| 2026-03-14 | Phase 3: Visual migration (Pico CSS removal, rb-* design system) |
| 2026-03-15 | Native GWS connector; reliability hardening |

### Key Experimental Evidence Commits

#### Failed/Abandoned Approaches

**2026-02-26 - Flat config structure insufficient for multi-provider**
```
Add ProviderConfig dataclass for multi-provider support
Replace flat embedding_model/llm_model/llm_provider fields with nested
ProviderConfig objects. This enables per-provider API keys and base
URLs for routing through services like OpenRouter.
```
*Original flat config couldn't support provider-specific routing - required architectural redesign.*

**2026-02-26 - Orphaned chunks on re-ingestion**
```
Fix orphaned chunks on WXR re-ingestion
Clean up all per-post records and vector chunks before re-processing a
modified WXR file, so removed posts don't leave orphaned data.
```
*Data lifecycle gap discovered empirically - deleted content persisting in vector store.*

**2026-03-06 - Streamlit replaced with FastAPI**
```
Merge feat/stage1-fastapi-sources: Stage 1 complete
FastAPI migration, Source model, Connector protocol. 210 tests passing.
Streamlit replaced as default UI.
```
*Streamlit framework insufficient for production requirements - complete UI framework replacement.*

**2026-03-06 - Local embedding fallback**
```
feat: add local embedding fallback via sentence-transformers
Add LocalEmbedder class and try_create_local_embedder() factory that
generates embeddings locally using sentence-transformers.
```
*API-only embedding unreliable - required local fallback for resilience.*

**2026-03-06 - Prompt hardening after security review**
```
Security hardening: localhost binding, symlink protection, defusedxml,
prompt hardening
Use XML <document> tags in LLM prompts instead of easily-forged ---
delimiters.
```
*Delimiter-based prompt boundaries found to be forgeable - required structured markup approach.*

**2026-03-14 - History sanitization**
```
feat: merge generation-quality and phase2-chat-upgrade branches
Generation quality: history sanitization, query length truncation,
re-ranking support, error handling, MAX_MESSAGES cap, blocked
directory prefixes for ingest safety.
```
*Multiple quality issues discovered requiring sanitization, truncation, and safety limits.*

#### Technical Uncertainty References

- **Concurrent database access:** SQLite WAL mode enabled for web UI read/write performance
- **Graceful degradation:** Reliability hardening spec covering dependency failures
- **API retry strategies:** Exponential backoff (1-8 seconds, 4 attempts) for LLM and embedding calls
- **Token management:** CLAUDE.md token discipline; prompt template evolution
- **Input sanitization:** Filename sanitization, history role validation, HTML stripping

---

## 4. HumanSparkForge

**Repository:** alastair/humansparkforge
**Description:** Document generation system producing branded PDF and HTML presentations, proposals, whitepapers, and books from YAML content sources with overflow management and density control.

| Metric | Value |
|--------|-------|
| First commit | 2026-02-11 |
| Most recent commit | 2026-03-15 |
| Total commits | 186 |
| Test files | 16 |
| Monthly: Feb 2026 | 37 commits |
| Monthly: Mar 2026 | 149 commits |

### Phase/Iteration Timeline

| Date | Phase/Milestone |
|------|----------------|
| 2026-02-11 | Initial commit: book, whitepaper, document templates |
| 2026-02-12 | Whitepaper enrichment (illustrations, callouts, pull-quotes) |
| 2026-02-13 | --compare flag for reference PDF comparison |
| 2026-02-15 | Architecture simplification; cross-template consistency |
| 2026-02-16 | Density system: adaptive sizing, --audit, --split, threshold tuning |
| 2026-02-17 | Redesign: full-bleed cover, natural sizing |
| 2026-02-18 | 15 new slide layouts |
| 2026-03-05 | Page composition system design (Approach A: Container Restructure) |
| 2026-03-06 | Graduated overflow response system (3 phases); cover title clipping fix |
| 2026-03-06 | Visual quality: Phase 1 (7->8.5/10), Phase 2 iteration 4 |
| 2026-03-08 | Presentation slide density: Layer B + Layer A two-layer system |
| 2026-03-09 | SDET audit: 154 tests; module extraction from God Object |
| 2026-03-10 | Roadway proposal (v11 after 11 design iterations) |
| 2026-03-11 | 16-iteration C.R.A.P. design refinement experiment |
| 2026-03-12 | Self-healing pipeline Phase 1: automated critique via vision API |
| 2026-03-15 | Self-healing Phase 2: auto-fix loop design |

### Key Experimental Evidence Commits

#### Failed/Abandoned Approaches

**2026-02-15 - Architecture over-engineering**
```
Simplify architecture: skip Tailwind for non-presentations, structural
footer fix, remove dead code
Replace whitepaper footer hack (absolute + gradient guard band) with
structural flex layout.
```
*Tailwind CSS approach abandoned for non-presentations; absolute positioning hack replaced with structural solution.*

**2026-02-15 - Absolute positioning cover approach**
```
Simplify whitepaper template: flexbox cover, consolidated callouts
Replace absolute-positioned cover with flexbox layout (remove
cover-orb, title-overlay, big_lines/accent mechanism). Template
reduced from 1636 to 1486 lines.
```
*Decorative absolute positioning approach too fragile - replaced with simpler flexbox.*

**2026-02-16 - Font rendering issues**
```
Add --presenter-notes flag and local font bundling
Fonts: replace Google Fonts network dependency with 12 bundled TTF
files. Eliminates mixed local/remote font rendering that caused
anti-aliasing issues.
```
*Mixed local/remote font loading caused rendering inconsistencies - required local bundling.*

**2026-03-06 - Overflow system: 5 bugs in book support**
```
Harden overflow system: fix book support, block detection,
continuation aesthetics
Five bugs fixed: Book overflow non-functional (.book-body vs
.book-prose class mismatch). Whitepaper block coordinates wrong
(offsetTop relative to positioned parent). Book split/shrink selectors
misaligned. Book measurement used body.offsetHeight (content height)
instead of available space. Non-splittable pages silently failed.
```
*Overflow measurement system had 5 interacting bugs across different document types - each required individual empirical diagnosis.*

**2026-03-10 - CSS multi-column failure**
```
fix: repair quotes-wall layout and polish visual depth; fix emoji rendering
quotes-wall: replace CSS multi-column (column-fill: balance ignored
flex height) with CSS Grid + align-content: space-evenly so rows fill
the full slide height.
```
*CSS column-fill: balance specification not honoured in flex container context - replaced with Grid.*

**2026-03-11 - 16-iteration design refinement experiment**
```
experiment: 16-iteration C.R.A.P. design refinement on whitepaper and
proposal templates
Whitepaper (base_whitepaper_exp.html) - 8 iterations:
Iter 1-8: Header, body leading, gold border, pull-quote, footer,
text-heavy, info-card, cover title refinements
Proposal (base_proposal_exp.html) - 8 iterations:
Iter 9-16: Cover title, card padding, investment pill, situation lede,
prose leading, blockquote, logo bar, contact refinements
```
*Explicit experimental methodology: 16 documented iterations applying design principles systematically.*

**2026-03-12 - Self-healing pipeline (automated visual critique)**
```
feat: add vision API call with retry logic
feat: add rubric-to-prompt builder
feat: add response parsing and pass/fail threshold logic
feat: add run_critique orchestrator
```
*Novel approach: using vision API to automatically evaluate PDF output quality against design rubric - experimental investigation into automated aesthetic assessment.*

#### Technical Uncertainty References

- **Overflow measurement:** Two-pass Playwright JS measurement with 25px threshold classification
- **Density thresholds:** Layout-aware thresholds (paragraph vs card vs horizontal); tuned across 5 iterative rounds
- **Regression testing:** Verified across 50+ page real documents after each change
- **Coverage instrumentation challenges:** Playwright sync API greenlet switching drops sys.settrace; required concurrency=greenlet config
- **Edge cases:** Minimal sidebar, heavy sidebar, two-column with summary bar, single large stat

---

## 5. SessionPilot

**Repository:** alastair/sessionpilot
**Description:** Real-time tangent detection and coaching overlay for trainers and presenters, with sales coaching mode featuring conversation stage tracking, heuristic detectors, and LLM-driven suggestions.

| Metric | Value |
|--------|-------|
| First commit | 2026-03-01 |
| Most recent commit | 2026-03-15 |
| Total commits | 72 |
| Test files | 60 |
| Peak test count | 272 |
| Monthly: Mar 2026 | 72 commits |

### Phase/Iteration Timeline

| Date | Phase/Milestone |
|------|----------------|
| 2026-03-01 | SRS and implementation plan; tangent tracker with temporal smoothing |
| 2026-03-11 | Sales coach mode design spec (brainstormed and designed) |
| 2026-03-14 | Engineering standards restructure |
| 2026-03-15 | Coaching engine v2 implementation plan (18 tasks, 4 chunks, ~145 new tests) |
| 2026-03-15 | v2 methodology playbook format with escalation ladders |
| 2026-03-15 | Full v2 integration: 12 new modules wired into pipeline |

### v1-to-v2 Coaching Engine Progression

This is a textbook experimental development arc:

**v1 (flat playbook loader):**
```
2026-03-11 | docs: add sales coach mode design spec
Brainstormed and designed a sales coaching extension. Covers dual audio
capture, speaker-labeled buffers, LLM situation classification,
heuristic detectors, and playbook-driven suggestions.
```

**Why v1 was insufficient - architectural limitations discovered:**
```
2026-03-15 | feat: add coaching engine v2 implementation plan (18 tasks,
4 chunks, ~145 new tests)
```
*v1's flat situation->suggestion mapping couldn't handle escalation sequences, conversation stage tracking, or context-aware suggestion generation.*

**v2 design decisions:**
```
2026-03-15 | feat: add v2 methodology playbook format with escalation
ladders and backward compat
Replaces the flat v1 playbook loader (situations -> suggestions lists)
with a dual-format loader that auto-detects v1 vs v2 based on presence
of 'methodology' or 'stages' keys. v2 adds escalation ladders per
situation (level -> severity + nudge + pivot + coaching),
StageDefinition parsing, required_topics extraction, and
custom_triggers pass-through.
```

**v2 integration - 12 new modules:**
```
2026-03-15 | feat: integrate coaching engine v2 into main pipeline
Wires all 12 new modules: StageTracker, TalkRatioTracker,
QuestionDepthDetector, SilenceComfortDetector,
PriceAnchoringDetector, AgreementRatioDetector,
DeliverableTalkDetector, PriceCaveDetector, ProposalTrapDetector,
CallMemory, FullTranscriptLog, MetricsAccumulator, DashboardRenderer,
SalesTranscriptWriter, CustomTriggerProcessor, SuggestionGenerator
```

#### Technical Uncertainty References

- **Temporal smoothing:** Tangent tracker uses smoothing and cooldown parameters (empirically tuned)
- **LLM confidence thresholds:** TOCTOU race condition discovered in _surface method; config-driven threshold
- **Fuzzy matching for STT:** rapidfuzz token_set_ratio for phrase matching (handles word order variation in speech-to-text output)
- **Classification accuracy:** Heuristic detectors for 8 value conversation patterns with question depth classification
- **Regression support:** Conversation stage tracker with dwell time and regression detection
- **Context-injected suggestions:** Second LLM call with static fallback on error/timeout

---

## 6. ClarityBot

**Repository:** alastair/claritybot
**Description:** Multi-tenant WordPress chatbot plugin with deterministic content guard, 4-layer defence-in-depth security, prompt builder, and admin panel.

| Metric | Value |
|--------|-------|
| First commit | 2026-03-13 |
| Most recent commit | 2026-03-15 |
| Total commits | 71 |
| Test files | 13 (PHP) |
| Peak test count | 215 |
| Monthly: Mar 2026 | 71 commits |

### Phase/Iteration Timeline

| Date | Phase/Milestone |
|------|----------------|
| 2026-03-13 | v2 design spec; v2 implementation plan (80 tests across 3 tiers) |
| 2026-03-13 | TDD red phase: 24 failing guard tests, 13 failing rate limiter tests |
| 2026-03-13 | Deterministic content guard implementation (3-layer: sanitisation, block patterns, violation tracking) |
| 2026-03-14 | 4-tab admin panel; REST endpoint orchestrator; prompt builder |
| 2026-03-14 | Red team audit: 9 security hardening fixes |
| 2026-03-14 | Guard enhancements spec #1: Audit trail, observe mode, pattern provenance |
| 2026-03-14 | Guard enhancements spec #2: Category-aware messages, output guard, core boundaries |
| 2026-03-15 | Character counter, validation warnings, accessibility (ARIA) |

### Architectural Evolution - Defence-in-Depth

The defence layer progression demonstrates iterative empirical discovery:

**Layer 1 - Input Guard (2026-03-13):**
```
feat: implement deterministic content guard with 24 passing tests
Three-layer guard: block patterns (injection, extraction, profanity,
sexual, off-topic), sanitisation, violation tracking with session lock
at 3 strikes.
```
*Initial approach: deterministic guards chosen over LLM-based detection for security (design decision documented).*

**Layer 2 - Prompt Boundaries (2026-03-14):**
```
feat: add core boundaries class with non-overridable prompt preamble
Constraints prepended to ALL system prompts - template and override
alike. 10 new tests (164 total).
```
*Discovered that admin prompt overrides could weaken security - required non-overridable boundary layer.*

**Layer 3 - Output Guard (2026-03-14):**
```
feat: add post-LLM output guard with URL allowlist and content checks
Pure processor class. Checks for fabricated URLs, email addresses,
phone numbers, profanity/sexual content, prompt boundary marker
leakage, system prompt self-reference leakage, fenced code blocks.
21 new tests, 42 assertions.
```
*Input guard insufficient - LLM could still fabricate URLs, leak prompt markers, generate phone numbers. Required post-LLM output validation.*

**Layer 4 - Audit and Observe (2026-03-14):**
```
feat: add JSONL audit log for guard decisions
No PII (hashed IP, truncated session hash, no message content).
13 audit log tests (129 total).

feat: add observe mode and audit log to REST pipeline
Guard decisions logged to JSONL audit trail. Observe mode logs blocks
without enforcing.
```
*Need to investigate false positives without blocking users - observe mode enables empirical assessment of guard accuracy.*

**Security Hardening from Red Team (2026-03-14):**
```
fix: 9 security hardening fixes from red team audit
Rate limit bypass (remove session token from hash, IP-only). XSS via
output attributes (replace strip_tags with wp_kses attribute-free
allowlist). Unicode guard bypass.
```
*9 vulnerabilities discovered through adversarial testing - each required individual investigation and fix.*

**Domain spoofing discovery (2026-03-14):**
```
fix: harden URL allowlist against domain-spoofing and trailing punctuation
Replace strpos prefix matching with parse_url scheme+host exact
comparison to block domain-spoofing (e.g. humanspark.ai.evil.com).
```
*URL validation approach found vulnerable to domain-spoofing attacks - required stricter parsing.*

**False positive management (2026-03-14):**
```
docs: fix 9 review issues in guard enhancements spec #2
inline code detection dropped for false positive risk

docs: add observe mode, audit log, and security tab
observe mode for investigating false positives
```
*Explicit trade-off: feature dropped due to false positive risk. Observe mode specifically designed for empirical false positive investigation.*

#### Technical Uncertainty References

- **False positive rates:** Observe mode for measuring guard accuracy; inline code detection dropped for FP risk
- **Routing word limits:** "Widen routing word limit buffer from 200 to 225 for LLM variation"
- **Unicode bypass:** Guard regex \s only matches ASCII whitespace; non-breaking spaces bypass patterns
- **Prompt reliability:** Tier 3 tests for hallucination prevention, output constraints (word limits, UK English, banned words)

### Test Suite Growth

| Date | Test Count | Milestone |
|------|-----------|-----------|
| 2026-03-13 | 24 | TDD red phase (guard) |
| 2026-03-13 | 37 | Guard + rate limiter |
| 2026-03-14 | 95 | Admin, client, prompt reliability |
| 2026-03-14 | 102 | Red team hardening |
| 2026-03-14 | 129 | Audit log |
| 2026-03-14 | 164 | Core boundaries |
| 2026-03-14 | 189 | Output guard |
| 2026-03-15 | 215 | Character counter, validation |

---

## 7. TenderHelper

**Repository:** alastair/tenderhelper
**Description:** Automated public procurement tender monitoring system with email-based notifications, relevance scoring, web scraping of eTenders, and digest generation.

| Metric | Value |
|--------|-------|
| First commit | 2026-03-05 |
| Most recent commit | 2026-03-15 |
| Total commits | 54 |
| Test files | 44 |
| Peak test count | 252 |
| Monthly: Mar 2026 | 54 commits |

### Phase/Iteration Timeline

| Date | Phase/Milestone |
|------|----------------|
| 2026-03-05 | Initial commit; core pipeline (email, fetcher, scorer, DB, digest) |
| 2026-03-05 | 96 tests; logging module; config validation; DB error handling |
| 2026-03-05 | 172 tests (79% coverage); export, pruning, lockfile |
| 2026-03-06 | Install script with 10 tests |
| 2026-03-10 | Spark brain integration (SparkWriter module) |
| 2026-03-15 | Phase 3: Reliability improvements (retry, health, urgency, UA rotation) |

### Key Experimental Evidence Commits

**2026-03-05 - URL routing for multiple resource types**
```
Extract _build_url() helper for testable URL construction
Move URL building logic from fetch_tender() into _build_url() with
explicit routing for CFT, PMC, and DPS resource types
Improve unexpected-page-content warning to include resource_type and
a hint about DPS URL patterns
```
*Three different eTenders resource types requiring different URL patterns - discovered through failed fetches.*

**2026-03-05 - Scoring algorithm tuning**
```
Add Skillnet/LEO training keywords to scoring config
New positive keywords: skillnet (+20), training services (+15),
panel of trainers (+15), LEO (+15). Sligo training tender now
scores 60 (MAYBE) instead of 10 (FILTERED).
```
*Scoring weights empirically tuned - real tender misclassified, requiring keyword and weight adjustments.*

**2026-03-05 - Concurrent execution prevention**
```
Add process lockfile to prevent concurrent cron executions
Add acquire_lock()/release_lock() using fcntl.flock to prevent
concurrent pipeline runs from corrupting SQLite.
```
*Cron overlap discovered as corruption risk - required OS-level locking.*

**2026-03-15 - WAF resilience**
```
feat: rotate user agents across requests for WAF resilience
Replace single hardcoded Firefox UA with a pool of 5 browser-like
strings, randomly selected per request.
```
*Single UA blocked by WAF - required rotation strategy.*

**2026-03-15 - Failed fetch retry strategy**
```
feat: add --retry-errors to re-fetch previously failed tenders
Adds get_fetch_errors() and clear_fetch_error() to TenderDB, and a
retry_errors() pipeline function.
```
*Silent fetch failures causing missed tenders - required explicit error tracking and retry mechanism.*

**2026-03-15 - Date format mismatch breaking alerts**
```
docs: add deadline warnings design spec
Fixes broken Spark deadline alerts (date format mismatch) and adds
upcoming deadlines section to digest output.
```
*Integration failure between systems due to date format assumptions.*

#### Technical Uncertainty References

- **Relevance scoring:** Configurable keyword weights, budget thresholds, scoring algorithm with empirical tuning
- **Edge cases:** 172 tests covering all production code paths, DB error rollback, parse edge cases
- **WAF interaction:** User agent rotation as empirical response to blocking
- **Concurrent access:** SQLite corruption prevention via fcntl.flock

---

## 8. Workstation Dotfiles

**Repository:** alastair/workstation-dotfiles
**Description:** Workstation configuration files and setup scripts for Fish shell, Ghostty terminal, tmux, and cross-machine deployment.

| Metric | Value |
|--------|-------|
| First commit | 2026-02-07 |
| Most recent commit | 2026-03-15 |
| Total commits | 48 |
| Test files | 0 |
| Monthly: Feb 2026 | 8 commits |
| Monthly: Mar 2026 | 40 commits |

### Key Activity

- **Fish + Ghostty migration:** Complete shell stack migration from Bash-only to Fish interactive / Bash scripting dual strategy
- **Cross-machine deployment:** dotpush function for rsync-based remote deployment
- **Design spec + implementation plan** for migration (phased 4-stage deployment across 7 environments)
- **Reliability fixes:** Guard for missing env files, pipefail, mktemp for temp files

*Limited R&D evidence - primarily operational tooling and configuration management.*

---

## 9. AI Coding Standards

**Repository:** alastair/ai-coding-standards
**Description:** Evidence-based engineering standards system for AI-assisted development, derived from analysis of 960+ commits across 7 repositories.

| Metric | Value |
|--------|-------|
| First commit | 2025-04-13 |
| Most recent commit | 2026-03-15 |
| Total commits | 18 |
| Test files | 0 |
| Monthly: Apr 2025 | 6 commits |
| Monthly: Mar 2026 | 12 commits |

### Key Activity

**2026-03-12 - v2: Evidence-based standards replacing generic guidelines**
```
feat: v2 - evidence-based standards system replacing generic guidelines
Replaces the original generic AI coding standards with a complete
evidence-based system derived from 960+ commits across 7 repositories.
```
*v1 generic standards found insufficient - replaced with evidence-derived standards based on empirical analysis of actual project outcomes.*

**2026-03-14 - Token discipline system**
```
feat: add CLAUDE.md token discipline (Rule 7.6) with three-tier
progressive disclosure
Evidence: cross-project audit found 3 of 7 projects over budget.
```
*Context window management as engineering challenge - required measurement and budgeting framework.*

---

## 10. Shared Email

**Repository:** alastair/shared-email
**Description:** Shared email processing package (thread extraction, reply composition, neomutt integration) used by ClearMail and Inbox Roulette.

| Metric | Value |
|--------|-------|
| First commit | 2026-03-07 |
| Most recent commit | 2026-03-15 |
| Total commits | 9 |
| Test files | 6 |
| Monthly: Mar 2026 | 9 commits |

### Key Activity

- Thread extractor, EML assembly, LLM draft generation with fallback
- OpenRouter LLM integration with graceful error fallback
- Shared library extracted to avoid duplication across ClearMail and Inbox Roulette

---

## 11. Inbox Roulette

**Repository:** alastair/inbox-roulette
**Description:** Gamified email processing system with XP, levels, streaks, and a rich terminal UI.

| Metric | Value |
|--------|-------|
| First commit | 2026-03-07 |
| Most recent commit | 2026-03-15 |
| Total commits | 8 |
| Test files | 12 |
| Monthly: Mar 2026 | 8 commits |

### Key Activity

- Phase 1 and Phase 2 markers in commit history
- 54 tests in initial module commit (DB, engine, notmuch, integration, edge-case, scoring)
- Gamification scoring system with mode-based email selection

---

## 12. GDrive Ops

**Repository:** alastair/gdrive-ops
**Description:** Google Workspace automation scripts via gws CLI.

| Metric | Value |
|--------|-------|
| First commit | 2026-03-14 |
| Most recent commit | 2026-03-15 |
| Total commits | 2 |
| Test files | 0 |
| Monthly: Mar 2026 | 2 commits |

*Early-stage scaffolding only. No R&D evidence yet.*

---

## 13. Cross-Project Summary

### Combined Timeline

```
2025-04                                                    ai-coding-standards
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2026-02  |                                                 workstation-dotfiles
         |   spark =====================================>>
         |       humansparkforge =======================>>
         |                      ragbuilder =============>>
2026-03  |               clearmail =====================>>
         |               tenderhelper ==================>>
         |               shared-email ==================>>
         |               inbox-roulette ================>>
         |                    sessionpilot =============>>
         |                          claritybot ========>>
         |                          gdrive-ops ========>>
         |                                                 ai-coding-standards
```

### Combined Monthly Commit Volume

| Month | Commits | Active Projects |
|-------|---------|-----------------|
| 2025-04 | 6 | 1 (ai-coding-standards) |
| 2026-02 | 293 | 4 (spark, humansparkforge, ragbuilder, workstation-dotfiles) |
| 2026-03 | 1,033 | 12 (all except commitreader) |
| **Total** | **1,332** | |

### Per-Project Commit Volume (March 2026)

| Project | Mar Commits | % of Mar Total |
|---------|------------|----------------|
| ClearMail | 235 | 22.7% |
| RAGBuilder | 194 | 18.8% |
| Spark | 187 | 18.1% |
| HumanSparkForge | 149 | 14.4% |
| SessionPilot | 72 | 7.0% |
| ClarityBot | 72 | 7.0% |
| TenderHelper | 54 | 5.2% |
| Workstation Dotfiles | 40 | 3.9% |
| AI Coding Standards | 12 | 1.2% |
| Shared Email | 9 | 0.9% |
| Inbox Roulette | 8 | 0.8% |
| GDrive Ops | 2 | 0.2% |

### Experimental Evidence Summary

| Project | Failed/Abandoned Approaches | Experimental Commits | Technical Uncertainty Refs | Test Files | Peak Tests |
|---------|---------------------------|---------------------|--------------------------|------------|------------|
| Spark | 24 | 6 | 47+ (prompt alone) | 261 | 2,043 |
| ClearMail | 22 | 18 | 30+ | 148 | 1,126+ |
| RAGBuilder | 17 | 21 | 12 | 102 | 210+ |
| HumanSparkForge | 18 | 12 | 20+ | 16 | 266 |
| SessionPilot | 4 | 2 | 12 | 60 | 272 |
| ClarityBot | 8 | 2 | 12+ | 13 | 215 |
| TenderHelper | 6 | 7 | 8 | 44 | 252 |
| Workstation Dotfiles | 10 | 4 | - | 0 | - |
| AI Coding Standards | 3 | 1 | 2 | 0 | - |
| Shared Email | 0 | 0 | 0 | 6 | - |
| Inbox Roulette | 0 | 1 | 0 | 12 | 54 |
| GDrive Ops | 0 | 0 | 0 | 0 | - |
| **Totals** | **112** | **74** | **143+** | **662** | **4,000+** |

### Strongest R&D Evidence by Category

**Systematic experimentation:**
- Spark: 6-model prompt reliability comparison (71-100% variance)
- Spark: Transcript audit cycle (62% -> 97.7% reliability through systematic diagnosis)
- HumanSparkForge: 16-iteration C.R.A.P. design refinement experiment
- ClarityBot: 4-layer defence evolution driven by adversarial discovery
- ClearMail: Closing detection validated against 624 real messages (100% precision)

**Failed approaches requiring redesign:**
- Spark: LLM hallucinations requiring architectural shift to pre-computation (3 distinct types)
- Spark: Night-owl rule moved from LLM prompt to deterministic code (model couldn't be trusted)
- Spark: 17-param god function extracted after empirical failure analysis
- RAGBuilder: Streamlit replaced with FastAPI (framework couldn't meet requirements)
- HumanSparkForge: CSS multi-column abandoned for CSS Grid; absolute positioning abandoned for flexbox
- ClearMail: notmuch tag:inbox matching all 34k messages + shallow parser dropping 18k messages

**Technical uncertainty resolution:**
- Prompt positional sensitivity (rules ignored when buried mid-prompt)
- Model-specific behavioural differences (DeepSeek ignoring preambles, Haiku hallucinating times)
- Unicode whitespace bypassing regex guards
- Race conditions in concurrent operations
- Token limit tuning through empirical measurement
- False positive rate management through observe mode

---

*Report generated from local git repositories on 2026-03-15. All dates are from git commit timestamps. Commit messages are reproduced verbatim.*
