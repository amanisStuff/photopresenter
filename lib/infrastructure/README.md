# infrastructure/

External-facing implementations. All IO, platform APIs, and third-party library wrappers live here.

- `services/` — Concrete service classes (WindowService, FileService, AudioService, ClipboardService, GalleryService)
- `service_providers.dart` — Riverpod provider definitions wiring services into the dependency graph
