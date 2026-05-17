# infrastructure/services/

Concrete implementations of IO and platform operations. Each wraps a specific external capability.

- `window_service.dart` — Window positioning, fullscreen toggle, and drag-to-move
- `file_service.dart` — File picker (open images) via `file_picker` package
- `clipboard_service.dart` — Paste images from the system clipboard
- `audio_service.dart` — Audio playback for audio-driven slideshow mode using `audioplayers`
- `gallery_service.dart` — Save/load gallery manifests as JSON files
