---
name: themes
description: A centralized style manager for handling dynamic color palettes, typography, and UI states.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: debugging, UI-development
  version: 2.1.0
---

## Principle

Every visual value in the UI (color, text style, border, padding, shadow, gradient, decoration) must be defined inside `AppTheme` in `lib/shared/theme.dart`. Widget code must never contain hardcoded visual constants or inline style definitions.

## Rules

### 1. Centralization

All of the following must live as named members of `AppTheme`:

- **Colors** — `static const Color`
- **Text Styles** — `static TextStyle get`
- **Box Decorations** — `static BoxDecoration get` (gradients, borders, border radius, shadows)
- **Shadows** — `static List<BoxShadow> get`
- **Padding / Insets** — `static EdgeInsets get` (if a padding value is reused outside a single widget)
- **Durations** — `static Duration get` (if an animation duration is reused)

### 2. No Inline Styles

- `TextStyle(...)` is forbidden in widget `.dart` files (except `theme.dart` itself).
- `Border(...)`, `Border.all(...)`, `BoxShadow(...)` are forbidden in widget files — use a named `BoxDecoration` getter instead, or add one.
- `EdgeInsets(...)` should come from a getter when the same padding appears in more than one widget.
- `LinearGradient(...)` is forbidden in widget files.
- `Color(0xFF...)` is forbidden in widget files.

### 3. Naming Convention

| Prefix | Type | Example |
|--------|------|---------|
| (color) | `static const Color` | `primary`, `background`, `onSurface` |
| `card*` / `tile*` | `TextStyle` / `BoxDecoration` for card/tile surfaces | `cardTitleStyle`, `tileOuterDecoration` |
| `dialog*` | Dialog-specific values | `dialogTitleStyle` |
| `button*` | Button gradient stops, decorations | `buttonGradientTop`, `buttonDecoration(...)` |
| `textField*` | Text field styles | `textFieldInputStyle` |
| `overlay*` | Overlay/layer styles | `overlayTitleStyle` |
| `section*` | Section header styles | `sectionHeaderStyle` |
| `settings*` | Settings screen specific | `settingsBackground` |
| `presentation*` | Presentation screen specific | `presentationBackground` |
| `controlsBar` / `headerDecoration` | Screen chrome | — |

### 4. Contrast Responsibility

The `AppTheme` class is solely responsible for ensuring sufficient contrast. Widget code must not override colors for contrast reasons — if text is illegible on a given surface, add a new `TextStyle` getter or a new `BoxDecoration` getter rather than patching it inline.

### 5. Adding New Values

When a widget needs a visual value that doesn't exist yet:

1. Scan `theme.dart` for the closest existing match.
2. If no match exists, add a new named getter following the naming convention above.
3. Name it after its **semantic role** (e.g., `phaseLabelStyle`, `tileSubtitleStyle`), not after its visual properties.

### 6. Enforcement

- `flutter analyze` must pass with zero violations.
- `flutter test` must pass with zero failures.
- Review imports: `theme.dart` should be the only file containing `Color(0xFF`, `TextStyle(`, `Border(`, `BoxShadow(`, `LinearGradient(`, or `BoxDecoration(`.
