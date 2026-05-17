# shared/theme/

WMP9/Luna-inspired visual style. Everything that controls the look and feel.

- `colors.dart` — Colour palette constants
- `typography.dart` — Text styles and font configuration
- `decorations.dart` — Box decorations, borders, and button styles
- `theme_style.dart` — Abstract base for theme variants
- `light_theme_style.dart` / `dark_theme_style.dart` — Concrete light and dark theme implementations
- `theme_mode.dart` — Enum for theme mode selection (light/dark/system)
- `theme_composition.dart` — Composes theme from parts
- `theme_choices.dart` — Available theme options
- `theme_notifier.dart` — Riverpod notifier for switching themes at runtime
