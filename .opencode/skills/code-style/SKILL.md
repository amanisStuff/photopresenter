---
name: code-style
description: A comprehensive guide for maintaining high-quality, readable, and maintainable code following CUPID principles and descriptive naming conventions.

license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: debugging
---

 
## Principles

### COMPOSABILITY
Focus on creating small, modular components that can be easily combined to build complex systems. Ensure that interfaces are clean and dependencies are minimal to facilitate seamless integration.

### UNIX PHILOSOPHY
Each module or function should have a single, well-defined responsibility. Aim for simplicity and excellence in performing one specific task.

### PREDICTABILITY
Code should behave in a consistent and expected manner. Avoid side effects and hidden logic; given the same input, the output should be reliable and the state changes transparent.

### IDIOMATIC CODE
Adhere to the established conventions and patterns of the language and framework being used. Write code that is familiar and readable to other developers in the community.

### DOMAIN-DRIVEN DESIGN
Align the code structure and naming conventions with the business domain. Use terminology that reflects the actual processes and entities of the project (e.g., use `PhotoGallery` and `SlideTransition` for a photo presentation application).

### DESCRIPTIVE LANGUAGE
Use full, meaningful names for all variables, functions, directories, modules, and classes. Abbreviations are strictly prohibited to ensure maximum clarity.
*   **Incorrect:** `const di = container.get('dep');`
*   **Correct:** `const dependencyInjection = container.get('dependency');`

