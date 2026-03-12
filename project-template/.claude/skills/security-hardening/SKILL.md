---
name: security-hardening
description: Security patterns for external data handling, sanitisation, prompt injection defence, SafetyValve pattern. Use when handling user input, external APIs, file uploads, email, calendar data, or LLM prompt assembly.
allowed-tools: Read, Grep, Glob
---

# Security Hardening

## When to Use
- Processing any external data (API responses, user input, file uploads)
- Handling email headers, calendar events, or invoice data
- Building LLM system prompts with injected data
- Adding authentication or authorisation
- Creating file read/write operations

## Core Principle: Sanitise First, Feature Second

Write the sanitisation layer BEFORE the feature that consumes external data.

```python
def sanitize_for_prompt(text: str, max_length: int = 500) -> str:
    """Strip characters that could break prompt structure."""
    text = text.replace("|", "")
    text = text[:max_length]
    return text.strip()
```

## The SafetyValve Pattern

For any component where an LLM can trigger state mutations:

1. **Whitelist allowed files** - explicit list, not a blacklist
2. **Whitelist allowed operations** - add_task, update_status, etc.
3. **Rate limits** - MAX_OPS_PER_RESPONSE, MAX_CONTENT_LENGTH
4. **Read-only declarations** - files the system reads but NEVER writes
5. **Validation before execution** - every op validated before state mutation

## Prompt Injection Defence

- Boundary markers: `--- BEGIN/END DATA ---` around untrusted data
- XML `<document>` tags in RAG contexts (harder to forge than `---`)
- Summarise data-heavy replies before storing in conversation history
- Sanitise history roles: only `user`/`assistant` allowed

## The Lethal Trifecta

NEVER combine in one component:
1. Unrestricted data access
2. Untrusted content
3. Autonomous action

Use delegated automation: system proposes, human confirms.

## Anti-Patterns

- Do NOT add security as an afterthought
- Do NOT rely on prompt rules alone (72% of failures are code/architecture)
- Do NOT expose API keys in tracebacks or logs
- Do NOT trust LLM-generated file paths without validation
