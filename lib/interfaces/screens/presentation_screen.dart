import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';
import '../widgets/image_grid.dart';
import '../widgets/image_display.dart';
import '../widgets/presentation_controls.dart';
import '../widgets/break_overlay.dart';
import '../widgets/focus_timer_overlay.dart';

class PresentationScreen extends ConsumerWidget {
  const PresentationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    Widget content;
    if (state.images.isEmpty) {
      content = const Center(child: ImageDisplay());
    } else if (state.isPlaying || state.isPaused) {
      content = const Center(child: ImageDisplay());
    } else {
      content = const ImageGrid();
    }

    return Scaffold(
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (state.isFocusMode) {
              notifier.toggleFocusMode();
            } else if (state.isPaused || state.isAutoPausing) {
              notifier.stopPlayback();
            }
          },
          const SingleActivator(LogicalKeyboardKey.space): () =>
              notifier.togglePlay(),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              notifier.nextImage(),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              notifier.previousImage(),
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
              notifier.pasteFromClipboard(),
          const SingleActivator(LogicalKeyboardKey.keyM, control: true): () =>
              notifier.minimizeWindow(),
          const SingleActivator(LogicalKeyboardKey.f11): () =>
              notifier.toggleFocusMode(),
          const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
              notifier.toggleFocusMode(),
          const SingleActivator(LogicalKeyboardKey.keyD, control: true): () =>
              notifier.exportAllImages(),
          const SingleActivator(LogicalKeyboardKey.keyG, control: true): () =>
              notifier.saveGallery(
                'Gallery ${DateTime.now().millisecondsSinceEpoch}',
              ),
          const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
              notifier.savePlaylist(),
        },
        child: Focus(
          autofocus: true,
          child: DropTarget(
            onDragDone: (details) {
              notifier.addImages(details.files.map((f) => f.path).toList());
            },
            child: Stack(
              children: [
                Container(decoration: AppTheme.presentationBackground),

                content,

                if (!state.isFocusMode && state.images.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        state.isClassMode
                            ? '${state.images.length} / ${state.totalPhaseCount}'
                            : '${state.currentIndex + 1} / ${state.images.length}',
                        style: const TextStyle(
                          color: AppTheme.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                if (!state.isFocusMode &&
                    state.images.isNotEmpty &&
                    state.currentImage != null)
                  Positioned(
                    bottom: 80,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceOverlay.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        state.currentImage!.name,
                        style: AppTheme.overlayTextStyle.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                if (state.isPaused)
                  const _PauseOverlay(),

                if (state.isAutoPausing && !state.isPaused)
                  const _AutoPauseOverlay(),

                if (!state.isFocusMode || !state.isPlaying)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: PresentationControls(),
                  ),

                if (state.isFocusMode)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => notifier.toggleFocusMode(),
                    ),
                  ),

                if (!state.isFocusMode && (state.isPaused || state.isAutoPausing))
                  Positioned(
                    top: 12,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      tooltip: 'Back to gallery',
                      onPressed: () => notifier.stopPlayback(),
                    ),
                  ),

                if (state.isPlaying && state.isClassMode && state.isOnBreak)
                  BreakOverlay(state: state),

                if (state.isFocusMode &&
                    state.isPlaying &&
                    state.remainingTime.inSeconds <= 10)
                  FocusTimerOverlay(state: state),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOverlay.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.pause,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'PAUSED',
                  style: AppTheme.overlayTitleStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Press Space to continue',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AutoPauseOverlay extends ConsumerWidget {
  const _AutoPauseOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.black38,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOverlay.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.hourglass_bottom,
                    size: 48,
                    color: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'NEXT IMAGE IN',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.autoPauseRemaining.inSeconds}s',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
