import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/viewport_controls_provider.dart';
import '../../../core/strategies/image_filter_decorator.dart';

class Viewport3D extends ConsumerStatefulWidget {
  const Viewport3D({super.key});

  @override
  ConsumerState<Viewport3D> createState() => _Viewport3DState();
}

class _Viewport3DState extends ConsumerState<Viewport3D>
    with SingleTickerProviderStateMixin {
  Scene? _scene;
  Object? _floor;
  Object? _lightIndicator;
  bool _gravityMode = false;
  bool _sizeLocked = false;
  double _uniformScale = 1.0;
  bool _lightHorizontalLocked = false;
  bool _lightVerticalLocked = false;
  bool _lightDistanceLocked = false;
  double _lightHorizontalAngle = 0.0;
  double _lightVerticalAngle = 0.0;
  double _lightDistance = 5.0;
  double _cameraHorizontalAngle = 0.0;
  double _cameraVerticalAngle = 30.0;
  double _cameraDistance = 15.0;
  double _cameraPanX = 0.0;
  double _cameraPanY = 0.0;
  double _cameraPanZ = 0.0;
  bool _floorAdded = false;
  late final AnimationController _controller;

  final List<Object> _cubes = [];
  final List<Vector3> _targetPositions = [];
  final List<Vector3> _targetRotations = [];
  final List<Vector3> _targetScales = [];

  final GlobalKey _cubeKey = GlobalKey();
  Offset _lastFocalPoint = Offset.zero;
  bool _isPanning = false;
  Offset _lastPanPoint = Offset.zero;

  int _lastTrigger = -1;
  bool _lastScatter = false;
  bool _lastGravity = false;
  bool _lastSizeLocked = false;
  double _lastUniformScale = 1.0;
  double _unlockedHorizontalAngle = 0.0;
  double _unlockedVerticalAngle = 0.0;
  double _unlockedDistance = 5.0;
  bool _initialized = false;
  bool _lastLightHorizontalLocked = false;
  bool _lastLightVerticalLocked = false;
  bool _lastLightDistanceLocked = false;

  @override
  void initState() {
    _randomizeUnlockedPosition();
    _controller = AnimationController(vsync: this)
      ..addListener(_onTick)
      ..repeat(period: const Duration(milliseconds: 16));
    super.initState();
  }

  void _randomizeUnlockedPosition() {
    final random = math.Random();
    _unlockedHorizontalAngle = random.nextDouble() * 360;
    _unlockedVerticalAngle = random.nextDouble() * 360;
    _unlockedDistance = 1 + random.nextDouble() * 19;
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
      if (_gravityMode) {
        cube.position.y = _floorLevel + tScale.x * 0.5;
      } else {
        cube.position.y += (tPos.y - cube.position.y) * 0.06;
      }
      cube.position.z += (tPos.z - cube.position.z) * 0.06;

      cube.rotation.x += (tRot.x - cube.rotation.x) * 0.06;
      cube.rotation.y += (tRot.y - cube.rotation.y) * 0.06;
      cube.rotation.z += (tRot.z - cube.rotation.z) * 0.06;

      cube.scale.x += (tScale.x - cube.scale.x) * 0.06;
      cube.scale.y += (tScale.y - cube.scale.y) * 0.06;
      cube.scale.z += (tScale.z - cube.scale.z) * 0.06;

      cube.updateTransform();
    }

    if (_scene == null) return;

    final theta = (_lightHorizontalLocked
            ? _lightHorizontalAngle
            : _unlockedHorizontalAngle) *
        math.pi / 180;
    final phi = (_lightVerticalLocked
            ? _lightVerticalAngle
            : _unlockedVerticalAngle) *
        math.pi / 180;
    final dist = _lightDistanceLocked ? _lightDistance : _unlockedDistance;

    _scene!.light.position.setValues(
      dist * math.sin(phi) * math.sin(theta),
      dist * math.cos(phi) + _floorLevel,
      dist * math.sin(phi) * math.cos(theta),
    );

    if (_lightIndicator != null) {
      _lightIndicator!.position.setFrom(_scene!.light.position);
      _lightIndicator!.updateTransform();
    }

    final elev = _cameraVerticalAngle * math.pi / 180;
    final azim = _cameraHorizontalAngle * math.pi / 180;
    final panX = _cameraPanX;
    final panY = _cameraPanY;
    final panZ = _cameraPanZ;

    _scene!.camera.position.setValues(
      panX + _cameraDistance * math.cos(elev) * math.sin(azim),
      _cameraDistance * math.sin(elev) + _floorLevel + panY,
      panZ + _cameraDistance * math.cos(elev) * math.cos(azim),
    );
    _scene!.camera.target.setValues(panX, _floorLevel + panY, panZ);
    _scene!.camera.up.setValues(0, 1, 0);
  }

  void _setNewTargets() {
    final random = math.Random();
    final double? lockedScale = _sizeLocked && _cubes.length > 1
        ? _uniformScale
        : null;
    for (int i = 0; i < _cubes.length; i++) {
      final s = lockedScale ?? (random.nextDouble() * 2.0) + 0.5;

      final double half = s * 0.5;
      final double range = _positionRange;
      Vector3 pos;
      if (_gravityMode) {
        pos = Vector3(
          _clampComponent((random.nextDouble() * range * 2) - range, half),
          _floorLevel + half,
          _clampComponent((random.nextDouble() * range * 2) - range, half),
        );
      } else {
        int attempts = 0;
        do {
          pos = Vector3(
            _clampComponent((random.nextDouble() * range * 2) - range, half),
            _clampComponent(
              (random.nextDouble() * range * 2) - range,
              half,
              isY: true,
            ),
            _clampComponent((random.nextDouble() * range * 2) - range, half),
          );
          attempts++;
        } while (attempts < 80 && _intersectsAny(pos, i, s));
      }

      _targetPositions[i] = pos;
      _targetRotations[i] = _gravityMode
          ? Vector3(0, random.nextDouble() * 360, 0)
          : Vector3(
              random.nextDouble() * 360,
              random.nextDouble() * 360,
              random.nextDouble() * 360,
            );
      _targetScales[i] = Vector3(s, s, s);
    }
  }

  static const double _viewLimit = 5.0;
  static const double _floorLevel = -3.0;

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
    final double? uniformScale = _sizeLocked && count > 1 ? _uniformScale : null;
    int attempts = 0;

    while (_cubes.length < count && attempts < 200) {
      attempts++;

      final s = uniformScale ?? (random.nextDouble() * 2.0) + 0.5;
      final halfSize = s * 0.5;

      final double half = s * 0.5;
      final double range = _positionRange;
      final Vector3 pos;
      if (count == 1) {
        pos = Vector3(0, _gravityMode ? _floorLevel + halfSize : 1, 0);
      } else {
        pos = Vector3(
          _clampComponent((random.nextDouble() * range * 2) - range, half),
          _gravityMode
              ? _floorLevel + halfSize
              : _clampComponent(
                  (random.nextDouble() * range * 2) - range,
                  half,
                  isY: true,
                ),
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

      final rot = _gravityMode
          ? Vector3(0, random.nextDouble() * 360, 0)
          : Vector3(
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
              _clampComponent(
                (random.nextDouble() * range * 2) - range,
                halfJ,
                isY: true,
              ),
              _clampComponent((random.nextDouble() * range * 2) - range, halfJ),
            );
          }
        }
      }
      if (!anyIntersection) break;
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _scene != null) {
      final notifier = ref.read(viewportProvider.notifier);
      final current = ref.read(viewportProvider).cameraDistance;
      notifier.setCameraDistance((current * (1 - event.scrollDelta.dy * 0.002)).clamp(2.0, 50.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(presentationProvider);
    final settings = ref.watch(settingsProvider);
    final vpState = ref.watch(viewportProvider);

    _gravityMode = vpState.gravityMode;
    _sizeLocked = vpState.sizeLocked;
    _uniformScale = vpState.uniformScale;
    _lightHorizontalLocked = vpState.lightHorizontalLocked;
    _lightVerticalLocked = vpState.lightVerticalLocked;
    _lightDistanceLocked = vpState.lightDistanceLocked;
    _lightHorizontalAngle = vpState.lightHorizontalAngle;
    _lightVerticalAngle = vpState.lightVerticalAngle;
    _lightDistance = vpState.lightDistance;
    _cameraHorizontalAngle = vpState.cameraHorizontalAngle;
    _cameraVerticalAngle = vpState.cameraVerticalAngle;
    _cameraDistance = vpState.cameraDistance;
    _cameraPanX = vpState.cameraPanX;
    _cameraPanY = vpState.cameraPanY;
    _cameraPanZ = vpState.cameraPanZ;

    if (_lastLightHorizontalLocked && !_lightHorizontalLocked) {
      _unlockedHorizontalAngle = math.Random().nextDouble() * 360;
    }
    if (_lastLightVerticalLocked && !_lightVerticalLocked) {
      _unlockedVerticalAngle = math.Random().nextDouble() * 360;
    }
    if (_lastLightDistanceLocked && !_lightDistanceLocked) {
      _unlockedDistance = 1 + math.Random().nextDouble() * 19;
    }
    _lastLightHorizontalLocked = _lightHorizontalLocked;
    _lastLightVerticalLocked = _lightVerticalLocked;
    _lastLightDistanceLocked = _lightDistanceLocked;

    final isPaused = state.isPaused;
    final isScatter = settings.scatterMode;
    final trigger = state.viewportTrigger;

    if (_initialized) {
      if (_lastGravity != _gravityMode) {
        if (_gravityMode) {
          _generateCubes(count: _cubes.length);
        } else {
          _setNewTargets();
        }
        _lastGravity = _gravityMode;
      }
      if (_lastSizeLocked != _sizeLocked) {
        if (_sizeLocked && _cubes.length > 1) {
          _applySizeToCubes(_uniformScale);
        } else if (!_sizeLocked && _cubes.length > 1) {
          _setNewTargets();
        }
        _lastSizeLocked = _sizeLocked;
        _lastUniformScale = _uniformScale;
      } else if (_lastUniformScale != _uniformScale && _sizeLocked && _cubes.length > 1) {
        _applySizeToCubes(_uniformScale);
        _lastUniformScale = _uniformScale;
      }
      if (_lastScatter != isScatter) {
        final count = isScatter ? (2 + math.Random().nextInt(9)) : 1;
        _generateCubes(count: count);
        _lastScatter = isScatter;
      } else if (_lastTrigger != trigger) {
        if (!_lightHorizontalLocked) {
          _unlockedHorizontalAngle = math.Random().nextDouble() * 360;
        }
        if (!_lightVerticalLocked) {
          _unlockedVerticalAngle = math.Random().nextDouble() * 360;
        }
        if (!_lightDistanceLocked) {
          _unlockedDistance = 1 + math.Random().nextDouble() * 19;
        }
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
      key: _cubeKey,
      interactive: false,
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
        if (_lightIndicator == null) {
          _lightIndicator = Object(
            fileName: "assets/sphere/sphere.obj",
            lighting: false,
            backfaceCulling: false,
            position: Vector3(0, 0, 5),
            scale: Vector3(0.2, 0.2, 0.2),
          );
          scene.world.add(_lightIndicator!);
        }
        final count = isScatter ? (2 + math.Random().nextInt(9)) : 1;
        _generateCubes(count: count);
        _lastScatter = isScatter;
        _initialized = true;
      },
    );

    cubeWidget = applyFilters(state.activeFilters, cubeWidget);

    cubeWidget = ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: isPaused ? 6 : 0,
        sigmaY: isPaused ? 6 : 0,
      ),
      child: cubeWidget,
    );

    final bool isFocus = state.isFocusMode;

    Widget viewport = cubeWidget;
    if (!isFocus) {
      viewport = Listener(
        onPointerSignal: _onPointerSignal,
        onPointerDown: (event) {
          if ((event.buttons & kSecondaryMouseButton) != 0) {
            _isPanning = true;
            _lastPanPoint = event.localPosition;
          } else if (event.buttons == kPrimaryMouseButton) {
            _lastFocalPoint = event.localPosition;
          }
        },
        onPointerMove: (event) {
          if (_isPanning && _scene != null) {
            final delta = event.localPosition - _lastPanPoint;
            _lastPanPoint = event.localPosition;
            final keyboard = HardwareKeyboard.instance;
            final ctrl = keyboard.isControlPressed;
            final alt = keyboard.isAltPressed;
            final shift = keyboard.isShiftPressed;
            final speed = 0.005 * (_cameraDistance / 15.0);
            final notifier = ref.read(viewportProvider.notifier);
            final elev = _cameraVerticalAngle * math.pi / 180;
            final forward = math.cos(elev);

            if (shift) {
              notifier.setCameraPanY(
                (_cameraPanY - delta.dy * speed).clamp(-10.0, 10.0),
              );
            } else if (ctrl) {
              notifier.setCameraPanX(
                (_cameraPanX + delta.dx * speed).clamp(-10.0, 10.0),
              );
            } else if (alt) {
              notifier.setCameraPanZ(
                (_cameraPanZ - delta.dy * speed * forward).clamp(-10.0, 10.0),
              );
            } else {
              notifier.setCameraPanZ(
                (_cameraPanZ - delta.dy * speed * forward).clamp(-10.0, 10.0),
              );
              notifier.setCameraPanX(
                (_cameraPanX + delta.dx * speed).clamp(-10.0, 10.0),
              );
            }
          } else if (_scene != null &&
              (event.buttons & kPrimaryMouseButton) != 0) {
            final delta = event.localPosition - _lastFocalPoint;
            _lastFocalPoint = event.localPosition;
            const sensitivity = 0.4;
            final notifier = ref.read(viewportProvider.notifier);
            notifier.setCameraHorizontalAngle(
              (_cameraHorizontalAngle + delta.dx * sensitivity) % 360,
            );
            notifier.setCameraVerticalAngle(
              (_cameraVerticalAngle + delta.dy * sensitivity).clamp(-90.0, 90.0),
            );
          }
        },
        onPointerUp: (event) {
          _isPanning = false;
        },
        child: viewport,
      );
    }

    return viewport;
  }
}
