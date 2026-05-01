import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'providers/presentation_provider.dart';
import 'widgets/image_grid.dart';
import 'widgets/image_display.dart';
import 'widgets/presentation_controls.dart';
import 'widgets/custom_title_bar.dart';

class PresentationScreen extends ConsumerWidget {
  const PresentationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    // Determine the main content
    Widget content;
    if (state.images.isEmpty) {
      content = const Center(child: ImageDisplay());
    } else if (state.isPlaying) {
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
        },
        child: Focus(
          autofocus: true,
          child: DropTarget(
            onDragDone: (details) {
              notifier.addImages(details.files.map((f) => f.path).toList());
            },
            child: Stack(
              children: [
                // Background Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: state.isFocusMode
                        ? const LinearGradient(
                            colors: [Colors.black, Color(0xFF121212)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                  ),
                ),

                // Custom Title Bar
                if (!state.isFocusMode)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: CustomTitleBar(),
                  ),

                // Main Content (Grid or Display)
                content,

                // Controls (Hidden in Focus Mode unless mouse moved - simpler implementation for now: just overlay)
                if (!state.isFocusMode)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: PresentationControls(),
                  ),

                // Focus Mode Exit Hint
                if (state.isFocusMode)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => notifier.toggleFocusMode(),
                    ),
                  ),

                // Focus Mode Timer Overlay (shows in last 10 seconds)
                if (state.isFocusMode && state.isPlaying && state.remainingTime.inSeconds <= 10)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: state.timerDuration.inMilliseconds > 0
                                      ? state.remainingTime.inMilliseconds /
                                          state.timerDuration.inMilliseconds
                                      : 0,
                                  backgroundColor: Colors.white24,
                                  valueColor: AlwaysStoppedAnimation(
                                    state.remainingTime.inSeconds <= 5
                                        ? Colors.redAccent
                                        : Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${state.remainingTime.inSeconds}s',
                              style: TextStyle(
                                color: state.remainingTime.inSeconds <= 5
                                    ? Colors.redAccent
                                    : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
