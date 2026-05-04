AGENT_CONTEXT.md

Mission Statement
- PhotoPresenter renders a desktop image slideshow with timer- or audio-driven transitions, plus a class-mode practice flow, all in Flutter.

The Tech Stack
- Language/Platform: Dart (Flutter desktop)
- Flutter/Dart
  - Flutter for desktop (Windows/macOS/Linux)
  - Dart SDK constraints: ^3.9.0 (per pubspec.yaml)
- Core Frameworks/Libraries
  - flutter_riverpod: ^3.3.1
  - window_manager: ^0.5.1
  - desktop_drop: ^0.7.1
  - pasteboard: ^0.5.0
  - file_picker: ^11.0.2
  - audioplayers: ^6.6.0
  - http: ^1.2.0
  - uuid: ^4.0.0
  - path_provider: ^2.0.0
  - path: ^1.8.0
  - animate_do: ^5.1.0
- Local/Supportive
  - Riverpod for DI/state
  - Custom services: window, file, clipboard, audio, gallery
  - Lightweight in-app logger (AppLogger) for debug

Project Topography
- lib/
  - main.dart: App entry; bootstraps window services and Riverpod scope
- core/
  - theme.dart, widgets/ (shared UI components)
- services/
  - service_providers.dart (DI for services)
  - window_service.dart, file_service.dart, clipboard_service.dart, audio_service.dart, gallery_service.dart
- features/
  - presentation/
    - models/ (PresentationImage, ClassSession)
    - providers/ (presentation_provider.dart)
    - screens/ (presentation_screen.dart)
    - widgets/
      - image_grid.dart, image_display.dart
      - presentation_controls.dart (centered playback controls; now uses stateless components)
      - center_playback_panel.dart (new)
      - slideshow_header.dart (new)
      - _??_ (other internal widgets)
  - settings/
    - models/ (app_settings.dart)
    - providers/ (settings_provider.dart)
    - screens/ (settings_screen.dart)
  - gallery/
    - models/ (gallery_manifest.dart)
- test/
  - widget_test.dart
- AGENT_CONTEXT.md (high-level briefing for new AI agents)

Architectural Patterns
- Unidirectional data flow with Riverpod
  - PresentationNotifier (State notifier) -> PresentationState (immutable) -> UI
- MV-esque composition
  - Stateless widgets for UI composition; Stateful logic centralized in Notifier
- Feature-based modularization
  - Separate concerns for presentation, settings, gallery, and services
- Separation of concerns
  - Data/models in lib/features/presentation/models
  - State/logic in lib/features/presentation/providers
  - UI in lib/features/presentation/widgets and lib/features/presentation/screens
  - IO/services in lib/services

Data Flow
- User Input (UI) -> PresentationNotifier
- State mutation -> PresentationState (via copyWith)
- Timer/Audio loops drive transitions (via _startTimer, _startAudioPlayback)
- External IO:
  - URL images loaded via http in _downloadUrlImage
  - Local images/audios loaded via file_service/clipboard_service
  - Images/audios saved/loaded via gallery_service and file_service
- UI Readouts include image counts, current image.name, timer remaining, and audio progress

Critical Constraints
- All state management via Riverpod; no raw setState in presentation layer
- One source of truth for slideshow state (PresentationState in PresentationNotifier)
- Use of const constructors and StatelessWidgets where appropriate
- Debug logging gated behind AppLogger and kDebugMode
- Class Mode and timer logic must remain deterministic and tested
- Avoid direct DOM/OS calls from UI; interactions go through services
- Ensure that UI components do not cause drift (e.g., fixed widths for headers, centered controls, etc.)

Current State of Play
- Last major feature implemented
  - Separation of center playback controls into CenterPlaybackPanel (stateless)
  - SlideshowHeader with fixed width (ConstrainedBox) to prevent layout drift
  - Auto vs manual timing: 1-second inter-slide delay for auto transitions; manual navigation bypasses the delay
  - Introduced AppLogger and Debug mode toggle in Settings
- Immediate next technical hurdle
  - Strengthen test coverage for timing logic (auto vs manual vs class-mode)
  - Validate cross-platform UI behavior under extreme window sizes
  - Finalize in-app Debug mode persistence across restarts (if desired)
  - Potentially extract remaining right-side controls into explicit stateless widgets for testability

Glossary of Domains
- PresentationState: Immutable data class holding slideshow state (images, currentIndex, timer, audio, class mode, etc.)
- PresentationNotifier: Riverpod Notifier implementing slideshow logic (advance, timer, audio, class mode, breaks)
- PresentationImage: Image data model (path, name, source, etc.)
- ClassPreset / ClassConfig: Models describing class-mode timing presets and run-time configuration
- ImageSource: Enum used to distinguish file vs memory-based images
- AudioMode: Enum with audioDriven vs timerDriven
- SlideshowHeader: Stateless widget for the left-side header line; width-constrained to prevent drift
- CenterPlaybackPanel: Stateless widget rendering Prev/Play/Pause/Next controls centered in the UI
- AppSettings: Settings for timer, audio, class presets, and debug flags
- AppLogger: Lightweight runtime logger for debug output
- _Helper Widgets: Various small stateless widgets used to compose the UI (grid, image_display, etc.)

Onboarding and Agent Guidance (New)
- Entry points for understanding the system
- Quick acceptance criteria for new agent
- Suggested checks for a new AI agent
- Quick commands to verify locally
- If you want, I can further tailor AGENT_CONTEXT.md with:
  - A section for onboarding tasks with a ready-to-run checklist
  - A short “README-like quickstart” for new agents
  - Cross-references or a diagram mapping key components to their files for faster orientation

Notes
- This document is intended as a living briefing to minimize context drift. Update as the codebase evolves.
