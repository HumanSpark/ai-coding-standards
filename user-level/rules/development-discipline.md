# Development Discipline

Meta-rules for working inside Claude Code sessions. These govern *how* the
agent operates, not *what* the code should look like (that's CLAUDE.md's job).

## Guard against context decay

After 10+ tool uses in a single session, re-read any file before editing it.
Auto-compaction silently drops file contents from context, and you will edit
against stale state without realising. Do not trust your memory of a file's
contents - re-read it.

## Verify edits applied

After every file edit, re-read the file to confirm the change landed correctly.
The edit tool fails silently when `old_string` does not match due to stale
context - the file is unchanged but no error is reported. Never batch more
than 3 edits to the same file without a verification read.

## Assume tool output is truncated

Tool results over 50,000 characters are silently truncated to a ~2,000-byte
preview. If any grep, test run, or command output returns suspiciously few
results or seems incomplete, re-run with narrower scope (single directory,
stricter glob, specific test file). State when you suspect truncation
occurred rather than drawing conclusions from partial output.

## Sub-agents: use for independent work only

For tasks touching many files, consider parallel sub-agents - but only when
the files are genuinely independent. Each sub-agent gets its own context
window and cannot see what other agents are doing. Safe: updating README
files across projects, adding file headers to unrelated modules, running
independent test suites. Unsafe: any files that share imports, consume the
same SparkCore types, or sit on the same Layer 1/2/3 dependency chain. When
in doubt, work sequentially. If using sub-agents, list which files each
agent owns and confirm there are no cross-agent import dependencies before
launching.
