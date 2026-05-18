import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';
import 'class_phase_indicator.dart';

class PlaybackSection extends ConsumerWidget {
  const PlaybackSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (context) {
                  final settings = ref.watch(settingsProvider);
                  final canGoToPrevious = state.images.isNotEmpty && !settings.useViewport3D;
                  return Container(
                    decoration: AppTheme.buttonDecoration(),
                    padding: const EdgeInsets.all(2),
                    child: IconButton(
                      icon: const Icon(Icons.skip_previous, size: 20),
                      onPressed: canGoToPrevious
                          ? () => notifier.previousImage()
                          : null,
                      color: AppTheme.onSurface,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Builder(
                builder: (context) {
                  final settings = ref.watch(settingsProvider);
                  if (settings.useViewport3D) {
                    return Container(
                      decoration: AppTheme.buttonDecoration(),
                      padding: const EdgeInsets.all(2),
                      child: IconButton(
                        icon: Icon(
                          Icons.blur_on,
                          size: 18,
                          color: settings.scatterMode
                              ? AppTheme.success
                              : AppTheme.onSurface,
                        ),
                        tooltip: 'Scatter',
                        onPressed: () {
                          final notifier = ref.read(settingsProvider.notifier);
                          notifier.setScatterMode(!settings.scatterMode);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  }
                  return Container(
                    decoration: AppTheme.buttonDecoration(),
                    padding: const EdgeInsets.all(2),
                    child: IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        size: 18,
                        color: state.isShuffled ? AppTheme.success : AppTheme.onSurface,
                      ),
                      tooltip: 'Shuffle',
                      onPressed: state.images.isEmpty
                          ? null
                          : () => notifier.toggleShuffle(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Builder(
                builder: (context) {
                  final settings = ref.watch(settingsProvider);
                  final canTogglePlay = state.images.isNotEmpty || settings.useViewport3D;
                  return Container(
                    decoration: AppTheme.buttonDecoration(isPlay: true),
                    padding: const EdgeInsets.all(2),
                    child: IconButton(
                      icon: Icon(
                        state.isPlaying
                            ? Icons.pause
                            : (state.isPaused ? Icons.play_arrow : Icons.play_arrow),
                        size: 26,
                      ),
                      onPressed: canTogglePlay ? () => notifier.togglePlay() : null,
                      color: AppTheme.primary,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Builder(
                builder: (context) {
                  final settings = ref.watch(settingsProvider);
                  final canNavigate = state.images.isNotEmpty || settings.useViewport3D;
                  return Container(
                    decoration: AppTheme.buttonDecoration(),
                    padding: const EdgeInsets.all(2),
                    child: IconButton(
                      icon: const Icon(Icons.skip_next, size: 20),
                      onPressed: canNavigate
                          ? () => notifier.nextImage()
                          : null,
                      color: AppTheme.onSurface,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (state.isClassMode)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ClassPhaseIndicator(state: state),
          ),
      ],
    );
  }
}
