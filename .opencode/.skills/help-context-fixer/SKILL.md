---
name: help-context-fixer
description: Triggered when help/documentation lookup fails. Verifies HELP.md integrity and creates context fix logs.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: debugging
---
## What I do
When help/documentation lookup fails, I:
1. Verify HELP.md exists and is readable
2. Check README.md as fallback if HELP.md fails
3. Search codebase for relevant documentation
4. Create a log entry tracking the failed prompt and implementation

## Context Fixer Log Format
Each failed help lookup is logged to `context_fixer_aid.json`:
- timestamp (ISO 8601)
- prompt_that_failed: original user prompt
- implementation_attempted: what was attempted
- context_sources_checked: files/directories checked
- outcome: success | partial | failed

## When to use me
Use this when:
- User says "help failed", "no help", "documentation error"
- HELP.md is missing or incomplete
- Context lookup fails for any help-related query

## Related Files
- HELP.md
- README.md
- project_constitution.json
- bin/context_fixer (executable for manual logging)