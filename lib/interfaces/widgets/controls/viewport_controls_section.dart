import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/viewport_controls_provider.dart';
import 'silver_controls.dart';

const _objectOptions = [
  ('assets/cube/cube.obj', 'Cube'),
  ('assets/sphere/sphere.obj', 'Sphere'),
  ('assets/cone/cone.obj', 'Cone'),
  ('assets/cylinder/cylinder.obj', 'Cylinder'),
  ('assets/pyramid/pyramid.obj', 'Pyramid'),
  ('assets/Torus/Torus.obj', 'Torus'),
];

class ViewportControlsSection extends ConsumerWidget {
  const ViewportControlsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final vpState = ref.watch(viewportProvider);

    if (!settings.useViewport3D) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        SilverIconButton(
          icon: Icons.height,
          color: vpState.gravityMode ? Colors.amber : null,
          tooltip: 'Gravity',
          onPressed: () =>
              ref.read(viewportProvider.notifier).toggleGravity(),
        ),
        SilverIconButton(
          icon: Icons.lightbulb_outline,
          color: vpState.activeOptionsPanel == ActiveOptionsPanel.light
              ? Colors.amber
              : null,
          tooltip: 'Light',
          onPressed: () =>
              ref.read(viewportProvider.notifier).toggleLightOptions(),
        ),
        SilverIconButton(
          icon: Icons.aspect_ratio,
          color: vpState.activeOptionsPanel == ActiveOptionsPanel.size
              ? Colors.cyanAccent
              : null,
          tooltip: 'Size',
          onPressed: () =>
              ref.read(viewportProvider.notifier).toggleSizeOptions(),
        ),
        SilverIconButton(
          icon: Icons.videocam,
          color: vpState.activeOptionsPanel == ActiveOptionsPanel.camera
              ? Colors.purpleAccent
              : null,
          tooltip: 'Camera',
          onPressed: () =>
              ref.read(viewportProvider.notifier).toggleCameraOptions(),
        ),
        SilverPopupButton<String>(
          icon: Icons.view_in_ar,
          tooltip: 'Object',
          onSelected: (path) =>
              ref.read(viewportProvider.notifier).setObjectPath(path),
          itemBuilder: (context) => _objectOptions.map((entry) {
            final (path, name) = entry;
            final isSelected = path == vpState.objectPath;
            return PopupMenuItem<String>(
              value: path,
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    size: 16,
                    color: isSelected ? Colors.amberAccent : null,
                  ),
                  const SizedBox(width: 8),
                  Text(name),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
