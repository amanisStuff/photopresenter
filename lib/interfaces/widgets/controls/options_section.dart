import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/viewport_controls_provider.dart';

class OptionsSection extends ConsumerWidget {
  const OptionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final vpState = ref.watch(viewportProvider);

    if (!settings.useViewport3D) return const SizedBox.shrink();
    if (vpState.activeOptionsPanel == ActiveOptionsPanel.none) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: _buildPanel(vpState, ref),
      ),
    );
  }

  Widget _buildPanel(ViewportControlsState vpState, WidgetRef ref) {
    switch (vpState.activeOptionsPanel) {
      case ActiveOptionsPanel.size:
        return _buildSizePanel(vpState, ref);
      case ActiveOptionsPanel.light:
        return _buildLightPanel(vpState, ref);
      case ActiveOptionsPanel.camera:
        return _buildCameraPanel(vpState, ref);
      case ActiveOptionsPanel.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSizePanel(ViewportControlsState vpState, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('Lock Size', style: TextStyle(fontSize: 12)),
            const Spacer(),
            SizedBox(
              height: 24,
              child: Switch(
                value: vpState.sizeLocked,
                onChanged: (val) {
                  ref.read(viewportProvider.notifier).toggleSizeLocked();
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        if (vpState.sizeLocked) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Scale', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: vpState.uniformScale,
                  min: 1.0,
                  max: 3.0,
                  divisions: 20,
                  label: vpState.uniformScale.toStringAsFixed(1),
                  onChanged: (val) {
                    ref.read(viewportProvider.notifier).setUniformScale(val);
                  },
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  vpState.uniformScale.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLightPanel(ViewportControlsState vpState, WidgetRef ref) {
    final notifier = ref.read(viewportProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _lightSliderRow(
          label: 'H',
          value: vpState.lightHorizontalAngle,
          min: 0,
          max: 360,
          divisions: 72,
          locked: vpState.lightHorizontalLocked,
          formatValue: (v) => '${v.round()}\u00B0',
          onChanged: (v) => notifier.setLightHorizontalAngle(v),
          onToggleLock: () => notifier.toggleHorizontalLocked(),
        ),
        const SizedBox(height: 4),
        _lightSliderRow(
          label: 'V',
          value: vpState.lightVerticalAngle,
          min: 0,
          max: 360,
          divisions: 72,
          locked: vpState.lightVerticalLocked,
          formatValue: (v) => '${v.round()}\u00B0',
          onChanged: (v) => notifier.setLightVerticalAngle(v),
          onToggleLock: () => notifier.toggleVerticalLocked(),
        ),
        const SizedBox(height: 4),
        _lightSliderRow(
          label: 'D',
          value: vpState.lightDistance,
          min: 1,
          max: 20,
          divisions: 38,
          locked: vpState.lightDistanceLocked,
          formatValue: (v) => v.toStringAsFixed(1),
          onChanged: (v) => notifier.setLightDistance(v),
          onToggleLock: () => notifier.toggleDistanceLocked(),
        ),
      ],
    );
  }

  Widget _buildCameraPanel(ViewportControlsState vpState, WidgetRef ref) {
    final notifier = ref.read(viewportProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _cameraSliderRow(
          label: 'H',
          value: vpState.cameraHorizontalAngle,
          min: 0,
          max: 360,
          divisions: 360,
          formatValue: (v) => '${v.round()}\u00B0',
          onChanged: (v) => notifier.setCameraHorizontalAngle(v),
          locked: vpState.cameraHorizontalLocked,
          onToggleLock: () => notifier.toggleCameraHorizontalLocked(),
        ),
        const SizedBox(height: 4),
        _cameraSliderRow(
          label: 'V',
          value: vpState.cameraVerticalAngle,
          min: -90,
          max: 90,
          divisions: 180,
          formatValue: (v) => '${v.round()}\u00B0',
          onChanged: (v) => notifier.setCameraVerticalAngle(v),
          locked: vpState.cameraVerticalLocked,
          onToggleLock: () => notifier.toggleCameraVerticalLocked(),
        ),
        const SizedBox(height: 4),
        _cameraSliderRow(
          label: 'D',
          value: vpState.cameraDistance,
          min: 2,
          max: 50,
          divisions: 480,
          formatValue: (v) => v.toStringAsFixed(1),
          onChanged: (v) => notifier.setCameraDistance(v),
          locked: vpState.cameraDistanceLocked,
          onToggleLock: () => notifier.toggleCameraDistanceLocked(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Divider(height: 1),
        ),
        _cameraSliderRow(
          label: 'X',
          value: vpState.cameraPanX,
          min: -10,
          max: 10,
          divisions: 200,
          formatValue: (v) => v.toStringAsFixed(1),
          onChanged: (v) => notifier.setCameraPanX(v),
          locked: vpState.cameraPanXLocked,
          onToggleLock: () => notifier.toggleCameraPanXLocked(),
        ),
        const SizedBox(height: 4),
        _cameraSliderRow(
          label: 'Z',
          value: vpState.cameraPanZ,
          min: -10,
          max: 10,
          divisions: 200,
          formatValue: (v) => v.toStringAsFixed(1),
          onChanged: (v) => notifier.setCameraPanZ(v),
          locked: vpState.cameraPanZLocked,
          onToggleLock: () => notifier.toggleCameraPanZLocked(),
        ),
        const SizedBox(height: 4),
        _cameraSliderRow(
          label: 'Y',
          value: vpState.cameraPanY,
          min: -10,
          max: 10,
          divisions: 200,
          formatValue: (v) => v.toStringAsFixed(1),
          onChanged: (v) => notifier.setCameraPanY(v),
          locked: vpState.cameraPanYLocked,
          onToggleLock: () => notifier.toggleCameraPanYLocked(),
        ),
      ],
    );
  }

  Widget _lightSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required bool locked,
    required String Function(double) formatValue,
    required ValueChanged<double> onChanged,
    required VoidCallback onToggleLock,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(label, style: const TextStyle(fontSize: 11)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: formatValue(value),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            formatValue(value),
            style: const TextStyle(fontSize: 11),
          ),
        ),
        SizedBox(
          width: 40,
          child: Transform.scale(
            scale: 0.7,
            child: Switch(
              value: locked,
              onChanged: (_) => onToggleLock(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cameraSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) formatValue,
    required ValueChanged<double> onChanged,
    bool? locked,
    VoidCallback? onToggleLock,
  }) {
    final snapPoints = [min, min + (max - min) * 0.25, min + (max - min) * 0.5, min + (max - min) * 0.75, max];
    final snapThreshold = (max - min) * 0.05;

    void handleChanged(double v) {
      for (final snap in snapPoints) {
        if ((v - snap).abs() < snapThreshold) {
          onChanged(snap);
          return;
        }
      }
      onChanged(v);
    }

    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(label, style: const TextStyle(fontSize: 11)),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final thumbShape = SliderTheme.of(context).thumbShape;
              const defaultRadius = 10.0;
              final thumbRadius = (thumbShape?.getPreferredSize(true, true).width ?? defaultRadius * 2) / 2;
              final trackWidth = constraints.maxWidth - thumbRadius * 2;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: formatValue(value),
                    onChanged: handleChanged,
                  ),
                  ...snapPoints.map((sp) {
                    final frac = (sp - min) / (max - min);
                    return Positioned(
                      left: thumbRadius + trackWidth * frac - 2,
                      bottom: 6,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            formatValue(value),
            style: const TextStyle(fontSize: 11),
          ),
        ),
        locked != null && onToggleLock != null
            ? SizedBox(
                width: 40,
                child: Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: locked,
                    onChanged: (_) => onToggleLock(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              )
            : const SizedBox(width: 40),
      ],
    );
  }
}
