---
name: structure-things
description: give the agent a general idea about the app
---
# Instructions

### PHASE 1: Architectural Design & Compartmentalization
To ensure the project is maintainable and scalable, you MUST adhere to the following structural guidelines:

1.  **SOLID & CUPID Principles:** 
    *   **Single Responsibility:** Each module, class, or function must have one reason to change.
    *   **CUPID focus:** Prioritize **C**omposable, **U**nix-style (small/focused), **P**redictable, **I**diomatic, and **D**omain-driven code.
2.  **Directory Hierarchy:**
    *   `/src/core`: Business logic and domain entities (framework-agnostic).
    *   `/src/infrastructure`: External implementations (database, API clients, file system).
    *   `/src/interfaces`: Entry points (CLI, Controllers, Event Listeners).
    *   `/src/shared`: Reusable utilities and constants.
3.  **Naming Conventions:**
    *   Use descriptive, intention-revealing names.
    *   Follow the project-specific casing (e.g., `PascalCase` for classes, `camelCase` for functions) as identified in `AGENT_CONTEXT.md`.
    *   No abbreviations in any name — every variable, parameter, class, and file must be spelled out fully.

### PHASE 2: Implementation Protocol
When creating or refactoring components:
- **Decoupling:** Use Dependency Injection or Interfaces to ensure that high-level modules do not depend on low-level implementations.
- **Encapsulation:** Keep internal state private; expose only what is necessary through a clean public API.
- **Consistency:** Ensure that new modules follow the existing folder structure and naming patterns discovered during the "Read-Smartly" phase.
- **Modular Extraction:** Every distinct section of logic or layout MUST be extracted into its own named module or class. No single function or method should exceed a target line count (e.g., 60 lines for UI frameworks, 30 lines for business logic); if it does, extract inline subtrees into named abstractions.

### PHASE 3: Documentation & Handoff
To facilitate seamless collaboration and future maintenance:
- **Self-Documenting Code:** Write code that is readable enough to minimize the need for comments, using clear variable names and small, focused functions.
- **Module Manifests:** If a new directory or significant module is created, ensure it contains a local `README.md` explaining its purpose and how it fits into the overall architecture.
- **Traceability:** Ensure every structural change is reflected in the `AGENT_CONTEXT.md` to maintain a single source of truth for the project's architectural state.

**GOAL:** Maintain a clean, modular, and predictable codebase that allows any developer to understand the system's intent and structure at a glance.
