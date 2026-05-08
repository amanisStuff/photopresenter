# PhotoPresenter Help File

## Overview

PhotoPresenter is a cross-platform desktop image slideshow application built with Flutter. It allows users to display images in a presentation format with automatic slide transitions, focus mode, class mode for figure drawing practice, and various input methods (drag & drop, clipboard, file picker).

**Theme**: Windows Media Player 9 / Windows XP Luna aesthetic with brushed aluminum controls, royal blue title bars, green progress indicators, and 3D beveled buttons.

---

## Project Structure

```
lib/
├── main.dart                            # App entry point
├── core/
│   ├── entities/
│   │   ├── presentation_image.dart      # Image data model
│   │   ├── class_session.dart           # Class mode session model
│   │   ├── app_settings.dart            # App settings & class presets
│   │   └── gallery_manifest.dart        # Gallery manifest data model
│   ├── providers/
│   │   ├── presentation_provider.dart   # State management (Riverpod)
│   │   └── settings_provider.dart       # Settings state management
│   └── strategies/
│       ├── audio_mode_strategy.dart     # Strategy pattern (audio/timer driven)
│       ├── strategy_providers.dart      # Strategy provider wiring
│       └── image_filter_decorator.dart  # Filter effect implementations
├── infrastructure/
│   ├── services/
│   │   ├── window_service.dart          # Window management (fullscreen, focus mode)
│   │   ├── file_service.dart            # File picking (native file dialog)
│   │   ├── clipboard_service.dart       # Clipboard operations (paste images/files)
│   │   ├── audio_service.dart           # Audio playback
│   │   └── gallery_service.dart         # Gallery save/load operations
│   └── service_providers.dart           # DI wiring for all services
├── interfaces/
│   ├── screens/
│   │   ├── presentation_screen.dart     # Main screen with keyboard shortcuts
│   │   └── settings_screen.dart         # Settings UI
│   └── widgets/
│       ├── add_image_card.dart          # Add image placeholder card
│       ├── audio_mode_tile.dart         # Audio mode radio list (settings)
│       ├── audio_mode_toggle.dart       # TMR/AUD toggle button (controls)
│       ├── break_overlay.dart           # Break timer overlay
│       ├── class_mode_button.dart       # Class mode toggle button
│       ├── class_mode_dialog.dart       # Class mode configuration dialog
│       ├── class_phase_indicator.dart   # Current phase label
│       ├── class_preset_tile.dart       # Class preset display tile
│       ├── custom_title_bar.dart        # Custom window title bar
│       ├── draggable_image_card.dart    # Draggable/reorderable image card
│       ├── edit_preset_dialog.dart      # Add/edit class preset dialog
│       ├── focus_timer_overlay.dart     # Focus mode timer overlay
│       ├── image_display.dart           # Full-screen image display
│       ├── image_grid.dart              # Image library grid view
│       ├── load_gallery_dialog.dart     # Gallery load/delete dialog
│       ├── number_input_row.dart        # Stepper row for numeric input
│       ├── presentation_controls.dart   # Bottom control bar
│       ├── section_header.dart          # Settings section label
│       ├── settings_tile.dart           # Reusable settings row
│       ├── silver_controls.dart         # Silver-themed buttons (IconButton, Menu etc.)
│       └── timer_adjustment.dart        # Timer increment/decrement
└── shared/
    ├── theme.dart                       # App theming (WMP9/Luna aesthetic)
    └── widgets/
        └── clickable.dart               # Custom clickable widget
```

---

## Core Features

### 1. Image Slideshow

- **Drag & Drop**: Drag image files directly onto the window
- **File Picker**: Click "Add Images" button or use Load menu
- **Clipboard Paste**: `Ctrl+V` to paste images from clipboard
- **Reorder Images**: In the Library grid, long-press and drag an image to reorder it
- **Shuffle**: Click the shuffle button to randomize image order; click again to restore original order
- Automatic slide transitions with configurable timer
- Inter-slide delay: When auto-advancing between images, a 1 second delay is inserted between slides. This delay does not apply when you actively navigate (next/previous) images.

### 2. Class Mode (Figure Drawing Practice)

Class Mode simulates live figure drawing sessions with progressive timing:

| Phase | Duration | Purpose |
|-------|----------|---------|
| Warm-up | 30 seconds | Gesture, line of action, basic flow |
| Early Study | 1 minute | Weight, proportion, major masses |
| Mid Study | 5 minutes | Refining shapes, silhouettes |
| Final Study | 10 minutes | Anatomical detail, lighting, shadow |
| Break Time | 3 minutes | Rest break (configurable) |

**Class Length Presets:**
- **30 Minutes**: 4 warm-up, 4 early, 2 mid, 1 final (11 images)
- **60 Minutes**: 6 warm-up, 6 early, 4 mid, 2 final + break (18 images)
- **Custom**: User-configurable counts for each phase

**Break Timer**: For longer sessions, a break can be triggered at a specific image to prevent hand cramping.

### 3. Audio Modes

Two audio modes available in Settings → Audio Mode:

| Mode | Behavior |
|------|----------|
| **Audio Driven** | Audio plays from start to end. Image changes when audio ends. Timer shows audio countdown when audio is longer than timer. |
| **Timer Driven** | Timer controls when images change. Audio starts at a random position and image changes when the timer ends. |

### 4. Custom Class Presets

In Settings, users can create and manage custom class presets:
- Add custom class with name and phase counts
- Configure break timing
- Edit or delete custom presets

---

## Settings

Settings accessible via the gear icon in controls:

