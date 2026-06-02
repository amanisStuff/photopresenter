import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme.dart';
import '../../../core/providers/drawing_provider.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';

const List<Color> _colorOptions = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFDD835),
  Colors.white,
  Colors.black,
];

const List<double> _brushSizeOptions = [2.0, 6.0, 12.0];

class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({super.key});

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

    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOverlay.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._colorOptions.map(
                  (color) => _ColorDot(
                    color: color,
                    selected: drawingState.currentColor == color &&
                        !drawingState.eraserMode,
                    onTap: () => notifier.setColor(color),
                  ),
                ),
                const SizedBox(width: 6),
                Container(width: 1, height: 24, color: AppTheme.border),
                const SizedBox(width: 6),
                ..._brushSizeOptions.map(
                  (size) => _BrushSizeButton(
                    size: size,
                    selected: drawingState.currentStrokeWidth == size,
                    onTap: () => notifier.setStrokeWidth(size),
                  ),
                ),
                const SizedBox(width: 6),
                Container(width: 1, height: 24, color: AppTheme.border),
                const SizedBox(width: 6),
                _ToolButton(
                  icon: Icons.auto_fix_high,
                  active: drawingState.eraserMode,
                  tooltip: 'Eraser',
                  onTap: () => notifier.toggleEraser(),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.undo,
                  active: false,
                  tooltip: 'Undo',
                  onTap: () => notifier.undoLastStroke(imageId),
                ),
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.delete_sweep,
                  active: false,
                  tooltip: 'Clear current',
                  onTap: () => notifier.clearImageDrawings(imageId),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _OpacitySlider(
              value: drawingState.currentOpacity,
              onChanged: notifier.setOpacity,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.grey.shade600,
            width: selected ? 2.5 : 1.0,
          ),
        ),
      ),
    );
  }
}

class _BrushSizeButton extends StatelessWidget {
  final double size;
  final bool selected;
  final VoidCallback onTap;

  const _BrushSizeButton({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: selected
              ? Border.all(color: AppTheme.primary, width: 1)
              : null,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: active
                ? Border.all(color: AppTheme.primary, width: 1)
                : null,
          ),
          child: Icon(icon, size: 16, color: active ? AppTheme.primaryLight : AppTheme.onSurface),
        ),
      ),
    );
  }
}

class _OpacitySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _OpacitySlider({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 16,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 5,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 12,
              ),
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.primaryLight,
              overlayColor: AppTheme.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value,
              min: 0.1,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.onSurface,
          ),
        ),
      ],
    );
  }
}
