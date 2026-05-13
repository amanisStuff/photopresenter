import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';
import '../../core/entities/presentation_image.dart';
import 'add_image_card.dart';

class ImageGrid extends ConsumerStatefulWidget {
  const ImageGrid({super.key});

  @override
  ConsumerState<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends ConsumerState<ImageGrid> {
  int? _draggedIndex;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Text(
                    'Library',
                    style: AppTheme.screenTitleStyle,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.4),
                          AppTheme.primaryDark.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${state.images.length} images',
                      style: AppTheme.badgeCounterStyle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: state.images.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return AddImageCard(onTap: () => notifier.pickFiles());
                  }

                  final actualIndex = index - 1;
                  final image = state.images[actualIndex];
                  final isSelected = state.currentIndex == actualIndex;

                  return _DraggableImage(
                    key: ValueKey(image.path ?? image.name),
                    image: image,
                    actualIndex: actualIndex,
                    isSelected: isSelected,
                    isDragging: _draggedIndex == actualIndex,
                    onDragStarted: () => setState(() => _draggedIndex = actualIndex),
                    onDragEnd: () => setState(() => _draggedIndex = null),
                    onTap: () => notifier.setCurrentIndex(actualIndex),
                    onRemove: () => notifier.removeImage(actualIndex),
                    onReorder: notifier.reorderImages,
                    imagesLength: state.images.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraggableImage extends StatelessWidget {
  final PresentationImage image;
  final int actualIndex;
  final bool isSelected;
  final bool isDragging;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final void Function(int, int) onReorder;
  final int imagesLength;

  const _DraggableImage({
    super.key,
    required this.image,
    required this.actualIndex,
    required this.isSelected,
    required this.isDragging,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onTap,
    required this.onRemove,
    required this.onReorder,
    required this.imagesLength,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: actualIndex,
      delay: const Duration(milliseconds: 200),
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd(),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 180,
          height: 180,
          child: _buildImageCard(context, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildImageCard(context),
      ),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => details.data != actualIndex,
        onAcceptWithDetails: (details) {
          onReorder(details.data, actualIndex);
        },
        builder: (context, candidateData, rejectedData) {
          final isDropTarget = candidateData.isNotEmpty;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDropTarget
                        ? AppTheme.primary
                        : isSelected
                            ? AppTheme.primary
                            : AppTheme.textOnDarkSubtle,
                    width: 3,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _GridImage(image: image),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: AppTheme.textOnDarkMedium,
                        ),
                        onPressed: onRemove,
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, {bool isDragging = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDragging ? AppTheme.primary : AppTheme.textOnDarkSubtle,
          width: 3,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _GridImage(image: image),
          if (isDragging)
            Container(
color: AppTheme.surfaceMuted.withValues(alpha: 0.4),
              child: Center(
                child: Icon(Icons.drag_indicator, color: AppTheme.textOnDarkSubtle, size: 40),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridImage extends StatefulWidget {
  final PresentationImage image;

  const _GridImage({required this.image});

  @override
  State<_GridImage> createState() => _GridImageState();
}

class _GridImageState extends State<_GridImage> {
  late final ImageProvider _imageProvider;
  bool _loaded = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _imageProvider =
        widget.image.source == ImageSource.file && widget.image.path != null
            ? FileImage(File(widget.image.path!))
            : widget.image.source == ImageSource.memory &&
                    widget.image.bytes != null
                ? MemoryImage(widget.image.bytes!)
                : const NetworkImage('about:blank');

    _imageProvider
        .resolve(ImageConfiguration.empty)
        .addListener(
          ImageStreamListener(
             (imageInfo, synchronousCall) {
                if (mounted) setState(() => _loaded = true);
              },
              onError: (error, stackTrace) {
                if (mounted) setState(() => _error = true);
              },
           ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Center(
        child: Icon(Icons.broken_image, color: AppTheme.textOnDarkSubtle),
      );
    }

    if (!_loaded) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Image(
      image: _imageProvider,
      fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) =>
          Center(child: Icon(Icons.broken_image, color: AppTheme.textOnDarkSubtle)),
    );
  }
}