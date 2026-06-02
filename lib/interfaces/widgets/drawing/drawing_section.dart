import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/drawing_provider.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../controls/silver_controls.dart';
import '../common/section_header.dart';

class DrawingSection extends ConsumerWidget {
  final VoidCallback? onSaveImage;

  const DrawingSection({super.key, this.onSaveImage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingState = ref.watch(drawingProvider);
    final notifier = ref.read(drawingProvider.notifier);
    final presentationState = ref.watch(presentationProvider);
    final settings = ref.watch(settingsProvider);

    if (!drawingState.drawingEnabled) return const SizedBox.shrink();

    final imageId = settings.useViewport3D
        ? '_3d_'
        : (presentationState.currentImage?.id ?? '');
    final hasDrawing = drawingState.strokesFor(imageId).isNotEmpty;
    final hasAnyDrawing = notifier.hasAnyDrawing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const SectionHeader(title: 'Drawing'),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 8,
          children: [
            Opacity(
              opacity: hasDrawing ? 1.0 : 0.4,
              child: SilverIconButton(
                icon: Icons.save_alt,
                tooltip: 'Save as image',
                onPressed: onSaveImage ?? () {},
              ),
            ),
            Opacity(
              opacity: hasAnyDrawing ? 1.0 : 0.4,
              child: SilverIconButton(
                icon: Icons.delete_forever,
                tooltip: 'Clear all drawings',
                onPressed: hasAnyDrawing
                    ? () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear all drawings?'),
                            content: const Text(
                              'This will remove all drawings from all images.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  notifier.clearAllDrawings();
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('Clear All'),
                              ),
                            ],
                          ),
                        );
                      }
                    : () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
