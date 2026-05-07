import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';
import '../../core/entities/class_session.dart';
import '../screens/settings_screen.dart';
import '../../core/entities/app_settings.dart';
import '../../core/providers/settings_provider.dart';
import '../../infrastructure/service_providers.dart';

class PresentationControls extends ConsumerWidget {
  const PresentationControls({super.key});

  Future<void> _showLoadGalleryDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final galleryService = ref.read(galleryServiceProvider);
    final galleries = await galleryService.listGalleries();

    if (!context.mounted) return;

    if (galleries.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No saved galleries found')));
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Gallery'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: galleries.length,
            itemBuilder: (context, index) {
              final gallery = galleries[index];
              return ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(gallery.name),
                subtitle: Text(
                  '${gallery.imageCount} images, ${gallery.audioCount} audio · '
                  '${gallery.createdAt.month}/${gallery.createdAt.day}/${gallery.createdAt.year}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Gallery'),
                            content: Text(
                              'Are you sure you want to delete "${gallery.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await galleryService.deleteGallery(gallery.id);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gallery "${gallery.name}" deleted',
                                ),
                              ),
                            );
                            _showLoadGalleryDialog(context, ref);
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: () async {
                        final notifier = ref.read(presentationProvider.notifier);
                        await notifier.loadGalleryById(gallery.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gallery "${gallery.name}" loaded'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: AppTheme.silverControlsBar,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
        children: [
          Positioned(
            left: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.35),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                        color: state.isPlaying ? AppTheme.xpGreen : AppTheme.silverDark,
                      ),
                      _AudioModeToggle(),
                    ],
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: state.isPlaying ? AppTheme.royalBlue : AppTheme.silverDark,
                    ),
                    Builder(
                      builder: (context) {
                        final settings = ref.watch(settingsProvider);
                        final isAudioDriven =
                            settings.audioMode == AudioMode.audioDriven;

                        final bool showAudioCountdown =
                            state.hasAudio &&
                            state.isPlaying &&
                            state.audioDuration.inSeconds > 0 &&
                            (isAudioDriven || state.isClassMode);

                        final int secondsLeft = showAudioCountdown
                            ? (state.audioDuration.inSeconds -
                                  state.audioPosition.inSeconds)
                            : state.remainingTime.inSeconds;

                        final bool isLowTime =
                            !showAudioCountdown && secondsLeft <= 5;

                        return Text(
                          '${secondsLeft}s',
                          style: TextStyle(
                            color: showAudioCountdown
                                ? AppTheme.xpGreen
                                : (isLowTime ? AppTheme.closeRed : AppTheme.textOnSilver),
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
                          final isAudioDriven =
                              settings.audioMode == AudioMode.audioDriven;
                          final showAudioProgress =
                              state.hasAudio &&
                              state.audioDuration.inMilliseconds > 0 &&
                              (isAudioDriven || state.isClassMode);

                          final double progress = showAudioProgress
                              ? (state.audioDuration.inMilliseconds > 0
                                    ? (state.audioDuration.inMilliseconds -
                                              state
                                                  .audioPosition
                                                  .inMilliseconds) /
                                          state.audioDuration.inMilliseconds
                                    : 0.0)
                              : (state.timerDuration.inMilliseconds > 0
                                    ? state.remainingTime.inMilliseconds /
                                          state.timerDuration.inMilliseconds
                                    : 0.0);

                          return SizedBox(
                            width: 100,
                            height: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFF808080),
                                valueColor: AlwaysStoppedAnimation(
                                  showAudioProgress
                                      ? AppTheme.xpGreen
                                      : (state.remainingTime.inSeconds <= 5
                                            ? AppTheme.closeRed
                                            : AppTheme.xpGreen),
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.royalBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.royalBlue.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${state.timerDuration.inSeconds}s',
                          style: const TextStyle(
                            color: AppTheme.royalBlueLight,
                            fontWeight: FontWeight.bold,
                          ),
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
          ),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: AppTheme.silverButton(),
                  padding: const EdgeInsets.all(2),
                  child: IconButton(
                    icon: const Icon(Icons.skip_previous, size: 20),
                    onPressed: state.images.isEmpty
                        ? null
                        : () => notifier.previousImage(),
                    color: AppTheme.textOnSilver,
                    style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: AppTheme.silverButton(),
                padding: const EdgeInsets.all(2),
                child: IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    size: 18,
                    color: state.isShuffled ? AppTheme.xpGreen : AppTheme.textOnSilver,
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
              ),
              const SizedBox(width: 6),
              Container(
                decoration: AppTheme.silverButton(isPlay: true),
                padding: const EdgeInsets.all(2),
                child: IconButton(
                  icon: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 26,
                  ),
                  onPressed: state.images.isEmpty
                      ? null
                      : () => notifier.togglePlay(),
                  color: AppTheme.royalBlue,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: AppTheme.silverButton(),
                padding: const EdgeInsets.all(2),
                child: IconButton(
                  icon: const Icon(Icons.skip_next, size: 20),
                  onPressed: state.images.isEmpty
                      ? null
                      : () => notifier.nextImage(),
                  color: AppTheme.textOnSilver,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              ),
            ],
          ),
          ),

          Positioned(
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
            children: [
              if (state.hasAudio) ...[
                _SilverIconButton(
                  icon: Icons.audiotrack,
                  color: AppTheme.xpGreen,
                  tooltip: 'Audio',
                  onPressed: () => notifier.pickAudio(),
                ),
                const SizedBox(width: 2),
                _SilverIconButton(
                  icon: Icons.clear,
                  size: 12,
                  tooltip: 'Clear audio',
                  onPressed: () => notifier.clearAudio(),
                ),
              ] else
                _SilverIconButton(
                  icon: Icons.library_music,
                  tooltip: 'Add audio',
                  onPressed: () => notifier.pickAudio(),
                ),
              const SizedBox(width: 4),
              _SilverIconButton(
                icon: Icons.settings,
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _SilverIconButton(
                icon: Icons.fullscreen,
                tooltip: 'Focus Mode',
                onPressed: () => notifier.toggleFocusMode(),
              ),
              const SizedBox(width: 4),
              _SilverPopupButton(
                icon: Icons.filter,
                isActive: state.activeFilters.isNotEmpty,
                activeColor: AppTheme.royalBlue,
                tooltip: 'Image Filters',
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<void>>[];
                  if (state.activeFilters.isNotEmpty) {
                    items.add(
                      PopupMenuItem<void>(
                        onTap: () => notifier.clearFilters(),
                        child: Row(
                          children: [
                            Icon(Icons.clear_all, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('None (Clear All)', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                    items.add(const PopupMenuDivider());
                  }
                  for (final filter in ImageFilter.values) {
                    if (filter == ImageFilter.none) continue;
                    items.add(
                      PopupMenuItem<void>(
                        onTap: () => notifier.toggleFilter(filter),
                        child: Row(
                          children: [
                            Icon(
                              state.activeFilters.contains(filter)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 18,
                              color: state.activeFilters.contains(filter) ? Colors.amber : null,
                            ),
                            const SizedBox(width: 8),
                            Icon(_filterIconData(filter), size: 18),
                            const SizedBox(width: 8),
                            Text(filter.displayName),
                          ],
                        ),
                      ),
                    );
                  }
                  return items;
                },
              ),
              const SizedBox(width: 6),
              Container(
                decoration: AppTheme.silverButton(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MenuButton(
                      icon: Icons.folder_open,
                      tooltip: 'Load',
                      onSelected: (String value) {
                        switch (value) {
                          case 'images':
                            notifier.pickFiles();
                            break;
                          case 'gallery':
                            _showLoadGalleryDialog(context, ref);
                            break;
                          case 'playlist':
                            notifier.loadPlaylist();
                            break;
                        }
                      },
                      items: const [
                        (Icons.image, 'Add Images'),
                        (Icons.collections, 'Load Gallery'),
                        (Icons.queue_music, 'Load Playlist'),
                      ],
                    ),
                    Container(width: 1, height: 20, color: const Color(0xFF808080)),
                    _MenuButton(
                      icon: Icons.save_alt,
                      tooltip: 'Save / Export',
                      onSelected: (String value) {
                        switch (value) {
                          case 'export':
                            notifier.exportAllImages();
                            break;
                          case 'gallery':
                            notifier.saveGallery(
                              'Gallery ${DateTime.now().millisecondsSinceEpoch}',
                            );
                            break;
                          case 'playlist':
                            notifier.savePlaylist();
                            break;
                        }
                      },
                      items: const [
                        (Icons.download, 'Download Images'),
                        (Icons.collections, 'Save Gallery'),
                        (Icons.queue_music, 'Save Playlist'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ],
      ),
      ),
      );
  }
}

IconData _filterIconData(ImageFilter filter) {
  switch (filter) {
    case ImageFilter.none: return Icons.filter_none;
    case ImageFilter.grayscale: return Icons.gradient;
    case ImageFilter.sepia: return Icons.filter_vintage;
    case ImageFilter.invert: return Icons.invert_colors;
    case ImageFilter.brightness: return Icons.brightness_6;
    case ImageFilter.contrast: return Icons.contrast;
    case ImageFilter.extremeContrast: return Icons.contrast;
    case ImageFilter.blurEffect: return Icons.blur_on;
    case ImageFilter.heavyBlur: return Icons.blur_circular;
  }
}

class _SilverIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final String tooltip;
  final VoidCallback onPressed;

  const _SilverIconButton({
    required this.icon,
    this.color,
    this.size = 16,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.silverButton(),
      padding: const EdgeInsets.all(1),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: color ?? AppTheme.textOnSilver, size: size),
        onPressed: onPressed,
        style: IconButton.styleFrom(backgroundColor: Colors.transparent),
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _MenuButton<T> extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final void Function(T)? onSelected;
  final List<(IconData, String)> items;

  const _MenuButton({
    required this.icon,
    required this.tooltip,
    this.onSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      icon: Icon(icon, color: AppTheme.textOnSilver, size: 16),
      itemBuilder: (context) {
        return items.map((entry) {
          return PopupMenuItem<T>(
            value: (entry.$2 as dynamic) as T,
            child: Row(
              children: [
                Icon(entry.$1, size: 18),
                const SizedBox(width: 8),
                Text(entry.$2),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

class _SilverPopupButton<T> extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final String tooltip;
  final void Function(T)? onSelected;
  final PopupMenuItemBuilder<T>? itemBuilder;
  final List<(IconData, String)>? items;

  const _SilverPopupButton({
    required this.icon,
    this.isActive = false,
    this.activeColor = AppTheme.textOnSilver,
    required this.tooltip,
    this.onSelected,
    this.itemBuilder,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.silverButton(),
      padding: const EdgeInsets.all(1),
      child: PopupMenuButton<T>(
        tooltip: tooltip,
        onSelected: onSelected,
        icon: Icon(icon, color: isActive ? activeColor : AppTheme.textOnSilver, size: 16),
        itemBuilder: itemBuilder ?? (context) {
          if (items == null) return [];
          return items!.map((entry) {
            return PopupMenuItem<T>(
              value: (entry.$2 as dynamic) as T,
              child: Row(
                children: [
                  Icon(entry.$1, size: 18),
                  const SizedBox(width: 8),
                  Text(entry.$2),
                ],
              ),
            );
          }).toList();
        },
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDisabled
                ? [const Color(0xFFC0C0C0), const Color(0xFFD8D8D8)]
                : [const Color(0xFFE8E8E8), const Color(0xFFC0C0C0)],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF808080), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          '${value}s',
          style: TextStyle(
            color: isDisabled
                ? AppTheme.textOnSilver.withValues(alpha: 0.4)
                : AppTheme.textOnSilver,
            fontWeight: FontWeight.bold,
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
      decoration: AppTheme.xpPillButton(active: isActive),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isActive ? onStop : onStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school,
                  size: 14,
                  color: isActive ? Colors.white : AppTheme.textOnSilver,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'Class' : 'Class Mode',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textOnSilver,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
                ? AppTheme.royalBlue.withValues(alpha: 0.2)
                : AppTheme.xpGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: state.isOnBreak
                  ? AppTheme.royalBlue.withValues(alpha: 0.4)
                  : AppTheme.xpGreen.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            phaseName,
            style: TextStyle(
              color: state.isOnBreak ? AppTheme.royalBlueLight : AppTheme.xpGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (!state.isOnBreak && state.imagesRemainingInPhase > 1) ...[
          const SizedBox(width: 4),
          Text(
            '(${state.imagesRemainingInPhase} left in phase)',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetButton(
                    label: '30 Min (11 img)',
                    onTap: () =>
                        widget.onSelectPreset(ClassLength.thirtyMinutes),
                  ),
                  _PresetButton(
                    label: '60 Min (18 img)',
                    onTap: () =>
                        widget.onSelectPreset(ClassLength.sixtyMinutes),
                  ),
                  ...widget.customPresets.map(
                    (preset) => _PresetButton(
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Custom Configuration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    onChanged: (val) =>
                        setState(() => _hasBreak = val ?? false),
                  ),
                  const Text('Include break'),
                  if (_hasBreak) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: DropdownButton<int>(
                        value: _breakMinutes,
                        isDense: true,
                        items: [3, 5, 10]
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text('$m min'),
                              ),
                            )
                            .toList(),
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
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.royalBlue.withValues(alpha: 0.12),
                      AppTheme.royalBlueDark.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.royalBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      color: AppTheme.royalBlueLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Images needed: ${_warmUpCount + _earlyCount + _midCount + _finalCount}',
                      style: const TextStyle(
                        color: AppTheme.royalBlueLight,
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
          Expanded(flex: 2, child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
      message: isTimerDriven
          ? 'Timer Driven: Audio starts randomly'
          : 'Audio Driven: Image changes when audio ends',
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                final notifier = ref.read(settingsProvider.notifier);
                notifier.setAudioMode(
                  isTimerDriven ? AudioMode.audioDriven : AudioMode.timerDriven,
                );
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDisabled
                  ? [const Color(0xFFC0C0C0), const Color(0xFFD8D8D8)]
                  : (isTimerDriven
                        ? [const Color(0xFFE8E8E8), const Color(0xFFC0C0C0)]
                        : [AppTheme.xpGreen, AppTheme.xpGreenDark]),
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDisabled
                  ? const Color(0xFF808080)
                  : (isTimerDriven ? const Color(0xFF808080) : AppTheme.xpGreenDark),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            isTimerDriven ? 'TMR' : 'AUD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDisabled
                  ? AppTheme.textOnSilver.withValues(alpha: 0.4)
                  : (isTimerDriven ? AppTheme.textOnSilver : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
