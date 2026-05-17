# core/providers/

Riverpod state management. All business logic lives here — never in widgets.

- `presentation_provider.dart` — `PresentationNotifier` (~830 lines). Owns slideshow playback, audio sync, class mode orchestration, and image filtering via `PresentationState`.
- `settings_provider.dart` — `SettingsNotifier`. Manages timer duration, audio mode, class presets, and viewport toggle. In-memory only (no persistence).
