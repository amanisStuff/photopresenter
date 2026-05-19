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
import '../../../core/providers/shape_manager.dart';

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

  ShapeManager _shapeManager = CubeShapeManager();

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
  String _lastObjectPath = 'assets/cube/cube.obj';

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
    if (_scene == null || _shapeManager.isEmpty) return;
    _shapeManager.animate();
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
      dist * math.cos(phi) + ShapeManager.floorLevel,
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
      _cameraDistance * math.sin(elev) + ShapeManager.floorLevel + panY,
      panZ + _cameraDistance * math.cos(elev) * math.cos(azim),
    );
    _scene!.camera.target.setValues(panX, ShapeManager.floorLevel + panY, panZ);
    _scene!.camera.up.setValues(0, 1, 0);
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
    _shapeManager.gravityMode = _gravityMode;
    _shapeManager.sizeLocked = _sizeLocked;
    _shapeManager.uniformScale = _uniformScale;
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
          _shapeManager.generate(count: _shapeManager.length);
        } else {
          _shapeManager.setNewTargets();
        }
        _lastGravity = _gravityMode;
      }
      if (_lastSizeLocked != _sizeLocked) {
        if (_sizeLocked) {
          _shapeManager.applySize(_uniformScale);
        } else if (!_sizeLocked) {
          _shapeManager.setNewTargets();
        }
        _lastSizeLocked = _sizeLocked;
        _lastUniformScale = _uniformScale;
      } else if (_lastUniformScale != _uniformScale && _sizeLocked) {
        _shapeManager.applySize(_uniformScale);
        _lastUniformScale = _uniformScale;
      }
      if (_lastScatter != isScatter) {
        final count = isScatter ? (2 + math.Random().nextInt(9)) : 1;
        _shapeManager.generate(count: count);
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
          _shapeManager.generate(count: count);
        } else {
          _shapeManager.setNewTargets();
        }
      }
      if (_lastObjectPath != vpState.objectPath) {
        _lastObjectPath = vpState.objectPath;
        final count = _shapeManager.length;
        _shapeManager.clear();
        _shapeManager = ShapeManager.fromPath(vpState.objectPath);
        _shapeManager.scene = _scene;
        _shapeManager.gravityMode = _gravityMode;
        _shapeManager.sizeLocked = _sizeLocked;
        _shapeManager.uniformScale = _uniformScale;
        _shapeManager.generate(count: count);
      }
    }
    _lastTrigger = trigger;

    Widget cubeWidget = Cube(
      key: _cubeKey,
      interactive: false,
      onSceneCreated: (Scene scene) {
        _scene = scene;
        _shapeManager.scene = scene;
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
        _shapeManager.generate(count: count);
        _lastScatter = isScatter;
        _lastObjectPath = vpState.objectPath;
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
