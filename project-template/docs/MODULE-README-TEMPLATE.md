# Module README Template

Copy this template into each module directory as `README.md` and fill in
the sections. This file serves as the contract between the module and
everything that consumes it - including Claude Code.

Keep it short. If it takes more than 30 seconds to read, it's too long.

---

```markdown
# {Module Name}

## Purpose
{One sentence: what this module does. Then one sentence: what it does NOT do.
The boundary statement is as important as the purpose statement. If you find
yourself describing two distinct responsibilities, split the module.}

## Public Interface
- `function_name(arg: Type, arg: Type) -> ReturnType`
  {Brief description of what it does and any important behaviour.}
- `another_function(arg: Type) -> ReturnType`
  {Brief description.}

## Dependencies
- **Internal:** {which models.py types and config.py sections it uses}
- **External:** {pip packages - requests, beautifulsoup4, etc.}
- **I/O:** {what it reads, writes, or calls - network, filesystem, database}

## Known Issues
- {Anything broken, incomplete, or requiring workaround. Include file/line
  references where possible. Remove items as they're resolved.}

## Testing
{Run command, e.g.: `pytest tests/test_module_name.py -v`}
{What the test fixtures contain and where they live.}
{Any special setup needed to run the tests.}
```

---

## Guidance

**When to create a module README:** When the module has a distinct
responsibility, a public interface that other code imports, and enough
complexity that reading the code alone isn't sufficient context.

**When NOT to create one:** For simple utility files, single-function
helpers, or modules where the __init__.py and docstrings provide
sufficient documentation.

**Keeping it current:** Update the README in the same commit as any
interface change. If the public interface section doesn't match
__init__.py, the README is stale.
