---
name: prompt-engineering
description: System prompt conventions, LLM prompt assembly, boundary markers, prompt reliability testing. Use when writing or modifying LLM system prompts, building context injection, or working with prompt templates.
allowed-tools: Read, Grep, Glob
---

# Prompt Engineering Patterns

## When to Use
- Writing or modifying system prompts (core.txt, strategic.txt, etc.)
- Building context assembly / prompt injection pipelines
- Working with `.format()` templates for LLM prompts
- Adding prompt reliability test scenarios

## Prompts Are Code

System prompts are version-controlled engineering artefacts with the same discipline as Python files: tracked in git, reviewed, tested via reliability suites, documented in CLAUDE.md.

## Template Conventions

Python `.format()` for prompt templates:
- Literal braces doubled: `{{` and `}}`
- Placeholders in single braces: `{todays_date}`, `{task_summary}`
- Document all placeholders in CLAUDE.md key patterns section

## Data Boundary Markers

Untrusted data MUST be wrapped:

```
--- BEGIN TASKS DATA ---
{tasks_content}
--- END TASKS DATA ---
```

For RAG contexts, use XML tags (harder to forge):
```xml
<document source="user-uploaded">
{document_content}
</document>
```

## Context Poisoning Prevention

- Summarise data-heavy replies before storing in conversation history
- Validate conversation history roles: only `user` and `assistant`
- Strip system-like content from stored responses

## Prompt Reliability Testing

Separate test file hitting the real LLM API. Track scenario count in CLAUDE.md.

```python
# tests/test_prompt_reliability.py - NOT in regular pytest suite
SCENARIOS = [
    {
        "name": "explicit_calendar_no_time_creates_all_day",
        "message": "Create a calendar appt next Tuesday",
        "checks": [
            lambda r: "create_event" in str(r.get("file_ops", [])),
        ],
    },
]
```

## Anti-Patterns

- Do NOT rely on prompt rules alone for security
- Do NOT use `---` delimiters for RAG document boundaries
- Do NOT store raw data-heavy responses in conversation history
- Do NOT hardcode model names in prompts - use config
