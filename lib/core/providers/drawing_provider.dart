import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/drawing_state.dart';

class DrawingNotifier extends Notifier<DrawingState> {
  @override
  DrawingState build() => const DrawingState();

  void toggleDrawing() {
    state = state.copyWith(drawingEnabled: !state.drawingEnabled);
  }

  void setColor(Color color) {
    state = state.copyWith(currentColor: color, eraserMode: false);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(currentStrokeWidth: width);
  }

  void setOpacity(double opacity) {
    state = state.copyWith(currentOpacity: opacity);
  }

  void toggleEraser() {
    state = state.copyWith(eraserMode: !state.eraserMode);
  }

  void addStroke(String imageId, DrawingStroke stroke) {
    if (imageId == '_3d_') {
      state = state.copyWith(
        tempStrokes: [...state.tempStrokes, stroke],
      );
    } else {
      final existing = List<DrawingStroke>.from(
        state.imageDrawings[imageId] ?? [],
      );
      existing.add(stroke);
      state = state.copyWith(
        imageDrawings: {...state.imageDrawings, imageId: existing},
      );
    }
  }

  void undoLastStroke(String imageId) {
    if (imageId == '_3d_') {
      if (state.tempStrokes.isEmpty) return;
      state = state.copyWith(
        tempStrokes: state.tempStrokes.sublist(
          0,
          state.tempStrokes.length - 1,
        ),
      );
    } else {
      final existing = state.imageDrawings[imageId] ?? [];
      if (existing.isEmpty) return;
      state = state.copyWith(
        imageDrawings: {
          ...state.imageDrawings,
          imageId: existing.sublist(0, existing.length - 1),
        },
      );
    }
  }

  void clearImageDrawings(String imageId) {
    if (imageId == '_3d_') {
      state = state.copyWith(tempStrokes: []);
    } else {
      state = state.copyWith(
        imageDrawings: {...state.imageDrawings, imageId: []},
      );
    }
  }

  void clearAllDrawings() {
    state = state.copyWith(
      imageDrawings: {},
      tempStrokes: [],
    );
  }

  bool hasAnyDrawing() =>
      state.imageDrawings.values.any((s) => s.isNotEmpty) ||
      state.tempStrokes.isNotEmpty;
}

final drawingProvider = NotifierProvider<DrawingNotifier, DrawingState>(() {
  return DrawingNotifier();
});
