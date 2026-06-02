import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/drawing_provider.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/entities/drawing_state.dart';

class DrawingCanvas extends ConsumerStatefulWidget {
  const DrawingCanvas({super.key});

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  DrawingStroke? _currentStroke;

  @override
  Widget build(BuildContext context) {
    final presentationState = ref.watch(presentationProvider);
    final settings = ref.watch(settingsProvider);
    final drawingState = ref.watch(drawingProvider);
    final drawingNotifier = ref.read(drawingProvider.notifier);

    ref.listen(presentationProvider, (prev, next) {
      if (settings.useViewport3D &&
          prev != null &&
          prev.currentIndex != next.currentIndex) {
        drawingNotifier.clearImageDrawings('_3d_');
      }
    });

    if (!drawingState.drawingEnabled) {
      return const IgnorePointer(child: SizedBox.expand());
    }

    final imageId = settings.useViewport3D
        ? '_3d_'
        : (presentationState.currentImage?.id ?? '');

    final strokes = drawingState.strokesFor(imageId);

    return GestureDetector(
      onPanStart: (details) {
        _currentStroke = DrawingStroke(
          points: [details.localPosition],
          color: drawingState.currentColor,
          strokeWidth: drawingState.currentStrokeWidth,
          opacity: drawingState.currentOpacity,
          isEraser: drawingState.eraserMode,
        );
      },
      onPanUpdate: (details) {
        if (_currentStroke == null) return;
        setState(() {
          _currentStroke = _currentStroke!.copyWith(
            points: [..._currentStroke!.points, details.localPosition],
          );
        });
      },
      onPanEnd: (details) {
        if (_currentStroke == null) return;
        drawingNotifier.addStroke(imageId, _currentStroke!);
        setState(() => _currentStroke = null);
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DrawingPainter(
            strokes: strokes,
            currentStroke: _currentStroke,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  _DrawingPainter({
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final allStrokes = [
      ...strokes,
      if (currentStroke != null) currentStroke!,
    ];
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final stroke in allStrokes) {
      if (stroke.points.isEmpty) continue;
      if (stroke.isEraser) {
        _drawEraserStroke(canvas, stroke);
      } else {
        _drawTexturedStroke(canvas, stroke);
      }
    }
    canvas.restore();
  }

  void _drawEraserStroke(Canvas canvas, DrawingStroke stroke) {
    final paint = Paint()
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.clear;
    canvas.drawPath(_buildPath(stroke.points), paint);
  }

  void _drawTexturedStroke(Canvas canvas, DrawingStroke stroke) {
    final points = stroke.points;
    final baseWidth = stroke.strokeWidth;
    final o = stroke.opacity;
    final baseColor = stroke.color.withValues(alpha: o);

    final blurPaint = Paint()
      ..color = stroke.color.withValues(alpha: o * 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseWidth * 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, baseWidth * 0.3);
    canvas.drawPath(_buildPath(points), blurPaint);

    final corePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseWidth * 0.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_buildPath(points), corePaint);

    final dotPaint = Paint();
    double carry = 0;
    const step = 3.0;
    for (int i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final seg = (b - a).distance;
      if (seg == 0) continue;
      carry += seg;
      while (carry >= step) {
        carry -= step;
        final t = 1.0 - carry / seg;
        final x = a.dx + (b.dx - a.dx) * t;
        final y = a.dy + (b.dy - a.dy) * t;
        final r = baseWidth * (0.15 + (i * 7 % 11) / 22);
        dotPaint.color = stroke.color.withValues(
          alpha: o * (0.85 + (i % 5) * 0.05),
        );
        canvas.drawCircle(Offset(x, y), r, dotPaint);
      }
    }
  }

  Path _buildPath(List<Offset> points) {
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.currentStroke != currentStroke;
}
