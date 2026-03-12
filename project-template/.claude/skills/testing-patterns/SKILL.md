---
name: testing-patterns
description: Pytest testing patterns, TDD tiers, edge case checklist, mocking conventions. Use when writing tests, creating fixtures, or following test-first workflow.
allowed-tools: Read, Grep, Glob, Bash(python -m pytest *)
---

# Testing Patterns

## When to Use
- Writing any new test file
- Adding tests to an existing module
- User mentions "tests", "testing", "TDD", "coverage", "fixtures"
- Creating mocks or fixtures for external services

## Three-Tier Testing Discipline

The user will specify which tier applies. If not specified, default to Tier 2.

### Tier 1 - Tests First (TDD)
Write tests BEFORE implementation. Applies to:
- Security boundaries and sanitisation
- Protocol/spec compliance (RFC, API contracts)
- Data validation layers
- Anything with a formal specification

### Tier 2 - Tests Alongside (Default)
Write tests in the SAME COMMIT as the feature. Never commit a feature without its tests.

### Tier 3 - Gap-Fill
Retrospective test coverage for legacy code. Only when user explicitly requests it.

## Edge Case Checklist

Walk this checklist for EVERY function under test:

- **Empty/missing:** empty strings, None/null, missing dict keys, empty lists/dicts
- **Boundary strings:** very long strings (10k+ chars), single character, whitespace-only
- **Unicode:** emoji, Arabic, Chinese, mixed scripts, zero-width characters
- **Numeric:** zero, negative, sys.maxsize, very small floats, float('inf'), float('nan')
- **Type mismatches:** string where int expected, list where dict expected, None where object expected

## Test Structure

```python
def test_descriptive_name_of_behaviour():
    """What this test verifies and why it matters."""
    # Arrange
    input_data = create_test_fixture()

    # Act
    result = function_under_test(input_data)

    # Assert
    assert result.status == "expected"
```

## Mocking Conventions

- Use `unittest.mock.patch` for all external services
- NEVER hit real external APIs in unit tests
- Place shared fixtures in `tests/conftest.py`
- Store test data in `tests/fixtures/` - never use real personal data

## Anti-Patterns

- Do NOT write happy-path-only tests
- Do NOT test implementation details (private methods, internal state)
- Do NOT use `time.sleep()` in tests - mock time-dependent behaviour
- Do NOT leave `TODO: add tests` without actually adding them in the same commit
