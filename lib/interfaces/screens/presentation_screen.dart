import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../shared/theme.dart';
import '../../shared/theme/theme_notifier.dart';
import '../../core/entities/drawing_state.dart';
import '../../core/providers/presentation_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/drawing_provider.dart';
import '../../infrastructure/service_providers.dart';
import '../widgets/image_media/image_grid.dart';
import '../widgets/image_media/image_display.dart';
import '../widgets/overlays/viewport_3d.dart';
import '../widgets/controls/presentation_controls.dart';
import '../widgets/overlays/break_overlay.dart';
import '../widgets/overlays/focus_timer_overlay.dart';
import '../widgets/drawing/drawing_canvas.dart';
import '../widgets/drawing/drawing_toolbar.dart';

class PresentationScreen extends ConsumerStatefulWidget {
  const PresentationScreen({super.key});

  @override
  ConsumerState<PresentationScreen> createState() =>
      _PresentationScreenState();
}

class _PresentationScreenState extends ConsumerState<PresentationScreen> {
  final GlobalKey _captureKey = GlobalKey();
  final Set<LogicalKeyboardKey> _heldShapeKeys = {};
  bool? _eraserWasActive;
  double? _eraserPreviousWidth;

  Future<void> saveAsImage() async {
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final fileService = ref.read(fileServiceProvider);
      final name =
          'Drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final result = await fileService.saveRenderedImage(
        byteData.buffer.asUint8List(),
        name,
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to $result')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);
    final state = ref.watch(presentationProvider);
    final settings = ref.watch(settingsProvider);
    final drawingState = ref.watch(drawingProvider);
    final notifier = ref.read(presentationProvider.notifier);

    Widget content;
    if (state.images.isEmpty) {
      content = Center(
        child: settings.useViewport3D
            ? const Viewport3D()
            : const ImageDisplay(),
      );
    } else if (state.isPlaying || state.isPaused) {
      content = Center(
        child: settings.useViewport3D
            ? const Viewport3D()
            : const ImageDisplay(),
      );
    } else {
      content = const ImageGrid();
    }

    return Scaffold(
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (state.isFocusMode) {
              notifier.toggleFocusMode();
            } else if (state.isPaused || state.isAutoPausing) {
              notifier.stopPlayback();
            }
          },
          const SingleActivator(LogicalKeyboardKey.space): () =>
              notifier.togglePlay(),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              notifier.nextImage(),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              notifier.previousImage(),
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
              notifier.pasteFromClipboard(),
          const SingleActivator(LogicalKeyboardKey.keyM, control: true): () =>
              notifier.minimizeWindow(),
          const SingleActivator(LogicalKeyboardKey.f11): () =>
              notifier.toggleFocusMode(),
          const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
              notifier.toggleFocusMode(),
          const SingleActivator(
            LogicalKeyboardKey.keyD,
            control: true,
            shift: true,
          ): () => ref.read(drawingProvider.notifier).toggleDrawing(),
          const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
            final drawingState = ref.read(drawingProvider);
            if (!drawingState.drawingEnabled) return;
            final settings = ref.read(settingsProvider);
            final state = ref.read(presentationProvider);
            final imageId = settings.useViewport3D
                ? '_3d_'
                : (state.currentImage?.id ?? '');
            ref.read(drawingProvider.notifier).undoLastStroke(imageId);
          },
          const SingleActivator(LogicalKeyboardKey.keyD, control: true): () =>
              notifier.exportAllImages(),
          const SingleActivator(LogicalKeyboardKey.keyG, control: true): () =>
              notifier.saveGallery(
                'Gallery ${DateTime.now().millisecondsSinceEpoch}',
              ),
          const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
              notifier.savePlaylist(),
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isShiftPressed ||
                HardwareKeyboard.instance.isAltPressed ||
                HardwareKeyboard.instance.isMetaPressed) {
              return KeyEventResult.ignored;
            }

            final drawingNotifier = ref.read(drawingProvider.notifier);
            final drawingState = ref.read(drawingProvider);
            if (!drawingState.drawingEnabled) {
              return KeyEventResult.ignored;
            }

            if (event.logicalKey == LogicalKeyboardKey.keyE) {
              if (event is KeyDownEvent && _eraserWasActive == null) {
                _eraserWasActive = drawingState.eraserMode;
                _eraserPreviousWidth = drawingState.currentStrokeWidth;
                if (!_eraserWasActive!) {
                  drawingNotifier.toggleEraser();
                }
                drawingNotifier.setStrokeWidth(12.0);
                return KeyEventResult.handled;
              }
              if (event is KeyUpEvent && _eraserWasActive != null) {
                if (!_eraserWasActive!) {
                  drawingNotifier.toggleEraser();
                }
                drawingNotifier.setStrokeWidth(_eraserPreviousWidth!);
                _eraserWasActive = null;
                _eraserPreviousWidth = null;
                return KeyEventResult.handled;
              }
              return KeyEventResult.handled;
            }

            LogicalKeyboardKey? shapeKey;
            ShapeType? shapeType;

            if (event.logicalKey == LogicalKeyboardKey.keyC) {
              shapeKey = LogicalKeyboardKey.keyC;
              shapeType = ShapeType.circle;
            } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
              shapeKey = LogicalKeyboardKey.keyV;
              shapeType = ShapeType.line;
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              shapeKey = LogicalKeyboardKey.keyS;
              shapeType = ShapeType.rectangle;
            }

            if (shapeKey == null) return KeyEventResult.ignored;

            if (event is KeyDownEvent) {
              _heldShapeKeys.add(shapeKey);
              drawingNotifier.setShapeType(shapeType!);
              return KeyEventResult.handled;
            }

            if (event is KeyUpEvent) {
              _heldShapeKeys.remove(shapeKey);
              if (_heldShapeKeys.isEmpty) {
                drawingNotifier.setShapeType(ShapeType.freehand);
              }
              return KeyEventResult.handled;
            }

            return KeyEventResult.ignored;
          },
          child: DropTarget(
            onDragDone: (details) {
              notifier.addImages(details.files.map((f) => f.path).toList());
            },
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        key: _captureKey,
                        child: Stack(
                          children: [
                            Container(
                              decoration: AppTheme.presentationBackground,
                            ),
                            content,
                            if (drawingState.drawingEnabled &&
                                state.images.isNotEmpty &&
                                (state.isPlaying || state.isPaused))
                              const Positioned.fill(
                                child: DrawingCanvas(),
                              ),
                          ],
                        ),
                      ),
                      if (drawingState.drawingEnabled &&
                          (state.isPlaying || state.isPaused))
                        const DrawingToolbar(),
                      if (!state.isFocusMode && state.images.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              state.isClassMode
                                  ? '${state.images.length} / ${state.totalPhaseCount}'
                                  : '${state.currentIndex + 1} / ${state.images.length}',
                              style: AppTheme.imageCounterStyle,
                            ),
                          ),
                        ),
                      if (!state.isFocusMode &&
                          state.images.isNotEmpty &&
                          state.currentImage != null)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.surfaceOverlay.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.25),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              state.currentImage!.name,
                              style: AppTheme.overlayTextStyle.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (state.isPaused) const _PauseOverlay(),
                      if (state.isAutoPausing && !state.isPaused)
                        const _AutoPauseOverlay(),
                      if (state.isFocusMode)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppTheme.textOnDarkSubtle,
                            ),
                            onPressed: () => notifier.toggleFocusMode(),
                          ),
                        ),
                      if (!state.isFocusMode &&
                          (state.isPaused || state.isAutoPausing))
                        Positioned(
                          top: 12,
                          right: 16,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppTheme.textOnDarkSubtle,
                            ),
                            tooltip: 'Back to gallery',
                            onPressed: () => notifier.stopPlayback(),
                          ),
                        ),
                      if (state.isPlaying &&
                          state.isClassMode &&
                          state.isOnBreak)
                        BreakOverlay(state: state),
                      if (state.isFocusMode &&
                          state.isPlaying &&
                          state.remainingTime.inSeconds <= 10)
                        FocusTimerOverlay(state: state),
                    ],
                  ),
                ),
                Container(width: 1, color: AppTheme.border),
                if (!state.isFocusMode || !state.isPlaying)
                  Expanded(
                    flex: 1,
                    child: PresentationControls(
                      onSaveImage: saveAsImage,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppTheme.background.withValues(alpha: 0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOverlay.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.pause,
                    size: 64,
                    color: AppTheme.textOnDark,
                  ),
                ),
                const SizedBox(height: 20),
                Text('PAUSED', style: AppTheme.overlayTitleStyle),
                const SizedBox(height: 8),
                Text(
                  'Press Space to continue',
                  style: AppTheme.overlayHintStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AutoPauseOverlay extends ConsumerWidget {
  const _AutoPauseOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppTheme.background.withValues(alpha: 0.6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOverlay.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.hourglass_bottom,
                    size: 48,
                    color: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'NEXT IMAGE IN',
                  style: AppTheme.overlaySubtextStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.autoPauseRemaining.inSeconds}s',
                  style: AppTheme.overlayCountdownStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
