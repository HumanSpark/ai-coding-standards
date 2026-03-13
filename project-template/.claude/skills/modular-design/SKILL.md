---
name: modular-design
description: Module boundary patterns, standard roles (client/processor/storage/output), typed interfaces, data flow pipeline. Use when creating modules, restructuring code, or wrapping external services.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(python -m pytest *)
---

# Modular Design Patterns

## When to Use
- Creating a new module or package within a project
- Extracting responsibilities from a file approaching 300 lines
- Designing how data flows between components
- Wrapping a new external service (API, database, email)
- Adding persistence or output generation
- User mentions "module", "boundary", "interface", "refactor", "extract"
- Re-explaining project context to Claude Code (symptom of missing boundaries)
- Starting a new project with multiple distinct responsibilities

## Core Principle: Structure Is Documentation

If Claude Code needs verbal context to understand a module, the module is
missing structural documentation. Every module should be understandable from
its README.md, __init__.py, and tests alone.

---

## Structural Patterns

### Module README as Contract

Every module with distinct responsibilities gets a README.md. This replaces
verbal context-setting in CC prompts.

Use the template from `docs/MODULE-README-TEMPLATE.md`. The five sections are:

1. **Purpose** - what it does AND what it does NOT do (boundary)
2. **Public Interface** - function signatures with types
3. **Dependencies** - internal (models, config), external (pip packages), I/O
4. **Known Issues** - anything broken or incomplete
5. **Testing** - run command, fixture description

Update the README when the module's interface changes. If the purpose section
starts describing two responsibilities, that's the signal to split.

### Public Interfaces via __init__.py

Other modules import from the package, never from internal files.

```python
# scraper/__init__.py
from .core import scrape_tenders, scrape_tender_detail

__all__ = ["scrape_tenders", "scrape_tender_detail"]
```

Why: reading __init__.py instantly reveals the module's public API. Internal
files can be refactored freely without changing imports elsewhere.

### Shared Typed Models (models.py)

Data structures that flow between modules live in a shared models file.
Frozen dataclasses for internal flow. Pydantic at validation boundaries only.

```python
@dataclass(frozen=True)
class Tender:
    """Immutable - modules receive tenders, they don't modify them."""
    reference: str
    title: str
    description: str
    published: datetime
```

New dataclass types for enriched data: when a processor adds information,
return a new type that wraps the input (e.g. ScoredTender with a Tender field).

### Typed Configuration (config.py)

All tuneable values in one place. Frozen dataclasses per module. Modules
receive their specific config section, never full AppConfig or raw env vars.

```python
@dataclass(frozen=True)
class ScraperConfig:
    base_url: str = "https://www.etenders.gov.ie"
    request_timeout: int = 30

@dataclass(frozen=True)
class AppConfig:
    scraper: ScraperConfig = field(default_factory=ScraperConfig)

    @classmethod
    def from_env(cls) -> "AppConfig":
        return cls(
            scraper=ScraperConfig(
                request_timeout=int(os.getenv("SCRAPER_TIMEOUT", "30")),
            ),
        )
```

---

## Standard Module Roles

Where things live. Not every project needs all roles - create as needed, but
put them in the standard location.

| Role | Flat layout | Package layout | Responsibility |
|------|-------------|----------------|----------------|
| **Client** | `{service}_client.py` | `clients/{service}.py` | Wraps one external service. Handles auth, retries, timeouts. Returns validated data (Pydantic → frozen dataclass). |
| **Storage** | `db.py` | `storage/` | Application state persistence. External data file ingestion is a client role. Accepts/returns frozen dataclasses. Owns schema. |
| **Processor** | `{concern}.py` | `{concern}/` | Pure business logic. NO I/O, no network, no database. Dataclasses in, dataclasses out. |
| **Output** | `{type}_writer.py` | `output/` | Generates deliverables (digests, reports, notifications). |
| **Entrypoint** | `cli.py` | `cli.py` or `main.py` | Thin orchestrator. Only file that imports from multiple modules. |
| **Models** | `models.py` | `models.py` | Shared frozen dataclasses. |
| **Config** | `config.py` | `config.py` | Typed configuration with from_env(). |

**Critical constraint: Processors have no I/O.** They take dataclasses in and
return dataclasses out. If a processor test needs a mock, something is in the
wrong layer.

---

## The Data Flow Pipeline

Data flows in one direction with explicit type transitions:

```
External source
    ↓
Client module (HTTP, IMAP, filesystem)
    ↓ raw response
Pydantic validation (in the client module)
    ↓ validated Pydantic model
Convert to frozen dataclass
    ↓ frozen dataclass (enters the internal system)
Processor module(s) (scoring, detection, transformation)
    ↓ enriched/transformed frozen dataclass
Output module (digest, notification, UI) or Storage module
```

