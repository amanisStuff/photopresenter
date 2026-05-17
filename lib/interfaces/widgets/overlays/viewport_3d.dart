import 'dart:math' as math;
import 'package:flutter/material.dart';
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

class _Viewport3DState extends ConsumerState<Viewport3D> {
  static const double _cubeSize = 250;
  static const double _focalLength = 1200;

  List<_CubeParams> _cubes = [_CubeParams()];

  int _lastIndex = 0;
  bool _lastPlaying = false;
  bool _lastScatter = false;

  void _randomize() {
    final random = math.Random();
    final scatter = ref.read(settingsProvider).scatterMode;
    setState(() {
      if (scatter) {
        final count = 5 + random.nextInt(8);
        final cols = (math.sqrt(count)).ceil();
        final rows = (count / cols).ceil();

          const areaW = 2200.0;
          const areaH = 1500.0;
        final cellW = areaW / cols;
        final cellH = areaH / rows;
        final marginX = cellW * 0.15;
        final marginY = cellH * 0.15;

        final indices = List.generate(rows * cols, (i) => i)..shuffle(random);

        _cubes = List.generate(count, (i) {
          final cell = indices[i];
          final col = cell % cols;
          final row = cell ~/ cols;

          final isNear = i < (count / 2).ceil();

          return _CubeParams(
            yaw: (random.nextDouble() - 0.5) * 4 * math.pi,
            pitch: (random.nextDouble() - 0.5) * 1.2,
            offsetX: -areaW / 2 + col * cellW + marginX +
                random.nextDouble() * (cellW - 2 * marginX),
            offsetY: -areaH / 2 + row * cellH + marginY +
                random.nextDouble() * (cellH - 2 * marginY),
            distance: isNear
                ? 450 + random.nextDouble() * 100  // 450-550
                : 550 + random.nextDouble() * 150  // 550-700 (smaller range)
          );
        });
      } else {
        _cubes = [_CubeParams(
          yaw: (random.nextDouble() - 0.5) * 4 * math.pi,
          pitch: (random.nextDouble() - 0.5) * 1.2,
          offsetX: (random.nextDouble() - 0.5) * 600,
          offsetY: (random.nextDouble() - 0.5) * 400,
          distance: 300 + random.nextDouble() * 700,
        )];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);

    final settings = ref.watch(settingsProvider);

    ref.listen<int>(
      presentationProvider.select((state) => state.currentIndex),
      (previous, next) {
        if (next != _lastIndex) {
          _lastIndex = next;
          _randomize();
        }
      },
    );

    ref.listen<bool>(
      presentationProvider.select((state) => state.isPlaying),
      (previous, next) {
        if (next && !_lastPlaying) {
          _randomize();
        }
        _lastPlaying = next;
      },
    );

    if (settings.scatterMode != _lastScatter) {
      _lastScatter = settings.scatterMode;
      _randomize();
    }

    return ClipRect(
      child: Center(
        child: SizedBox.expand(
          child: _buildCubeScene(),
        ),
      ),
    );
  }

  Widget _buildCubeScene() {
    final faceData = <_FaceData>[];
    int globalFaceIndex = 0;
    for (final cube in _cubes) {
      for (int i = 0; i < 6; i++) {
        final matrix = _combinedTransform(i, cube);
        final z = matrix.storage[14];
        faceData.add(_FaceData(globalFaceIndex, z, matrix));
        globalFaceIndex++;
      }
    }
    faceData.sort((a, b) => a.z.compareTo(b.z));

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        for (final face in faceData)
          Transform(
            transform: face.matrix,
            alignment: Alignment.center,
            child: SizedBox(
              width: _cubeSize,
              height: _cubeSize,
              child: _buildFaceContent(face.index % 6),
            ),
          ),
      ],
    );
  }

  Matrix4 _combinedTransform(int faceIndex, _CubeParams cube) {
    final half = _cubeSize / 2;
    Matrix4 faceMatrix;
    switch (faceIndex) {
      case 0:
        faceMatrix = Matrix4.identity()..setTranslationRaw(0.0, 0.0, half);
      case 1:
        faceMatrix = Matrix4.identity()
          ..setTranslationRaw(0.0, 0.0, -half)
          ..rotateY(math.pi);
      case 2:
        faceMatrix = Matrix4.identity()
          ..setTranslationRaw(-half, 0.0, 0.0)
          ..rotateY(-math.pi / 2);
      case 3:
        faceMatrix = Matrix4.identity()
          ..setTranslationRaw(half, 0.0, 0.0)
          ..rotateY(math.pi / 2);
      case 4:
        faceMatrix = Matrix4.identity()
          ..setTranslationRaw(0.0, -half, 0.0)
          ..rotateX(math.pi / 2);
      case 5:
        faceMatrix = Matrix4.identity()
          ..setTranslationRaw(0.0, half, 0.0)
          ..rotateX(-math.pi / 2);
      default:
        faceMatrix = Matrix4.identity();
    }

    final viewMatrix = Matrix4.identity()
      ..setEntry(3, 2, -1.0 / _focalLength)
      ..setTranslationRaw(cube.offsetX, cube.offsetY, -cube.distance)
      ..rotateY(cube.yaw)
      ..rotateX(cube.pitch);

    return viewMatrix * faceMatrix;
  }

  Widget _buildFaceContent(int index) {
    final faceGradients = <List<Color>>[
      [AppTheme.primary, AppTheme.primaryDark],
      [AppTheme.surfaceCard, AppTheme.surfaceDark],
      [AppTheme.primaryLight, AppTheme.primary],
      [AppTheme.surfaceDark, AppTheme.surfaceOverlay],
      [AppTheme.buttonGradientTop, AppTheme.buttonGradientBottom],
      [AppTheme.surfaceOverlay, AppTheme.surfaceCard],
    ];

    final faceIcons = <IconData>[
      Icons.view_in_ar,
      Icons.crop_square,
      Icons.grid_on,
      Icons.layers,
      Icons.dashboard,
      Icons.apps,
    ];

    final gradient = faceGradients[index % faceGradients.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.surfaceLightest.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          faceIcons[index % faceIcons.length],
          size: 60,
          color: AppTheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _CubeParams {
  final double yaw;
  final double pitch;
  final double offsetX;
  final double offsetY;
  final double distance;

  const _CubeParams({
    this.yaw = 0,
    this.pitch = 0,
    this.offsetX = 0,
    this.offsetY = 0,
    this.distance = 500,
  });
}

class _FaceData {
  final int index;
  final double z;
  final Matrix4 matrix;

  const _FaceData(this.index, this.z, this.matrix);
}
