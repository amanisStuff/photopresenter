import 'dart:ffi';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/theme.dart';
import '../../../shared/theme/theme_notifier.dart';

class Viewport3D extends ConsumerStatefulWidget {
  const Viewport3D({super.key});

  @override
  ConsumerState<Viewport3D> createState() => _Viewport3DState();
}

class _Viewport3DState extends ConsumerState<Viewport3D>
    with SingleTickerProviderStateMixin {
  Scene? _scene;
  bool lightLocked = false;
  late final AnimationController _lightSync;
  @override
  void initState() {
    // TODO: implement initState
    _lightSync = AnimationController(vsync: this)
      ..addListener(() {
        if (_scene != null && !lightLocked) {
          _scene!.light.position.setFrom(_scene!.camera.position);
        }
      })
      ..repeat(period: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Cube(
          onSceneCreated: (Scene scene) {
            _scene = scene;
            scene.light.position.setFrom(scene.camera.position);
            // var cubes = _generateNonIntersectingCubes();
            _generateNonIntersectingCubes(scene: scene);
          },
        ),
        Positioned(
          bottom: 84,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    lightLocked = !lightLocked;
                  });
                },
                child: Icon(
                  // Icons.lock_open
                  Icons.lightbulb_outline,
                  color: lightLocked ? Colors.amber : null,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                onPressed: () {},
                child: const Icon(Icons.code),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//  non intersecting cubes take scene as peramter
List<Object> _generateNonIntersectingCubes({
  required Scene scene,
  int count = 5,
  double minDistance = 2.5,
}) {
  final List<Object> cubes = [];
  final math.Random random = math.Random();

  while (cubes.length < count) {
    final Vector3 position = Vector3(
      (random.nextDouble() * 10) - 5,
      (random.nextDouble() * 10) - 5,
      (random.nextDouble() * 10) - 5,
    );

    bool isIntersecting = false;
    for (final existingCube in cubes) {
      if (position.distanceTo(existingCube.position) < minDistance) {
        isIntersecting = true;
        break;
      }
    }

    if (!isIntersecting) {
      final cube = _generateRandomCube(position: position);
      cubes.add(cube);
      scene.world.add(cube);
    }
  }

  return cubes;
}

Object _generateRandomCube({
  Vector3? position,
  Vector3? rotation,
  double? scale,
}) {
  final random = math.Random();

  // Randomize position within a visible range (approx -3 to 3 for standard viewport)
  final pos =
      position ??
      Vector3(
        (random.nextDouble() * 6) - 3,
        (random.nextDouble() * 6) - 3,
        (random.nextDouble() * 6) - 3,
      );

  // Randomize rotation (0 to 360 degrees in radians)
  final rot =
      rotation ??
      Vector3(
        random.nextDouble() * 360,
        random.nextDouble() * 360,
        random.nextDouble() * 360,
      );

  // Randomize scale (keeping it uniform to remain a cube)
  final double s = (random.nextDouble() * 2.0) + 0.5;
  final sca = scale != null ? Vector3(scale, scale, scale) : Vector3(s, s, s);

  return Object(
    fileName: "assets/cube/cube.obj",
    lighting: true,
    position: pos,
    rotation: rot,
    scale: sca,
  );
}