| Setting | Description |
|--------|-------------|
| Default Timer Duration | Default slideshow interval (5s - 10m) |
| Auto-play Audio | Start audio when slideshow begins |
| Sound on Transition | Play sound when moving to next image |
| Transition Sound | Custom sound file for transitions |
| Default Volume | Audio playback volume |
| Show Image Info | Display image name and count |
| Confirm on Close | Ask before closing the app |
| Audio Mode | Audio Driven vs Timer Driven |
| Class Mode Presets | Manage custom class presets |

---

## State Management

### PresentationState (`presentation_provider.dart`)

| Property | Type | Default | Description |
|---------|------|---------|-------------|
| `images` | `List<PresentationImage>` | `[]` | Loaded images |
| `currentIndex` | `int` | `0` | Currently displayed image index |
| `isPlaying` | `bool` | `false` | Auto-playback active |
| `timerDuration` | `Duration` | `30 seconds` | Slideshow interval |
| `remainingTime` | `Duration` | `30 seconds` | Time until next slide |
| `isFocusMode` | `bool` | `false` | Focus mode enabled |
| `audioPaths` | `List<String>` | `[]` | Loaded audio file paths |
| `audioIndex` | `int` | `0` | Current audio track index |
| `audioPosition` | `Duration` | `0` | Current audio playback position |
| `audioDuration` | `Duration` | `0` | Current audio total duration |
| `isClassMode` | `bool` | `false` | Class mode active |
| `classConfig` | `ClassConfig?` | `null` | Current class configuration |
| `phaseQueue` | `List<Duration>` | `[]` | Queue of phase durations |
| `phaseQueueIndex` | `int` | `0` | Current phase index |
| `isOnBreak` | `bool` | `false` | Break timer active |
| `isShuffled` | `bool` | `false` | Shuffle mode active |
| `originalOrder` | `List<PresentationImage>?` | `null` | Original image order before shuffle |
| `lastActionWasManual` | `bool` | `false` | Tracks if last navigation was manual (affects inter-slide delay) |
| `activeFilters` | `Set<ImageFilter>` | `{}` | Currently active image color filters (multi-select) |

### AppSettings (`app_settings.dart`)

| Property | Type | Default | Description |
|---------|------|---------|-------------|
| `timerDurationSeconds` | `int` | `30` | Default timer in seconds |
| `autoPlayAudio` | `bool` | `true` | Start audio when slideshow begins |
| `soundOnTransition` | `bool` | `false` | Play sound when moving to next image |
| `transitionSoundPath` | `String?` | `null` | Custom sound file for transitions |
| `defaultVolume` | `double` | `1.0` | Audio playback volume |
| `showImageInfo` | `bool` | `true` | Display image name and count |
| `confirmOnClose` | `bool` | `false` | Ask before closing the app |
| `audioMode` | `AudioMode` | `audioDriven` | Audio/Timer driven mode |
| `customClassPresets` | `List<ClassPreset>` | `[]` | User-created class presets |

---

## UI Components

### PresentationControls

Bottom control bar with simplified layout:
- **Left**: Image count, timer countdown, timer selector, class mode toggle, phase indicator
- **Center**: Previous, Play/Pause, Next buttons
- **Right**: Audio toggle, Settings, Focus Mode, Load menu, Save menu

### Load Menu (folder icon)
- Add Images - Add images via file picker
- Load Gallery - Load a previously saved gallery (shows dialog with available galleries)
- Load Playlist - Load a previously saved audio playlist

### Save Menu (more options icon)
- Download Images - Export all images to a folder
- Save Gallery - Save images and audio as a gallery (user picks directory via file picker)
- Save Playlist - Save audio files as a playlist

### Focus Mode

- Hides controls when playing (shows when paused/stopped)
- Full-screen display with dark background
- Press `Escape` or click X to exit

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Escape` | Exit focus mode |
| `F11` or `Ctrl+F` | Toggle focus mode |
| `Space` | Toggle play/pause |
| `ArrowRight` | Next image |
| `ArrowLeft` | Previous image |
| `Ctrl+V` | Paste from clipboard |
| `Ctrl+M` | Minimize window |
| `Ctrl+D` | Download/export images |
| `Ctrl+G` | Save gallery |
| `Ctrl+P` | Save audio playlist |

---

## Class Mode Dialog
### Image Filters
- 9 color/effect filters available: None, Grayscale, Sepia, Invert, Bright, High Contrast, Extreme Contrast, Blur, Heavy Blur
- Access via the Presentation Controls popup menu (palette icon) for multi-select filter application
- Multiple filters can be combined simultaneously
- Rendering uses ColorFiltered; image data is unchanged.

When clicking "Class Mode" button:
1. **Quick Start**: Choose 30 Min or 60 Min preset
2. **Custom Configuration**: Adjust counts for each phase
3. **Break Option**: Enable break for longer sessions
4. **Image Counter**: Shows minimum images needed

The top bar shows: `[current]/[total] images` format during class mode.

---

## Building/Running

```bash
# Development (Linux)
flutter run -d linux

# Development (Windows)
flutter run -d windows

# Development (macOS)
flutter run -d macos

# Release build (Linux)
flutter build linux --release

# Release build (Windows)
flutter build windows --release

# Release build (macOS)
flutter build macos --release
```

---

## Notes

- Cross-platform: Windows, macOS, Linux
- Window size defaults to 1280x720
- Native window title bar (standard window controls)
- Images wrap around (last → first, first → last)
- Audio files can be loaded and cycle with images
- Custom class presets persist in app settings
- Timer and audio mode cannot be changed while playing
- Progress bar shows remaining time (empties during countdown)
- Galleries can be saved/loaded via file picker or persisted to app documents directory
