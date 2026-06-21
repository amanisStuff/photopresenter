import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/entities/drawing_state.dart';

Rect? imageRenderRect(Size canvasSize, double? imageWidth, double? imageHeight) {
  if (imageWidth == null || imageHeight == null) return null;
  if (canvasSize.width <= 0 || canvasSize.height <= 0) return null;
  if (imageWidth <= 0 || imageHeight <= 0) return null;
  final scale = math.min(
    canvasSize.width / imageWidth,
    canvasSize.height / imageHeight,
  );
  final renderWidth = imageWidth * scale;
  final renderHeight = imageHeight * scale;
  return Rect.fromLTWH(
    (canvasSize.width - renderWidth) / 2,
    (canvasSize.height - renderHeight) / 2,
    renderWidth,
    renderHeight,
  );
}

Offset scaleNormalizedPoint(
  Offset normalized,
  Size canvasSize,
  Rect? imageRect,
) {
  if (imageRect != null) {
    return Offset(
      normalized.dx * imageRect.width + imageRect.left,
      normalized.dy * imageRect.height + imageRect.top,
    );
  }
  return Offset(normalized.dx * canvasSize.width, normalized.dy * canvasSize.height);
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;
  final double? imageWidth;
  final double? imageHeight;

  DrawingPainter({
    required this.strokes,
    this.currentStroke,
    this.imageWidth,
    this.imageHeight,
  });

  Rect? _imageRect(Size canvasSize) {
    return imageRenderRect(canvasSize, imageWidth, imageHeight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final renderRect = _imageRect(size);
    final allStrokes = [
      ...strokes,
      if (currentStroke != null) currentStroke!,
    ];
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final stroke in allStrokes) {
      if (stroke.points.isEmpty) continue;
      if (stroke.isEraser) {
        if (stroke.shapeType != ShapeType.freehand) {
          _drawEraserShapeStroke(canvas, stroke, size, renderRect);
        } else {
          _drawEraserStroke(canvas, stroke, size, renderRect);
        }
      } else if (stroke.shapeType != ShapeType.freehand) {
        _drawShapeStroke(canvas, stroke, size, renderRect);
      } else {
        _drawTexturedStroke(canvas, stroke, size, renderRect);
      }
    }
    canvas.restore();
  }

  void _drawEraserStroke(
    Canvas canvas,
    DrawingStroke stroke,
    Size size,
    Rect? renderRect,
  ) {
    final refWidth = renderRect?.width ?? size.width;
    final paint = Paint()
      ..strokeWidth = stroke.strokeWidth * refWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.clear;
    canvas.drawPath(_buildPath(stroke.points, size, renderRect), paint);
  }

  void _drawTexturedStroke(
    Canvas canvas,
    DrawingStroke stroke,
    Size size,
    Rect? renderRect,
  ) {
    final points = stroke.points;
    final refWidth = renderRect?.width ?? size.width;
    final baseWidth = stroke.strokeWidth * refWidth;
    final o = stroke.opacity;
    final baseColor = stroke.color.withValues(alpha: o);

    final blurPaint = Paint()
      ..color = stroke.color.withValues(alpha: o * 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseWidth * 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, baseWidth * 0.3);
    canvas.drawPath(_buildPath(points, size, renderRect), blurPaint);

    final corePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseWidth * 0.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_buildPath(points, size, renderRect), corePaint);

    final dotPaint = Paint();
    double carry = 0;
    const step = 3.0;
    for (int i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final segA = scaleNormalizedPoint(a, size, renderRect);
      final segB = scaleNormalizedPoint(b, size, renderRect);
      final seg = (segB - segA).distance;
      if (seg == 0) continue;
      carry += seg;
      while (carry >= step) {
        carry -= step;
        final t = 1.0 - carry / seg;
        final x = segA.dx + (segB.dx - segA.dx) * t;
        final y = segA.dy + (segB.dy - segA.dy) * t;
        final r = baseWidth * (0.15 + (i * 7 % 11) / 22);
        dotPaint.color = stroke.color.withValues(
          alpha: o * (0.85 + (i % 5) * 0.05),
        );
        canvas.drawCircle(Offset(x, y), r, dotPaint);
      }
    }
  }

  void _drawShapeStroke(
    Canvas canvas,
    DrawingStroke stroke,
    Size size,
    Rect? renderRect,
  ) {
    if (stroke.points.length < 2) return;
    final a = scaleNormalizedPoint(stroke.points[0], size, renderRect);
    final b = scaleNormalizedPoint(stroke.points[1], size, renderRect);
    final refWidth = renderRect?.width ?? size.width;
    final sw = stroke.strokeWidth * refWidth;
    final o = stroke.opacity;
    final color = stroke.color.withValues(alpha: o);
    final paint = Paint()
      ..color = color
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (stroke.shapeType) {
      case ShapeType.rectangle:
        final rect = Rect.fromPoints(a, b);
        paint.style =
            stroke.isFilled ? PaintingStyle.fill : PaintingStyle.stroke;
        canvas.drawRect(rect, paint);
      case ShapeType.circle:
        final center = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
        final radius = (b - a).distance / 2;
        paint.style =
            stroke.isFilled ? PaintingStyle.fill : PaintingStyle.stroke;
        canvas.drawCircle(center, radius, paint);
      case ShapeType.line:
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(a, b, paint);
      case ShapeType.arrow:
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(a, b, paint);
        _drawArrowhead(canvas, a, b, sw, color);
      case ShapeType.freehand:
        break;
    }
  }

  void _drawEraserShapeStroke(
    Canvas canvas,
    DrawingStroke stroke,
    Size size,
    Rect? renderRect,
  ) {
    if (stroke.points.length < 2) return;
    final a = scaleNormalizedPoint(stroke.points[0], size, renderRect);
    final b = scaleNormalizedPoint(stroke.points[1], size, renderRect);
    final refWidth = renderRect?.width ?? size.width;
    final sw = stroke.strokeWidth * refWidth;
    final paint = Paint()
      ..strokeWidth = sw
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    switch (stroke.shapeType) {
      case ShapeType.rectangle:
        canvas.drawRect(Rect.fromPoints(a, b), paint);
      case ShapeType.circle:
        final center = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
        final radius = (b - a).distance / 2;
        canvas.drawCircle(center, radius, paint);
      case ShapeType.line:
      case ShapeType.arrow:
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(a, b, paint);
      case ShapeType.freehand:
        break;
    }
  }

  void _drawArrowhead(
    Canvas canvas,
    Offset from,
    Offset to,
    double strokeWidth,
    Color color,
  ) {
    final direction = to - from;
    final length = direction.distance;
    if (length == 0) return;
    final unit = direction / length;
    final normal = Offset(-unit.dy, unit.dx);
    final headSize = strokeWidth * 3.5;
    const angle = 0.45;
    final left = to -
        unit * headSize * math.cos(angle) +
        normal * headSize * math.sin(angle);
    final right = to -
        unit * headSize * math.cos(angle) -
        normal * headSize * math.sin(angle);
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = color..style = PaintingStyle.fill,
    );
  }

  Path _buildPath(
    List<Offset> points,
    Size size,
    Rect? renderRect,
  ) {
    final path = Path();
    final first = scaleNormalizedPoint(points.first, size, renderRect);
    path.moveTo(first.dx, first.dy);
    for (int i = 1; i < points.length; i++) {
      final pt = scaleNormalizedPoint(points[i], size, renderRect);
      path.lineTo(pt.dx, pt.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.currentStroke != currentStroke ||
      oldDelegate.imageWidth != imageWidth ||
      oldDelegate.imageHeight != imageHeight;
}
