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
- core/                        # Domain entities & business logic
  - entities/                  # Framework-agnostic data models
    - presentation_image.dart, class_session.dart, app_settings.dart, gallery_manifest.dart
  - providers/                 # Riverpod Notifier business logic
    - presentation_provider.dart, settings_provider.dart
- infrastructure/              # External implementations & DI
  - services/                  # IO / platform wrappers
    - window_service.dart, file_service.dart, audio_service.dart, clipboard_service.dart, gallery_service.dart
  - service_providers.dart
- interfaces/                  # UI layer (entry points, screens, widgets)
  - screens/                   # Full-page views
    - presentation_screen.dart, settings_screen.dart
  - widgets/                   # Composable UI components
    - add_image_card.dart, audio_mode_tile.dart, audio_mode_toggle.dart, break_overlay.dart,
      class_mode_button.dart, class_mode_dialog.dart, class_phase_indicator.dart,
      class_preset_tile.dart, custom_title_bar.dart, draggable_image_card.dart,
      edit_preset_dialog.dart, focus_timer_overlay.dart, image_display.dart, image_grid.dart,
      load_gallery_dialog.dart, number_input_row.dart, presentation_controls.dart,
      section_header.dart, settings_tile.dart, silver_controls.dart, timer_adjustment.dart
- shared/                      # Reusable utilities & constants
  - theme.dart                 # WMP9/Luna theme (royal blue, brushed silver, XP green)
  - widgets/clickable.dart     # Shared MouseRegion + GestureDetector wrapper
- test/
  - widget_test.dart

Architectural Patterns
- Unidirectional data flow with Riverpod
  - PresentationNotifier (State notifier) -> PresentationState (immutable) -> UI
- MV-esque composition
  - Stateless widgets for UI composition; Stateful logic centralized in Notifier
- Four-layer architecture: core (entities + providers), infrastructure (services + DI), interfaces (screens + widgets), shared
- Separation of concerns
  - Data/models in lib/core/entities
  - State/logic in lib/core/providers
  - UI in lib/interfaces/screens and lib/interfaces/widgets
  - IO/services in lib/infrastructure/services

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
  - Complete widget extraction: all private widget classes extracted into separate files under lib/interfaces/widgets/
    (section_header, settings_tile, class_preset_tile, audio_mode_tile, number_input_row, edit_preset_dialog,
     silver_controls, timer_adjustment, class_mode_button, class_phase_indicator, audio_mode_toggle,
     class_mode_dialog, load_gallery_dialog, draggable_image_card, add_image_card, break_overlay,
     focus_timer_overlay)
  - Full flutter analyze passes (2 pre-existing info-level empty-catch warnings only)
- Immediate next technical hurdle
  - Strengthen test coverage for timing logic (auto vs manual vs class-mode)
  - Validate cross-platform UI behavior under extreme window sizes
  - Finalize in-app Debug mode persistence across restarts (if desired)

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
- Widgets (all under lib/interfaces/widgets/): Composable stateless widgets extracted into individual files for single responsibility

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

- New Feature: Image Filters
  - Implemented Black & White and Sepia image rendering for the slideshow.
  - Access via the Presentation Controls bar: click the Filter menu (palette icon) to choose None / BW / Sepia.
  - Rendering uses ColorFiltered; the underlying image data remains unchanged.
