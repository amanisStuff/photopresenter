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

A module or component should be discoverable by name, not buried inside another file. If a piece of logic or UI layout can be named, extract it into its own module.

- **Incorrect:** A single 500-line function with inline rendering, repeated patterns, and nested conditionals.
- **Correct:** A short function that composes named sub-components, each in its own file with a descriptive name.

### UNIX PHILOSOPHY
Each module, class, or function should have a single, well-defined responsibility. Aim for simplicity and excellence in performing one specific task. One entity per file. If a helper is reused across modules, promote it to a public export in its own file.

### PREDICTABILITY
Code should behave in a consistent and expected manner. Avoid side effects and hidden logic; given the same input, the output should be reliable and the state changes transparent.

### IDIOMATIC CODE
Adhere to the established conventions and patterns of the language and framework being used. Write code that is familiar and readable to other developers in the community. When in doubt, match the style of neighboring files.

### DOMAIN-DRIVEN DESIGN
Align the code structure and naming conventions with the business domain. Use terminology that reflects the actual processes and entities of the project (e.g., use `PhotoGallery` and `SlideTransition` for a photo presentation application).

### DESCRIPTIVE LANGUAGE
Use full, meaningful names for all variables, functions, directories, modules, and classes. Abbreviations are strictly prohibited to ensure maximum clarity.

- **Incorrect:** `const di = container.get('dep');`
- **Correct:** `const dependencyInjection = container.get('dependency');`
- **Incorrect:** `function getUsr(n) { ... }`
- **Correct:** `function getUserByName(name) { ... }`

## Extraction Thresholds (Framework-Agnostic)

Any code segment that meets one or more of the following thresholds MUST be extracted into its own named module, class, or function:

| Threshold | Action |
|-----------|--------|
| 15+ lines of logic or nested structure | Extract into a named function or class |
| Repeated pattern appearing 2+ times | Extract into a reusable function or component |
| Complex conditional or builder block | Extract into a named entity |
| A group of 3+ related children (rows, items, cases) | Extract into a named sub-component |

### Naming Patterns
- **Section/grouping modules:** `{Domain}Section` or `{Domain}Group` (e.g., `TimerStatusSection`, `UserProfileCard`)
- **Reusable utilities:** `{Verb}{Noun}` (e.g., `formatCurrency`, `validateEmail`)
- **Functions:** `verbNoun` (e.g., `showLoadDialog`, `calculateTotal`)
- **Variables:** full descriptive camelCase or snake_case per language convention — no abbreviations

## Project Examples (PhotoPresenter — Flutter/Dart)

The following patterns are specific to the PhotoPresenter project and demonstrate the principles above:

```
controls/
├── presentation_controls.dart    # Composition root — ~50 lines, composes named children
├── timer_status_section.dart      # Extracted section widget
├── playback_section.dart          # Extracted section widget
├── actions_section.dart           # Extracted section widget
├── silver_controls.dart           # Shared reusable widgets
├── audio_mode_toggle.dart         # Single widget per file
└── class_mode_button.dart         # Single widget per file
```

- Every public widget class gets its own `.dart` file
- Every visual section in a widget tree is extracted into a named `ConsumerWidget`/`StatelessWidget`
- `build()` methods read like a table of contents — target <60 lines
- No `setState` for business logic (use Riverpod notifiers)
