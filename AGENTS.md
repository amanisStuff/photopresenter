# AGENTS.md — PhotoPresenter

## Quick start

```bash
flutter run -d linux          # dev
flutter test                  # tests (single widget test exists)
flutter analyze               # lint (must pass before commit)
flutter build linux --release # release bundle
```

## Architecture

Four-layer structure under `lib/`:

| Layer | Dir | Responsibility |
|-------|-----|----------------|
| Core | `core/entities/`, `core/providers/`, `core/strategies/` | Data models, Riverpod Notifiers, strategy pattern |
| Infrastructure | `infrastructure/services/`, `service_providers.dart` | IO wrappers, DI wiring |
| Interfaces | `interfaces/screens/`, `interfaces/widgets/` | UI — 21 widgets, 2 screens |
| Shared | `shared/theme.dart`, `shared/widgets/` | WMP9/Luna theme, shared utilities |

Riverpod is the only state management — no `setState` for business logic. `PresentationNotifier` (~830 lines) owns all slideshow state via immutable `PresentationState`.

## Key conventions

- **No comments** in code unless explicitly requested
- **`const` constructors** preferred
- **`snake_case`** for files, **`PascalCase`** for classes
- **No `StatefulWidget`** where logic is involved (use Riverpod notifiers)
- **`useMaterial3: false`** — custom theme, not M3
- Dialog text contrast fix: use `AppTheme.onSurface` (#2A2A2A) on silver controls bar; avoid `primaryLight` (#4A7AE8) on dark surfaces (fails WCAG AA)

## Widget composition rules

- **One widget per file** — every public widget class gets its own `.dart` file
- **Every section extracted** — any widget subtree with 15+ lines or 3+ children in a `Wrap`/`Row`/`Column` must be extracted into a named `ConsumerWidget`/`StatelessWidget`
- **`build()` as a table of contents** — a `build()` method should compose named children, not inline entire UIs. Target <60 lines per `build()`
- **No abbreviations** in any name: `canGoToPrevious` not `canPrev`, `value` not `val`, `remainingTimerSeconds` not `secondsLeft`
- **Descriptive file names** match the widget class name (e.g., `timer_status_section.dart` contains `TimerStatusSection`)

## State management

- `presentationProvider` / `PresentationNotifier` — slideshow, audio, class mode, filters
- `settingsProvider` / `SettingsNotifier` — timer, audio mode, class presets (no persistence — in-memory only)
- `service_providers.dart` wires WindowService, FileService, ClipboardService, AudioService, GalleryService

## Strategies (under `core/strategies/`)

- `audio_mode_strategy.dart` — sealed class: `AudioDrivenStrategy` / `TimerDrivenStrategy`
- `image_filter_decorator.dart` — 9 filter implementations (None, Grayscale, Sepia, Invert, Bright, High Contrast, Extreme Contrast, Blur, Heavy Blur)
- `strategy_providers.dart` — returns strategy based on `settings.audioMode`

## Testing

Single file: `test/widget_test.dart`. No provider/business-logic tests exist (notable gap).

## Troubleshooting

- `flutter clean && flutter pub get` for build issues
- Window not showing → check `WindowService.initialize()` in `main.dart`
- Audio not playing → check file format (mp3/wav) and path validity

## Related docs

- `AGENT_CONTEXT.md` — deeper architecture and state
- `project_constitution.json` — architectural principles (partially aspirational)
- `HELP.md`, `DEVELOPERS.md`, `FEATURES.md` — user and dev docs
- `lib/features/settings/screens/` is empty — do not duplicate settings code there; use `lib/interfaces/screens/settings_screen.dart`
