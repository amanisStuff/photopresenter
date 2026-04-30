import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/presentation_provider.dart';
import '../../../services/service_providers.dart';

class PresentationControls extends ConsumerWidget {
  const PresentationControls({super.key});

  Future<void> _showSaveGalleryDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController(text: 'My Gallery');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Gallery'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Gallery name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final manifest = await ref
          .read(presentationProvider.notifier)
          .saveGallery(name);
      if (context.mounted) {
        if (manifest != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gallery "${manifest.name}" saved successfully'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No images or audio to save')),
          );
        }
      }
    }
  }

  Future<void> _showLoadGalleryDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final notifier = ref.read(presentationProvider.notifier);
    final galleries = await notifier.listGalleries();

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
                          final galleryService = ref.read(
                            galleryServiceProvider,
                          );
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
                        await notifier.loadGallery(gallery.id);
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

  Future<void> _showAddWebImagesDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final notifier = ref.read(presentationProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Images from Web'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter image URLs (one per line):',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText:
                      'https://example.com/image1.jpg\nhttps://example.com/image2.png',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final urls = controller.text
                  .split('\n')
                  .map((u) => u.trim())
                  .where((u) => u.isNotEmpty)
                  .toList();

              if (urls.isEmpty) return;

              Navigator.of(context).pop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading images...')),
                );
              }

              final addedPaths = await notifier.addImagesFromUrls(urls);

              if (context.mounted) {
                if (addedPaths.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${addedPaths.length} image(s) added'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to download any images'),
                    ),
                  );
                }
              }
            },
            child: const Text('Download'),
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
                  tooltip: 'Focus Mode',
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => notifier.toggleFocusMode(),
                ),
                IconButton(
                  tooltip: 'Save Gallery',
                  icon: const Icon(Icons.save, color: Colors.white70, size: 20),
                  onPressed: state.images.isEmpty && !state.hasAudio
                      ? null
                      : () => _showSaveGalleryDialog(context, ref),
                ),
                IconButton(
                  tooltip: 'Load Gallery',
                  icon: const Icon(
                    Icons.folder_open,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => _showLoadGalleryDialog(context, ref),
                ),
                IconButton(
                  tooltip: 'Add Images from Web',
                  icon: const Icon(
                    Icons.language,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => _showAddWebImagesDialog(context, ref),
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
