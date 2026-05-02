import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/presentation_provider.dart';
import '../models/class_session.dart';
import '../../settings/settings_screen.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/providers/settings_provider.dart';

class PresentationControls extends ConsumerWidget {
  const PresentationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.images.isNotEmpty)
                  Text(
                    state.isClassMode
                        ? '${state.images.length}/${state.totalPhaseCount} images: ${state.currentImage?.name}'
                        : '${state.images.length} images: ${state.currentImage?.name}',
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (state.hasAudio) ...[
                      Icon(
                        Icons.audiotrack,
                        size: 16,
                        color: state.isPlaying ? Colors.green : Colors.grey,
                      ),
                      _AudioModeToggle(),
                    ],
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: state.isPlaying ? Colors.blue : Colors.grey,
                    ),
                    Builder(
                      builder: (context) {
                        final settings = ref.watch(settingsProvider);
                        final isAudioDriven = settings.audioMode == AudioMode.audioDriven;
                        final audioLonger = state.hasAudio && 
                            state.audioDuration.inSeconds > state.timerDuration.inSeconds;
                        
                        final bool showAudioCountdown = state.hasAudio && 
                            state.isPlaying && 
                            state.audioDuration.inSeconds > 0 &&
                            (isAudioDriven || state.isClassMode);
                        
                        final int secondsLeft = showAudioCountdown 
                            ? (state.audioDuration.inSeconds - state.audioPosition.inSeconds)
                            : state.remainingTime.inSeconds;
                        
                        final bool isLowTime = !showAudioCountdown && secondsLeft <= 5;
                        
                        return Text(
                          '${secondsLeft}s',
                          style: TextStyle(
                            color: showAudioCountdown 
                                ? Colors.green 
                                : (isLowTime ? Colors.redAccent : Colors.white),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        );
                      },
                    ),
                    if (state.isPlaying)
                      Builder(
                        builder: (context) {
                          final settings = ref.watch(settingsProvider);
                          final isAudioDriven = settings.audioMode == AudioMode.audioDriven;
                          final showAudioProgress = state.hasAudio && 
                              state.audioDuration.inMilliseconds > 0 &&
                              (isAudioDriven || state.isClassMode);
                          
                          final double progress = showAudioProgress
                              ? (state.audioDuration.inMilliseconds > 0 
                                  ? (state.audioDuration.inMilliseconds - state.audioPosition.inMilliseconds) / state.audioDuration.inMilliseconds 
                                  : 0.0)
                              : (state.timerDuration.inMilliseconds > 0 
                                  ? state.remainingTime.inMilliseconds / state.timerDuration.inMilliseconds 
                                  : 0.0);
                          
                          return SizedBox(
                            width: 100,
                            height: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation(
                                  showAudioProgress
                                      ? Colors.green
                                      : (state.remainingTime.inSeconds <= 5
                                          ? Colors.redAccent
                                          : Colors.blueAccent),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    if (!state.isClassMode)
                      _TimerAdjustment(
                        value: state.timerDuration.inSeconds,
                        onChanged: (val) =>
                            notifier.setTimerDuration(Duration(seconds: val)),
                      ),
                    if (state.isClassMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${state.timerDuration.inSeconds}s',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ),
                    _ClassModeButton(
                      isActive: state.isClassMode,
                      onStart: () => _showClassModeDialog(context, ref),
                      onStop: () => notifier.stopClassMode(),
                    ),
                  ],
                ),
                if (state.isClassMode) ...[
                  const SizedBox(height: 4),
                  _ClassPhaseIndicator(state: state),
                ],
              ],
            ),
          ),

          // Center: Playback Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 24),
                onPressed: state.images.isEmpty ? null : () => notifier.previousImage(),
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, size: 28),
                onPressed: state.images.isEmpty ? null : () => notifier.togglePlay(),
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 24),
                onPressed: state.images.isEmpty ? null : () => notifier.nextImage(),
                color: Colors.white70,
              ),
            ],
          ),

          // Right side: Settings & Focus
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.hasAudio) ...[
                IconButton(
                  tooltip: 'Audio',
                  icon: Icon(Icons.audiotrack, color: Colors.green, size: 20),
                  onPressed: () => notifier.pickAudio(),
                ),
                IconButton(
                  iconSize: 16,
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () => notifier.clearAudio(),
                ),
              ] else
                IconButton(
                  tooltip: 'Add audio',
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white54, size: 20),
                  onPressed: () => notifier.pickAudio(),
                ),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
              ),
              IconButton(
                tooltip: 'Focus Mode',
                icon: const Icon(Icons.fullscreen, color: Colors.white70, size: 20),
                onPressed: () => notifier.toggleFocusMode(),
              ),
              PopupMenuButton<String>(
                tooltip: 'Load',
                icon: const Icon(Icons.folder_open, color: Colors.white70, size: 20),
                onSelected: (value) {
                  switch (value) {
                    case 'images':
                      notifier.pickFiles();
                      break;
                    case 'gallery':
                      notifier.loadGallery();
                      break;
                    case 'playlist':
                      notifier.loadPlaylist();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'images',
                    child: Row(
                      children: [
                        Icon(Icons.image, size: 18),
                        SizedBox(width: 8),
                        Text('Add Images'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.collections, size: 18),
                        SizedBox(width: 8),
                        Text('Load Gallery'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'playlist',
                    child: Row(
                      children: [
                        Icon(Icons.queue_music, size: 18),
                        SizedBox(width: 8),
                        Text('Load Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                tooltip: 'More options',
                icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
                onSelected: (value) {
                  switch (value) {
                    case 'export':
                      notifier.exportAllImages();
                      break;
                    case 'gallery':
                      notifier.saveGallery('Gallery ${DateTime.now().millisecondsSinceEpoch}');
                      break;
                    case 'playlist':
                      notifier.savePlaylist();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 18),
                        SizedBox(width: 8),
                        Text('Download Images'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.collections, size: 18),
                        SizedBox(width: 8),
                        Text('Save Gallery'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'playlist',
                    child: Row(
                      children: [
                        Icon(Icons.queue_music, size: 18),
                        SizedBox(width: 8),
                        Text('Save Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerAdjustment extends ConsumerWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _TimerAdjustment({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final isDisabled = state.isPlaying;

    return PopupMenuButton<int>(
      initialValue: value,
      tooltip: 'Set timer duration',
      enabled: !isDisabled,
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.white.withValues(alpha: 0.05) : Colors.white10,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${value}s',
          style: TextStyle(
            color: isDisabled ? Colors.white.withValues(alpha: 0.3) : Colors.white60,
          ),
        ),
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

Future<String?> _showSaveGalleryDialog(BuildContext context) async {
  final controller = TextEditingController(
    text: 'Gallery ${DateTime.now().millisecondsSinceEpoch}',
  );

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Save Gallery'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Gallery Name',
          hintText: 'Enter gallery name',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _ClassModeButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const _ClassModeButton({
    required this.isActive,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withValues(alpha: 0.3) : Colors.white10,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.white24,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: isActive ? onStop : onStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school,
                  size: 16,
                  color: isActive ? Colors.blue : Colors.white60,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'Class' : 'Class Mode',
                  style: TextStyle(
                    color: isActive ? Colors.blue : Colors.white60,
                    fontSize: 12,
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

class _ClassPhaseIndicator extends StatelessWidget {
  final PresentationState state;

  const _ClassPhaseIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final phase = state.currentPhase;
    final phaseName = state.isOnBreak
        ? 'Break Time'
        : (phase?.displayName ?? 'Unknown');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: state.isOnBreak
                ? Colors.orange.withValues(alpha: 0.3)
                : Colors.green.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            phaseName,
            style: TextStyle(
              color: state.isOnBreak ? Colors.orange : Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Image ${state.phaseQueueIndex + 1} of ${state.totalPhaseCount}',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
        if (!state.isOnBreak && state.imagesRemainingInPhase > 1) ...[
          const SizedBox(width: 4),
          Text(
            '(${state.imagesRemainingInPhase} left in phase)',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> _showClassModeDialog(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(presentationProvider.notifier);
  final state = ref.read(presentationProvider);

  if (state.isClassMode) {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Class Mode?'),
        content: const Text(
          'Are you sure you want to stop the current class session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
    if (shouldStop == true) {
      notifier.stopClassMode();
    }
    return;
  }

  if (state.images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please add images before starting Class Mode'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  final settings = ref.read(settingsProvider);

  await showDialog<void>(
    context: context,
    builder: (context) => _ClassModeSelectionDialog(
      customPresets: settings.customClassPresets,
      onSelectPreset: (preset) {
        final config = ClassConfig.fromPreset(preset);
        final queue = config.generatePhaseQueue();
        if (queue.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please configure class settings first'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        notifier.startClassMode(config);
        Navigator.pop(context);
      },
      onSelectCustom: (config) {
        final queue = config.generatePhaseQueue();
        if (queue.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please configure class settings first'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        notifier.startClassMode(config);
        Navigator.pop(context);
      },
    ),
  );
}

class _ClassModeSelectionDialog extends StatefulWidget {
  final List<ClassPreset> customPresets;
  final Function(ClassLength) onSelectPreset;
  final Function(ClassConfig) onSelectCustom;

  const _ClassModeSelectionDialog({
    this.customPresets = const [],
    required this.onSelectPreset,
    required this.onSelectCustom,
  });

  @override
  State<_ClassModeSelectionDialog> createState() =>
      _ClassModeSelectionDialogState();
}

class _ClassModeSelectionDialogState extends State<_ClassModeSelectionDialog> {
  int _warmUpCount = 4;
  int _earlyCount = 4;
  int _midCount = 2;
  int _finalCount = 1;
  bool _hasBreak = false;
  int _breakMinutes = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start Class Mode'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Start',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetButton(
                    label: '30 Min (11 img)',
                    onTap: () => widget.onSelectPreset(ClassLength.thirtyMinutes),
                  ),
                  _PresetButton(
                    label: '60 Min (18 img)',
                    onTap: () => widget.onSelectPreset(ClassLength.sixtyMinutes),
                  ),
                  ...widget.customPresets.map((preset) => _PresetButton(
                    label: '${preset.name} (${preset.totalImages} img)',
                    onTap: () {
                      final config = ClassConfig(
                        length: ClassLength.custom,
                        warmUpCount: preset.warmUpCount,
                        earlyStudyCount: preset.earlyStudyCount,
                        midStudyCount: preset.midStudyCount,
                        finalStudyCount: preset.finalStudyCount,
                        hasBreak: preset.hasBreak,
                        breakMinutes: preset.breakMinutes,
                      );
                      widget.onSelectCustom(config);
                    },
                  )),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Custom Configuration',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _PhaseConfigRow(
                label: 'Warm-up (30s)',
                value: _warmUpCount,
                onChanged: (val) => setState(() => _warmUpCount = val),
              ),
              _PhaseConfigRow(
                label: 'Early Study (1m)',
                value: _earlyCount,
                onChanged: (val) => setState(() => _earlyCount = val),
              ),
              _PhaseConfigRow(
                label: 'Mid Study (5m)',
                value: _midCount,
                onChanged: (val) => setState(() => _midCount = val),
              ),
              _PhaseConfigRow(
                label: 'Final Study (10m)',
                value: _finalCount,
                onChanged: (val) => setState(() => _finalCount = val),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _hasBreak,
                    onChanged: (val) => setState(() => _hasBreak = val ?? false),
                  ),
                  const Text('Include break'),
                  if (_hasBreak) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: DropdownButton<int>(
                        value: _breakMinutes,
                        isDense: true,
                        items: [3, 5, 10].map((m) => DropdownMenuItem(
                          value: m,
                          child: Text('$m min'),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _breakMinutes = val);
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Images needed: ${_warmUpCount + _earlyCount + _midCount + _finalCount}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final config = ClassConfig(
              length: ClassLength.custom,
              warmUpCount: _warmUpCount,
              earlyStudyCount: _earlyCount,
              midStudyCount: _midCount,
              finalStudyCount: _finalCount,
              hasBreak: _hasBreak,
              breakMinutes: _breakMinutes,
            );
            widget.onSelectCustom(config);
          },
          child: const Text('Start Class'),
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

class _PhaseConfigRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _PhaseConfigRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => onChanged(value + 1),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _AudioModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final state = ref.watch(presentationProvider);
    final isTimerDriven = settings.audioMode == AudioMode.timerDriven;
    final isDisabled = state.isPlaying;

    return Tooltip(
      message: isTimerDriven ? 'Timer Driven: Audio starts randomly' : 'Audio Driven: Image changes when audio ends',
      child: InkWell(
        onTap: isDisabled ? null : () {
          final notifier = ref.read(settingsProvider.notifier);
          notifier.setAudioMode(isTimerDriven ? AudioMode.audioDriven : AudioMode.timerDriven);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isDisabled 
                ? Colors.white.withValues(alpha: 0.05)
                : (isTimerDriven ? Colors.white10 : Colors.green.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDisabled 
                  ? Colors.white.withValues(alpha: 0.1)
                  : (isTimerDriven ? Colors.white24 : Colors.green), 
              width: 1,
            ),
          ),
          child: Text(
            isTimerDriven ? 'TMR' : 'AUD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDisabled 
                  ? Colors.white.withValues(alpha: 0.3)
                  : (isTimerDriven ? Colors.white60 : Colors.green),
            ),
          ),
        ),
      ),
    );
  }
}
