import 'package:flutter_cube/flutter_cube.dart';

class ShapeObject {
  final Object object;
  Vector3 targetPosition;
  Vector3 targetRotation;
  Vector3 targetScale;

  ShapeObject({
    required this.object,
    required Vector3 position,
    required Vector3 rotation,
    required Vector3 scale,
  })  : targetPosition = position,
        targetRotation = rotation,
        targetScale = scale;
}
