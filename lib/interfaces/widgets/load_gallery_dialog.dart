import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/presentation_provider.dart';
import '../../infrastructure/service_providers.dart';

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
