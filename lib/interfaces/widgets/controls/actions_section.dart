import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/drawing_provider.dart';
import '../../screens/settings_screen.dart';
import '../../../infrastructure/service_providers.dart';
import 'silver_controls.dart';

Future<void> showLoadGalleryDialog(
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
                          showLoadGalleryDialog(context, ref);
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
                            content: Text(
                              'Gallery "${gallery.name}" loaded',
                            ),
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

IconData filterIconData(ImageFilter filter) {
  switch (filter) {
    case ImageFilter.none:
      return Icons.filter_none;
    case ImageFilter.grayscale:
      return Icons.gradient;
    case ImageFilter.sepia:
      return Icons.filter_vintage;
    case ImageFilter.invert:
      return Icons.invert_colors;
    case ImageFilter.brightness:
      return Icons.brightness_6;
    case ImageFilter.contrast:
      return Icons.contrast;
    case ImageFilter.extremeContrast:
      return Icons.contrast;
    case ImageFilter.blurEffect:
      return Icons.blur_on;
    case ImageFilter.heavyBlur:
      return Icons.blur_circular;
  }
}

class ActionsSection extends ConsumerWidget {
  const ActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: [
        if (state.hasAudio) ...[
          SilverIconButton(
            icon: Icons.audiotrack,
            color: AppTheme.success,
            tooltip: 'Audio',
            onPressed: () => notifier.pickAudio(),
          ),
          SilverIconButton(
            icon: Icons.clear,
            size: 12,
            tooltip: 'Clear audio',
            onPressed: () => notifier.clearAudio(),
          ),
        ] else
          SilverIconButton(
            icon: Icons.library_music,
            tooltip: 'Add audio',
            onPressed: () => notifier.pickAudio(),
          ),
        SilverIconButton(
          icon: Icons.settings,
          tooltip: 'Settings',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          ),
        ),
        Builder(
          builder: (context) {
            final settings = ref.watch(settingsProvider);
            return SilverIconButton(
              icon: settings.useViewport3D
                  ? Icons.view_in_ar
                  : Icons.crop_original,
              tooltip: settings.useViewport3D
                  ? '3D Viewport (tap to switch)'
                  : 'Flat View (tap for 3D)',
              onPressed: () {
                final notifier = ref.read(settingsProvider.notifier);
                notifier.setUseViewport3D(!settings.useViewport3D);
              },
            );
          },
        ),
        SilverIconButton(
          icon: Icons.fullscreen,
          tooltip: 'Focus Mode',
          onPressed: () => notifier.toggleFocusMode(),
        ),
        Consumer(
          builder: (context, ref, child) {
            final drawingState = ref.watch(drawingProvider);
            return SilverIconButton(
              icon: Icons.brush,
              color: drawingState.drawingEnabled
                  ? AppTheme.primaryLight
                  : null,
              tooltip: drawingState.drawingEnabled
                  ? 'Disable Drawing'
                  : 'Enable Drawing (Ctrl+Shift+D)',
              onPressed: () =>
                  ref.read(drawingProvider.notifier).toggleDrawing(),
            );
          },
        ),
        SilverPopupButton(
          icon: Icons.filter,
          isActive: state.activeFilters.isNotEmpty,
          activeColor: AppTheme.primary,
          tooltip: 'Image Filters',
          itemBuilder: (context) {
            final items = <PopupMenuEntry<void>>[];
            if (state.activeFilters.isNotEmpty) {
              items.add(
                PopupMenuItem<void>(
                  onTap: () => notifier.clearFilters(),
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 18, color: AppTheme.filterClearStyle.color),
                      const SizedBox(width: 8),
                      Text('None (Clear All)', style: AppTheme.filterClearStyle),
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
                      Icon(filterIconData(filter), size: 18),
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
        Container(
          decoration: AppTheme.buttonDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MenuButton(
                icon: Icons.folder_open,
                tooltip: 'Load',
                onSelected: (String value) {
                  switch (value) {
                    case 'images':
                      notifier.pickFiles();
                      break;
                    case 'gallery':
                      showLoadGalleryDialog(context, ref);
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
              Container(width: 1, height: 20, color: AppTheme.border),
              MenuButton(
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
    );
  }
}
