# PhotoPresenter Help File

## Overview

PhotoPresenter is a desktop image slideshow application built with Flutter for Windows. It allows users to display images in a presentation format with automatic slide transitions, focus mode, and various input methods (drag & drop, clipboard, file picker).

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   └── theme.dart               # App theming (dark theme)
├── services/
│   ├── service_providers.dart   # Riverpod providers for services
│   ├── window_service.dart      # Window management (fullscreen, focus mode)
│   ├── file_service.dart        # File picking (native file dialog)
│   ├── clipboard_service.dart  # Clipboard operations (paste images/files)
│   └── audio_service.dart       # Audio feedback (tick sounds)
└── features/
    └── presentation/
        ├── models/
        │   └── presentation_image.dart   # Image data model
        ├── providers/
        │   └── presentation_provider.dart # State management (Riverpod)
        ├── presentation_screen.dart      # Main screen with keyboard shortcuts
        └── widgets/
            ├── custom_title_bar.dart     # Custom window title bar
            ├── image_grid.dart          # Image library grid view
            ├── image_display.dart        # Full-screen image display
            └── presentation_controls.dart # Bottom control bar
```

---

## Core Components

### 1. Main Entry Point (`main.dart`)

- Initializes `WindowService` for desktop window management
- Wraps app in `ProviderScope` for Riverpod state management
- Sets up dark theme via `AppTheme.darkTheme`

### 2. Theme (`core/theme.dart`)

- Dark theme configuration using Material 3
- Custom gradients for primary and focus modes
- Color scheme: Blue accent seed color, dark surface (#121212, #0A0A0A)

---

## Services

### WindowService (`services/window_service.dart`)

| Method | Description |
|--------|-------------|
| `initialize()` | Sets up window (1280x720, hidden title bar, centered) |
| `toggleFullScreen()` | Toggles full-screen mode |
| `enterFocusMode()` | Enters ultra-focus mode (fullscreen + frameless) |
| `exitFocusMode()` | Exits focus mode |
| `minimize()` | Minimizes window to taskbar |
| `close()` | Closes the application |

### FileService (`services/file_service.dart`)

| Method | Description |
|--------|-------------|
| `pickImages()` | Opens native file picker, returns list of image paths |

### ClipboardService (`services/clipboard_service.dart`)

| Method | Description |
|--------|-------------|
| `getClipboardImage()` | Returns image bytes from clipboard, or null |
| `getClipboardFiles()` | Returns file paths from clipboard |
| `hasRelevantData()` | Checks if clipboard has images or files |

### AudioService (`services/audio_service.dart`)

| Method | Description |
|--------|-------------|
| `playAudio(String path, {void Function()? onComplete})` | Plays audio file, calls onComplete when done |
| `stop()` | Stops current playback |
| `pause()` | Pauses playback |
| `resume()` | Resumes playback |
| `isPlaying` | Getter - checks if audio is playing |
| `dispose()` | Disposes audio player |

---

## State Management

### PresentationState (`features/presentation/providers/presentation_provider.dart`)

| Property | Type | Default | Description |
|-----------|------|---------|-------------|
| `images` | `List<PresentationImage>` | `[]` | Loaded images |
| `currentIndex` | `int` | `0` | Currently displayed image index |
| `isPlaying` | `bool` | `false` | Auto-playback active |
| `timerDuration` | `Duration` | `30 seconds` | Slideshow interval |
| `remainingTime` | `Duration` | `30 seconds` | Time until next slide |
| `isFocusMode` | `bool` | `false` | Focus mode enabled |
| `audioPaths` | `List<String>` | `[]` | Loaded audio file paths |
| `audioIndex` | `int` | `0` | Current audio track index |

### PresentationNotifier Methods

| Method | Description |
|--------|-------------|
| `addImages(List<String> paths)` | Add images from file paths |
| `addMemoryImage(dynamic bytes, String name)` | Add image from clipboard bytes |
| `removeImage(int index)` | Remove image at index |
| `setCurrentIndex(int index)` | Jump to specific image |
| `nextImage()` | Go to next image (wraps to start) |
| `previousImage()` | Go to previous image (wraps to end) |
| `togglePlay()` | Start/stop auto-slideshow |
| `setTimerDuration(Duration duration)` | Set slideshow interval |
| `toggleFocusMode()` | Toggle focus/fullscreen mode |
| `minimizeWindow()` | Minimize to taskbar |
| `pasteFromClipboard()` | Paste image(s) from clipboard |
| `pickFiles()` | Open file picker dialog |
| `pickAudio()` | Pick multiple audio files |
| `clearAudio()` | Clear all audio files |

---

## Image Model

### PresentationImage (`features/presentation/models/presentation_image.dart`)

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier (path or timestamp) |
| `path` | `String?` | File path (if source is file) |
| `bytes` | `Uint8List?` | Image bytes (if source is memory) |
| `source` | `ImageSource` | `file` or `memory` |
| `name` | `String` | Display name (filename) |

---

## UI Widgets

### PresentationScreen (`features/presentation/presentation_screen.dart`)

Main screen that switches between:
- **Empty state**: Shows drag hint and "Pick Images" button
- **Grid view**: When not playing, shows library grid
- **Display view**: When playing, shows current image fullscreen

### CustomTitleBar (`features/presentation/widgets/custom_title_bar.dart`)

Custom window title bar with:
- App icon and title "PhotoPresenter"
- Window controls: Minimize, Focus Mode, Close
- Draggable area for moving window

### ImageGrid (`features/presentation/widgets/image_grid.dart`)

- Displays all loaded images in a grid (200px tiles)
- "Add Images" card at the start
- Click to select/display image
- Delete button on each thumbnail
- Shows image count badge

### ImageDisplay (`features/presentation/widgets/image_display.dart`)

- Full-screen image display with `BoxFit.contain`
- FadeIn animation on image change
- Empty state with drag hint and file picker button

### PresentationControls (`features/presentation/widgets/presentation_controls.dart`)

Bottom control bar with:
- **Left**: Image info, timer countdown, timer duration selector (dropdown: 5s/10s/30s/1m/5m)
- **Center**: Previous, Play/Pause, Next buttons
- **Right**: Minimize, Paste, Focus Mode buttons

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Escape` | Exit focus mode (when in focus mode) |
| `Space` | Toggle play/pause |
| `ArrowRight` | Next image |
| `ArrowLeft` | Previous image |
| `Ctrl+V` | Paste from clipboard |
| `Ctrl+M` | Minimize window |

---

## Input Methods

1. **Drag & Drop**: Drag image files directly onto the window
2. **File Picker**: Click "Pick Images" button or "+" card
3. **Clipboard Paste**: `Ctrl+V` to paste images from clipboard (including screenshots)
4. **File Explorer Paste**: Copy files in Explorer, then `Ctrl+V`

---

## Focus Mode

- Hides title bar and controls
- Full-screen display with dark gradient background
- Shows close button in top-right corner
- Press `Escape` or click close button to exit

---

## Dependencies (from `pubspec.yaml`)

- `flutter_riverpod` - State management
- `window_manager` - Desktop window control
- `file_picker` - Native file dialogs
- `desktop_drop` - Drag & drop support
- `pasteboard` - Clipboard access
- `audioplayers` - Audio playback (placeholder)
- `animate_do` - Animations

---

## Building/Running

```bash
# Development
flutter run -d windows

# Release build
flutter build windows --release
```

---

## Notes

- Window size defaults to 1280x720
- Hidden native title bar (custom title bar implemented)
- Timer tick sound triggers when < 3 seconds remaining (audio not implemented)
- Images wrap around (last -> first, first -> last)