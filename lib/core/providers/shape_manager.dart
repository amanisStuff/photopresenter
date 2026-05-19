import 'dart:math' as math;
import 'package:flutter_cube/flutter_cube.dart';
import '../entities/shape_object.dart';

abstract class ShapeManager {
  final List<ShapeObject> _shapeObjects = [];

  Scene? scene;
  bool gravityMode = false;
  bool sizeLocked = false;
  double uniformScale = 1.0;

  String get objectPath;
  bool get lighting => true;
  bool get originIsCenter;
  double get scaleMultiplier => 1.0;
  double get modelHalfWidth;
  double get modelHalfHeight;

  static const double viewLimit = 5.0;
  static const double floorLevel = -3.0;

  int get length => _shapeObjects.length;
  bool get isEmpty => _shapeObjects.isEmpty;

  void animate() {
    for (final shapeObject in _shapeObjects) {
      final obj = shapeObject.object;
      final tPos = shapeObject.targetPosition;
      final tRot = shapeObject.targetRotation;
      final tScale = shapeObject.targetScale;

      obj.position.x += (tPos.x - obj.position.x) * 0.06;
      if (gravityMode) {
        obj.position.y = gravityY(tScale.x);
      } else {
        obj.position.y += (tPos.y - obj.position.y) * 0.06;
      }
      obj.position.z += (tPos.z - obj.position.z) * 0.06;

      obj.rotation.x += (tRot.x - obj.rotation.x) * 0.06;
      obj.rotation.y += (tRot.y - obj.rotation.y) * 0.06;
      obj.rotation.z += (tRot.z - obj.rotation.z) * 0.06;

      obj.scale.x += (tScale.x - obj.scale.x) * 0.06;
      obj.scale.y += (tScale.y - obj.scale.y) * 0.06;
      obj.scale.z += (tScale.z - obj.scale.z) * 0.06;

      obj.updateTransform();
    }
  }

  void setNewTargets() {
    final random = math.Random();
    final double? lockedScale = sizeLocked ? uniformScale : null;

    for (int i = 0; i < _shapeObjects.length; i++) {
      final double s = math.min(
        (lockedScale ?? (random.nextDouble() * 2.0) + 0.5) * scaleMultiplier,
        viewLimit / modelHalfWidth,
      );

      final double radius = s * modelHalfWidth;
      final double height = s * modelHalfHeight;
      final double range = positionRange;
      Vector3 pos;
      if (gravityMode) {
        pos = Vector3(
          clampComponent((random.nextDouble() * range * 2) - range, radius),
          gravityY(s),
          clampComponent((random.nextDouble() * range * 2) - range, radius),
        );
      } else {
        int attempts = 0;
        do {
          pos = Vector3(
            clampComponent((random.nextDouble() * range * 2) - range, radius),
            clampComponent(
              (random.nextDouble() * range * 2) - range,
              height,
              isY: true,
            ),
            clampComponent((random.nextDouble() * range * 2) - range, radius),
          );
          attempts++;
        } while (attempts < 80 && intersectsAny(pos, i, s));
      }

      _shapeObjects[i].targetPosition = pos;
      _shapeObjects[i].targetRotation = gravityMode
          ? Vector3(0, random.nextDouble() * 360, 0)
          : Vector3(
              random.nextDouble() * 360,
              random.nextDouble() * 360,
              random.nextDouble() * 360,
            );
      _shapeObjects[i].targetScale = Vector3(s, s, s);
    }
  }

  void clear() {
    if (scene == null) return;
    for (final shapeObject in _shapeObjects) {
      scene!.world.remove(shapeObject.object);
    }
    _shapeObjects.clear();
  }

  void generate({required int count}) {
    if (scene == null) return;
    clear();

    final random = math.Random();
    final double? uniform = sizeLocked && count >= 1 ? uniformScale : null;
    int attempts = 0;

    while (_shapeObjects.length < count && attempts < 200) {
      attempts++;

      final double s = math.min(
        (uniform ?? (random.nextDouble() * 2.0) + 0.5) * scaleMultiplier,
        viewLimit / modelHalfWidth,
      );
      final double radius = s * modelHalfWidth;
      final double height = s * modelHalfHeight;

      final double range = positionRange;
      final Vector3 pos;
      if (count == 1) {
        pos = Vector3(0, gravityMode ? gravityY(s) : 1, 0);
      } else {
        pos = Vector3(
          clampComponent((random.nextDouble() * range * 2) - range, radius),
          gravityMode
              ? gravityY(s)
              : clampComponent(
                  (random.nextDouble() * range * 2) - range,
                  height,
                  isY: true,
                ),
          clampComponent((random.nextDouble() * range * 2) - range, radius),
        );
      }

      bool intersects = false;
      final double newRadius = s * modelHalfWidth;
      for (final existing in _shapeObjects) {
        final double existingRadius = existing.targetScale.x * modelHalfWidth;
        final double minDist = (newRadius + existingRadius) * 1.1;
        if (pos.distanceTo(existing.targetPosition) < minDist) {
          intersects = true;
          break;
        }
      }
      if (intersects) continue;

      final rot = gravityMode
          ? Vector3(0, random.nextDouble() * 360, 0)
          : Vector3(
              random.nextDouble() * 360,
              random.nextDouble() * 360,
              random.nextDouble() * 360,
            );
      final scale = Vector3(s, s, s);

      final object = Object(
        fileName: objectPath,
        lighting: lighting,
        position: pos,
        rotation: rot,
        scale: scale,
      );

      _shapeObjects.add(
        ShapeObject(object: object, position: pos, rotation: rot, scale: scale),
      );
      scene!.world.add(object);
    }
  }

