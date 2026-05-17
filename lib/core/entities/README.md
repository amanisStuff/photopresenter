# core/entities/

Pure data classes with no framework dependencies. These are the source of truth for all state shapes in the app.

- `presentation_image.dart` — Represents a single slide image with its file path and source type
- `app_settings.dart` — Contains all app-wide configuration (timer duration, audio mode, class presets, viewport toggle)
- `class_session.dart` — Models a class session: phases, break state, phase queue generation
- `gallery_manifest.dart` — Serialisable gallery metadata (name, creation date, file paths)
