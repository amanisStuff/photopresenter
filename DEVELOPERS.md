# PhotoPresenter Developer Guide

## Overview

PhotoPresenter is a Flutter desktop application for image slideshows with audio, focus mode, and class mode for figure drawing practice.

---

## Development Environment

### Prerequisites

- Flutter SDK 3.x
- Linux (primary target), Windows, or macOS
- `flutter` and `dart` in PATH

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd photopresenter

# Get dependencies
flutter pub get

# Run in debug mode
flutter run -d linux

# Build release
flutter build linux --release
```

### Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Domain entities & business logic
│   ├── entities/                      # Framework-agnostic data models
│   │   ├── presentation_image.dart    # Image data model
│   │   ├── class_session.dart         # Class mode session model
│   │   ├── app_settings.dart          # App settings & class presets
│   │   └── gallery_manifest.dart      # Gallery manifest data model
│   ├── providers/                     # Riverpod Notifier business logic
│   │   ├── presentation_provider.dart # Main slideshow state management
│   │   └── settings_provider.dart     # Settings state management
│   └── strategies/                    # Strategy pattern implementations
│       ├── audio_mode_strategy.dart   # Sealed class for audio/timer driven modes
│       ├── strategy_providers.dart    # Riverpod provider for strategy selection
│       └── image_filter_decorator.dart# Color filter effect implementations
├── infrastructure/                    # External implementations & DI
│   ├── services/                      # IO / platform wrappers
│   │   ├── window_service.dart        # Window management (fullscreen, focus mode)
│   │   ├── file_service.dart          # File picking (native file dialog)
│   │   ├── clipboard_service.dart     # Clipboard operations (paste images/files)
│   │   ├── audio_service.dart         # Audio playback
│   │   └── gallery_service.dart       # Gallery save/load operations
│   └── service_providers.dart         # Riverpod DI wiring for services
├── interfaces/                        # UI layer (entry points, screens, widgets)
│   ├── screens/                       # Full-page views
│   │   ├── presentation_screen.dart   # Main screen with keyboard shortcuts
│   │   └── settings_screen.dart       # Settings UI
│   └── widgets/                       # Composable UI components (21 widgets)
│       ├── add_image_card.dart        # Add image placeholder card
│       ├── audio_mode_tile.dart       # Audio mode radio list (settings)
│       ├── audio_mode_toggle.dart     # TMR/AUD toggle button (controls)
│       ├── break_overlay.dart         # Break timer overlay
│       ├── class_mode_button.dart     # Class mode toggle button
│       ├── class_mode_dialog.dart     # Class mode configuration dialog
│       ├── class_phase_indicator.dart # Current phase label
│       ├── class_preset_tile.dart     # Class preset display tile
│       ├── custom_title_bar.dart      # Custom window title bar
│       ├── draggable_image_card.dart  # Draggable/reorderable image card
│       ├── edit_preset_dialog.dart    # Add/edit class preset dialog
│       ├── focus_timer_overlay.dart   # Focus mode timer overlay
│       ├── image_display.dart         # Full-screen image display
│       ├── image_grid.dart            # Image library grid view
│       ├── load_gallery_dialog.dart   # Gallery load/delete dialog
│       ├── number_input_row.dart      # Stepper row for numeric input
│       ├── presentation_controls.dart # Bottom control bar
│       ├── section_header.dart        # Settings section label
│       ├── settings_tile.dart         # Reusable settings row
│       ├── silver_controls.dart       # Silver-themed buttons
│       └── timer_adjustment.dart      # Timer increment/decrement
└── shared/                            # Reusable utilities & constants
    ├── theme.dart                     # App theming (WMP9/Luna theme)
    └── widgets/
        └── clickable.dart             # Custom clickable widget
```

---

## Architecture

### Layered Structure

The codebase follows a **four-layer architecture** based on SOLID & CUPID principles:

| Layer | Path | Responsibility |
|-------|------|----------------|
| **Core** | `lib/core/` | Domain entities & business logic (framework-agnostic data models + Riverpod providers) |
| **Infrastructure** | `lib/infrastructure/` | External implementations (file I/O, audio, clipboard, window management) |
| **Interfaces** | `lib/interfaces/` | UI layer (screens, widgets, entry point) |
| **Shared** | `lib/shared/` | Reusable utilities, theme, shared widgets |

Dependency flows inward: `interfaces → core ← infrastructure`, with `shared` available to all layers.

### State Management

The app uses **Riverpod** for state management with two main providers:

1. **PresentationProvider** (`core/providers/presentation_provider.dart`)
   - Manages slideshow state: images, playback, timers, audio, focus mode, class mode
   - Handles all user interactions
   - Contains ~830 lines of core logic

2. **SettingsProvider** (`core/providers/settings_provider.dart`)
   - Manages app settings: timer duration, audio mode, class presets
   - Persists settings to local storage

