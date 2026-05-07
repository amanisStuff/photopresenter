# core/

Domain entities and business logic. Framework-agnostic data models live in `entities/`, while Riverpod providers containing application logic live in `providers/`.

- `entities/` — Pure data classes (PresentationImage, ClassConfig, AppSettings, GalleryManifest)
- `providers/` — Stateful logic via Riverpod Notifiers (PresentationNotifier, SettingsNotifier)
