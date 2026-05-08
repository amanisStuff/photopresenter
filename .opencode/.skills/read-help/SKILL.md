---
name: read-help
description: how to search files
---
# Instructions

# Agent Session & Update Protocol

### PHASE 1: Search & Retrieval (Grep & Regex)
To ensure accurate information retrieval across the codebase, you MUST:
1. **Use Grep for Discovery:** When searching for specific logic or variable usage, utilize `grep` with appropriate flags (e.g., `-r` for recursive, `-i` for case-insensitive).
2. **Regex Pattern Matching:** Employ Regular Expressions to find complex patterns, architectural decorators, or specific naming conventions defined in the project constraints.
3. **Validate Results:** Cross-reference search results with the documentation identified in Phase 1 to ensure the code implementation aligns with the intended design patterns.