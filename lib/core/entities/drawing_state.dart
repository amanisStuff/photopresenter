import 'package:flutter/material.dart';

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final double opacity;
  final bool isEraser;

  const DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.opacity = 0.55,
    this.isEraser = false,
  });

  DrawingStroke copyWith({List<Offset>? points}) {
    return DrawingStroke(
      points: points ?? this.points,
      color: color,
      strokeWidth: strokeWidth,
      opacity: opacity,
      isEraser: isEraser,
    );
  }
}

class DrawingState {
  final Map<String, List<DrawingStroke>> imageDrawings;
  final List<DrawingStroke> tempStrokes;
  final Color currentColor;
  final double currentStrokeWidth;
  final double currentOpacity;
  final bool eraserMode;
  final bool drawingEnabled;

  const DrawingState({
    this.imageDrawings = const {},
    this.tempStrokes = const [],
    this.currentColor = Colors.red,
    this.currentStrokeWidth = 4.0,
    this.currentOpacity = 0.55,
    this.eraserMode = false,
    this.drawingEnabled = false,
  });

  DrawingState copyWith({
    Map<String, List<DrawingStroke>>? imageDrawings,
    List<DrawingStroke>? tempStrokes,
    Color? currentColor,
    double? currentStrokeWidth,
    double? currentOpacity,
    bool? eraserMode,
    bool? drawingEnabled,
  }) {
    return DrawingState(
      imageDrawings: imageDrawings ?? this.imageDrawings,
      tempStrokes: tempStrokes ?? this.tempStrokes,
      currentColor: currentColor ?? this.currentColor,
      currentStrokeWidth: currentStrokeWidth ?? this.currentStrokeWidth,
      currentOpacity: currentOpacity ?? this.currentOpacity,
      eraserMode: eraserMode ?? this.eraserMode,
      drawingEnabled: drawingEnabled ?? this.drawingEnabled,
    );
  }

  List<DrawingStroke> strokesFor(String imageId) {
    if (imageId == '_3d_') return tempStrokes;
    return imageDrawings[imageId] ?? [];
  }
}
