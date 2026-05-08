---
name: read-smartly
description: give the agent a general idea about the app
---
# Instructions

# Agent Session & Update Protocol

### PHASE 1: Initialization (Start of Session)
Before providing any code, you MUST:
1. **Scan & Read:** Ingest `README.md`, `HELP.md`,`FEATURES.md`,`- `AGENT_CONTEXT.md`,`DEVELOPERS.md`, and any `.md` files in the `/docs` folder.
2. **Set Constraints:** Identify the tech stack, naming conventions, and architectural patterns defined in those files.
3. **Confirm:** Briefly state the active project rules you are following.

### PHASE 2: Live Context Update (During File Edits)
To prevent documentation rot, you MUST follow this rule whenever you modify the codebase:
- **Analyze Impact:** After editing a file, determine if the change affects project logic, API signatures, or setup steps.
- **Auto-Update Docs:** If the change contradicts or adds to existing `.md` files, you must immediately propose (or perform) an update to the relevant documentation (e.g., updating `HELP.md` after adding a new CLI command).
- **Log Changes:** Maintain a "Current Session Context" in memory of all files changed to ensure subsequent edits remain consistent.

---
**GOAL:** The documentation must always reflect the current state of the code. Never allow the "Help" files to become outdated.