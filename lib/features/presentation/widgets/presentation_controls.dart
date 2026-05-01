import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/presentation_provider.dart';
import '../../settings/settings_screen.dart';
import '../../settings/providers/settings_provider.dart';

class PresentationControls extends ConsumerWidget {
  const PresentationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Info & Timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.images.isNotEmpty)
                  Text(
                    'Image ${state.currentIndex + 1} of ${state.images.length}: ${state.currentImage?.name}',
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.hasAudio)
                      Icon(
                        Icons.audiotrack,
                        size: 16,
                        color: state.isPlaying ? Colors.green : Colors.grey,
                      ),
                    if (state.hasAudio) const SizedBox(width: 8),
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: state.isPlaying ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${state.remainingTime.inSeconds}s',
                      style: TextStyle(
                        color: state.remainingTime.inSeconds <= 5
                            ? Colors.redAccent
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _TimerAdjustment(
                      value: state.timerDuration.inSeconds,
                      onChanged: (val) =>
                          notifier.setTimerDuration(Duration(seconds: val)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Center: Playback Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 32),
                onPressed: state.images.isEmpty
                    ? null
                    : () => notifier.previousImage(),
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: state.images.isEmpty
                    ? null
                    : () => notifier.togglePlay(),
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 32),
                onPressed: state.images.isEmpty
                    ? null
                    : () => notifier.nextImage(),
                color: Colors.white,
              ),
            ],
          ),

          // Right side: Settings & Focus
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Pick audio file',
                  icon: Icon(
                    Icons.audiotrack,
                    color: state.hasAudio ? Colors.green : Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => notifier.pickAudio(),
                ),
                if (state.hasAudio) ...[
                  Text(
                    '${state.audioIndex + 1}/${state.audioPaths.length}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  IconButton(
                    iconSize: 18,
                    tooltip: 'Clear audio',
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () => notifier.clearAudio(),
                  ),
                ],
                IconButton(
                  tooltip: 'Minimize window',
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => notifier.minimizeWindow(),
                ),
                IconButton(
                  tooltip: 'Paste from clipboard',
                  icon: const Icon(
                    Icons.content_paste,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => notifier.pasteFromClipboard(),
                ),
                IconButton(
                  tooltip: 'Export current image',
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: state.images.isEmpty
                      ? null
                      : () async {
                          final result = await notifier.exportCurrentImage();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result ?? 'Export failed'),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Focus Mode',
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => notifier.toggleFocusMode(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerAdjustment extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _TimerAdjustment({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: value,
      tooltip: 'Set timer duration',
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('${value}s', style: const TextStyle(color: Colors.white60)),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 5, child: Text('5 seconds')),
        const PopupMenuItem(value: 10, child: Text('10 seconds')),
        const PopupMenuItem(value: 30, child: Text('30 seconds')),
        const PopupMenuItem(value: 60, child: Text('1 minute')),
        const PopupMenuItem(value: 300, child: Text('5 minutes')),
      ],
    );
  }
}