### Services

Services are injected via Riverpod providers in `infrastructure/service_providers.dart`:

| Service | Purpose |
|---------|---------|
| WindowService | Window management (fullscreen, focus mode, minimize) |
| FileService | File picking, gallery save/load, export |
| ClipboardService | Paste images from clipboard |
| AudioService | Audio playback with audioplayers package |
| GalleryService | Gallery manifest save/load operations |

### Strategies

Strategies in `core/strategies/` implement the Strategy and Decorator patterns:

| File | Pattern | Purpose |
|------|---------|---------|
| `audio_mode_strategy.dart` | Strategy | Sealed class with `AudioDrivenStrategy` / `TimerDrivenStrategy` for transition logic |
| `strategy_providers.dart` | Factory | Riverpod provider returning the correct strategy based on `settings.audioMode` |
| `image_filter_decorator.dart` | Decorator | Abstract filter with 9 implementations (None, Grayscale, Sepia, Invert, Brightness, Contrast, ExtremeContrast, Blur, HeavyBlur) |

### Models (in `core/entities/`)

- **PresentationImage**: Image data (path, name, source: file/memory/url)
- **ClassConfig**: Class mode configuration (phase counts, break timing)
- **AppSettings**: User preferences
- **GalleryManifest**: Gallery metadata (images, audio, timestamps)

---

## Key Implementation Details

### Audio Modes

Two audio modes in `core/entities/app_settings.dart`:

```dart
enum AudioMode {
  audioDriven,    // Image changes when audio ends
  timerDriven,   // Timer controls image changes
}
```

When audio-driven mode is active and audio duration > timer, the countdown shows remaining audio time and progress bar empties instead of filling.

### Focus Mode

Focus mode in `infrastructure/services/window_service.dart`:
- Enters: `setFullScreen(true)` + `setAsFrameless()`
- Exits: `setFullScreen(false)` + `setTitleBarStyle(TitleBarStyle.normal)`

### Keyboard Shortcuts

Registered in `interfaces/screens/presentation_screen.dart` using `CallbackShortcuts`:

```dart
CallbackShortcuts(
  bindings: {
    const SingleActivator(LogicalKeyboardKey.f11): () => notifier.toggleFocusMode(),
    // ... more shortcuts
  },
  child: Focus(...)
)
```

### Grid Item Keys

The image grid in `interfaces/widgets/image_grid.dart` uses `ValueKey(image.path ?? image.name)` to ensure proper item tracking when removing images.

---

## Adding Features

### Adding a New Menu

1. Add method to `PresentationNotifier` in `core/providers/presentation_provider.dart`
2. Add button/popup in `interfaces/widgets/presentation_controls.dart`
3. Add keyboard shortcut in `interfaces/screens/presentation_screen.dart` (optional)
4. Update HELP.md and DEVELOPERS.md

### Adding a New Setting

1. Add field to `AppSettings` in `core/entities/app_settings.dart`
2. Add UI in `interfaces/screens/settings_screen.dart`
3. Handle in `SettingsNotifier` in `core/providers/settings_provider.dart`

### Adding a New Audio Feature

1. Add method to `AudioService` in `infrastructure/services/audio_service.dart`
2. Call from `PresentationNotifier` in `core/providers/presentation_provider.dart`

---

## Testing

```bash
# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

---

## Building

### Linux
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/photopresenter
```

### Windows
```bash
flutter build windows --release
# Output: build/windows/x64/release/bundle/
```

### macOS
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

---

## Dependencies

Key packages in `pubspec.yaml`:

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^3.3.1 | State management |
| window_manager | ^0.5.1 | Window management |
| desktop_drop | ^0.7.1 | Drag and drop |
| file_picker | ^11.0.2 | Native file dialogs |
| audioplayers | ^6.6.0 | Audio playback |
| pasteboard | ^0.5.0 | Clipboard access |
| http | ^1.2.0 | HTTP image loading from URLs |
| path_provider | ^2.0.0 | Platform-aware app directories |
| path | ^1.8.0 | File path utilities |
| uuid | ^4.0.0 | UUID generation for gallery manifests |
| animate_do | ^5.1.0 | Image transition animations |
| cupertino_icons | ^1.0.8 | iOS-style icons |

---

## Code Style

- No comments unless explicitly requested
- Use existing patterns in the codebase
- Prefer `const` constructors
- Use `Future<void>` for async methods that don't return values

---

## Troubleshooting

### Build Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build linux
```

### Window Not Showing

- Check `window_manager` initialization in `main.dart`
- Ensure `TitleBarStyle.normal` is set (not hidden)

### Audio Not Playing

- Check audio file format (mp3, wav, etc.)
- Verify audio files exist at path

---

## Contributing

1. Create a feature branch
2. Make changes following code style
3. Test on Linux (primary target)
4. Build for all platforms
5. Update documentation
6. Submit pull request
