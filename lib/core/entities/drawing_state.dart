import 'package:flutter/material.dart';

enum ShapeType { freehand, rectangle, circle, line, arrow }

class DrawingStroke {
  final List<Offset> points;
  final List<double>? pressures;
  final Color color;
  final double strokeWidth;
  final double opacity;
  final bool isEraser;
  final ShapeType shapeType;
  final bool isFilled;

  const DrawingStroke({
    required this.points,
    this.pressures,
    required this.color,
    required this.strokeWidth,
    this.opacity = 0.55,
    this.isEraser = false,
    this.shapeType = ShapeType.freehand,
    this.isFilled = false,
  });

  DrawingStroke copyWith({
    List<Offset>? points,
    List<double>? pressures,
    ShapeType? shapeType,
    bool? isFilled,
  }) {
    return DrawingStroke(
      points: points ?? this.points,
      pressures: pressures ?? this.pressures,
      color: color,
      strokeWidth: strokeWidth,
      opacity: opacity,
      isEraser: isEraser,
      shapeType: shapeType ?? this.shapeType,
      isFilled: isFilled ?? this.isFilled,
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
  final ShapeType currentShapeType;
  final bool shapeFillMode;

  const DrawingState({
    this.imageDrawings = const {},
    this.tempStrokes = const [],
    this.currentColor = Colors.red,
    this.currentStrokeWidth = 4.0,
    this.currentOpacity = 0.55,
    this.eraserMode = false,
    this.drawingEnabled = false,
    this.currentShapeType = ShapeType.freehand,
    this.shapeFillMode = false,
  });

  DrawingState copyWith({
    Map<String, List<DrawingStroke>>? imageDrawings,
    List<DrawingStroke>? tempStrokes,
    Color? currentColor,
    double? currentStrokeWidth,
    double? currentOpacity,
    bool? eraserMode,
    bool? drawingEnabled,
    ShapeType? currentShapeType,
    bool? shapeFillMode,
  }) {
    return DrawingState(
      imageDrawings: imageDrawings ?? this.imageDrawings,
      tempStrokes: tempStrokes ?? this.tempStrokes,
      currentColor: currentColor ?? this.currentColor,
      currentStrokeWidth: currentStrokeWidth ?? this.currentStrokeWidth,
      currentOpacity: currentOpacity ?? this.currentOpacity,
      eraserMode: eraserMode ?? this.eraserMode,
      drawingEnabled: drawingEnabled ?? this.drawingEnabled,
      currentShapeType: currentShapeType ?? this.currentShapeType,
      shapeFillMode: shapeFillMode ?? this.shapeFillMode,
    );
  }

  List<DrawingStroke> strokesFor(String imageId) {
    if (imageId == '_3d_') return tempStrokes;
    return imageDrawings[imageId] ?? [];
  }
}
