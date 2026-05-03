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
├── core/
│   ├── theme.dart                     # App theming (dark theme)
│   └── widgets/
│       └── clickable.dart             # Custom clickable widget
├── services/
│   ├── service_providers.dart         # Riverpod providers for services
│   ├── window_service.dart            # Window management (fullscreen, focus mode)
│   ├── file_service.dart              # File picking, save/load galleries
│   ├── clipboard_service.dart        # Clipboard operations (paste images/files)
│   └── audio_service.dart             # Audio playback
└── features/
    ├── presentation/
    │   ├── models/
    │   │   ├── presentation_image.dart    # Image data model
    │   │   └── class_session.dart         # Class mode session model
    │   ├── providers/
    │   │   └── presentation_provider.dart # Main state management (Riverpod)
    │   ├── presentation_screen.dart       # Main screen with keyboard shortcuts
    │   └── widgets/
    │       ├── image_grid.dart            # Image library grid view
    │       ├── image_display.dart         # Full-screen image display
    │       └── presentation_controls.dart # Bottom control bar
    └── settings/
        ├── models/
        │   └── app_settings.dart          # App settings & class presets
        ├── providers/
        │   └── settings_provider.dart     # Settings state management
        └── settings_screen.dart           # Settings UI
```

---

## Architecture

### State Management

The app uses **Riverpod** for state management with two main providers:

1. **PresentationProvider** (`presentation_provider.dart`)
   - Manages slideshow state: images, playback, timers, audio, focus mode, class mode
   - Handles all user interactions
   - Contains ~650 lines of core logic

2. **SettingsProvider** (`settings_provider.dart`)
   - Manages app settings: timer duration, audio mode, class presets
   - Persists settings to local storage

### Services

Services are injected via Riverpod providers in `service_providers.dart`:

| Service | Purpose |
|---------|---------|
| WindowService | Window management (fullscreen, focus mode, minimize) |
| FileService | File picking, gallery save/load, export |
| ClipboardService | Paste images from clipboard |
| AudioService | Audio playback with audioplayers package |
| SettingsProvider | App settings persistence |

### Models

- **PresentationImage**: Image data (path, name, source: file/memory/url)
- **ClassConfig**: Class mode configuration (phase counts, break timing)
- **AppSettings**: User preferences

---

## Key Implementation Details

### Audio Modes

Two audio modes in `app_settings.dart`:

```dart
enum AudioMode {
  audioDriven,    // Image changes when audio ends
  timerDriven,   // Timer controls image changes
}
```

When audio-driven mode is active and audio duration > timer, the countdown shows remaining audio time and progress bar empties instead of filling.

### Focus Mode

Focus mode in `window_service.dart`:
- Enters: `setFullScreen(true)` + `setAsFrameless()`
- Exits: `setFullScreen(false)` + `setTitleBarStyle(TitleBarStyle.normal)`

### Keyboard Shortcuts

Registered in `presentation_screen.dart` using `CallbackShortcuts`:

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

The image grid in `image_grid.dart` uses `ValueKey(image.path ?? image.name)` to ensure proper item tracking when removing images.

---

## Adding Features

### Adding a New Menu

1. Add method to `PresentationProvider` in `presentation_provider.dart`
2. Add button/popup in `presentation_controls.dart`
3. Add keyboard shortcut in `presentation_screen.dart` (optional)
4. Update HELP.md and DEVELOPERS.md

### Adding a New Setting

1. Add field to `AppSettings` in `app_settings.dart`
2. Add UI in `settings_screen.dart`
3. Handle in `SettingsProvider` in `settings_provider.dart`

### Adding a New Audio Feature

1. Add method to `AudioService` in `audio_service.dart`
2. Call from `PresentationProvider` methods

---

## Testing

```bash
# Run tests
flutter test

# Run specific test file
flutter test test/presentation_provider_test.dart
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