Rules:
1. **Pydantic at the edge only.** Client modules validate, convert, return
   frozen dataclasses. No other module imports Pydantic.
2. **Processors are pure.** No I/O. If a test needs a mock, wrong layer.
3. **The entrypoint owns the pipeline.** The sequence is readable in one file.
4. **New types for enriched data.** TenderNotification → TenderDetail →
   ScoredTender. Each stage has its own type.

---

## External Service Clients

1. **One client per service.** Even if 40 lines. Replaceable and testable.
2. **Clients accept config, not raw credentials.**
3. **Clients return validated data.** Callers never see raw HTTP responses
   or BeautifulSoup objects.
4. **Clients handle retries and timeouts.** Config-driven (Rule 12.4).
5. **Tests use saved response fixtures.** Capture with curl, commit to
   `tests/fixtures/`. Name: `{service}_{scenario}.{ext}` -
   e.g. `etenders_cft_standard.html`, `etenders_cft_dps.html`.

---

## Error Handling at Module Boundaries

1. **Modules raise, the entrypoint catches.** Modules raise specific
   exceptions. The CLI catches and decides (log and continue, abort, retry).
   Never silently swallow.
2. **External errors are wrapped.** Client modules catch library exceptions
   and re-raise as project-specific exceptions. Implementation details don't
   leak.
3. **Processors never raise I/O errors.** They have no I/O. Only ValueError,
   TypeError, or domain-specific exceptions.
4. **Always include context.** Pass resource ID, URL, or input that caused
   the failure.

```python
class TenderFetchError(Exception):
    """Raised when a tender detail page cannot be fetched or parsed."""
    pass

class DPSPageError(TenderFetchError):
    """Raised for DPS pages with a different HTML structure."""
    pass
```

---

## Logging Conventions

1. **Every module:** `logger = logging.getLogger(__name__)` after imports.
2. **Entrypoint only:** `logging.basicConfig()` called once. Modules never
   configure logging.
3. **Levels:** DEBUG (internal state), INFO (pipeline progress), WARNING
   (recoverable), ERROR (output-affecting failures).
4. **Include identifiers:** `logger.warning("Timeout fetching %s", resource_id)`
   not `logger.warning("Timeout")`.
5. **No print in modules.** Only `print()` in entrypoint for user-facing
   output (e.g. --dry-run).

---

## CC Workflow

### Working on an existing module
```
Read src/project_name/scraper/README.md and tests/test_scraper.py, then
implement the fix in src/project_name/scraper/core.py.
Run make test-module MOD=scraper to verify.
```

### Adding a new module
```
Read src/project_name/models.py and src/project_name/scraper/README.md for
the pattern. Create a new module at src/project_name/notifier/ following
the same structure. Write tests first (Tier 1).
```

### Deciding what role a new file plays
Ask: "Does this file do I/O?" If yes, it's a client or storage module.
If no, it's a processor. Processors are pure - no mocks needed in tests.

---

## When This Structure Applies

**Yes if:**
- More than 3 source files with distinct responsibilities
- You've re-explained context to CC more than twice
- Files approaching 300-line extraction threshold
- You expect to maintain it beyond 6 months

**No if:**
- Single-purpose script under 200 lines
- One-off automation
- Exploratory spike (spike first, modularise when approach is validated)

---

## New Module Checklist

- [ ] Determine role: client, processor, storage, or output?
- [ ] Directory created with README.md, __init__.py, core.py
- [ ] README has purpose (including what it does NOT do), interface, deps
- [ ] __init__.py has public exports and __all__
- [ ] New types added to models.py if needed (frozen dataclasses)
- [ ] New config section added to config.py if needed
- [ ] If client: handles retries, returns validated data, has fixture tests
- [ ] If processor: no I/O, dataclasses in/out, no mocks needed in tests
- [ ] Tests written against the public interface
- [ ] Fixtures saved in tests/fixtures/ for external data
- [ ] Logger created: `logger = logging.getLogger(__name__)`
- [ ] Exception types defined if callers need to handle errors
- [ ] CLAUDE.md key files table updated

## Anti-Patterns

- Do NOT create module READMEs for simple utility files
- Do NOT put all types in one models.py past 300 lines - split by domain
- Do NOT test internal helper functions directly - test through public interface
- Do NOT pass full AppConfig to modules - pass their specific config section
- Do NOT import from another module's internal files - use __init__.py
- Do NOT do I/O in processors - if a test needs a mock, wrong layer
- Do NOT configure logging in modules - only in the entrypoint
- Do NOT catch exceptions inside modules to silently continue
- Do NOT let callers see raw HTTP responses or library objects from clients
