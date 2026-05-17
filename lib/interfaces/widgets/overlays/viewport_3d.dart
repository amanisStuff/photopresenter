import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';

class Viewport3D extends ConsumerStatefulWidget {
  const Viewport3D({super.key});

  @override
  ConsumerState<Viewport3D> createState() => _Viewport3DState();
}

class _Viewport3DState extends ConsumerState<Viewport3D>
    with SingleTickerProviderStateMixin {
  Scene? _scene;
  Object? _floor;
  bool lightLocked = false;
  bool _floorAdded = false;
  bool sizeLocked = false;
  bool _showSizePanel = false;
  double _uniformScale = 1.0;
  late final AnimationController _controller;

  final List<Object> _cubes = [];
  final List<Vector3> _targetPositions = [];
  final List<Vector3> _targetRotations = [];
  final List<Vector3> _targetScales = [];

  int _lastTrigger = -1;
  bool _lastScatter = false;
  bool _initialized = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this)
      ..addListener(_onTick)
      ..repeat(period: const Duration(milliseconds: 16));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTick() {
    if (_scene == null || _cubes.isEmpty) return;

    for (int i = 0; i < _cubes.length; i++) {
      final cube = _cubes[i];
      final tPos = _targetPositions[i];
      final tRot = _targetRotations[i];
      final tScale = _targetScales[i];

      cube.position.x += (tPos.x - cube.position.x) * 0.06;
      cube.position.y += (tPos.y - cube.position.y) * 0.06;
      cube.position.z += (tPos.z - cube.position.z) * 0.06;

      cube.rotation.x += (tRot.x - cube.rotation.x) * 0.06;
      cube.rotation.y += (tRot.y - cube.rotation.y) * 0.06;
      cube.rotation.z += (tRot.z - cube.rotation.z) * 0.06;

      cube.scale.x += (tScale.x - cube.scale.x) * 0.06;
      cube.scale.y += (tScale.y - cube.scale.y) * 0.06;
      cube.scale.z += (tScale.z - cube.scale.z) * 0.06;

      cube.updateTransform();
    }

    if (!lightLocked && _scene != null) {
      _scene!.light.position.setFrom(_scene!.camera.position);
    }
  }

  void _setNewTargets() {
    final random = math.Random();
    final double? lockedScale = sizeLocked && _cubes.length > 1 ? _uniformScale : null;
    for (int i = 0; i < _cubes.length; i++) {
      final s = lockedScale ?? (random.nextDouble() * 2.0) + 0.5;

      final double half = s * 0.5;
      final double range = _positionRange;
      Vector3 pos;
      int attempts = 0;
      do {
        pos = Vector3(
          _clampComponent((random.nextDouble() * range * 2) - range, half),
          _clampComponent((random.nextDouble() * range * 2) - range, half, isY: true),
          _clampComponent((random.nextDouble() * range * 2) - range, half),
        );
        attempts++;
      } while (attempts < 80 && _intersectsAny(pos, i, s));

      _targetPositions[i] = pos;
      _targetRotations[i] = Vector3(
        random.nextDouble() * 360,
        random.nextDouble() * 360,
        random.nextDouble() * 360,
      );
      _targetScales[i] = Vector3(s, s, s);
    }
  }

  static const double _viewLimit = 5.0;
  static const double _floorLevel = -2.5;

  double _clampComponent(double value, double halfSize, {bool isY = false}) {
    final double bound = _viewLimit - halfSize;
    final clamped = value.clamp(-bound, bound);
    if (isY) return clamped.clamp(_floorLevel + halfSize, bound);
    return clamped;
  }

  double get _positionRange {
    if (_targetScales.isEmpty) return 5.0;
    final double maxScale = _targetScales.map((s) => s.x).reduce(math.max);
    return math.max(5.0, _cubes.length * maxScale * 0.5);
  }

  bool _intersectsAny(Vector3 pos, int upTo, double newScale) {
    final newHalf = newScale * 0.5;
    for (int j = 0; j < upTo; j++) {
      final existingHalf = _targetScales[j].x * 0.5;
      final minDist = (newHalf + existingHalf) * 1.3;
      if (pos.distanceTo(_targetPositions[j]) < minDist) return true;
    }
    return false;
  }

  void _clearCubes() {
    if (_scene == null) return;
    for (final cube in _cubes) {
      _scene!.world.remove(cube);
    }
    _cubes.clear();
    _targetPositions.clear();
    _targetRotations.clear();
    _targetScales.clear();
  }

  void _generateCubes({required int count}) {
    if (_scene == null) return;
    _clearCubes();

    final random = math.Random();
    final double? uniformScale = sizeLocked && count > 1 ? _uniformScale : null;
    int attempts = 0;

    while (_cubes.length < count && attempts < 200) {
      attempts++;

      final s = uniformScale ?? (random.nextDouble() * 2.0) + 0.5;
      final halfSize = s * 0.5;

      final double half = s * 0.5;
      final double range = _positionRange;
      final Vector3 pos;
      if (count == 1) {
        pos = Vector3(0, 1, 0);
      } else {
        pos = Vector3(
          _clampComponent((random.nextDouble() * range * 2) - range, half),
          _clampComponent((random.nextDouble() * range * 2) - range, half, isY: true),
          _clampComponent((random.nextDouble() * range * 2) - range, half),
        );
      }

      bool intersects = false;
      for (int j = 0; j < _cubes.length; j++) {
        final existingScale = _targetScales[j].x;
        final minDist = (halfSize + existingScale * 0.5) * 1.3;
        if (pos.distanceTo(_targetPositions[j]) < minDist) {
          intersects = true;
          break;
        }
      }
      if (intersects) continue;

      final rot = Vector3(
        random.nextDouble() * 360,
        random.nextDouble() * 360,
        random.nextDouble() * 360,
      );
      final scale = Vector3(s, s, s);

      final cube = Object(
        fileName: "assets/cube/cube.obj",
        lighting: true,
        position: pos,
        rotation: rot,
        scale: scale,
      );

      _cubes.add(cube);
      _targetPositions.add(pos);
      _targetRotations.add(rot);
      _targetScales.add(scale);
      _scene!.world.add(cube);
    }
  }

  void _applySizeToCubes(double scale) {
    _uniformScale = scale;
    if (_cubes.length <= 1) return;

    for (int i = 0; i < _cubes.length; i++) {
      final s = Vector3(scale, scale, scale);
      _targetScales[i] = s;
    }
    _resolveIntersections();
  }

  void _resolveIntersections() {
    final random = math.Random();
    final double range = _positionRange;
    for (int iter = 0; iter < 100; iter++) {
      bool anyIntersection = false;
      for (int i = 0; i < _cubes.length; i++) {
        for (int j = i + 1; j < _cubes.length; j++) {
          final halfI = _targetScales[i].x * 0.5;
          final halfJ = _targetScales[j].x * 0.5;
          final minDist = (halfI + halfJ) * 1.3;
          if (_targetPositions[i].distanceTo(_targetPositions[j]) < minDist) {
            anyIntersection = true;
            _targetPositions[j] = Vector3(
              _clampComponent((random.nextDouble() * range * 2) - range, halfJ),
              _clampComponent((random.nextDouble() * range * 2) - range, halfJ, isY: true),
              _clampComponent((random.nextDouble() * range * 2) - range, halfJ),
            );
          }
        }
      }
      if (!anyIntersection) break;
    }
  }

  Widget _buildSizePanel() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Lock Size', style: TextStyle(fontSize: 12)),
                  const Spacer(),
                  SizedBox(
                    height: 24,
                    child: Switch(
                      value: sizeLocked,
                      onChanged: (val) {
                        setState(() {
                          sizeLocked = val;
                          if (val && _cubes.length > 1) {
                            _applySizeToCubes(_uniformScale);
                          } else if (!val && _cubes.length > 1) {
                            _setNewTargets();
                          }
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              if (sizeLocked) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Scale', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: _uniformScale,
                        min: 1.0,
                        max: 3.0,
                        divisions: 20,
                        label: _uniformScale.toStringAsFixed(1),
                        onChanged: (val) {
                          setState(() {
                            _uniformScale = val;
                            if (_cubes.length > 1) {
                              _applySizeToCubes(val);
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        _uniformScale.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(presentationProvider);
    final settings = ref.watch(settingsProvider);

    final isPaused = state.isPaused;
    final isScatter = settings.scatterMode;
    final trigger = state.viewportTrigger;

    if (_initialized) {
      if (_lastScatter != isScatter) {
        final count = isScatter ? (2 + math.Random().nextInt(9)) : 1;
        _generateCubes(count: count);
        _lastScatter = isScatter;
      } else if (_lastTrigger != trigger) {
        if (isScatter) {
          final count = 2 + math.Random().nextInt(9);
          _generateCubes(count: count);
        } else {
          _setNewTargets();
        }
      }
    }
    _lastTrigger = trigger;

    Widget cubeWidget = Cube(
      onSceneCreated: (Scene scene) {
        _scene = scene;
        scene.light.position.setFrom(scene.camera.position);

        if (!_floorAdded) {
          _floor = Object(
            fileName: "assets/floor/floor.obj",
            lighting: false,
            backfaceCulling: false,
            position: Vector3(0, -3, 0),
            scale: Vector3(10, 1, 10),
          );
          scene.world.add(_floor!);
          _floorAdded = true;
        }
        final count = isScatter ? (2 + math.Random().nextInt(9)) : 1;
        _generateCubes(count: count);
        _lastScatter = isScatter;
        _initialized = true;
      },
    );

    if (isPaused) {
      cubeWidget = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: cubeWidget,
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTapDown: (_) {
            if (_showSizePanel) setState(() => _showSizePanel = false);
          },
          child: cubeWidget,
        ),
        Positioned(
          bottom: 84,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_showSizePanel) ...[
                _buildSizePanel(),
                const SizedBox(height: 8),
              ],
              FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    lightLocked = !lightLocked;
                  });
                },
                child: Icon(
                  Icons.lightbulb_outline,
                  color: lightLocked ? Colors.amber : null,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                onPressed: () {
                  setState(() => _showSizePanel = !_showSizePanel);
                },
                child: Icon(
                  Icons.aspect_ratio,
                  color: sizeLocked ? Colors.cyanAccent : null,
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
