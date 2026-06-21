import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/drawing_provider.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/entities/drawing_state.dart';
import 'drawing_painter.dart';

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

    final currentImage = presentationState.currentImage;
    final imageWidth = currentImage?.width?.toDouble();
    final imageHeight = currentImage?.height?.toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;
        final canvasValid = canvasWidth > 0 && canvasHeight > 0;

        final canvasSize = Size(canvasWidth, canvasHeight);
        final imageRect = imageRenderRect(
          canvasSize,
          imageWidth,
          imageHeight,
        );

        Offset normalizePoint(Offset raw) {
          if (imageRect != null) {
            return Offset(
              (raw.dx - imageRect.left) / imageRect.width,
              (raw.dy - imageRect.top) / imageRect.height,
            );
          }
          return Offset(raw.dx / canvasWidth, raw.dy / canvasHeight);
        }

        double normalizeWidth(double raw) {
          final refWidth = imageRect?.width ?? canvasWidth;
          return raw / refWidth;
        }

        return GestureDetector(
          onPanStart: (details) {
            if (!canvasValid) return;
            final np = normalizePoint(details.localPosition);
            final isShape = drawingState.currentShapeType != ShapeType.freehand;
            _currentStroke = DrawingStroke(
              points: [np],
              color: drawingState.currentColor,
              strokeWidth: normalizeWidth(drawingState.currentStrokeWidth),
              opacity: drawingState.currentOpacity,
              isEraser: drawingState.eraserMode,
              shapeType: isShape ? drawingState.currentShapeType : ShapeType.freehand,
              isFilled: isShape && drawingState.shapeFillMode,
            );
          },
          onPanUpdate: (details) {
            if (_currentStroke == null || !canvasValid) return;
            final np = normalizePoint(details.localPosition);
            setState(() {
              if (_currentStroke!.shapeType != ShapeType.freehand) {
                _currentStroke = _currentStroke!.copyWith(
                  points: [_currentStroke!.points.first, np],
                );
              } else {
                _currentStroke = _currentStroke!.copyWith(
                  points: [..._currentStroke!.points, np],
                );
              }
            });
          },
          onPanEnd: (details) {
            if (_currentStroke == null) return;
            if (_currentStroke!.shapeType != ShapeType.freehand &&
                _currentStroke!.points.length < 2) {
              setState(() => _currentStroke = null);
              return;
            }
            drawingNotifier.addStroke(imageId, _currentStroke!);
            setState(() => _currentStroke = null);
          },
          child: RepaintBoundary(
            child: CustomPaint(
              painter: DrawingPainter(
                strokes: strokes,
                currentStroke: _currentStroke,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}