  void applySize(double scale) {
    for (final shapeObject in _shapeObjects) {
      shapeObject.targetScale = Vector3(
        scale * scaleMultiplier,
        scale * scaleMultiplier,
        scale * scaleMultiplier,
      );
    }
    resolveIntersections();
  }

  void resolveIntersections() {
    final random = math.Random();
    final double range = positionRange;
    for (int iter = 0; iter < 100; iter++) {
      bool anyIntersection = false;
      for (int i = 0; i < _shapeObjects.length; i++) {
        for (int j = i + 1; j < _shapeObjects.length; j++) {
          final halfI = _shapeObjects[i].targetScale.x * modelHalfWidth;
          final halfJ = _shapeObjects[j].targetScale.x * modelHalfWidth;
          final minDist = (halfI + halfJ) * 1.1;
          if (_shapeObjects[i].targetPosition.distanceTo(
                _shapeObjects[j].targetPosition,
              ) <
              minDist) {
            anyIntersection = true;
            _shapeObjects[j].targetPosition = Vector3(
              clampComponent((random.nextDouble() * range * 2) - range, halfJ),
              clampComponent(
                (random.nextDouble() * range * 2) - range,
                halfJ,
                isY: true,
              ),
              clampComponent((random.nextDouble() * range * 2) - range, halfJ),
            );
          }
        }
      }
      if (!anyIntersection) break;
    }
  }

  bool intersectsAny(Vector3 pos, int upTo, double newScale) {
    final double newRadius = newScale * modelHalfWidth;
    for (int j = 0; j < upTo; j++) {
      final double existingRadius =
          _shapeObjects[j].targetScale.x * modelHalfWidth;
      final double minDist = (newRadius + existingRadius) * 1.1;
      if (pos.distanceTo(_shapeObjects[j].targetPosition) < minDist) {
        return true;
      }
    }
    return false;
  }

  double clampComponent(double value, double halfSize, {bool isY = false}) {
    if (isY) {
      final double yMin = floorLevel + halfSize;
      final double yMax = viewLimit - halfSize;
      return value.clamp(math.min(yMin, yMax), math.max(yMin, yMax));
    }
    final double bound = viewLimit - halfSize;
    return value.clamp(-bound, bound);
  }

  double get positionRange {
    if (_shapeObjects.isEmpty) return 5.0;
    final double maxScale = _shapeObjects
        .map((c) => c.targetScale.x)
        .reduce(math.max);
    return math.max(5.0, _shapeObjects.length * maxScale * modelHalfWidth);
  }

  double gravityY(double scale) =>
      originIsCenter ? floorLevel + scale * modelHalfHeight : floorLevel;

  static ShapeManager fromPath(String path) {
    return switch (path) {
      'assets/cube/cube.obj' => CubeShapeManager(),
      'assets/sphere/sphere.obj' => SphereShapeManager(),
      'assets/cone/cone.obj' => ConeShapeManager(),
      'assets/cylinder/cylinder.obj' => CylinderShapeManager(),
      'assets/pyramid/pyramid.obj' => PyramidShapeManager(),
      'assets/Torus/Torus.obj' => TorusShapeManager(),
      _ => CubeShapeManager(),
    };
  }
}

class CubeShapeManager extends ShapeManager {
  @override
  String get objectPath => 'assets/cube/cube.obj';
  @override
  bool get originIsCenter => true;
  @override
  double get modelHalfWidth => 1.0;
  @override
  double get modelHalfHeight => 1.0;
}

class SphereShapeManager extends ShapeManager {
  @override
  String get objectPath => 'assets/sphere/sphere.obj';
  @override
  bool get originIsCenter => true;
  @override
  double get modelHalfWidth => 1.0;
  @override
  double get modelHalfHeight => 1.0;
}

class ConeShapeManager extends ShapeManager {
  @override
  String get objectPath => 'assets/cone/cone.obj';
  @override
  bool get originIsCenter => false;
  @override
  double get scaleMultiplier => 3.0;
  @override
  double get modelHalfWidth => 0.953;
  @override
  double get modelHalfHeight => 2.0;
}

class CylinderShapeManager extends ShapeManager {
  @override
  String get objectPath => 'assets/cylinder/cylinder.obj';
  @override
  bool get originIsCenter => false;
  @override
  double get scaleMultiplier => 2.0;
  @override
  double get modelHalfWidth => 1.0;
  @override
  double get modelHalfHeight => 2.0;
}

class PyramidShapeManager extends ShapeManager {
  @override
  String get objectPath => 'assets/pyramid/pyramid.obj';
  @override
  bool get originIsCenter => false;
  @override
  double get scaleMultiplier => 3.0;
  @override
  double get modelHalfWidth => 0.983;
  @override
  double get modelHalfHeight => 1.96;
}

class TorusShapeManager extends ShapeManager {
  @override
  String get objectPath => 'assets/Torus/Torus.obj';
  @override
  bool get originIsCenter => false;
  @override
  double get modelHalfWidth => 1.25;
  @override
  double get modelHalfHeight => 0.5;
}
