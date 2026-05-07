import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';
import '../widgets/image_grid.dart';
import '../widgets/image_display.dart';
import '../widgets/presentation_controls.dart';

class PresentationScreen extends ConsumerWidget {
  const PresentationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

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
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D0D1A), Color(0xFF06060D)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

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
                        color: AppTheme.royalBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.royalBlue.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        state.isClassMode
                            ? '${state.images.length} / ${state.totalPhaseCount}'
                            : '${state.currentIndex + 1} / ${state.images.length}',
                        style: const TextStyle(
                          color: AppTheme.royalBlueLight,
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
                        color: AppTheme.bgCard.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.royalBlue.withValues(alpha: 0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        state.currentImage!.name,
                        style: const TextStyle(
                          color: Color(0xFFB0B0C8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

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

                if (state.isPlaying && state.isClassMode && state.isOnBreak)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0A0A18), Color(0xFF14142A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.royalBlue.withValues(alpha: 0.4),
                                  AppTheme.royalBlueDark.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.royalBlue.withValues(
                                  alpha: 0.5,
                                ),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.coffee,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'BREAK TIME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rest your hand',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.royalBlue.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${state.remainingTime.inMinutes}:${(state.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: AppTheme.royalBlueLight,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (state.isFocusMode &&
                    state.isPlaying &&
                    state.remainingTime.inSeconds <= 10)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.royalBlue.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 10,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: state.timerDuration.inMilliseconds > 0
                                      ? state.remainingTime.inMilliseconds /
                                            state.timerDuration.inMilliseconds
                                      : 0,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation(
                                    state.remainingTime.inSeconds <= 5
                                        ? AppTheme.closeRed
                                        : AppTheme.xpGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${state.remainingTime.inSeconds}s',
                              style: TextStyle(
                                color: state.remainingTime.inSeconds <= 5
                                    ? AppTheme.closeRed
                                    : Colors.white,
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
